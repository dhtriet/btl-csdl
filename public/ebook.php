<?php

declare(strict_types=1);

session_start();

require_once __DIR__ . '/../app/config.php';
require_once __DIR__ . '/../app/database.php';
require_once __DIR__ . '/../app/visibility.php';

if (empty($_SESSION['user'])) {
    http_response_code(401);
    header('Content-Type: text/plain; charset=utf-8');
    exit('Vui lòng đăng nhập để đọc sách điện tử.');
}

header('X-Content-Type-Options: nosniff');
header('Content-Security-Policy: frame-ancestors \'self\';');
header('Referrer-Policy: same-origin');
header('Cache-Control: private, no-store');

$bookId = filter_input(INPUT_GET, 'book_id', FILTER_VALIDATE_INT);
if (!$bookId || $bookId < 1) {
    http_response_code(400);
    header('Content-Type: text/plain; charset=utf-8');
    exit('Mã sách không hợp lệ.');
}

$statement = Database::connection()->prepare(
    'SELECT b.title, e.file_path
     FROM books b
     LEFT JOIN ebooks e ON e.book_id = b.id
     WHERE b.id = :id
     LIMIT 1'
);
$statement->execute(['id' => $bookId]);
$book = $statement->fetch();
if ($book && !resource_accessible(Database::connection(),'books',$bookId)) $book=false;

if (!$book) {
    http_response_code(404);
    header('Content-Type: text/plain; charset=utf-8');
    exit('Không tìm thấy sách.');
}

$logicalPath = (string) ($book['file_path'] ?? '');
if ($logicalPath === '') {
    http_response_code(404);
    header('Content-Type: text/plain; charset=utf-8');
    exit('Chưa có sách điện tử của sách đó.');
}

$fileName = basename($logicalPath);
$storageRoot = realpath(__DIR__ . '/../storage/ebooks');
$filePath = $storageRoot ? realpath($storageRoot . DIRECTORY_SEPARATOR . $fileName) : false;

if (!$storageRoot || !$filePath || !is_file($filePath) || !str_starts_with($filePath, $storageRoot . DIRECTORY_SEPARATOR)) {
    http_response_code(404);
    header('Content-Type: text/plain; charset=utf-8');
    exit('Không tìm thấy file sách điện tử.');
}

$extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
$contentType = $extension === 'pdf' ? 'application/pdf' : 'application/octet-stream';
$safeFileName = preg_replace('/[^A-Za-z0-9._-]+/', '-', $fileName) ?: 'ebook.' . $extension;

header('Content-Type: ' . $contentType);
header('Content-Length: ' . (string) filesize($filePath));
header('Content-Disposition: inline; filename="' . $safeFileName . '"');
header('Accept-Ranges: bytes');
readfile($filePath);
