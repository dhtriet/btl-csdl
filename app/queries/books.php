<?php
declare(strict_types=1);

/** SQL identifiers are application-owned; request values cannot select tables. */
function book_relations(): array
{
    return [
        'authors' => ['pivot' => 'book_authors', 'foreign_key' => 'author_id', 'column' => 'full_name', 'max_length' => 160],
        'genres' => ['pivot' => 'book_genres', 'foreign_key' => 'genre_id', 'column' => 'name', 'max_length' => 100],
        'keywords' => ['pivot' => 'book_keywords', 'foreign_key' => 'keyword_id', 'column' => 'name', 'max_length' => 100],
    ];
}

function book_relation_names(PDO $pdo, string $relation, int $bookId, bool $orderByName = true): array
{
    $definition = book_relations()[$relation] ?? throw new InvalidArgumentException('Invalid book relation');
    $pivot = $definition['pivot'];
    $foreignKey = $definition['foreign_key'];
    $column = $definition['column'];
    $orderColumn = $orderByName ? $column : 'id';

    $statement = $pdo->prepare(<<<SQL
        SELECT n.ma, n.`$column` AS name
        FROM `$relation` n
        JOIN `$pivot` p ON p.`$foreignKey` = n.id
        WHERE p.book_id = :book_id
        ORDER BY n.`$orderColumn`
        SQL);
    $statement->execute(['book_id' => $bookId]);
    return $statement->fetchAll();
}

/** Each aggregate has one row per book, avoiding multiplication across relations. */
function catalog_books(PDO $pdo, ?string $search, ?string $language, ?string $year): array
{
    $conditions = ['b.is_visible = 1', 'b.deleted_at IS NULL'];
    $parameters = [];

    if ($search) {
        $conditions[] = 'b.title LIKE :search';
        $parameters['search'] = '%' . $search . '%';
    }
    if ($language) {
        $conditions[] = 'b.language = :language';
        $parameters['language'] = $language;
    }
    if ($year && ctype_digit($year)) {
        $conditions[] = 'b.publication_year = :year';
        $parameters['year'] = (int) $year;
    }

    $where = implode("\n    AND ", $conditions);
    $statement = $pdo->prepare(<<<SQL
        SELECT b.ma, b.ten_sach, b.nam_xuat_ban, b.ngon_ngu, b.anh_bia,
               p.ten AS publisher,
               tac_gia.names AS tac_gia,
               the_loai.names AS the_loai,
               tu_khoa.names AS tu_khoa,
               COALESCE(stock.copy_count, 0) AS copy_count,
               COALESCE(stock.available_copies, 0) AS available_copies,
               EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma) AS has_ebook
        FROM dau_sach b
        JOIN nha_xuat_ban p ON p.ma = b.ma_nha_xuat_ban
        LEFT JOIN (
            SELECT ba.ma_dau_sach,
                   GROUP_CONCAT(DISTINCT a.ho_ten ORDER BY a.ho_ten SEPARATOR ', ') AS names
            FROM dau_sach_tac_gia ba
            JOIN tac_gia a ON a.ma = ba.ma_tac_gia
            GROUP BY ba.ma_dau_sach
        ) tac_gia ON tac_gia.ma_dau_sach = b.ma
        LEFT JOIN (
            SELECT bg.ma_dau_sach,
                   GROUP_CONCAT(DISTINCT g.ten ORDER BY g.ten SEPARATOR ', ') AS names
            FROM dau_sach_the_loai bg
            JOIN the_loai g ON g.ma = bg.ma_the_loai
            GROUP BY bg.ma_dau_sach
        ) the_loai ON the_loai.ma_dau_sach = b.ma
        LEFT JOIN (
            SELECT bk.ma_dau_sach,
                   GROUP_CONCAT(DISTINCT k.ten ORDER BY k.ten SEPARATOR ', ') AS names
            FROM dau_sach_tu_khoa bk
            JOIN tu_khoa k ON k.ma = bk.ma_tu_khoa
            GROUP BY bk.ma_dau_sach
        ) tu_khoa ON tu_khoa.ma_dau_sach = b.ma
        LEFT JOIN (
            SELECT c.ma_dau_sach, COUNT(*) AS copy_count,
                   COUNT(CASE WHEN c.trang_thai = 'available' THEN 1 END) AS available_copies
            FROM ban_sach c
            WHERE c.hien_thi = 1
              AND c.thoi_diem_xoa IS NULL
            GROUP BY c.ma_dau_sach
        ) stock ON stock.ma_dau_sach = b.ma
        WHERE $where
        ORDER BY b.ma DESC
        SQL);
    $statement->execute($parameters);
    return $statement->fetchAll();
}

function popular_books(PDO $pdo, int $limit): array
{
    $statement = $pdo->prepare(<<<'SQL'
        SELECT b.ma, b.ten_sach, b.anh_bia,
               COALESCE(loans.borrow_count, 0) AS borrow_count,
               tac_gia.names AS tac_gia
        FROM dau_sach b
        JOIN (
            SELECT c.ma_dau_sach, COUNT(ld.ma) AS borrow_count
            FROM ban_sach c
            LEFT JOIN chi_tiet_muon_sach ld ON ld.ma_ban_sach = c.ma
            GROUP BY c.ma_dau_sach
        ) loans ON loans.ma_dau_sach = b.ma
        LEFT JOIN (
            SELECT ba.ma_dau_sach,
                   GROUP_CONCAT(DISTINCT a.ho_ten ORDER BY a.ho_ten SEPARATOR ', ') AS names
            FROM dau_sach_tac_gia ba
            JOIN tac_gia a ON a.ma = ba.ma_tac_gia
            GROUP BY ba.ma_dau_sach
        ) tac_gia ON tac_gia.ma_dau_sach = b.ma
        WHERE b.hien_thi = 1
          AND b.thoi_diem_xoa IS NULL
        ORDER BY borrow_count DESC, b.ten_sach
        LIMIT :limit
        SQL);
    $statement->bindValue('limit', max(1, min($limit, 100)), PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function assistant_book_catalog(PDO $pdo): array
{
    return $pdo->query(<<<'SQL'
        SELECT b.ma, b.ten_sach,
               LEFT(COALESCE(b.tom_tat, b.mo_ta, ''), 800) AS tom_tat,
               b.ngon_ngu,
               (
                   SELECT GROUP_CONCAT(a.ho_ten SEPARATOR ', ')
                   FROM tac_gia a
                   JOIN dau_sach_tac_gia ba ON ba.ma_tac_gia = a.ma
                   WHERE ba.ma_dau_sach = b.ma
               ) AS tac_gia,
               (
                   SELECT GROUP_CONCAT(g.ten SEPARATOR ', ')
                   FROM the_loai g
                   JOIN dau_sach_the_loai bg ON bg.ma_the_loai = g.ma
                   WHERE bg.ma_dau_sach = b.ma
               ) AS the_loai,
               e.duong_dan_tep
        FROM dau_sach b
        LEFT JOIN sach_dien_tu e ON e.ma_dau_sach = b.ma
        WHERE b.hien_thi = 1
          AND b.thoi_diem_xoa IS NULL
        ORDER BY b.ten_sach
        SQL)->fetchAll();
}

function learning_book_stock(PDO $pdo, array $bookIds): array
{
    if (!$bookIds) {
        return [];
    }

    // Only placeholder count is interpolated; book IDs remain bound values.
    $placeholders = implode(', ', array_fill(0, count($bookIds), '?'));
    $statement = $pdo->prepare(<<<SQL
        SELECT b.ma, b.ten_sach,
               (
                   SELECT GROUP_CONCAT(a.ho_ten SEPARATOR ', ')
                   FROM tac_gia a
                   JOIN dau_sach_tac_gia ba ON ba.ma_tac_gia = a.ma
                   WHERE ba.ma_dau_sach = b.ma
               ) AS tac_gia,
               (
                   SELECT COUNT(*)
                   FROM ban_sach c
                   WHERE c.ma_dau_sach = b.ma
                     AND c.trang_thai = 'available'
                     AND c.hien_thi = 1
                     AND c.thoi_diem_xoa IS NULL
               ) AS available_copies,
               EXISTS (
                   SELECT 1
                   FROM sach_dien_tu e
                   WHERE e.ma_dau_sach = b.ma
                     AND UPPER(e.dinh_dang_tep) = 'PDF'
               ) AS has_ebook
        FROM dau_sach b
        WHERE b.hien_thi = 1
          AND b.thoi_diem_xoa IS NULL
          AND b.ma IN ($placeholders)
        SQL);
    $statement->execute(array_values($bookIds));
    return $statement->fetchAll();
}
