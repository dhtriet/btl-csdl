<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli') {http_response_code(404);exit;}
require dirname(__DIR__).'/app/config.php';require dirname(__DIR__).'/app/database.php';require dirname(__DIR__).'/app/integrity.php';require __DIR__.'/lib/database-snapshot.php';
$p=Database::connection();$changes=[];
foreach (['loan_details'=>'chk_loan_return_result','equipment_loan_details'=>'chk_equipment_return_result'] as $table=>$name) {
    $q=$p->prepare('SELECT CHECK_CLAUSE FROM information_schema.CHECK_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND CONSTRAINT_NAME=?');$q->execute([$name]);$old=$q->fetchColumn();
    if ($old===false || preg_match('/to_days|datediff/i',$old)) $changes[]=[$table,$name,$old!==false];
}
if (($argv[1]??'--check')!=='--apply') {echo json_encode(['constraints_to_update'=>count($changes)]),PHP_EOL;exit;}
if (!$changes) {echo "Manual return days already installed.\n";exit;}
$backup=database_snapshot($p,dirname(__DIR__,2).'/resource-center-backups/manual-return-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)));
$dropCheck=str_contains(strtolower((string)$p->getAttribute(PDO::ATTR_SERVER_VERSION)),'mariadb') ? 'DROP CONSTRAINT' : 'DROP CHECK';
foreach ($changes as [$table,$name,$exists]) {
    $clauses=$exists?["$dropCheck `$name`"]:[];
    $expression=integrity_rules()[$table][$name];$clauses[]="ADD CONSTRAINT `$name` CHECK ($expression)";
    $p->exec("ALTER TABLE `$table` ".implode(', ',$clauses));
}
echo json_encode(['updated'=>count($changes),'backup'=>$backup]),PHP_EOL;
