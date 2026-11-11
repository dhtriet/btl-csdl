<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
$p=Database::connection();
$name='resource_center_test_'.gmdate('YmdHis').random_int(100,999);
if (!preg_match('/^resource_center_test_[0-9]+$/D',$name)) throw new RuntimeException('Isolated test name required');
$exists=$p->prepare('SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME=?');$exists->execute([$name]);
if ($exists->fetchColumn()) throw new RuntimeException('Refusing to reuse existing database');
$schema=file_get_contents(dirname(__DIR__).'/database/schema.sql');
$schema=str_replace(['CREATE DATABASE IF NOT EXISTS resource_center','USE resource_center;'],["CREATE DATABASE `$name`","USE `$name`;"],$schema);
$p->exec($schema);
$p->exec(str_replace('USE resource_center;',"USE `$name`;",file_get_contents(dirname(__DIR__).'/database/seed.sql')));
putenv('NEXUS_DB_NAME='.$name);
function migrate_for_test(): array {
    $command=escapeshellarg(PHP_BINARY).' '.escapeshellarg(dirname(__DIR__).'/scripts/migrate-circulation.php').' --apply';
    exec($command,$lines,$status);
    if ($status!==0) throw new RuntimeException('Migration failed');
    return json_decode(implode("\n",$lines),true,512,JSON_THROW_ON_ERROR);
}
$first=migrate_for_test();$second=migrate_for_test();
if ($second['opening_records']!==0 || $second['linked_receipts']!==0) throw new RuntimeException('Migration is not idempotent');
$bad=(int)$p->query('SELECT COUNT(*) FROM equipment e LEFT JOIN (SELECT equipment_id,SUM(quantity) n FROM equipment_loan_details WHERE return_date IS NULL GROUP BY equipment_id) d ON d.equipment_id=e.id WHERE total_quantity<>available_quantity+unavailable_quantity+COALESCE(d.n,0)')->fetchColumn();
if ($bad) throw new RuntimeException('Fresh stock is unbalanced');
$sid=(int)$p->query('SELECT id FROM students ORDER BY id LIMIT 1')->fetchColumn();
$lid=(int)$p->query('SELECT id FROM librarians ORDER BY id LIMIT 1')->fetchColumn();
$p->beginTransaction();
try {
    $expect=static function(string $sql,int $code) use($p): void {
        try {$p->exec($sql);}catch(PDOException $e){if((int)$e->errorInfo[1]===$code)return;throw $e;}
        throw new RuntimeException('Expected database constraint rejection');
    };
    $expect('UPDATE equipment SET unavailable_quantity=total_quantity+1 WHERE id=(SELECT id FROM (SELECT MIN(id) id FROM equipment) t)',3819);
    $expect("INSERT INTO loan_receipts (student_id,librarian_id,request_id) VALUES ($sid,$lid,4294967294)",1452);
    $p->exec("INSERT INTO book_loan_requests (student_id,librarian_id,status) VALUES ($sid,$lid,'approved')");$request=(int)$p->lastInsertId();
    $p->exec("INSERT INTO loan_receipts (student_id,librarian_id,request_id) VALUES ($sid,$lid,$request)");
    $expect("INSERT INTO loan_receipts (student_id,librarian_id,request_id) VALUES ($sid,$lid,$request)",1062);
} finally {$p->rollBack();}
$standalone=trim(file_get_contents(dirname(__DIR__).'/database/equipment_inventory_adjustments.sql'));
if (!str_contains(preg_replace('/\s+/',' ',file_get_contents(dirname(__DIR__).'/database/schema.sql')),preg_replace('/\s+/',' ',$standalone))) throw new RuntimeException('Fresh schema and migration inventory DDL differ');
echo json_encode(['database'=>$name,'tables'=>(int)$p->query('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()')->fetchColumn(),'first_opening_records'=>$first['opening_records'],'second_run'=>'no changes','stock_balance'=>'passed','direct_sql_fk_unique_checks'=>'passed','shared_ddl'=>'passed'],JSON_PRETTY_PRINT),PHP_EOL;
