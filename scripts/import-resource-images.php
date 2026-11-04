<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../app/config.php';require __DIR__.'/../app/database.php';
$p=Database::connection();$manifest=json_decode(file_get_contents(__DIR__.'/../docs/resource-image-import.json'),true,512,JSON_THROW_ON_ERROR);
$p->beginTransaction();try{foreach($manifest as $item){$table=$item['table'];if(!in_array($table,['books','rooms','equipment'],true))throw new RuntimeException('Invalid table');$file=__DIR__.'/../public'.$item['path'];if(!getimagesize($file)||filesize($file)>2097152)throw new RuntimeException('Invalid image');$field=$table==='books'?'cover_image':'image_path';$q=$p->prepare("UPDATE `$table` SET `$field`=?".($table==='books'?'':',image_is_illustration=1')." WHERE id=? AND deleted_at IS NULL AND (`$field` IS NULL OR `$field`=?)");$q->execute([$item['path'],$item['id'],$item['path']]);} $p->commit();echo 'Imported '.count($manifest)." image assignments; existing custom images preserved.\n";}catch(Throwable $e){$p->rollBack();throw $e;}
