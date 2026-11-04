<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/config.php';require dirname(__DIR__).'/app/database.php';require dirname(__DIR__).'/app/integrity.php';
if (!preg_match('/^resource_center_test_[0-9]+$/D',getenv('NEXUS_DB_NAME') ?: '')) throw new RuntimeException('Requires isolated resource_center_test_<digits> database');
$pdo=Database::connection();$passed=0;
function verify(bool $condition,string $message): void {global $passed;if (!$condition) throw new RuntimeException($message);$passed++;}
function reject_sql(PDO $pdo,string $sql,int $code,string $name): void {
    try {$pdo->exec($sql);} catch (PDOException $error) {
        verify((int)$error->errorInfo[1]===$code && str_contains($error->getMessage(),$name),"Unexpected rejection for $name");return;
    }
    throw new RuntimeException("Invalid SQL accepted: $name");
}
$pdo->beginTransaction();
try {
    $suffix=bin2hex(random_bytes(5));
    $student=(int)$pdo->query('SELECT id FROM students LIMIT 1')->fetchColumn();$librarian=(int)$pdo->query('SELECT id FROM librarians LIMIT 1')->fetchColumn();$publisher=(int)$pdo->query('SELECT id FROM publishers LIMIT 1')->fetchColumn();
    $pdo->exec("INSERT INTO books(title,language,publisher_id,pages) VALUES ('Integrity $suffix','vi',$publisher,10)");$book=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO ebooks(book_id,file_format,file_size_mb) VALUES ($book,'pdf',1)");$ebook=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO book_copies(book_id,barcode,storage_location) VALUES ($book,'CHK_$suffix','Test')");$copy=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO loan_receipts(student_id,librarian_id) VALUES ($student,$librarian)");$receipt=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO loan_details(receipt_id,copy_id,borrow_date,due_date) VALUES ($receipt,$copy,'2026-11-01','2026-11-07')");$loan=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO book_loan_requests(student_id) VALUES ($student)");$request=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO book_loan_request_items(request_id,book_id,requested_due_date) VALUES ($request,$book,'2026-11-07')");$item=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO equipment(name,equipment_type,total_quantity,available_quantity) VALUES ('Integrity $suffix','Test',5,4)");$equipment=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO equipment_loans(student_id,librarian_id) VALUES ($student,$librarian)");$equipmentLoan=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO equipment_loan_details(loan_id,equipment_id,quantity,borrow_date,due_date) VALUES ($equipmentLoan,$equipment,1,'2026-11-01','2026-11-07')");$equipmentDetail=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO equipment_loan_requests(student_id) VALUES ($student)");$equipmentRequest=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO equipment_loan_request_items(request_id,equipment_id,requested_due_date) VALUES ($equipmentRequest,$equipment,'2026-11-07')");$equipmentItem=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO rooms(name,room_type,location,capacity) VALUES ('Integrity $suffix','classroom','Test',10)");$room=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO room_requests(student_id,room_id,use_date,start_time,end_time,purpose) VALUES ($student,$room,'2026-11-07','10:00','11:00','Test')");$roomRequest=(int)$pdo->lastInsertId();
    $pdo->exec("INSERT INTO extensions(loan_detail_id,librarian_id,old_due_date,new_due_date,extension_date) VALUES ($loan,$librarian,'2026-11-07','2026-11-14','2026-11-01')");$extension=(int)$pdo->lastInsertId();
    foreach ([
        ["UPDATE books SET pages=0 WHERE id=$book",'chk_books_pages'],
        ["UPDATE ebooks SET file_size_mb=0 WHERE id=$ebook",'chk_ebooks_size'],
        ["UPDATE book_loan_request_items SET quantity=0 WHERE id=$item",'chk_book_request_quantity'],
        ["UPDATE equipment_loan_request_items SET quantity=0 WHERE id=$equipmentItem",'chk_equipment_request_quantity'],
        ["UPDATE equipment SET available_quantity=6 WHERE id=$equipment",'chk_equipment_quantities'],
        ["UPDATE equipment SET total_quantity=0,available_quantity=0 WHERE id=$equipment",'chk_equipment_quantities'],
        ["UPDATE rooms SET capacity=0 WHERE id=$room",'chk_rooms_capacity'],
        ["UPDATE room_requests SET end_time=start_time WHERE id=$roomRequest",'chk_room_request_time'],
        ["UPDATE room_requests SET start_time='-01:00:00' WHERE id=$roomRequest",'chk_room_request_time'],
        ["UPDATE room_requests SET end_time='25:00:00' WHERE id=$roomRequest",'chk_room_request_time'],
        ["UPDATE extensions SET new_due_date=old_due_date WHERE id=$extension",'chk_extensions_dates'],
        ["UPDATE loan_details SET due_date='2026-10-31' WHERE id=$loan",'chk_loan_dates'],
        ["UPDATE loan_details SET extension_count=4 WHERE id=$loan",'chk_loan_extensions'],
        ["UPDATE loan_details SET status='returned' WHERE id=$loan",'chk_loan_return_state'],
        ["UPDATE loan_details SET return_date='2026-11-09',return_status='late',late_days=2,status='returned' WHERE id=$loan",'chk_loan_return_state'],
        ["UPDATE loan_details SET return_date='2026-11-09',return_status='late',late_days=3,status='returned',condition_on_return='good' WHERE id=$loan",'chk_loan_return_result'],
        ["UPDATE loan_details SET return_date='2026-10-31',return_status='on_time',late_days=0,status='returned',condition_on_return='good' WHERE id=$loan",'chk_loan_dates'],
        ["UPDATE equipment_loan_details SET quantity=0 WHERE id=$equipmentDetail",'chk_equipment_loan_quantity'],
        ["UPDATE equipment_loan_details SET due_date='2026-10-31' WHERE id=$equipmentDetail",'chk_equipment_loan_dates'],
        ["UPDATE equipment_loan_details SET status='returned' WHERE id=$equipmentDetail",'chk_equipment_return_state'],
        ["UPDATE equipment_loan_details SET return_date='2026-11-09',return_status='on_time',late_days=0,status='returned',condition_on_return='Good' WHERE id=$equipmentDetail",'chk_equipment_return_result'],
    ] as [$sql,$constraint]) reject_sql($pdo,$sql,3819,$constraint);
    reject_sql($pdo,"INSERT INTO loan_details(receipt_id,copy_id,borrow_date,due_date) VALUES ($receipt,$copy,'2026-11-01','2026-11-07')",1062,'uq_loan_details_active_copy');
    for ($i=0;$i<2;$i++) $pdo->exec("INSERT INTO loan_details(receipt_id,copy_id,borrow_date,due_date,return_date,return_status,late_days,status,condition_on_return) VALUES ($receipt,$copy,'2026-10-01','2026-10-07','2026-10-06','on_time',0,'returned','good')");
    $history=(int)$pdo->lastInsertId();
    reject_sql($pdo,"UPDATE loan_details SET return_date=NULL,return_status=NULL,late_days=0,status='borrowed',condition_on_return=NULL WHERE id=$history",1062,'uq_loan_details_active_copy');
    $pdo->exec("UPDATE loan_details SET return_date='2026-11-09',return_status='late',late_days=2,status='returned',condition_on_return='good' WHERE id=$loan");
    $pdo->exec("INSERT INTO loan_details(receipt_id,copy_id,borrow_date,due_date) VALUES ($receipt,$copy,'2026-11-10','2026-11-17')");
    verify((int)$pdo->query("SELECT COUNT(*) FROM loan_details WHERE active_copy_id=$copy")->fetchColumn()===1,'Return must release the copy for the next borrower');
    $pdo->exec("UPDATE books SET pages=NULL WHERE id=$book");$pdo->exec("UPDATE ebooks SET file_size_mb=NULL WHERE id=$ebook");
    $pdo->exec("UPDATE equipment SET total_quantity=1,available_quantity=0 WHERE id=$equipment");
    $pdo->exec("UPDATE room_requests SET start_time='00:00:00',end_time='24:00:00' WHERE id=$roomRequest");
    verify(true,'Valid boundary values accepted');
    verify(integrity_return_result('2026-11-07','2026-11-09')===['return_status'=>'late','late_days'=>2],'Late days must be calculated from dates');
    verify(integrity_return_result('2026-11-07','2026-11-07')===['return_status'=>'on_time','late_days'=>0],'Same-day return is on time');
    verify(integrity_return_result('2026-11-07','2026-11-01')===['return_status'=>'on_time','late_days'=>0],'Early return has zero late days');
    echo "PASS $passed SQL and return-date assertions; all fixtures rolled back.\n";
} finally {if ($pdo->inTransaction()) $pdo->rollBack();}
