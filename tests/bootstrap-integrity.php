<?php
declare(strict_types=1);
require dirname(__DIR__).'/app/config.php';require dirname(__DIR__).'/app/database.php';require dirname(__DIR__).'/scripts/lib/database-snapshot.php';
$source=getenv('NEXUS_DB_NAME') ?: '';$fresh=$argv[1] ?? '';$restored=$argv[2] ?? '';
foreach ([$source,$fresh,$restored] as $name) if (!preg_match('/^resource_center_test_[0-9]+$/D',$name)) throw new RuntimeException('Only isolated test databases allowed');
if (count(array_unique([$source,$fresh,$restored]))!==3) throw new RuntimeException('Test database names must differ');
$pdo=Database::connection();
$schema=file_get_contents(dirname(__DIR__).'/database/schema.sql');
$schema=str_replace(['CREATE DATABASE IF NOT EXISTS resource_center','USE resource_center;'],["CREATE DATABASE IF NOT EXISTS `$fresh`","USE `$fresh`;"],$schema);
$exists=$pdo->prepare('SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME IN (?,?)');$exists->execute([$fresh,$restored]);
if ((int)$exists->fetchColumn()>0) throw new RuntimeException('Targets already exist; choose new database names');
$seed=str_replace('USE resource_center;',"USE `$fresh`;",file_get_contents(dirname(__DIR__).'/database/seed.sql'));
foreach ([$schema,$seed] as $sql) {
    preg_match_all('/\bUSE\s+([^;]+);/i',$sql,$uses);
    foreach ($uses[1] as $name) if (trim($name," `\t\r\n")!==$fresh) throw new RuntimeException('SQL attempted to select a non-test database');
}
$pdo->exec($schema);$pdo->exec($seed);
echo "PASS fresh schema + seed loaded with enforced constraints.\n";
$pdo->exec("USE `$source`");
function snapshot_digest(PDO $pdo): array {
    $result=[];
    foreach ($pdo->query("SHOW FULL TABLES WHERE Table_type='BASE TABLE'")->fetchAll(PDO::FETCH_NUM) as [$table]) {
        $rows=array_map(static fn($row)=>json_encode($row),$pdo->query("SELECT * FROM `$table`")->fetchAll());sort($rows);
        $result[$table]=['rows'=>count($rows),'hash'=>hash('sha256',implode("\n",$rows))];
    }
    return $result;
}
$before=snapshot_digest($pdo);
$snapshot=database_snapshot($pdo,sys_get_temp_dir().'/nexus-integrity-roundtrip-'.bin2hex(random_bytes(5)));
$pdo->exec("CREATE DATABASE `$restored` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");$pdo->exec("USE `$restored`");
$pdo->exec(file_get_contents($snapshot));
if ($before!==snapshot_digest($pdo)) throw new RuntimeException('Backup roundtrip changed table data');
echo 'PASS snapshot restored all rows, timestamps and generated columns across ',count($before)," tables without data changes.\n";
