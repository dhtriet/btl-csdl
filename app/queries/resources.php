<?php
declare(strict_types=1);

function resource_dashboard_counts(PDO $pdo): array
{
    $counts = $pdo->query(<<<'SQL'
        SELECT
            (SELECT COUNT(*) FROM dau_sach WHERE thoi_diem_xoa IS NULL) AS dau_sach,
            (
                SELECT COUNT(*)
                FROM ban_sach c
                JOIN dau_sach b ON b.ma = c.ma_dau_sach
                WHERE c.trang_thai = 'available'
                  AND c.hien_thi = 1
                  AND c.thoi_diem_xoa IS NULL
                  AND b.hien_thi = 1
                  AND b.thoi_diem_xoa IS NULL
            ) AS available_copies,
            (
                SELECT COUNT(*)
                FROM chi_tiet_muon_sach
                WHERE ngay_tra IS NULL
                  AND han_tra < CURDATE()
            ) AS overdue_books,
            (
                SELECT COALESCE(SUM(so_luong_san_sang), 0)
                FROM thiet_bi
                WHERE trang_thai = 'available'
                  AND hien_thi = 1
                  AND thoi_diem_xoa IS NULL
            ) AS available_equipment,
            (
                (SELECT COUNT(*) FROM yeu_cau_muon_sach WHERE trang_thai = 'pending')
                + (SELECT COUNT(*) FROM yeu_cau_muon_thiet_bi WHERE trang_thai = 'pending')
                + (SELECT COUNT(*) FROM yeu_cau_dat_phong WHERE trang_thai = 'pending')
            ) AS pending_requests,
            (SELECT COUNT(*) FROM sinh_vien) AS sinh_vien
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
        $join = 'JOIN dau_sach b ON b.ma = r.ma_dau_sach';
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
        ORDER BY r.ma DESC
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
                FROM chi_tiet_muon_sach ld
                JOIN ban_sach c ON c.ma = ld.ma_ban_sach
                WHERE c.ma_dau_sach = :id
                  AND ld.ngay_tra IS NULL
                LIMIT 1
                SQL,
            <<<'SQL'
                SELECT 1
                FROM chi_tiet_yeu_cau_muon_sach i
                JOIN yeu_cau_muon_sach r ON r.ma = i.ma_yeu_cau
                WHERE i.ma_dau_sach = :id
                  AND r.trang_thai = 'pending'
                LIMIT 1
                SQL,
        ],
        'copies' => [
            <<<'SQL'
                SELECT 1
                FROM chi_tiet_muon_sach
                WHERE ma_ban_sach = :id
                  AND ngay_tra IS NULL
                LIMIT 1
                SQL,
        ],
        'rooms' => [
            <<<'SQL'
                SELECT 1
                FROM yeu_cau_dat_phong
                WHERE ma_phong = :id
                  AND trang_thai IN ('pending', 'approved')
                  AND ngay_su_dung >= CURDATE()
                LIMIT 1
                SQL,
        ],
        'equipment' => [
            <<<'SQL'
                SELECT 1
                FROM chi_tiet_muon_thiet_bi
                WHERE ma_thiet_bi = :id
                  AND ngay_tra IS NULL
                LIMIT 1
                SQL,
            <<<'SQL'
                SELECT 1
                FROM chi_tiet_yeu_cau_muon_thiet_bi i
                JOIN yeu_cau_muon_thiet_bi r ON r.ma = i.ma_yeu_cau
                WHERE i.ma_thiet_bi = :id
                  AND r.trang_thai = 'pending'
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
