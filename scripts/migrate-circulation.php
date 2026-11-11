<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
require __DIR__.'/lib/database-snapshot.php';
$pdo = Database::connection();
$apply = ($argv[1] ?? '--check') === '--apply';
$has = static function(string $table, string $column) use ($pdo): bool {
    $q=$pdo->prepare('SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?'); $q->execute([$table,$column]); return (bool)$q->fetchColumn();
};
$missing=[];
foreach (['book_loan_requests'=>'source','equipment_loan_requests'=>'source','loan_receipts'=>'request_id','equipment_loans'=>'request_id','equipment'=>'unavailable_quantity'] as $t=>$c) if (!$has($t,$c)) $missing[]="$t.$c";
$installed=$pdo->query('SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE()')->fetchAll(PDO::FETCH_COLUMN);
foreach (['fk_loan_receipts_request','fk_equipment_loans_request','chk_equipment_stock_buckets'] as $name) if (!in_array($name,$installed,true)) $missing[]=$name;
if (!$apply) { echo json_encode(['missing'=>$missing],JSON_PRETTY_PRINT),PHP_EOL; exit($missing ? 2 : 0); }
// Snapshot before DDL. Keep request links and equipment balances consistent on reruns.
$backup=database_snapshot($pdo,dirname(__DIR__,2).'/resource-center-backups/circulation-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)));
foreach (['book_loan_requests','equipment_loan_requests'] as $table) if (!$has($table,'source')) $pdo->exec("ALTER TABLE $table ADD COLUMN source ENUM('online','counter') NOT NULL DEFAULT 'online'");
foreach (['loan_receipts'=>'book_loan_requests','equipment_loans'=>'equipment_loan_requests'] as $table=>$requestTable) {
    if (!$has($table,'request_id')) $pdo->exec("ALTER TABLE $table ADD COLUMN request_id INT UNSIGNED NULL, ADD UNIQUE KEY uq_{$table}_request(request_id), ADD CONSTRAINT fk_{$table}_request FOREIGN KEY(request_id) REFERENCES $requestTable(id)");
}
if (!$has('equipment','unavailable_quantity')) $pdo->exec('ALTER TABLE equipment ADD COLUMN unavailable_quantity INT UNSIGNED NOT NULL DEFAULT 0');
$type=$pdo->query("SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='equipment' AND COLUMN_NAME='status'")->fetchColumn();
if (!str_contains($type,"'unavailable'")) $pdo->exec("ALTER TABLE equipment MODIFY status ENUM('available','borrowed','maintenance','damaged','unavailable') NOT NULL DEFAULT 'available'");
$equipmentUpdated=0; $linked=0; $unlinked=[];
$pdo->beginTransaction();
try {
    $rows=$pdo->query('SELECT * FROM equipment ORDER BY id FOR UPDATE')->fetchAll();
    $active=$pdo->prepare('SELECT COALESCE(SUM(quantity),0) FROM equipment_loan_details WHERE equipment_id=? AND return_date IS NULL');
    foreach ($rows as $row) {
        $active->execute([$row['id']]); $onLoan=(int)$active->fetchColumn();
        $blocked=(int)$row['total_quantity']-(int)$row['available_quantity']-$onLoan;
        if ($blocked<0) throw new RuntimeException('Equipment #'.$row['id'].' has more available/borrowed units than its total; manual investigation required.');
        $status=$row['status'];
        if (!in_array($status,['maintenance','damaged'],true)) $status=(int)$row['available_quantity']>0?'available':($onLoan>0?'borrowed':'unavailable');
        $q=$pdo->prepare('UPDATE equipment SET unavailable_quantity=?,status=? WHERE id=?'); $q->execute([$blocked,$status,$row['id']]); $equipmentUpdated+=$q->rowCount();
    }
    foreach (['loan_receipts'=>['book_loan_requests','Duyet yeu cau sach #'], 'equipment_loans'=>['equipment_loan_requests','Duyet yeu cau thiet bi #']] as $table=>[$requests,$prefix]) {
        $candidates=[];
        foreach ($pdo->query("SELECT id,student_id,librarian_id,note FROM $table WHERE request_id IS NULL")->fetchAll() as $receipt) {
            if (!preg_match('/^'.preg_quote($prefix,'/').'(\d+)(?:\s|$)/u',(string)$receipt['note'],$match)) continue;
            $candidates[(int)$match[1]][]=$receipt;
        }
        foreach ($candidates as $requestId=>$receipts) {
            $q=$pdo->prepare("SELECT id,student_id,librarian_id,status FROM $requests WHERE id=?"); $q->execute([$requestId]); $request=$q->fetch();
            $receipt=$receipts[0];
            $exists=$pdo->prepare("SELECT COUNT(*) FROM $table WHERE request_id=?"); $exists->execute([$requestId]);
            if (count($receipts)!==1 || !$request || $request['status']!=='approved' || $request['student_id']!==$receipt['student_id'] || $request['librarian_id']!==$receipt['librarian_id'] || $exists->fetchColumn()) { $unlinked[]=['table'=>$table,'request'=>$requestId]; continue; }
            $q=$pdo->prepare("UPDATE $table SET request_id=? WHERE id=?"); $q->execute([$requestId,$receipt['id']]); $linked++;
        }
    }
    $pdo->commit();
} catch (Throwable $e) { if ($pdo->inTransaction()) $pdo->rollBack(); throw $e; }
$exists=$pdo->query("SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND CONSTRAINT_NAME='chk_equipment_stock_buckets'")->fetchColumn();
if (!$exists) $pdo->exec('ALTER TABLE equipment ADD CONSTRAINT chk_equipment_stock_buckets CHECK (available_quantity + unavailable_quantity <= total_quantity)');
echo json_encode(['backup'=>$backup,'equipment_updated'=>$equipmentUpdated,'linked_receipts'=>$linked,'ambiguous_links'=>$unlinked],JSON_UNESCAPED_UNICODE|JSON_PRETTY_PRINT),PHP_EOL;
