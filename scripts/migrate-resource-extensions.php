<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
require __DIR__.'/lib/database-snapshot.php';
$pdo = Database::connection();
$exists = (bool)$pdo->query("SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='resource_extension_requests'")->fetchColumn();
if (($argv[1] ?? '--check') !== '--apply') { echo json_encode(['migration_needed'=>!$exists]), PHP_EOL; exit; }
if ($exists) { echo "Resource renewals already installed.\n"; exit; }
$backup = database_snapshot($pdo, dirname(__DIR__,2).'/resource-center-backups/resource-extensions-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)));
$pdo->exec(file_get_contents(dirname(__DIR__).'/database/resource_extension_requests.sql'));
echo json_encode(['installed'=>true,'backup'=>$backup]), PHP_EOL;
