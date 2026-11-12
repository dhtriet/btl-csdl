<?php
declare(strict_types=1);

function resource_staff_access(): bool
{
    return in_array($_SESSION['user']['role'] ?? '', ['admin','librarian'],true);
}

function resource_accessible(PDO $pdo, string $table, int $id, bool $allowStaff = true): bool
{
    $allowedTables = ['books', 'book_copies', 'rooms', 'equipment'];
    if (!in_array($table, $allowedTables, true)) {
        throw new InvalidArgumentException('Invalid resource type');
    }

    $visibilityCondition = $allowStaff && resource_staff_access() ? '' : 'AND hien_thi = 1';
    $statement = $pdo->prepare(<<<SQL
        SELECT ma
        FROM `$table`
        WHERE ma = :id
          AND thoi_diem_xoa IS NULL
          $visibilityCondition
        SQL);
    $statement->execute(['id' => $id]);
    return $statement->fetchColumn() !== false;
}
