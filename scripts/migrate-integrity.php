<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli') {http_response_code(404);exit;}
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
require dirname(__DIR__).'/app/integrity.php';
require __DIR__.'/lib/database-snapshot.php';
$pdo=Database::connection();
$mode=$argv[1] ?? '--check';
if (!in_array($mode,['--check','--apply','--sql'],true)) throw new RuntimeException('Use --check, --apply or --sql');
$rules=integrity_rules();
$uniqueColumn="active_copy_id INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN return_date IS NULL THEN copy_id ELSE NULL END) VIRTUAL";
if ($mode==='--sql') {
    echo "-- Generated from app/integrity.php. Back up first. Prefer the idempotent PHP migration runner.\n";
    foreach (['loan_details','equipment_loan_details'] as $table) {
        echo "UPDATE $table SET return_status=IF(late_days>0,'late','on_time'),status='returned' WHERE return_date IS NOT NULL;\n";
        echo "UPDATE $table SET return_status=NULL,late_days=0,condition_on_return=NULL,status=IF(due_date<CURDATE(),'overdue','borrowed') WHERE return_date IS NULL;\n";
    }
    foreach ($rules as $table=>$checks) foreach ($checks as $name=>$expression) echo "ALTER TABLE `$table` ADD CONSTRAINT `$name` CHECK ($expression);\n";
    echo "ALTER TABLE loan_details ADD COLUMN $uniqueColumn, ADD UNIQUE KEY uq_loan_details_active_copy(active_copy_id);\n";exit;
}
$version=(string)$pdo->query('SELECT VERSION()')->fetchColumn();
if (str_contains(strtolower($version),'mariadb') || version_compare($version,'8.0.16','<')) throw new RuntimeException('Requires MySQL 8.0.16+ with enforced CHECK constraints');
$repairable=['chk_loan_return_state','chk_loan_return_result','chk_equipment_return_state','chk_equipment_return_result'];
function audit_integrity(PDO $pdo,array $rules): array {
    $issues=[];
    foreach ($rules as $table=>$checks) foreach ($checks as $name=>$expression) {
        $ids=$pdo->query("SELECT id FROM `$table` WHERE NOT ($expression) ORDER BY id")->fetchAll(PDO::FETCH_COLUMN);
        if ($ids) $issues[$name]=['table'=>$table,'ids'=>array_map('intval',$ids)];
    }
    $duplicates=$pdo->query('SELECT copy_id,COUNT(*) AS count FROM loan_details WHERE return_date IS NULL GROUP BY copy_id HAVING COUNT(*)>1')->fetchAll();
    if ($duplicates) $issues['uq_loan_details_active_copy']=$duplicates;
    foreach (['loan_details','equipment_loan_details'] as $table) {
        $ids=$pdo->query("SELECT id FROM $table WHERE return_date IS NOT NULL AND (condition_on_return IS NULL OR CHAR_LENGTH(TRIM(condition_on_return))=0)")->fetchAll(PDO::FETCH_COLUMN);
        if ($ids) $issues[$table.'_missing_return_condition']=['ids'=>array_map('intval',$ids)];
    }
    return $issues;
}
$issues=audit_integrity($pdo,$rules);
$installed=$pdo->query("SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE()")->fetchAll(PDO::FETCH_COLUMN);
$expected=array_merge(...array_map('array_keys',array_values($rules)));$expected[]='uq_loan_details_active_copy';
$missing=array_values(array_diff($expected,$installed));
if ($mode==='--check') {
    echo json_encode(['database'=>$pdo->query('SELECT DATABASE()')->fetchColumn(),'mysql'=>$version,'violations'=>$issues,'missing_constraints'=>$missing],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE),PHP_EOL;
    exit($issues || $missing?2:0);
}
$blockers=array_diff_key($issues,array_flip($repairable));
if ($blockers) {echo json_encode(['blocked'=>$blockers],JSON_PRETTY_PRINT),PHP_EOL;exit(2);}
if (!$issues && !$missing) {echo "All integrity constraints already installed; no changes needed.\n";exit;}
$folder=dirname(__DIR__,2).'/resource-center-backups/integrity-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3));
$backup=database_snapshot($pdo,$folder);
$repaired=[];$applied=[];
// DDL commits independently in MySQL. Audit all rows before adding constraints;
// reruns inspect information_schema and safely resume any interrupted installation.
$pdo->beginTransaction();
try {
    foreach (['loan_details','equipment_loan_details'] as $table) {
        $repaired[$table]=$pdo->exec("UPDATE $table SET return_status=IF(late_days>0,'late','on_time'),status='returned' WHERE return_date IS NOT NULL AND (return_status IS NULL OR return_status<>IF(late_days>0,'late','on_time') OR status<>'returned')");
        $repaired[$table]+=$pdo->exec("UPDATE $table SET return_status=NULL,late_days=0,condition_on_return=NULL,status=IF(due_date<CURDATE(),'overdue','borrowed') WHERE return_date IS NULL AND (return_status IS NOT NULL OR late_days<>0 OR condition_on_return IS NOT NULL OR status NOT IN ('borrowed','overdue'))");
    }
    if (audit_integrity($pdo,$rules)) throw new RuntimeException('Data still violates constraints after deterministic return-field repair');
    $pdo->commit();
} catch (Throwable $error) {if ($pdo->inTransaction()) $pdo->rollBack();throw $error;}
foreach ($rules as $table=>$checks) {
    $clauses=[];
    foreach ($checks as $name=>$expression) if (!in_array($name,$installed,true)) {$clauses[]="ADD CONSTRAINT `$name` CHECK ($expression)";$applied[]=$name;}
    if ($table==='loan_details') {
        $column=(int)$pdo->query("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='loan_details' AND COLUMN_NAME='active_copy_id'")->fetchColumn();
        if (!$column) $clauses[]='ADD COLUMN '.$uniqueColumn;
        if (!in_array('uq_loan_details_active_copy',$installed,true)) {$clauses[]='ADD UNIQUE KEY uq_loan_details_active_copy(active_copy_id)';$applied[]='uq_loan_details_active_copy';}
    }
    if ($clauses) $pdo->exec("ALTER TABLE `$table` ".implode(', ',$clauses));
}
if (audit_integrity($pdo,$rules)) throw new RuntimeException('Final integrity audit failed');
echo json_encode(['backup'=>$backup,'normalized_rows'=>$repaired,'added_constraints'=>$applied,'audit'=>'passed'],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE),PHP_EOL;
