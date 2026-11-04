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
        SELECT n.id, n.`$column` AS name
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
        SELECT b.id, b.title, b.publication_year, b.language, b.cover_image,
               p.name AS publisher,
               authors.names AS authors,
               genres.names AS genres,
               keywords.names AS keywords,
               COALESCE(stock.copy_count, 0) AS copy_count,
               COALESCE(stock.available_copies, 0) AS available_copies,
               EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id) AS has_ebook
        FROM books b
        JOIN publishers p ON p.id = b.publisher_id
        LEFT JOIN (
            SELECT ba.book_id,
                   GROUP_CONCAT(DISTINCT a.full_name ORDER BY a.full_name SEPARATOR ', ') AS names
            FROM book_authors ba
            JOIN authors a ON a.id = ba.author_id
            GROUP BY ba.book_id
        ) authors ON authors.book_id = b.id
        LEFT JOIN (
            SELECT bg.book_id,
                   GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ') AS names
            FROM book_genres bg
            JOIN genres g ON g.id = bg.genre_id
            GROUP BY bg.book_id
        ) genres ON genres.book_id = b.id
        LEFT JOIN (
            SELECT bk.book_id,
                   GROUP_CONCAT(DISTINCT k.name ORDER BY k.name SEPARATOR ', ') AS names
            FROM book_keywords bk
            JOIN keywords k ON k.id = bk.keyword_id
            GROUP BY bk.book_id
        ) keywords ON keywords.book_id = b.id
        LEFT JOIN (
            SELECT c.book_id, COUNT(*) AS copy_count,
                   COUNT(CASE WHEN c.status = 'available' THEN 1 END) AS available_copies
            FROM book_copies c
            WHERE c.is_visible = 1
              AND c.deleted_at IS NULL
            GROUP BY c.book_id
        ) stock ON stock.book_id = b.id
        WHERE $where
        ORDER BY b.id DESC
        SQL);
    $statement->execute($parameters);
    return $statement->fetchAll();
}

function popular_books(PDO $pdo, int $limit): array
{
    $statement = $pdo->prepare(<<<'SQL'
        SELECT b.id, b.title, b.cover_image,
               COALESCE(loans.borrow_count, 0) AS borrow_count,
               authors.names AS authors
        FROM books b
        JOIN (
            SELECT c.book_id, COUNT(ld.id) AS borrow_count
            FROM book_copies c
            LEFT JOIN loan_details ld ON ld.copy_id = c.id
            GROUP BY c.book_id
        ) loans ON loans.book_id = b.id
        LEFT JOIN (
            SELECT ba.book_id,
                   GROUP_CONCAT(DISTINCT a.full_name ORDER BY a.full_name SEPARATOR ', ') AS names
            FROM book_authors ba
            JOIN authors a ON a.id = ba.author_id
            GROUP BY ba.book_id
        ) authors ON authors.book_id = b.id
        WHERE b.is_visible = 1
          AND b.deleted_at IS NULL
        ORDER BY borrow_count DESC, b.title
        LIMIT :limit
        SQL);
    $statement->bindValue('limit', max(1, min($limit, 100)), PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function assistant_book_catalog(PDO $pdo): array
{
    return $pdo->query(<<<'SQL'
        SELECT b.id, b.title,
               LEFT(COALESCE(b.summary, b.description, ''), 800) AS summary,
               b.language,
               (
                   SELECT GROUP_CONCAT(a.full_name SEPARATOR ', ')
                   FROM authors a
                   JOIN book_authors ba ON ba.author_id = a.id
                   WHERE ba.book_id = b.id
               ) AS authors,
               (
                   SELECT GROUP_CONCAT(g.name SEPARATOR ', ')
                   FROM genres g
                   JOIN book_genres bg ON bg.genre_id = g.id
                   WHERE bg.book_id = b.id
               ) AS genres,
               e.file_path
        FROM books b
        LEFT JOIN ebooks e ON e.book_id = b.id
        WHERE b.is_visible = 1
          AND b.deleted_at IS NULL
        ORDER BY b.title
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
        SELECT b.id, b.title,
               (
                   SELECT GROUP_CONCAT(a.full_name SEPARATOR ', ')
                   FROM authors a
                   JOIN book_authors ba ON ba.author_id = a.id
                   WHERE ba.book_id = b.id
               ) AS authors,
               (
                   SELECT COUNT(*)
                   FROM book_copies c
                   WHERE c.book_id = b.id
                     AND c.status = 'available'
                     AND c.is_visible = 1
                     AND c.deleted_at IS NULL
               ) AS available_copies,
               EXISTS (
                   SELECT 1
                   FROM ebooks e
                   WHERE e.book_id = b.id
                     AND UPPER(e.file_format) = 'PDF'
               ) AS has_ebook
        FROM books b
        WHERE b.is_visible = 1
          AND b.deleted_at IS NULL
          AND b.id IN ($placeholders)
        SQL);
    $statement->execute(array_values($bookIds));
    return $statement->fetchAll();
}
