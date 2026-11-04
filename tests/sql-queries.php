<?php
declare(strict_types=1);
require dirname(__DIR__) . '/app/config.php';
require dirname(__DIR__) . '/app/database.php';
require dirname(__DIR__) . '/app/resources.php';

if (!preg_match('/^resource_center_test_[0-9]+$/D', getenv('NEXUS_DB_NAME') ?: '')) {
    throw new RuntimeException('Use a dedicated resource_center_test_<digits> database.');
}
function check_query(bool $condition, string $message): void
{
    if (!$condition) throw new RuntimeException($message);
}
$pdo = Database::connection();
$pdo->beginTransaction();
try {
    $suffix = bin2hex(random_bytes(5));
    $publisher = (int) $pdo->query('SELECT id FROM publishers LIMIT 1')->fetchColumn();
    $student = (int) $pdo->query('SELECT id FROM students LIMIT 1')->fetchColumn();
    $librarian = (int) $pdo->query('SELECT id FROM librarians LIMIT 1')->fetchColumn();
    $title = 'SQL aggregate ' . $suffix;
    $pdo->prepare("INSERT INTO books (title, language, publication_year, publisher_id) VALUES (?, 'SQL test', 2026, ?)")->execute([$title, $publisher]);
    $book = (int) $pdo->lastInsertId();
    foreach (['Zeta', 'Alpha'] as $name) {
        $pdo->prepare('INSERT INTO authors (full_name) VALUES (?)')->execute([$name . $suffix]);
        $pdo->prepare('INSERT INTO book_authors (book_id, author_id) VALUES (?, ?)')->execute([$book, $pdo->lastInsertId()]);
    }
    foreach (['genres' => ['book_genres', 'genre_id'], 'keywords' => ['book_keywords', 'keyword_id']] as $table => [$pivot, $foreignKey]) {
        foreach (['B', 'A'] as $name) {
            $pdo->prepare("INSERT INTO `$table` (name) VALUES (?)")->execute([$name . $suffix]);
            $pdo->prepare("INSERT INTO `$pivot` (book_id, `$foreignKey`) VALUES (?, ?)")->execute([$book, $pdo->lastInsertId()]);
        }
    }
    $copies = [];
    for ($i = 0; $i < 5; $i++) {
        $pdo->prepare("INSERT INTO book_copies (book_id, barcode, storage_location, is_visible, deleted_at) VALUES (?, ?, 'Test', ?, ?)")
            ->execute([$book, $suffix . '_' . $i, $i === 3 ? 0 : 1, $i === 4 ? '2026-01-01 00:00:00' : null]);
        $copies[] = (int) $pdo->lastInsertId();
    }
    $pdo->prepare("INSERT INTO loan_receipts (student_id, librarian_id, status) VALUES (?, ?, 'open')")->execute([$student, $librarian]);
    $receipt = (int) $pdo->lastInsertId();
    // Two separate past loans of the same copy must each count, without author fan-out.
    for ($i = 0; $i < 2; $i++) {
        $pdo->prepare("INSERT INTO loan_details (receipt_id, copy_id, borrow_date, due_date, return_date, return_status, late_days, status, condition_on_return)
            VALUES (?, ?, DATE_SUB(CURDATE(), INTERVAL 2 DAY), CURDATE(), CURDATE(), 'on_time', 0, 'returned', 'good')")
            ->execute([$receipt, $copies[0]]);
    }
    $pdo->prepare("INSERT INTO loan_details (receipt_id, copy_id, borrow_date, due_date, status) VALUES (?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'borrowed')")
        ->execute([$receipt, $copies[2]]);
    $pdo->prepare("UPDATE book_copies SET status = 'borrowed' WHERE id = ?")->execute([$copies[2]]);

    $catalog = catalog_books($pdo, $title, 'SQL test', '2026');
    check_query(count($catalog) === 1, 'Catalog filters must select one title');
    $row = $catalog[0];
    check_query((int) $row['copy_count'] === 3, 'Hidden/deleted copies must not enter catalog stock');
    check_query((int) $row['available_copies'] === 2, 'Multiple metadata relations must not multiply stock');
    check_query($row['authors'] === 'Alpha' . $suffix . ', Zeta' . $suffix, 'Author ordering changed');
    check_query($row['genres'] === 'A' . $suffix . ', B' . $suffix, 'Genre ordering changed');
    check_query($row['keywords'] === 'A' . $suffix . ', B' . $suffix, 'Keyword ordering changed');
    check_query(catalog_books($pdo, "' OR 1=1 --", null, null) === [], 'Search must remain a bound value');
    $top = array_column(popular_books($pdo, 100), null, 'id');
    check_query(isset($top[$book]) && (int) $top[$book]['borrow_count'] === 3, 'Popularity must count loans, not author joins or distinct copies');
    $stock = learning_book_stock($pdo, [$book]);
    check_query(count($stock) === 1 && (int) $stock[0]['available_copies'] === 2, 'Learning stock must agree with catalog');
    check_query(learning_book_stock($pdo, []) === [], 'Empty selection must not produce IN ()');
    $relations = book_relation_names($pdo, 'authors', $book);
    check_query(array_column($relations, 'name') === ['Alpha' . $suffix, 'Zeta' . $suffix], 'Detail relation shape/order changed');
    $managed = managed_record($pdo, 'books', $book);
    check_query($managed['authors'] === ['Zeta' . $suffix, 'Alpha' . $suffix], 'Management order must preserve version hashing');

    $listed = managed_resource_list($pdo, 'books', 999999, $title, '1');
    check_query($listed['total'] === 1 && $listed['page'] === 1 && count($listed['data']) === 1, 'List count, filter or page clamping changed');
    check_query(managed_resource_list($pdo, 'books', 1, $title, '0')['total'] === 0, 'Hidden filter must use same conditions for count and rows');
    check_query(resource_has_open_transactions($pdo, 'books', $book), 'Open-loan deletion guard must remain effective');
    foreach (resource_dashboard_counts($pdo) as $value) check_query(is_int($value), 'Dashboard response counts must remain integers');

    $pdo->prepare('UPDATE books SET is_visible = 0 WHERE id = ?')->execute([$book]);
    check_query(catalog_books($pdo, $title, null, null) === [], 'Hidden title returned by catalog');
    check_query(learning_book_stock($pdo, [$book]) === [], 'Hidden title returned by learning stock');
    check_query(!in_array($book, array_column(assistant_book_catalog($pdo), 'id'), true), 'Hidden title returned by assistant');

    // Execute the documented examples against the isolated database, never the live one.
    $examples = str_replace(
        'USE resource_center;',
        'USE `' . getenv('NEXUS_DB_NAME') . '`;',
        file_get_contents(dirname(__DIR__) . '/database/queries.sql'),
        $replacements
    );
    check_query($replacements === 1, 'Example database selector changed; review test isolation');
    $resultSets = 0;
    // Example statements end at a line boundary; quoted '; ' separators stay intact.
    foreach (preg_split('/;[\t ]*(?:\r?\n|$)/', $examples) as $sql) {
        $sql = trim(preg_replace('/^--.*$/m', '', $sql));
        if ($sql === '') continue;
        $statement = $pdo->query($sql);
        if ($statement->columnCount() > 0) {
            $statement->fetchAll();
            $resultSets++;
        }
        $statement->closeCursor();
    }
    check_query($resultSets === 12, 'Every documented SQL example must execute');
    echo "PASS SQL aggregates, metadata, stock, bound search/pagination, deletion guards and hidden resources\n";
    echo "PASS all 12 documented SQL examples\n";
} finally {
    $pdo->rollBack();
}
