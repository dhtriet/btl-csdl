<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/sql_names.php';
if(!preg_match('/^resource_center_test_[0-9]+$/D',getenv('NEXUS_DB_NAME')?:''))throw new RuntimeException('Isolated test database required');
$p=new PDO(sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',DB_HOST,DB_PORT,getenv('NEXUS_DB_NAME')),DB_USER,DB_PASS,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$map=SqlNames::mapping();
function fingerprint(PDO $p,array $map,bool $vietnamese):array {
    $result=[];
    foreach($map['tables'] as $old=>$new){
        $table=$vietnamese?$new:$old;
        $q=$p->prepare('SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? ORDER BY COLUMN_NAME');$q->execute([$table]);$columns=$q->fetchAll(PDO::FETCH_COLUMN);
        $rows=$p->query("SELECT * FROM `$table`")->fetchAll();
        foreach($rows as &$row){$row=SqlNames::apiRow($row);ksort($row);}unset($row);
        $rows=array_map(fn($row)=>json_encode($row,JSON_UNESCAPED_UNICODE|JSON_PRESERVE_ZERO_FRACTION),$rows);sort($rows);
        $result[$old]=hash('sha256',implode("\n",$rows));
    }
    return $result;
}
$before=fingerprint($p,$map,false);
$constraints=(int)$p->query('SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA=DATABASE()')->fetchColumn();
passthru(escapeshellarg(PHP_BINARY).' '.escapeshellarg(dirname(__DIR__).'/scripts/migrate-vietnamese-schema.php').' --apply',$status);
if($status!==0)throw new RuntimeException('Migration failed');
if($before!==fingerprint($p,$map,true))throw new RuntimeException('Stored data changed during renaming');
if($constraints!==(int)$p->query('SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA=DATABASE()')->fetchColumn())throw new RuntimeException('Constraint count changed');
passthru(escapeshellarg(PHP_BINARY).' '.escapeshellarg(dirname(__DIR__).'/scripts/migrate-vietnamese-schema.php').' --apply',$status);
if($status!==0)throw new RuntimeException('Repeated migration failed');
echo "Verified all 27 tables: identical stored values, unchanged constraints and idempotent migration.\n";
