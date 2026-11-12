<?php

declare(strict_types=1);

session_start();

require_once __DIR__ . '/../app/config.php';
require_once __DIR__ . '/../app/database.php';
require_once __DIR__ . '/../app/visibility.php';

if (empty($_SESSION['user'])) {
    header('Location: /');
    exit;
}

header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');
header("Content-Security-Policy: default-src 'self'; frame-src 'self'; style-src 'self';");
header('Cache-Control: no-store');

$bookId = filter_input(INPUT_GET, 'book_id', FILTER_VALIDATE_INT);
if (!$bookId || $bookId < 1) {
    http_response_code(400);
    exit('Mã sách không hợp lệ.');
}

$statement = Database::connection()->prepare(
    'SELECT b.ten_sach, b.nam_xuat_ban, b.tom_tat, p.ten AS publisher,
            e.dinh_dang_tep, e.dung_luong_mb, e.do_phan_giai, e.duong_dan_tep AS ebook_path
     FROM dau_sach b
     JOIN nha_xuat_ban p ON p.ma = b.ma_nha_xuat_ban
     LEFT JOIN sach_dien_tu e ON e.ma_dau_sach = b.ma
     WHERE b.ma = :id
     LIMIT 1'
);
$statement->execute(['id' => $bookId]);
$book = $statement->fetch();
if ($book && !resource_accessible(Database::connection(),'books',$bookId)) $book=false;

if (!$book) {
    http_response_code(404);
    exit('Không tìm thấy sách.');
}

$page = max(1,min(10000,(int)($_GET['page'] ?? 1)));
$readerPath = !empty($book['ebook_path']) ? '/ebook.php?book_id=' . $bookId . '#page=' . $page : '';

$escape = static fn(mixed $value): string => htmlspecialchars((string) ($value ?? ''), ENT_QUOTES, 'UTF-8');
$title = $escape($book['title']);
?>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Đọc giáo trình · Nexus</title>
  <link rel="icon" href="/favicon.ico?v=nexus-1" sizes="32x32">
  <link rel="icon" type="image/svg+xml" href="/favicon.svg?v=nexus-1" sizes="any">
  <link rel="stylesheet" href="/assets/reader.css">
</head>
<body>
  <main class="reader-stage">
    <?php if ($readerPath !== ''): ?>
      <iframe class="reader-frame" src="<?= $escape($readerPath) ?>" title="Đọc <?= $title ?>"></iframe>
    <?php else: ?>
      <section class="reader-empty">
        <span class="eyebrow">CHƯA CÓ FILE ĐỌC</span>
        <h2>Chưa có sách điện tử của sách đó.</h2>
        <p><?= $escape($book['summary']) ?></p>
      </section>
    <?php endif; ?>
  </main>
</body>
</html>
