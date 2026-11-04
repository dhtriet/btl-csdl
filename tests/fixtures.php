<?php
declare(strict_types=1);
require dirname(__DIR__) . '/app/config.php';
require dirname(__DIR__) . '/app/database.php';
if (!preg_match('/^resource_center_test_[0-9]+$/D', getenv('NEXUS_DB_NAME') ?: '')) throw new RuntimeException('Fixture restricted to isolated test database');
$pdo=Database::connection();
$mode=$argv[1] ?? 'seed';
if ($mode==='gate') {
    $type=$argv[2]; $id=(int)$argv[3];
    $table=['book'=>'book_copies','equipment'=>'equipment','room'=>'rooms'][$type] ?? throw new RuntimeException('Invalid gate');
    $pdo->beginTransaction(); $q=$pdo->prepare("SELECT id FROM `$table` WHERE id=? FOR UPDATE"); $q->execute([$id]);
    echo "locked\n"; flush(); fgets(STDIN); $pdo->commit(); exit;
}
if ($mode==='verify') {
    $fixture=json_decode(file_get_contents(getenv('NEXUS_TEST_FIXTURE_FILE')),true);
    $copy=(int)$fixture['copy']; $equipment=(int)$fixture['equipment']; $room=(int)$fixture['room'];
    echo json_encode([
        'copy_loans'=>(int)$pdo->query("SELECT COUNT(*) FROM loan_details WHERE copy_id=$copy AND return_date IS NULL")->fetchColumn(),
        'equipment_available'=>(int)$pdo->query("SELECT available_quantity FROM equipment WHERE id=$equipment")->fetchColumn(),
        'equipment_units'=>(int)$pdo->query("SELECT COALESCE(SUM(quantity),0) FROM equipment_loan_details WHERE equipment_id=$equipment AND return_date IS NULL")->fetchColumn(),
        'room_bookings'=>(int)$pdo->query("SELECT COUNT(*) FROM room_requests WHERE room_id=$room AND status IN ('pending','approved')")->fetchColumn(),
        'plain_passwords'=>count(array_filter($pdo->query('SELECT password FROM accounts')->fetchAll(PDO::FETCH_COLUMN),static fn($hash)=>password_get_info($hash)['algo']===null)),
    ]); exit;
}
$suffix=bin2hex(random_bytes(4));
$pdo->beginTransaction();
$pdo->prepare("INSERT INTO accounts(username,password,full_name,role) VALUES (?,?,'Fixture Student','student')")->execute(['fixture_'.$suffix,password_hash('FixturePass_123',PASSWORD_BCRYPT)]);
$account=(int)$pdo->lastInsertId();
$code='FIX_'.$suffix;
$pdo->prepare("INSERT INTO students(account_id,student_code,faculty,class_name) VALUES (?,?,'Test','Test')")->execute([$account,$code]);
$student=(int)$pdo->lastInsertId();
$librarian=(int)$pdo->query('SELECT id FROM librarians ORDER BY id LIMIT 1')->fetchColumn();
$publisher=(int)$pdo->query('SELECT id FROM publishers ORDER BY id LIMIT 1')->fetchColumn();
$pdo->prepare("INSERT INTO books(title,language,publisher_id) VALUES (?,'Tiếng Việt',?)")->execute(['Fixture Book '.$suffix,$publisher]); $book=(int)$pdo->lastInsertId();
$pdo->prepare("INSERT INTO book_copies(book_id,barcode,storage_location) VALUES (?,?,'Test')")->execute([$book,'FIX_'.$suffix]); $copy=(int)$pdo->lastInsertId();
$pdo->prepare("INSERT INTO equipment(name,equipment_type,total_quantity,available_quantity,status) VALUES (?,'Test',1,1,'available')")->execute(['Fixture Equipment '.$suffix]); $equipment=(int)$pdo->lastInsertId();
$pdo->prepare("INSERT INTO rooms(name,room_type,location,capacity,status) VALUES (?,'classroom','Test',10,'available')")->execute(['Fixture Room '.$suffix]); $room=(int)$pdo->lastInsertId();
$requests=['book'=>[],'equipment'=>[]];
foreach(['book','equipment'] as $type) {
    for($i=0;$i<3;$i++) {
        $table=$type.'_loan_requests'; $items=$type.'_loan_request_items'; $fk=$type==='book'?'book_id':'equipment_id'; $resource=$type==='book'?$book:$equipment;
        $pdo->prepare("INSERT INTO `$table`(student_id) VALUES (?)")->execute([$student]); $id=(int)$pdo->lastInsertId();
        $pdo->prepare("INSERT INTO `$items`(request_id,`$fk`,quantity,requested_due_date) VALUES (?,?,1,DATE_ADD(CURDATE(),INTERVAL 7 DAY))")->execute([$id,$resource]);
        $requests[$type][]=$id;
    }
}
$pdo->commit();
$fixture=compact('book','copy','equipment','room','student','code','publisher','requests');
$fixture['username']='fixture_'.$suffix;
file_put_contents(getenv('NEXUS_TEST_FIXTURE_FILE'),json_encode($fixture));
echo json_encode($fixture);
