<?php
declare(strict_types=1);

function resource_dashboard_counts(PDO $pdo): array
{
    $counts = $pdo->query(<<<'SQL'
        SELECT
            (SELECT COUNT(*) FROM books WHERE deleted_at IS NULL) AS books,
            (
                SELECT COUNT(*)
                FROM book_copies c
                JOIN books b ON b.id = c.book_id
                WHERE c.status = 'available'
                  AND c.is_visible = 1
                  AND c.deleted_at IS NULL
                  AND b.is_visible = 1
                  AND b.deleted_at IS NULL
            ) AS available_copies,
            (
                SELECT COUNT(*)
                FROM loan_details
                WHERE return_date IS NULL
                  AND due_date < CURDATE()
            ) AS overdue_books,
            (
                SELECT COALESCE(SUM(available_quantity), 0)
                FROM equipment
                WHERE status = 'available'
                  AND is_visible = 1
                  AND deleted_at IS NULL
            ) AS available_equipment,
            (
                (SELECT COUNT(*) FROM book_loan_requests WHERE status = 'pending')
                + (SELECT COUNT(*) FROM equipment_loan_requests WHERE status = 'pending')
                + (SELECT COUNT(*) FROM room_requests WHERE status = 'pending')
            ) AS pending_requests,
            (SELECT COUNT(*) FROM students) AS students
        SQL)->fetch();

    return array_map(static fn($value): int => (int) $value, $counts);
}

/** Table/column identifiers come exclusively from managed_types(), never input. */
function managed_resource_list(
    PDO $pdo,
    string $type,
    int $page,
    string $search,
    string $visibility
): array {
    $table = managed_table($type);
    $searchColumn = match ($type) {
        'books' => 'title',
        'copies' => 'barcode',
        default => 'name',
    };
    $conditions = ['r.deleted_at IS NULL'];
    $parameters = [];
    $join = '';
    $extraColumns = '';

    if ($type === 'copies') {
        $join = 'JOIN books b ON b.id = r.book_id';
        $extraColumns = ', b.title AS book_title, b.cover_image, b.is_visible AS book_visible';
        $conditions[] = 'b.deleted_at IS NULL';
    }
    if ($search !== '') {
        $conditions[] = "r.`$searchColumn` LIKE :search";
        $parameters['search'] = '%' . $search . '%';
    }
    if (in_array($visibility, ['0', '1'], true)) {
        $conditions[] = 'r.is_visible = :visibility';
        $parameters['visibility'] = (int) $visibility;
    }

    // Share the FROM/WHERE clauses so count and paginated rows cannot diverge.
    $where = implode("\n    AND ", $conditions);
    $from = "FROM `$table` r\n$join\nWHERE $where";
    $count = $pdo->prepare("SELECT COUNT(*)\n$from");
    $count->execute($parameters);
    $total = (int) $count->fetchColumn();
    $pageSize = 15;
    $page = max(1, min($page, max(1, (int) ceil($total / $pageSize))));

    $statement = $pdo->prepare(<<<SQL
        SELECT r.* $extraColumns
        $from
        ORDER BY r.id DESC
        LIMIT :limit OFFSET :offset
        SQL);
    foreach ($parameters as $name => $value) {
        $statement->bindValue($name, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $statement->bindValue('limit', $pageSize, PDO::PARAM_INT);
    $statement->bindValue('offset', ($page - 1) * $pageSize, PDO::PARAM_INT);
    $statement->execute();

    return [
        'data' => $statement->fetchAll(),
        'total' => $total,
        'page' => $page,
        'page_size' => $pageSize,
    ];
}

function resource_has_open_transactions(PDO $pdo, string $type, int $id): bool
{
    $queries = match ($type) {
        'books' => [
            <<<'SQL'
                SELECT 1
                FROM loan_details ld
                JOIN book_copies c ON c.id = ld.copy_id
                WHERE c.book_id = :id
                  AND ld.return_date IS NULL
                LIMIT 1
                SQL,
            <<<'SQL'
                SELECT 1
                FROM book_loan_request_items i
                JOIN book_loan_requests r ON r.id = i.request_id
                WHERE i.book_id = :id
                  AND r.status = 'pending'
                LIMIT 1
                SQL,
        ],
        'copies' => [
            <<<'SQL'
                SELECT 1
                FROM loan_details
                WHERE copy_id = :id
                  AND return_date IS NULL
                LIMIT 1
                SQL,
        ],
        'rooms' => [
            <<<'SQL'
                SELECT 1
                FROM room_requests
                WHERE room_id = :id
                  AND status IN ('pending', 'approved')
                  AND use_date >= CURDATE()
                LIMIT 1
                SQL,
        ],
        'equipment' => [
            <<<'SQL'
                SELECT 1
                FROM equipment_loan_details
                WHERE equipment_id = :id
                  AND return_date IS NULL
                LIMIT 1
                SQL,
            <<<'SQL'
                SELECT 1
                FROM equipment_loan_request_items i
                JOIN equipment_loan_requests r ON r.id = i.request_id
                WHERE i.equipment_id = :id
                  AND r.status = 'pending'
                LIMIT 1
                SQL,
        ],
        default => throw new InvalidArgumentException('Invalid resource type'),
    };

    foreach ($queries as $sql) {
        $statement = $pdo->prepare($sql);
        $statement->execute(['id' => $id]);
        if ($statement->fetchColumn() !== false) {
            return true;
        }
    }
    return false;
}
