<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../app/config.php';
require __DIR__ . '/../app/database.php';
$pdo=Database::connection();
$apply=in_array('--apply',$argv,true);
$count=0;
$pdo->beginTransaction();
try {
    $rows=$pdo->query('SELECT id,password FROM accounts FOR UPDATE')->fetchAll();
    $update=$pdo->prepare('UPDATE accounts SET password = ? WHERE id = ?');
    foreach ($rows as $row) {
        if (password_get_info($row['password'])['algo'] !== null) continue;
        $count++;
        if ($apply) $update->execute([password_hash($row['password'],PASSWORD_BCRYPT),$row['id']]);
    }
    if ($apply) $pdo->commit(); else $pdo->rollBack();
    echo json_encode(['mode'=>$apply?'applied':'dry-run','accounts'=>$count]),PHP_EOL;
} catch (Throwable $error) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    throw $error;
}
