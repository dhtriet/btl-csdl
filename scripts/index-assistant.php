<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli') {http_response_code(404);exit;}
require __DIR__.'/../app/config.php';
require __DIR__.'/../app/database.php';
require __DIR__.'/../app/assistant.php';
$catalog=assistant_catalog(Database::connection());
file_put_contents(__DIR__.'/../storage/assistant-manifest.json',json_encode($catalog,JSON_UNESCAPED_UNICODE));
if (is_file(__DIR__.'/../storage/assistant/restored-books.sqlite')) {
    passthru('python3 '.escapeshellarg(__DIR__.'/import-ebook-index.py'), $importCode);
    if ($importCode === 0) exit(0);
}
$result=assistant_worker(['action'=>'index','catalog'=>$catalog]);
echo json_encode($result,JSON_UNESCAPED_UNICODE),PHP_EOL;
exit(isset($result['error'])?1:0);
