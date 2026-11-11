<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
require __DIR__.'/lib/database-snapshot.php';

// Only replace the old shared demo image or an empty cover, never a custom upload.
$pdo=Database::connection();
$root=dirname(__DIR__);
$manifest=json_decode(file_get_contents($root.'/docs/unique-resource-images.json'),true,512,JSON_THROW_ON_ERROR);
$pending=[];
foreach ($manifest as $item) {
    $table=$item['table'];
    if (!in_array($table,['books','rooms','equipment'],true)) throw new RuntimeException('Invalid resource type');
    $field=$table==='books'?'cover_image':'image_path';
    if (!preg_match('~^/uploads/(covers|resources)/[a-f0-9]{32}\.jpg$~D',$item['path'])) throw new RuntimeException('Invalid image path');
    $file=$root.'/public'.$item['path'];
    if (!is_file($file) || !getimagesize($file) || filesize($file)>2097152) throw new RuntimeException('Missing or invalid image');
    $name=$table==='books'?'title':'name';
    $q=$pdo->prepare("SELECT `$field`, `$name` AS resource_name FROM `$table` WHERE id=? AND deleted_at IS NULL");
    $q->execute([$item['id']]);$current=$q->fetch();
    if (!$current || $current['resource_name']!==$item['resource_name'] || $current[$field]===$item['path']) continue;
    if ($current[$field]!==null && $current[$field]!=='' && $current[$field]!==$item['expected_previous']) continue;
    $pending[]=[$table,$field,$item,$current[$field]];
}
if (($argv[1]??'--check')!=='--apply') {
    echo json_encode(['pending'=>count($pending),'mode'=>'check']),PHP_EOL;exit;
}
if (!$pending) { echo "No image changes needed.\n";exit; }
$backup=database_snapshot($pdo,dirname($root).'/resource-center-backups/images-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)));
$updated=0;
$pdo->beginTransaction();
try {
    foreach ($pending as [$table,$field,$item,$old]) {
        $q=$pdo->prepare("UPDATE `$table` SET `$field`=?".($table==='books'?'':',image_is_illustration=1')." WHERE id=? AND deleted_at IS NULL AND `$field` <=> ?");
        $q->execute([$item['path'],$item['id'],$old]);$updated+=$q->rowCount();
    }
    $pdo->commit();
} catch (Throwable $error) { if ($pdo->inTransaction()) $pdo->rollBack();throw $error; }
echo json_encode(['updated'=>$updated,'backup'=>$backup],JSON_UNESCAPED_SLASHES),PHP_EOL;
