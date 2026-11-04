<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli') {http_response_code(404);exit;}
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
require __DIR__.'/lib/database-snapshot.php';
$pdo=Database::connection();$mode=$argv[1] ?? '--check';
if (!in_array($mode,['--check','--apply'],true)) throw new RuntimeException('Use --check or --apply');
$columns=[];
foreach (['books','book_copies','rooms','equipment'] as $table) {
    $columns[$table]=['is_visible'=>'TINYINT(1) NOT NULL DEFAULT 1','deleted_at'=>'DATETIME NULL'];
    if (in_array($table,['rooms','equipment'],true)) $columns[$table]+=['image_path'=>'VARCHAR(255) NULL','image_is_illustration'=>'TINYINT(1) NOT NULL DEFAULT 0'];
}
$changes=[];
foreach ($columns as $table=>$fields) foreach ($fields as $name=>$definition) {
    $q=$pdo->prepare('SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?');$q->execute([$table,$name]);
    if (!(int)$q->fetchColumn()) $changes[$table][]="ADD COLUMN `$name` $definition";
}
if ($mode==='--check') {echo json_encode(['missing_columns'=>$changes],JSON_PRETTY_PRINT),PHP_EOL;exit($changes?2:0);}
if (!$changes) {echo "Visibility schema is current.\n";exit;}
$folder=dirname(__DIR__,2).'/resource-center-backups/visibility-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3));
$backup=database_snapshot($pdo,$folder);
foreach (['app','public','database'] as $directory) {
    $iterator=new RecursiveIteratorIterator(new RecursiveDirectoryIterator(dirname(__DIR__).'/'.$directory,FilesystemIterator::SKIP_DOTS));
    foreach ($iterator as $file) if ($file->isFile()) {
        $relative=substr($file->getPathname(),strlen(dirname(__DIR__))+1);$destination=$folder.'/source/'.$relative;
        if (!is_dir(dirname($destination))) mkdir(dirname($destination),0700,true);
        if (!copy($file->getPathname(),$destination)) throw new RuntimeException('Source backup failed');
    }
}
foreach ($changes as $table=>$clauses) $pdo->exec("ALTER TABLE `$table` ".implode(', ',$clauses));
echo json_encode(['backup'=>$backup,'updated_tables'=>array_keys($changes)],JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE),PHP_EOL;
