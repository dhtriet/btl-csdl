<?php
declare(strict_types=1);
if(PHP_SAPI!=='cli') {http_response_code(404);exit;}
require __DIR__.'/../app/config.php';
require __DIR__.'/../app/database.php';
require __DIR__.'/../app/assistant.php';
file_put_contents(__DIR__.'/../storage/assistant-manifest.json',json_encode(assistant_catalog(Database::connection()),JSON_UNESCAPED_UNICODE));
echo "Book manifest written.\n";
