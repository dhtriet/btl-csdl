<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli') {http_response_code(404);exit;}
require dirname(__DIR__).'/app/config.php';
require dirname(__DIR__).'/app/database.php';
require __DIR__.'/lib/database-snapshot.php';
$pdo=Database::connection();
$table=(bool)$pdo->query("SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='equipment_inventory_adjustments'")->fetchColumn();
$column=(bool)$pdo->query("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='equipment' AND COLUMN_NAME='inventory_verified_at'")->fetchColumn();
if (($argv[1]??'--check')!=='--apply') {echo json_encode(['inventory_table_exists'=>$table,'verification_column_exists'=>$column]),PHP_EOL;exit;}
if (!$table && !$column) {echo "Inventory reconciliation already removed.\n";exit;}
$backup=database_snapshot($pdo,dirname(__DIR__,2).'/resource-center-backups/remove-inventory-'.gmdate('Ymd-His').'-'.bin2hex(random_bytes(3)));
if ($table) $pdo->exec('DROP TABLE equipment_inventory_adjustments');
if ($column) $pdo->exec('ALTER TABLE equipment DROP COLUMN inventory_verified_at');
echo json_encode(['removed'=>true,'backup'=>$backup]),PHP_EOL;
