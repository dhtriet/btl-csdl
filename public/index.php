<?php

declare(strict_types=1);

session_set_cookie_params(['httponly' => true, 'samesite' => 'Lax', 'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off']);
session_start();
date_default_timezone_set('Asia/Bangkok');

require_once __DIR__ . '/../app/config.php';
require_once __DIR__ . '/../app/database.php';
require_once __DIR__ . '/../app/integrity.php';
require_once __DIR__ . '/../app/helpers.php';
require_once __DIR__ . '/../app/resources.php';
require_once __DIR__ . '/../app/queries/books.php';
require_once __DIR__ . '/../app/assistant.php';
require_once __DIR__ . '/../app/circulation.php';
require_once __DIR__ . '/../app/extension_requests.php';
require_once __DIR__ . '/../app/resource_extensions.php';

final class ApiException extends RuntimeException
{
    public function __construct(string $message, private int $status = 422)
    {
        parent::__construct($message);
    }

    public function status(): int
    {
        return $this->status;
    }
}

$segments = path_segments();

if (($segments[0] ?? '') === 'api') {
    try {
        route_api(Database::connection(), $_SERVER['REQUEST_METHOD'] ?? 'GET', array_slice($segments, 1));
    } catch (ApiException $exception) {
        json_response(['message' => $exception->getMessage()], $exception->status());
    } catch (Throwable $exception) {
        if ($exception instanceof PDOException && ($integrity=integrity_api_error($exception))) {
            json_response(['message'=>$integrity['message']],$integrity['status']);
        }
        error_log((string) $exception);
        if ($exception instanceof PDOException && in_array($exception->errorInfo[1] ?? 0, [1205,1213], true)) {
            json_response(['message' => 'Tài nguyên đang được xử lý đồng thời. Hãy thử lại.'],409);
        }
        json_response(['message' => 'Không thể xử lý yêu cầu. Vui lòng thử lại.'],500);
    }
}

require __DIR__ . '/views/app.php';

function route_api(PDO $pdo, string $method, array $segments): void
{
    $resource = $segments[0] ?? '';
    $id = $segments[1] ?? null;
    $childId = $segments[2] ?? null;
    $action = $segments[3] ?? null;

    if (!in_array($resource, ['login','me'], true)) require_login();
    if (!in_array($method,['GET','HEAD'],true)) {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
        if ($origin !== '') {
            $parts = parse_url($origin);
            $originHost = ($parts['host'] ?? '') . (isset($parts['port']) ? ':' . $parts['port'] : '');
            if ($originHost !== ($_SERVER['HTTP_HOST'] ?? '')) throw new ApiException('Nguồn yêu cầu không hợp lệ.',403);
        }
        if ($resource !== 'login' && !hash_equals(csrf_token(), $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '')) throw new ApiException('Phiên biểu mẫu không hợp lệ. Tải lại trang và thử lại.',403);
    }
    if ($resource === 'assistant') route_assistant($pdo,$method,$id);
    if ($resource === 'manage') manage_resources($pdo,$method,$id,$childId);
    if ($resource === 'circulation') route_circulation($pdo, $method, $id, $childId, $action);
    if ($resource === 'accounts' && $id !== null && ctype_digit($id) && $method === 'GET') json_response(['data'=>account_full_detail($pdo, (int)$id)]);
    if ($method === 'GET' && (
        in_array($resource,['overdue-books','overdue-students','stats'],true)
        || ($resource==='books' && in_array($id,['overdue','returned'],true))
    )) require_staff();


    if ($resource === 'login' && $method === 'POST') {
        $body = request_body();
        $username = trim((string) ($body['username'] ?? ''));
        $password = (string) ($body['password'] ?? '');

        $query = $pdo->prepare(
            'SELECT a.ma, a.ten_dang_nhap, a.mat_khau, a.ho_ten, a.vai_tro,
                    s.ma AS ma_ho_so_sinh_vien, s.ma_sinh_vien, s.khoa, s.lop,
                    l.ma AS ma_ho_so_thu_thu, l.ma_thu_thu
             FROM tai_khoan a
             LEFT JOIN sinh_vien s ON s.ma_tai_khoan = a.ma
             LEFT JOIN thu_thu l ON l.ma_tai_khoan = a.ma
             WHERE a.ten_dang_nhap = :username
             LIMIT 1'
        );
        $query->execute(['username' => $username]);
        $account = $query->fetch();

        $stored = $account ? (string)$account['password'] : '';
        $hashed = password_get_info($stored)['algo'] !== null;
        $valid = $account && ($hashed ? password_verify($password,$stored) : hash_equals($stored,$password));
        if (!$valid) {
            json_response(['message' => 'Ten dang nhap hoac mat khau khong dung.'], 422);
        }

        if (!$hashed || password_needs_rehash($stored,PASSWORD_BCRYPT)) {
            $upgrade=$pdo->prepare('UPDATE tai_khoan SET mat_khau = ? WHERE ma = ? AND mat_khau = ?');
            $upgrade->execute([password_hash($password,PASSWORD_BCRYPT),$account['id'],$stored]);
        }
        session_regenerate_id(true);
        $_SESSION['csrf_token']=bin2hex(random_bytes(32));
        $_SESSION['user'] = [
            'id' => (int) $account['id'],
            'username' => $account['username'],
            'name' => $account['full_name'],
            'role' => $account['role'],
            'student_id' => $account['student_id'] ? (int) $account['student_id'] : null,
            'student_code' => $account['student_code'],
            'faculty' => $account['faculty'],
            'class_name' => $account['class_name'],
            'librarian_id' => $account['librarian_id'] ? (int) $account['librarian_id'] : null,
            'librarian_code' => $account['librarian_code'],
        ];

        json_response(['user' => $_SESSION['user'], 'csrf_token' => csrf_token()]);
    }

    if ($resource === 'logout' && $method === 'POST') {
        $_SESSION = [];
        session_destroy();
        json_response(['ok' => true]);
    }

    if ($resource === 'me' && $method === 'GET') {
        $user = current_user();
        if ($user && !empty($user['id'])) {
            $statement = $pdo->prepare(
                'SELECT a.ho_ten, s.khoa, s.lop
                 FROM tai_khoan a LEFT JOIN sinh_vien s ON s.ma_tai_khoan = a.ma
                 WHERE a.ma = :id LIMIT 1'
            );
            $statement->execute(['id' => $user['id']]);
            if ($account = $statement->fetch()) {
                $_SESSION['user']['name'] = $account['full_name'];
                $_SESSION['user']['faculty'] = $account['faculty'];
                $_SESSION['user']['class_name'] = $account['class_name'];
                $user = $_SESSION['user'];
            }
        }
        json_response(['user' => $user, 'csrf_token' => csrf_token()]);
    }

    if ($resource === 'profile' && $method === 'GET') {
        $user = require_login();
        json_response(['data' => profile_data($pdo, (int) $user['id'])]);
    }

    if ($resource === 'profile' && $method === 'PUT') {
        $user = require_login();
        json_response(['data' => update_profile($pdo, (int) $user['id'])]);
    }

    if ($resource === 'dashboard' && $method === 'GET') {
        json_response(['data' => dashboard_data($pdo)]);
    }

    if ($resource === 'books' && $method === 'GET' && $id === null) {
        json_response(['data' => books_list($pdo)]);
    }

    if ($resource === 'books' && $method === 'GET' && $id === 'returned') {
        json_response(['data' => returned_books($pdo)]);
    }

    if ($resource === 'books' && $method === 'GET' && $id === 'overdue') {
        json_response(['data' => overdue_books($pdo)]);
    }

    if ($resource === 'books' && $method === 'GET' && ctype_digit((string) $id) && $childId === 'read') {
        require_login();
        json_response(['data' => ebook_reader_data($pdo, (int) $id)]);
    }

    if ($resource === 'books' && $method === 'GET' && ctype_digit((string) $id)) {
        json_response(['data' => book_detail($pdo, (int) $id)]);
    }

    if ($resource === 'loan-details' && $method === 'POST' && ctype_digit((string) $id) && $childId === 'extend') {
        throw new ApiException('Gia hạn cần có yêu cầu của sinh viên và được thủ thư duyệt.',403);
    }

    if ($resource==='resource-extension-requests' && $method==='GET') json_response(['data'=>resource_extensions_list($pdo)]);
    if ($resource==='resource-extension-requests' && $method==='POST' && $id===null) json_response(['data'=>resource_extension_create($pdo,request_body())],201);
    if ($resource==='resource-extension-requests' && $method==='POST' && ctype_digit((string)$id) && $childId==='review') json_response(['data'=>resource_extension_review($pdo,(int)$id,request_body())]);
    if ($resource==='extension-requests' && $method==='GET') json_response(['data'=>array_merge(extension_requests_list($pdo),resource_extensions_list($pdo))]);
    if ($resource==='extension-requests' && $method==='POST' && $id===null) {
        $body=request_body();
        json_response(['data'=>extension_request_create($pdo,resource_int($body,'loan_detail_id',1,PHP_INT_MAX),$body)],201);
    }
    if ($resource==='extension-requests' && $method==='POST' && ctype_digit((string)$id) && $childId==='review') json_response(['data'=>extension_request_review($pdo,(int)$id,request_body())]);

    if ($resource === 'book-loan-requests' && $method === 'POST') {
        json_response(['data' => create_book_loan_request($pdo)], 201);
    }

    if ($resource === 'overdue-books' && $method === 'GET') {
        json_response(['data' => overdue_books($pdo)]);
    }

    if ($resource === 'overdue-students' && $method === 'GET') {
        json_response(['data' => overdue_students($pdo)]);
    }

    if ($resource === 'accounts' && $method === 'GET') {
        if ((current_user()['role'] ?? null) !== 'admin') {
            json_response(['message' => 'Chi quan tri vien moi xem duoc danh sach tai khoan.'], 403);
        }
        json_response(['data' => accounts_list($pdo)]);
    }

    if ($resource === 'students' && $method === 'GET' && $id !== null) {
        json_response(['data' => student_history($pdo, $id)]);
    }

    if ($resource === 'loan-receipts' && $method === 'GET' && ctype_digit((string) $id)) {
        json_response(['data' => loan_receipt_detail($pdo, (int) $id)]);
    }

    if ($resource === 'rooms' && $id === 'available' && $method === 'GET') {
        json_response(['data' => available_rooms($pdo)]);
    }

    if ($resource === 'room-schedule' && $method === 'GET') {
        require_login();
        json_response(['data' => room_schedule($pdo)]);
    }

    if ($resource === 'rooms' && $method === 'GET' && ctype_digit((string) $id) && $childId === 'schedule') {
        require_login();
        json_response(['data' => room_schedule($pdo, (int) $id)]);
    }

    if ($resource === 'room-requests' && $method === 'GET') {
        json_response(['data' => room_requests($pdo)]);
    }

    if ($resource === 'room-requests' && $method === 'POST') {
        json_response(['data' => create_room_request($pdo)], 201);
    }

    if ($resource === 'borrow-requests' && $id === 'mine' && $method === 'GET') {
        $user = require_role('student');
        json_response(['data' => student_borrow_requests($pdo, (int) $user['student_id'])]);
    }

    if ($resource === 'borrow-requests' && $id === 'pending' && $method === 'GET') {
        require_role('librarian');
        json_response(['data' => pending_borrow_requests($pdo)]);
    }

    if ($resource === 'borrow-requests' && $id === 'history' && $method === 'GET') {
        require_role('librarian');
        json_response(['data' => reviewed_borrow_requests($pdo)]);
    }

    if (
        $resource === 'borrow-requests'
        && in_array($id, ['book', 'equipment', 'room'], true)
        && ctype_digit((string) $childId)
        && $action === 'review'
        && $method === 'POST'
    ) {
        json_response(['data' => review_borrow_request($pdo, (string) $id, (int) $childId)]);
    }

    if ($resource === 'equipment' && $id === 'available' && $method === 'GET') {
        json_response(['data' => available_equipment($pdo)]);
    }

    if ($resource === 'equipment' && $id === 'overdue' && $method === 'GET') {
        $user = require_login();
        if ($user['role'] === 'student') {
            $q=$pdo->prepare('SELECT e.ten, eld.so_luong, DATEDIFF(CURDATE(),eld.han_tra) AS overdue_days FROM chi_tiet_muon_thiet_bi eld JOIN phieu_muon_thiet_bi el ON el.ma=eld.ma_phieu_muon_thiet_bi JOIN thiet_bi e ON e.ma=eld.ma_thiet_bi WHERE el.ma_ho_so_sinh_vien=? AND eld.ngay_tra IS NULL AND eld.han_tra<CURDATE() ORDER BY eld.han_tra');
            $q->execute([$user['student_id']]);
            json_response(['data'=>$q->fetchAll()]);
        }
        json_response(['data' => overdue_equipment($pdo)]);
    }

    if ($resource === 'equipment' && $id === 'returned' && $method === 'GET') {
        require_role('librarian');
        json_response(['data' => returned_equipment($pdo)]);
    }

    if ($resource === 'returns' && $method === 'GET' && $id === 'books') {
        require_role('librarian');
        json_response(['data' => active_book_loans($pdo)]);
    }

    if ($resource === 'returns' && $method === 'GET' && $id === 'equipment') {
        require_role('librarian');
        json_response(['data' => active_equipment_loans($pdo)]);
    }

    if ($resource === 'returns' && $method === 'GET' && $id === 'rooms') {
        require_role('librarian');
        json_response(['data' => room_usage_history($pdo)]);
    }

    if (
        $resource === 'returns'
        && in_array($id, ['books', 'equipment', 'rooms'], true)
        && ctype_digit((string) $childId)
        && $method === 'POST'
    ) {
        require_role('librarian');
        $returnData = match ($id) {
            'books' => mark_book_return($pdo, (int) $childId),
            'equipment' => mark_equipment_return($pdo, (int) $childId),
            'rooms' => mark_room_completed($pdo, (int) $childId),
        };
        json_response(['data' => $returnData]);
    }

    if ($resource === 'equipment-loan-requests' && $method === 'POST') {
        json_response(['data' => create_equipment_loan_request($pdo)], 201);
    }

    if ($resource === 'stats' && $id === 'books' && $method === 'GET') {
        json_response(['data' => top_books($pdo)]);
    }

    if ($resource === 'stats' && $id === 'rooms' && $method === 'GET') {
        json_response(['data' => top_rooms($pdo)]);
    }

    if ($resource === 'stats' && $id === 'equipment' && $method === 'GET') {
        json_response(['data' => top_equipment($pdo)]);
    }

    json_response(['message' => 'Khong tim thay API.'], 404);
}

function profile_data(PDO $pdo, int $accountId): array
{
    $statement = $pdo->prepare(
        'SELECT a.ma, a.ten_dang_nhap, a.ho_ten, a.ngay_sinh, a.thu_dien_tu, a.so_dien_thoai,
                a.dia_chi, a.thoi_diem_dang_ky, a.vai_tro,
                s.ma_sinh_vien, s.khoa, s.lop,
                l.ma_thu_thu
         FROM tai_khoan a
         LEFT JOIN sinh_vien s ON s.ma_tai_khoan = a.ma
         LEFT JOIN thu_thu l ON l.ma_tai_khoan = a.ma
         WHERE a.ma = :id
         LIMIT 1'
    );
    $statement->execute(['id' => $accountId]);
    $profile = $statement->fetch();
    if (!$profile) {
        throw new ApiException('Khong tim thay thong tin ca nhan.', 404);
    }
    return $profile;
}

function update_profile(PDO $pdo, int $accountId): array
{
    $body = request_body();
    $fullName = trim((string) ($body['full_name'] ?? ''));
    $dateOfBirth = trim((string) ($body['date_of_birth'] ?? ''));
    $email = trim((string) ($body['email'] ?? ''));
    $phone = trim((string) ($body['phone'] ?? ''));
    $address = trim((string) ($body['address'] ?? ''));
    $faculty = trim((string) ($body['faculty'] ?? ''));
    $className = trim((string) ($body['class_name'] ?? ''));

    if ($fullName === '' || text_length($fullName) > 120) {
        throw new ApiException('Ho ten khong hop le.');
    }
    if ($dateOfBirth !== '') {
        $date = DateTime::createFromFormat('!Y-m-d', $dateOfBirth);
        if (!$date || $date->format('Y-m-d') !== $dateOfBirth) {
            throw new ApiException('Ngay sinh khong hop le.');
        }
    } else {
        $dateOfBirth = null;
    }
    if ($email !== '' && (!filter_var($email, FILTER_VALIDATE_EMAIL) || text_length($email) > 120)) {
        throw new ApiException('Email khong hop le.');
    }
    if (text_length($phone) > 30 || text_length($address) > 255 || text_length($faculty) > 120 || text_length($className) > 80) {
        throw new ApiException('Thong tin ca nhan vuot qua do dai cho phep.');
    }

    $pdo->beginTransaction();
    try {
        $account = $pdo->prepare(
            'UPDATE tai_khoan
             SET ho_ten = :full_name, ngay_sinh = :date_of_birth, thu_dien_tu = :email,
                 so_dien_thoai = :phone, dia_chi = :address
             WHERE ma = :id'
        );
        $account->execute([
            'full_name' => $fullName,
            'date_of_birth' => $dateOfBirth,
            'email' => $email === '' ? null : $email,
            'phone' => $phone === '' ? null : $phone,
            'address' => $address === '' ? null : $address,
            'id' => $accountId,
        ]);

        $student = $pdo->prepare('UPDATE sinh_vien SET khoa = :faculty, lop = :class_name WHERE ma_tai_khoan = :account_id');
        $student->execute([
            'faculty' => $faculty,
            'class_name' => $className,
            'account_id' => $accountId,
        ]);
        $pdo->commit();
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }

    $profile = profile_data($pdo, $accountId);
    if (isset($_SESSION['user'])) {
        $_SESSION['user']['name'] = $profile['full_name'];
        $_SESSION['user']['faculty'] = $profile['faculty'];
        $_SESSION['user']['class_name'] = $profile['class_name'];
    }
    return $profile;
}

function text_length(string $value): int
{
    return function_exists('mb_strlen') ? mb_strlen($value) : strlen($value);
}

function dashboard_data(PDO $pdo): array
{
    $user = require_login();
    if ($user['role'] === 'student') {
        $studentId = (int) $user['student_id'];
        $loans = $pdo->prepare(
            'SELECT \'book\' AS resource_type, b.ten_sach AS resource_name, ld.han_tra, 1 AS so_luong,
                    (ld.han_tra < CURDATE()) AS overdue
             FROM chi_tiet_muon_sach ld
             JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
             JOIN ban_sach bc ON bc.ma = ld.ma_ban_sach
             JOIN dau_sach b ON b.ma = bc.ma_dau_sach
             WHERE lr.ma_ho_so_sinh_vien = :book_student AND ld.ngay_tra IS NULL
             UNION ALL
             SELECT \'equipment\' AS resource_type, e.ten AS resource_name, eld.han_tra, eld.so_luong,
                    (eld.han_tra < CURDATE()) AS overdue
             FROM chi_tiet_muon_thiet_bi eld
             JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
             JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
             WHERE el.ma_ho_so_sinh_vien = :equipment_student AND eld.ngay_tra IS NULL
             ORDER BY han_tra ASC'
        );
        $loans->execute(['book_student' => $studentId, 'equipment_student' => $studentId]);
        $activeLoans = $loans->fetchAll();
        $rooms = $pdo->prepare(
            'SELECT rr.ma, r.ten, rr.ngay_su_dung, rr.gio_bat_dau, rr.gio_ket_thuc, rr.trang_thai
             FROM yeu_cau_dat_phong rr JOIN phong r ON r.ma = rr.ma_phong
             WHERE rr.ma_ho_so_sinh_vien = :student AND rr.trang_thai IN (\'pending\', \'approved\')
               AND (rr.ngay_su_dung > CURDATE() OR (rr.ngay_su_dung = CURDATE() AND rr.gio_ket_thuc > CURTIME()))
             ORDER BY rr.ngay_su_dung, rr.gio_bat_dau'
        );
        $rooms->execute(['student' => $studentId]);
        $requests = student_borrow_requests($pdo, $studentId);
        return [
            'active_loans' => $activeLoans,
            'overdue_count' => count(array_filter($activeLoans, static fn(array $loan): bool => (bool) $loan['overdue'])),
            'upcoming_rooms' => $rooms->fetchAll(),
            'pending_requests' => count(array_filter($requests, static fn(array $request): bool => $request['status'] === 'pending')),
            'recent_requests' => array_slice($requests, 0, 5),
            'top_books' => top_books($pdo, 5),
        ];
    }
    return resource_dashboard_counts($pdo) + [
        'recent_requests' => pending_borrow_requests($pdo, 5),
        'top_books' => top_books($pdo, 5),
    ];
}

function books_list(PDO $pdo): array
{
    return catalog_books(
        $pdo,
        query_string('search'),
        query_string('language'),
        query_string('year')
    );
}

function book_detail(PDO $pdo, int $bookId): array
{
    if (!resource_accessible($pdo,'books',$bookId)) throw new ApiException('Không tìm thấy sách.',404);
    $statement = $pdo->prepare(
        'SELECT b.*, p.ten AS publisher, p.dia_chi AS publisher_address,
                p.thu_dien_tu AS publisher_email
         FROM dau_sach b JOIN nha_xuat_ban p ON p.ma = b.ma_nha_xuat_ban
         WHERE b.ma = :id'
    );
    $statement->execute(['id' => $bookId]);
    $book = $statement->fetch();
    if (!$book) {
        json_response(['message' => 'Khong tim thay sach.'], 404);
    }

    $book['authors'] = book_relation_names($pdo, 'authors', $bookId);
    $book['genres'] = book_relation_names($pdo, 'genres', $bookId);
    $book['keywords'] = book_relation_names($pdo, 'keywords', $bookId);

    $ebook = $pdo->prepare('SELECT ma, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep FROM sach_dien_tu WHERE ma_dau_sach = :id');
    $ebook->execute(['id' => $bookId]);
    $book['ebook'] = $ebook->fetch() ?: null;

    $copyVisibility=resource_staff_access()?'':' AND hien_thi = 1';
    $copies = $pdo->prepare('SELECT ma, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai FROM ban_sach WHERE ma_dau_sach = :id AND thoi_diem_xoa IS NULL'.$copyVisibility.' ORDER BY ma_vach');
    $copies->execute(['id' => $bookId]);
    $book['copies'] = $copies->fetchAll();

    return $book;
}

function ebook_reader_data(PDO $pdo, int $bookId): array
{
    $book = book_detail($pdo, $bookId);
    if (!$book['ebook']) {
        throw new ApiException('Cuon sach nay chua co sach dien tu.', 404);
    }

    $book['reader_url'] = $book['ebook']['file_path'] ?: null;
    return [
        'book' => $book,
        'ebook' => $book['ebook'],
    ];
}

function request_note(array $body): ?string
{
    $note = trim((string) ($body['note'] ?? ''));
    return $note === '' ? null : substr($note, 0, 255);
}

function requested_due_date(mixed $value): string
{
    $dateString = trim((string) $value);
    $date = DateTime::createFromFormat('!Y-m-d', $dateString);
    if (!$date || $date->format('Y-m-d') !== $dateString || $dateString <= date('Y-m-d')) {
        throw new ApiException('Han tra phai la mot ngay sau hom nay.');
    }

    return $dateString;
}

function book_request_items(array $body): array
{
    $items = $body['items'] ?? null;
    if (!is_array($items) || $items === []) {
        throw new ApiException('Hay chon it nhat mot cuon sach.');
    }

    $normalized = [];
    foreach ($items as $item) {
        $bookId = is_array($item) ? (int) ($item['book_id'] ?? 0) : 0;
        $quantity = is_array($item) ? (int) ($item['quantity'] ?? 1) : 1;
        if ($bookId < 1 || $quantity < 1 || isset($normalized[$bookId])) {
            throw new ApiException('Danh sach sach muon khong hop le.');
        }

        $normalized[$bookId] = [
            'book_id' => $bookId,
            'quantity' => $quantity,
            'requested_due_date' => requested_due_date($item['requested_due_date'] ?? ''),
        ];
    }

    return array_values($normalized);
}

function equipment_request_items(array $body): array
{
    $items = $body['items'] ?? null;
    if (!is_array($items) || $items === []) {
        throw new ApiException('Hay chon it nhat mot thiet bi.');
    }

    $normalized = [];
    foreach ($items as $item) {
        $equipmentId = is_array($item) ? (int) ($item['equipment_id'] ?? 0) : 0;
        $quantity = is_array($item) ? (int) ($item['quantity'] ?? 0) : 0;
        if ($equipmentId < 1 || $quantity < 1 || isset($normalized[$equipmentId])) {
            throw new ApiException('Danh sach thiet bi muon khong hop le.');
        }

        $normalized[$equipmentId] = [
            'equipment_id' => $equipmentId,
            'quantity' => $quantity,
            'requested_due_date' => requested_due_date($item['requested_due_date'] ?? ''),
        ];
    }

    return array_values($normalized);
}

function create_book_loan_request(PDO $pdo): array
{
    $user = require_role('student');
    if (empty($user['student_id'])) {
        throw new ApiException('Khong tim thay thong tin sinh vien.', 403);
    }

    $body = request_body();
    $items = book_request_items($body);
    $checkBook = $pdo->prepare(
        'SELECT b.ma, COUNT(c.ma) AS available_count
         FROM dau_sach b
         LEFT JOIN ban_sach c ON c.ma_dau_sach = b.ma AND c.trang_thai = \'available\' AND c.hien_thi = 1 AND c.thoi_diem_xoa IS NULL
         WHERE b.ma = :id AND b.hien_thi = 1 AND b.thoi_diem_xoa IS NULL
         GROUP BY b.ma'
    );
    foreach ($items as $item) {
        $checkBook->execute(['id' => $item['book_id']]);
        $book = $checkBook->fetch();
        if (!$book || (int) $book['available_count'] < $item['quantity']) {
            throw new ApiException('Mot hoac nhieu sach khong con du so luong ban sao san sang.');
        }
    }

    $pdo->beginTransaction();
    try {
        $guard = $pdo->prepare(
            'SELECT ma FROM dau_sach WHERE ma = ? AND hien_thi = 1 AND thoi_diem_xoa IS NULL FOR UPDATE'
        );
        foreach ($items as $item) {
            $guard->execute([$item['book_id']]);
            if (!$guard->fetchColumn()) throw new ApiException('Đầu sách đã ngừng hiển thị. Hãy tải lại kho sách.',409);
        }
        $request = $pdo->prepare('INSERT INTO yeu_cau_muon_sach (ma_ho_so_sinh_vien, ghi_chu) VALUES (:student_id, :note)');
        $request->execute(['student_id' => $user['student_id'], 'note' => request_note($body)]);
        $requestId = (int) $pdo->lastInsertId();

        $detail = $pdo->prepare(
            'INSERT INTO chi_tiet_yeu_cau_muon_sach (ma_yeu_cau, ma_dau_sach, so_luong, han_tra_de_nghi)
             VALUES (:request_id, :book_id, :quantity, :requested_due_date)'
        );
        foreach ($items as $item) {
            $detail->execute(['request_id' => $requestId] + $item);
        }

        $pdo->commit();
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }

    return ['id' => $requestId, 'status' => 'pending', 'message' => 'Da gui yeu cau muon sach.'];
}

function create_equipment_loan_request(PDO $pdo): array
{
    $user = require_role('student');
    if (empty($user['student_id'])) {
        throw new ApiException('Khong tim thay thong tin sinh vien.', 403);
    }

    $body = request_body();
    $items = equipment_request_items($body);
    $checkEquipment = $pdo->prepare(
        'SELECT ma
         FROM thiet_bi
         WHERE ma = :id AND trang_thai = \'available\' AND hien_thi=1 AND thoi_diem_xoa IS NULL AND so_luong_san_sang >= :quantity'
    );
    foreach ($items as $item) {
        $checkEquipment->execute(['id' => $item['equipment_id'], 'quantity' => $item['quantity']]);
        if (!$checkEquipment->fetch()) {
            throw new ApiException('Mot hoac nhieu thiet bi khong du so luong san sang.');
        }
    }

    $pdo->beginTransaction();
    try {
        $guard = $pdo->prepare(
            'SELECT ma FROM thiet_bi WHERE ma = ? AND hien_thi = 1 AND thoi_diem_xoa IS NULL FOR UPDATE'
        );
        foreach ($items as $item) {
            $guard->execute([$item['equipment_id']]);
            if (!$guard->fetchColumn()) throw new ApiException('Thiết bị đã ngừng hiển thị. Hãy tải lại danh sách.',409);
        }
        $request = $pdo->prepare('INSERT INTO yeu_cau_muon_thiet_bi (ma_ho_so_sinh_vien, ghi_chu) VALUES (:student_id, :note)');
        $request->execute(['student_id' => $user['student_id'], 'note' => request_note($body)]);
        $requestId = (int) $pdo->lastInsertId();

        $detail = $pdo->prepare(
            'INSERT INTO chi_tiet_yeu_cau_muon_thiet_bi (ma_yeu_cau, ma_thiet_bi, so_luong, han_tra_de_nghi)
             VALUES (:request_id, :equipment_id, :quantity, :requested_due_date)'
        );
        foreach ($items as $item) {
            $detail->execute(['request_id' => $requestId] + $item);
        }

        $pdo->commit();
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }

    return ['id' => $requestId, 'status' => 'pending', 'message' => 'Da gui yeu cau muon thiet bi.'];
}

function request_time(string $value): string
{
    if ($value === '24:00') {
        return $value;
    }

    if (!preg_match('/^(?:[01][0-9]|2[0-3]):[0-5][0-9]$/', $value)) {
        throw new ApiException('Khung giờ sử dụng phải từ 00:00 đến 24:00.');
    }

    return $value;
}

function create_room_request(PDO $pdo): array
{
    $user = require_role('student');
    if (empty($user['student_id'])) {
        throw new ApiException('Khong tim thay thong tin sinh vien.', 403);
    }

    $body = request_body();
    $roomId = (int) ($body['room_id'] ?? 0);
    $useDate = trim((string) ($body['use_date'] ?? ''));
    $date = DateTime::createFromFormat('!Y-m-d', $useDate);
    if ($roomId < 1 || !$date || $date->format('Y-m-d') !== $useDate || $useDate < date('Y-m-d')) {
        throw new ApiException('Thong tin dat phong khong hop le.');
    }

    $startTime = request_time(trim((string) ($body['start_time'] ?? '')));
    $endTime = request_time(trim((string) ($body['end_time'] ?? '')));
    if ($startTime >= $endTime) {
        throw new ApiException('Gio ket thuc phai sau gio bat dau.');
    }

    $purpose = substr(trim((string) ($body['purpose'] ?? '')), 0, 255);
    if ($purpose === '') {
        throw new ApiException('Hay nhap muc dich su dung phong.');
    }

    $pdo->beginTransaction();
    try {
        $room = $pdo->prepare('SELECT ma FROM phong WHERE ma = :id AND trang_thai = \'available\' AND hien_thi=1 AND thoi_diem_xoa IS NULL FOR UPDATE');
        $room->execute(['id' => $roomId]);
        if (!$room->fetch()) {
            throw new ApiException('Phong nay khong con san sang.');
        }

        $conflict = $pdo->prepare(
            'SELECT 1 FROM yeu_cau_dat_phong
             WHERE ma_phong = :room_id AND ngay_su_dung = :use_date
               AND trang_thai IN (\'pending\', \'approved\')
               AND gio_bat_dau < :end_time AND gio_ket_thuc > :start_time
             LIMIT 1'
        );
        $conflict->execute([
            'room_id' => $roomId,
            'use_date' => $useDate,
            'start_time' => $startTime,
            'end_time' => $endTime,
        ]);
        if ($conflict->fetchColumn() !== false) {
            throw new ApiException('Khung gio nay da co nguoi dat hoac dang cho duyet. Vui long chon khung gio khac.');
        }

        $request = $pdo->prepare(
            'INSERT INTO yeu_cau_dat_phong (ma_ho_so_sinh_vien, ma_phong, ngay_su_dung, gio_bat_dau, gio_ket_thuc, muc_dich, trang_thai)
             VALUES (:student_id, :room_id, :use_date, :start_time, :end_time, :purpose, \'pending\')'
        );
        $request->execute([
            'student_id' => $user['student_id'],
            'room_id' => $roomId,
            'use_date' => $useDate,
            'start_time' => $startTime,
            'end_time' => $endTime,
            'purpose' => $purpose,
        ]);
        $requestId = (int) $pdo->lastInsertId();
        $pdo->commit();
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }

    return ['id' => $requestId, 'status' => 'pending', 'message' => 'Da gui yeu cau dat phong.'];
}

function student_borrow_requests(PDO $pdo, int $studentId): array
{
    $statement = $pdo->prepare(
        'SELECT \'book\' AS request_type, r.ma, r.thoi_diem_gui_yeu_cau, r.trang_thai, r.ghi_chu, r.ghi_chu_xet_duyet,
                GROUP_CONCAT(CONCAT(b.ten_sach, \' · Số lượng: \', i.so_luong, \' (hạn \', DATE_FORMAT(i.han_tra_de_nghi, \'%d/%m/%Y\'), \')\') ORDER BY i.ma SEPARATOR \' | \') AS items
         FROM yeu_cau_muon_sach r
         JOIN chi_tiet_yeu_cau_muon_sach i ON i.ma_yeu_cau = r.ma
         JOIN dau_sach b ON b.ma = i.ma_dau_sach
         WHERE r.ma_ho_so_sinh_vien = :book_student_id
         GROUP BY r.ma, r.thoi_diem_gui_yeu_cau, r.trang_thai, r.ghi_chu, r.ghi_chu_xet_duyet
         UNION ALL
         SELECT \'equipment\' AS request_type, r.ma, r.thoi_diem_gui_yeu_cau, r.trang_thai, r.ghi_chu, r.ghi_chu_xet_duyet,
                GROUP_CONCAT(CONCAT(e.ten, \' x\', i.so_luong, \' (hạn \', DATE_FORMAT(i.han_tra_de_nghi, \'%d/%m/%Y\'), \')\') ORDER BY i.ma SEPARATOR \' | \') AS items
         FROM yeu_cau_muon_thiet_bi r
         JOIN chi_tiet_yeu_cau_muon_thiet_bi i ON i.ma_yeu_cau = r.ma
         JOIN thiet_bi e ON e.ma = i.ma_thiet_bi
         WHERE r.ma_ho_so_sinh_vien = :equipment_student_id
         GROUP BY r.ma, r.thoi_diem_gui_yeu_cau, r.trang_thai, r.ghi_chu, r.ghi_chu_xet_duyet
         UNION ALL
         SELECT \'room\' AS request_type, rr.ma, rr.thoi_diem_tao AS thoi_diem_gui_yeu_cau, rr.trang_thai,
                NULL AS ghi_chu, NULL AS ghi_chu_xet_duyet,
                CONCAT(r.ten, \' - \', DATE_FORMAT(rr.ngay_su_dung, \'%d/%m/%Y\'), \' \',
                       TIME_FORMAT(rr.gio_bat_dau, \'%H:%i\'), \'-\', TIME_FORMAT(rr.gio_ket_thuc, \'%H:%i\'),
                       \' (\', rr.muc_dich, \')\') AS items
         FROM yeu_cau_dat_phong rr
         JOIN phong r ON r.ma = rr.ma_phong
         WHERE rr.ma_ho_so_sinh_vien = :room_student_id
         ORDER BY thoi_diem_gui_yeu_cau DESC'
    );
    $statement->execute([
        'book_student_id' => $studentId,
        'equipment_student_id' => $studentId,
        'room_student_id' => $studentId,
    ]);
    return $statement->fetchAll();
}

function pending_borrow_requests(PDO $pdo, int $limit = 50): array
{
    $limit = max(1, min($limit, 100));
    $statement = $pdo->prepare(
        'SELECT \'book\' AS request_type, r.ma, r.thoi_diem_gui_yeu_cau, \'Mượn sách\' AS request_label,
                a.ho_ten AS student_name, s.ma_sinh_vien,
                GROUP_CONCAT(CONCAT(b.ten_sach, \' · Số lượng: \', i.so_luong, \' (hạn \', DATE_FORMAT(i.han_tra_de_nghi, \'%d/%m/%Y\'), \')\') ORDER BY i.ma SEPARATOR \' | \') AS items
         FROM yeu_cau_muon_sach r
         JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         JOIN chi_tiet_yeu_cau_muon_sach i ON i.ma_yeu_cau = r.ma
         JOIN dau_sach b ON b.ma = i.ma_dau_sach
         WHERE r.trang_thai = \'pending\'
         GROUP BY r.ma, r.thoi_diem_gui_yeu_cau, a.ho_ten, s.ma_sinh_vien
         UNION ALL
         SELECT \'equipment\' AS request_type, r.ma, r.thoi_diem_gui_yeu_cau, \'Mượn thiết bị\' AS request_label,
                a.ho_ten AS student_name, s.ma_sinh_vien,
                GROUP_CONCAT(CONCAT(e.ten, \' x\', i.so_luong, \' (hạn \', DATE_FORMAT(i.han_tra_de_nghi, \'%d/%m/%Y\'), \')\') ORDER BY i.ma SEPARATOR \' | \') AS items
         FROM yeu_cau_muon_thiet_bi r
         JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         JOIN chi_tiet_yeu_cau_muon_thiet_bi i ON i.ma_yeu_cau = r.ma
         JOIN thiet_bi e ON e.ma = i.ma_thiet_bi
         WHERE r.trang_thai = \'pending\'
         GROUP BY r.ma, r.thoi_diem_gui_yeu_cau, a.ho_ten, s.ma_sinh_vien
         UNION ALL
         SELECT \'room\' AS request_type, rr.ma, rr.thoi_diem_tao AS thoi_diem_gui_yeu_cau, \'Đặt phòng\' AS request_label,
                a.ho_ten AS student_name, s.ma_sinh_vien,
                CONCAT(r.ten, \' - \', DATE_FORMAT(rr.ngay_su_dung, \'%d/%m/%Y\'), \' \', TIME_FORMAT(rr.gio_bat_dau, \'%H:%i\'), \'-\', TIME_FORMAT(rr.gio_ket_thuc, \'%H:%i\'), \' (\', rr.muc_dich, \')\') AS items
         FROM yeu_cau_dat_phong rr
         JOIN sinh_vien s ON s.ma = rr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         JOIN phong r ON r.ma = rr.ma_phong
         WHERE rr.trang_thai = \'pending\'
         ORDER BY thoi_diem_gui_yeu_cau ASC
         LIMIT :limit'
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function reviewed_borrow_requests(PDO $pdo, int $limit = 100): array
{
    $limit = max(1, min($limit, 200));
    $statement = $pdo->prepare(
        'SELECT * FROM (
            SELECT \'book\' AS request_type, r.ma, r.thoi_diem_gui_yeu_cau, r.thoi_diem_xet_duyet, r.trang_thai,
                   r.ghi_chu AS request_note, r.ghi_chu_xet_duyet,
                   \'Mượn sách\' AS request_label, a.ho_ten AS student_name, s.ma_sinh_vien,
                   GROUP_CONCAT(CONCAT(b.ten_sach, \' · Số lượng: \', i.so_luong, \' (hạn \', DATE_FORMAT(i.han_tra_de_nghi, \'%d/%m/%Y\'), \')\') ORDER BY i.ma SEPARATOR \' | \') AS items,
                   la.ho_ten AS librarian_name
            FROM yeu_cau_muon_sach r
            JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
            JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
            LEFT JOIN thu_thu l ON l.ma = r.ma_ho_so_thu_thu
            LEFT JOIN tai_khoan la ON la.ma = l.ma_tai_khoan
            JOIN chi_tiet_yeu_cau_muon_sach i ON i.ma_yeu_cau = r.ma
            JOIN dau_sach b ON b.ma = i.ma_dau_sach
            WHERE r.trang_thai IN (\'approved\', \'rejected\')
            GROUP BY r.ma, r.thoi_diem_gui_yeu_cau, r.thoi_diem_xet_duyet, r.trang_thai, r.ghi_chu, r.ghi_chu_xet_duyet,
                     a.ho_ten, s.ma_sinh_vien, la.ho_ten
            UNION ALL
            SELECT \'equipment\' AS request_type, r.ma, r.thoi_diem_gui_yeu_cau, r.thoi_diem_xet_duyet, r.trang_thai,
                   r.ghi_chu AS request_note, r.ghi_chu_xet_duyet,
                   \'Mượn thiết bị\' AS request_label, a.ho_ten AS student_name, s.ma_sinh_vien,
                   GROUP_CONCAT(CONCAT(e.ten, \' x\', i.so_luong, \' (hạn \', DATE_FORMAT(i.han_tra_de_nghi, \'%d/%m/%Y\'), \')\') ORDER BY i.ma SEPARATOR \' | \') AS items,
                   la.ho_ten AS librarian_name
            FROM yeu_cau_muon_thiet_bi r
            JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
            JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
            LEFT JOIN thu_thu l ON l.ma = r.ma_ho_so_thu_thu
            LEFT JOIN tai_khoan la ON la.ma = l.ma_tai_khoan
            JOIN chi_tiet_yeu_cau_muon_thiet_bi i ON i.ma_yeu_cau = r.ma
            JOIN thiet_bi e ON e.ma = i.ma_thiet_bi
            WHERE r.trang_thai IN (\'approved\', \'rejected\')
            GROUP BY r.ma, r.thoi_diem_gui_yeu_cau, r.thoi_diem_xet_duyet, r.trang_thai, r.ghi_chu, r.ghi_chu_xet_duyet,
                     a.ho_ten, s.ma_sinh_vien, la.ho_ten
            UNION ALL
            SELECT \'room\' AS request_type, rr.ma, rr.thoi_diem_tao AS thoi_diem_gui_yeu_cau, rr.thoi_diem_xet_duyet,
                   rr.trang_thai, NULL AS request_note, rr.ghi_chu_xet_duyet,
                   \'Đặt phòng\' AS request_label, a.ho_ten AS student_name, s.ma_sinh_vien,
                   CONCAT(r.ten, \' - \', DATE_FORMAT(rr.ngay_su_dung, \'%d/%m/%Y\'), \' \',
                          TIME_FORMAT(rr.gio_bat_dau, \'%H:%i\'), \'-\', TIME_FORMAT(rr.gio_ket_thuc, \'%H:%i\'),
                          \' (\', rr.muc_dich, \')\') AS items,
                   la.ho_ten AS librarian_name
            FROM yeu_cau_dat_phong rr
            JOIN sinh_vien s ON s.ma = rr.ma_ho_so_sinh_vien
            JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
            LEFT JOIN thu_thu l ON l.ma = rr.ma_ho_so_thu_thu
            LEFT JOIN tai_khoan la ON la.ma = l.ma_tai_khoan
            JOIN phong r ON r.ma = rr.ma_phong
            WHERE rr.trang_thai IN (\'approved\', \'rejected\', \'completed\')
        ) reviewed_requests
        ORDER BY thoi_diem_xet_duyet DESC, thoi_diem_gui_yeu_cau DESC
        LIMIT :limit'
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function review_borrow_request(PDO $pdo, string $type, int $requestId): array
{
    $librarian = require_role('librarian');
    if (empty($librarian['librarian_id'])) {
        throw new ApiException('Không tìm thấy thông tin thủ thư.', 403);
    }

    $body = request_body();
    $decision = (string) ($body['decision'] ?? '');
    if (!in_array($decision, ['approved', 'rejected'], true)) {
        throw new ApiException('Quyết định duyệt không hợp lệ.');
    }

    return match ($type) {
        'book' => review_book_request($pdo, $requestId, (int) $librarian['librarian_id'], $decision, request_note($body)),
        'equipment' => review_equipment_request($pdo, $requestId, (int) $librarian['librarian_id'], $decision, request_note($body)),
        'room' => review_room_request($pdo, $requestId, (int) $librarian['librarian_id'], $decision, request_note($body)),
        default => throw new ApiException('Loại yêu cầu không hợp lệ.'),
    };
}

function review_book_request(PDO $pdo, int $requestId, int $librarianId, string $decision, ?string $reviewNote): array
{
    $ownsTransaction = !$pdo->inTransaction();
    if ($ownsTransaction) $pdo->beginTransaction();
    try {
        $request = $pdo->prepare('SELECT * FROM yeu_cau_muon_sach WHERE ma = :id FOR UPDATE');
        $request->execute(['id' => $requestId]);
        $header = $request->fetch();
        if (!$header) {
            throw new ApiException('Không tìm thấy yêu cầu mượn sách.', 404);
        }
        if ($header['status'] !== 'pending') {
            throw new ApiException('Yêu cầu này đã được xử lý.');
        }

        if ($decision === 'rejected') {
            $update = $pdo->prepare(
                'UPDATE yeu_cau_muon_sach
                 SET trang_thai = \'rejected\', ma_ho_so_thu_thu = :librarian_id, thoi_diem_xet_duyet = NOW(), ghi_chu_xet_duyet = :review_note
                 WHERE ma = :id'
            );
            $update->execute(['librarian_id' => $librarianId, 'review_note' => $reviewNote, 'id' => $requestId]);
            if ($ownsTransaction) $pdo->commit();
            return ['id' => $requestId, 'type' => 'book', 'status' => 'rejected'];
        }

        $itemsStatement = $pdo->prepare('SELECT ma_dau_sach, so_luong, han_tra_de_nghi FROM chi_tiet_yeu_cau_muon_sach WHERE ma_yeu_cau = :id ORDER BY ma_dau_sach');
        $itemsStatement->execute(['id' => $requestId]);
        $items = $itemsStatement->fetchAll();
        if ($items === []) {
            throw new ApiException('Yêu cầu mượn sách không có chi tiết.');
        }

        $copyStatement = $pdo->prepare(
            'SELECT ma FROM ban_sach
             WHERE ma_dau_sach = :book_id AND trang_thai = \'available\' AND hien_thi=1 AND thoi_diem_xoa IS NULL
             ORDER BY ma FOR UPDATE'
        );
        $copies = [];
        $bookGuard = $pdo->prepare(
            'SELECT ma FROM dau_sach WHERE ma = ? AND hien_thi = 1 AND thoi_diem_xoa IS NULL FOR UPDATE'
        );
        foreach ($items as $item) {
            if ($item['requested_due_date'] <= date('Y-m-d')) {
                throw new ApiException('Hạn trả của yêu cầu đã qua. Sinh viên cần tạo yêu cầu mới.');
            }
            $bookGuard->execute([$item['book_id']]);
            if (!$bookGuard->fetchColumn()) throw new ApiException('Đầu sách đang ẩn hoặc đã xóa. Không thể duyệt yêu cầu.',409);
            $copyStatement->execute(['book_id' => $item['book_id']]);
            $availableCopies = $copyStatement->fetchAll();
            $quantity = (int) $item['quantity'];
            if (count($availableCopies) < $quantity) {
                throw new ApiException('Một hoặc nhiều đầu sách không còn đủ số bản sẵn sàng.');
            }
            for ($copyIndex = 0; $copyIndex < $quantity; $copyIndex++) {
                $copies[] = ['copy_id' => (int) $availableCopies[$copyIndex]['id'], 'due_date' => $item['requested_due_date']];
            }
        }

        $receipt = $pdo->prepare(
            'INSERT INTO phieu_muon_sach (ma_ho_so_sinh_vien, ma_ho_so_thu_thu, ghi_chu, trang_thai, ma_yeu_cau)
             VALUES (:student_id, :librarian_id, :note, \'open\', :request_id)'
        );
        $receiptNote = substr(trim('Duyet yeu cau sach #' . $requestId . ' ' . (string) $header['note']), 0, 255);
        $receipt->execute(['student_id' => $header['student_id'], 'librarian_id' => $librarianId, 'note' => $receiptNote, 'request_id'=>$requestId]);
        $receiptId = (int) $pdo->lastInsertId();

        $loanDetail = $pdo->prepare(
            'INSERT INTO chi_tiet_muon_sach (ma_phieu_muon_sach, ma_ban_sach, ngay_muon, han_tra, trang_thai)
             VALUES (:receipt_id, :copy_id, CURDATE(), :due_date, \'borrowed\')'
        );
        $markBorrowed = $pdo->prepare('UPDATE ban_sach SET trang_thai = \'borrowed\' WHERE ma = :id');
        foreach ($copies as $copy) {
            $loanDetail->execute(['receipt_id' => $receiptId, 'copy_id' => $copy['copy_id'], 'due_date' => $copy['due_date']]);
            $markBorrowed->execute(['id' => $copy['copy_id']]);
        }

        $update = $pdo->prepare(
            'UPDATE yeu_cau_muon_sach
             SET trang_thai = \'approved\', ma_ho_so_thu_thu = :librarian_id, thoi_diem_xet_duyet = NOW(), ghi_chu_xet_duyet = :review_note
             WHERE ma = :id'
        );
        $update->execute(['librarian_id' => $librarianId, 'review_note' => $reviewNote, 'id' => $requestId]);
        if ($ownsTransaction) $pdo->commit();
        return ['id' => $requestId, 'type' => 'book', 'status' => 'approved', 'receipt_id' => $receiptId];
    } catch (Throwable $exception) {
        if ($ownsTransaction && $pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }
}

function review_equipment_request(PDO $pdo, int $requestId, int $librarianId, string $decision, ?string $reviewNote): array
{
    $ownsTransaction = !$pdo->inTransaction();
    if ($ownsTransaction) $pdo->beginTransaction();
    try {
        $request = $pdo->prepare('SELECT * FROM yeu_cau_muon_thiet_bi WHERE ma = :id FOR UPDATE');
        $request->execute(['id' => $requestId]);
        $header = $request->fetch();
        if (!$header) {
            throw new ApiException('Không tìm thấy yêu cầu mượn thiết bị.', 404);
        }
        if ($header['status'] !== 'pending') {
            throw new ApiException('Yêu cầu này đã được xử lý.');
        }

        if ($decision === 'rejected') {
            $update = $pdo->prepare(
                'UPDATE yeu_cau_muon_thiet_bi
                 SET trang_thai = \'rejected\', ma_ho_so_thu_thu = :librarian_id, thoi_diem_xet_duyet = NOW(), ghi_chu_xet_duyet = :review_note
                 WHERE ma = :id'
            );
            $update->execute(['librarian_id' => $librarianId, 'review_note' => $reviewNote, 'id' => $requestId]);
            if ($ownsTransaction) $pdo->commit();
            return ['id' => $requestId, 'type' => 'equipment', 'status' => 'rejected'];
        }

        $itemsStatement = $pdo->prepare(
            'SELECT ma_thiet_bi, so_luong, han_tra_de_nghi FROM chi_tiet_yeu_cau_muon_thiet_bi WHERE ma_yeu_cau = :id ORDER BY ma_thiet_bi'
        );
        $itemsStatement->execute(['id' => $requestId]);
        $items = $itemsStatement->fetchAll();
        if ($items === []) {
            throw new ApiException('Yêu cầu mượn thiết bị không có chi tiết.');
        }

        $equipmentStatement = $pdo->prepare('SELECT ma, so_luong_san_sang, trang_thai FROM thiet_bi WHERE ma = :id AND hien_thi=1 AND thoi_diem_xoa IS NULL FOR UPDATE');
        $equipmentUpdates = [];
        foreach ($items as $item) {
            if ($item['requested_due_date'] <= date('Y-m-d')) {
                throw new ApiException('Hạn trả của yêu cầu đã qua. Sinh viên cần tạo yêu cầu mới.');
            }
            $equipmentStatement->execute(['id' => $item['equipment_id']]);
            $equipment = $equipmentStatement->fetch();
            if (!$equipment || $equipment['status'] !== 'available' || (int) $equipment['available_quantity'] < (int) $item['quantity']) {
                throw new ApiException('Một hoặc nhiều thiết bị không đủ số lượng sẵn sàng.');
            }
            $equipmentUpdates[] = [
                'equipment_id' => (int) $equipment['id'],
                'quantity' => (int) $item['quantity'],
                'due_date' => $item['requested_due_date'],
                'available_quantity' => (int) $equipment['available_quantity'] - (int) $item['quantity'],
            ];
        }

        $loan = $pdo->prepare(
            'INSERT INTO phieu_muon_thiet_bi (ma_ho_so_sinh_vien, ma_ho_so_thu_thu, ghi_chu, trang_thai, ma_yeu_cau)
             VALUES (:student_id, :librarian_id, :note, \'borrowed\', :request_id)'
        );
        $loanNote = substr(trim('Duyet yeu cau thiet bi #' . $requestId . ' ' . (string) $header['note']), 0, 255);
        $loan->execute(['student_id' => $header['student_id'], 'librarian_id' => $librarianId, 'note' => $loanNote, 'request_id'=>$requestId]);
        $loanId = (int) $pdo->lastInsertId();

        $loanDetail = $pdo->prepare(
            'INSERT INTO chi_tiet_muon_thiet_bi (ma_phieu_muon_thiet_bi, ma_thiet_bi, so_luong, ngay_muon, han_tra, tinh_trang_khi_muon, trang_thai)
             VALUES (:loan_id, :equipment_id, :quantity, CURDATE(), :due_date, \'Tot\', \'borrowed\')'
        );
        $updateEquipment = $pdo->prepare(
            'UPDATE thiet_bi SET so_luong_san_sang = :available_quantity, trang_thai = :status WHERE ma = :id'
        );
        foreach ($equipmentUpdates as $item) {
            $loanDetail->execute([
                'loan_id' => $loanId,
                'equipment_id' => $item['equipment_id'],
                'quantity' => $item['quantity'],
                'due_date' => $item['due_date'],
            ]);
            $updateEquipment->execute([
                'available_quantity' => $item['available_quantity'],
                'status' => $item['available_quantity'] === 0 ? 'borrowed' : 'available',
                'id' => $item['equipment_id'],
            ]);
        }

        $update = $pdo->prepare(
            'UPDATE yeu_cau_muon_thiet_bi
             SET trang_thai = \'approved\', ma_ho_so_thu_thu = :librarian_id, thoi_diem_xet_duyet = NOW(), ghi_chu_xet_duyet = :review_note
             WHERE ma = :id'
        );
        $update->execute(['librarian_id' => $librarianId, 'review_note' => $reviewNote, 'id' => $requestId]);
        if ($ownsTransaction) $pdo->commit();
        return ['id' => $requestId, 'type' => 'equipment', 'status' => 'approved', 'loan_id' => $loanId];
    } catch (Throwable $exception) {
        if ($ownsTransaction && $pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }
}

function review_room_request(PDO $pdo, int $requestId, int $librarianId, string $decision, ?string $reviewNote): array
{
    $pdo->beginTransaction();
    try {
        $request = $pdo->prepare('SELECT * FROM yeu_cau_dat_phong WHERE ma = :id FOR UPDATE');
        $request->execute(['id' => $requestId]);
        $header = $request->fetch();
        if (!$header) {
            throw new ApiException('Không tìm thấy yêu cầu đặt phòng.', 404);
        }
        if ($header['status'] !== 'pending') {
            throw new ApiException('Yêu cầu này đã được xử lý.');
        }

        if ($decision === 'approved') {
            $room = $pdo->prepare('SELECT trang_thai FROM phong WHERE ma = :id AND hien_thi=1 AND thoi_diem_xoa IS NULL FOR UPDATE');
            $room->execute(['id' => $header['room_id']]);
            $roomData = $room->fetch();
            if (!$roomData || $roomData['status'] !== 'available') {
                throw new ApiException('Phòng này không còn sẵn sàng để duyệt.');
            }

            $conflict = $pdo->prepare(
                'SELECT 1 FROM yeu_cau_dat_phong
                 WHERE ma_phong = :room_id AND ma <> :request_id AND ngay_su_dung = :use_date
                   AND trang_thai = \'approved\'
                   AND gio_bat_dau < :end_time AND gio_ket_thuc > :start_time
             LIMIT 1'
            );
            $conflict->execute([
                'room_id' => $header['room_id'],
                'request_id' => $requestId,
                'use_date' => $header['use_date'],
                'start_time' => $header['start_time'],
                'end_time' => $header['end_time'],
            ]);
            if ($conflict->fetchColumn() !== false) {
                throw new ApiException('Phòng đã có lịch được duyệt trong khung giờ này.');
            }
        }

        $update = $pdo->prepare(
            'UPDATE yeu_cau_dat_phong
             SET trang_thai = :status, ma_ho_so_thu_thu = :librarian_id, thoi_diem_xet_duyet = NOW(), ghi_chu_xet_duyet = :review_note
             WHERE ma = :id'
        );
        $update->execute([
            'status' => $decision,
            'librarian_id' => $librarianId,
            'review_note' => $reviewNote,
            'id' => $requestId,
        ]);
        $pdo->commit();
        return ['id' => $requestId, 'type' => 'room', 'status' => $decision];
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }
}

function overdue_books(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT ld.ma AS ma_chi_tiet_muon_sach, b.ma AS ma_dau_sach, b.ten_sach, c.ma_vach,
                s.ma_sinh_vien, a.ho_ten AS student_name, ld.ngay_muon,
                ld.han_tra, DATEDIFF(CURDATE(), ld.han_tra) AS overdue_days,
                ld.so_lan_gia_han, lr.ma AS ma_phieu_muon_sach
         FROM chi_tiet_muon_sach ld
         JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
         JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         JOIN ban_sach c ON c.ma = ld.ma_ban_sach
         JOIN dau_sach b ON b.ma = c.ma_dau_sach
         WHERE ld.ngay_tra IS NULL AND ld.han_tra < CURDATE()
         ORDER BY overdue_days DESC, ld.han_tra ASC'
    );
    return $statement->fetchAll();
}

function returned_books(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT ld.ma AS ma_chi_tiet_muon_sach, lr.ma AS ma_phieu_muon_sach, b.ten_sach, c.ma_vach, s.ma_sinh_vien,
                a.ho_ten AS student_name, ld.ngay_muon, ld.han_tra,
                ld.ngay_tra, ld.so_lan_gia_han,
                CASE WHEN ld.ket_qua_tra = \'late\' THEN \'Tra tre\'
                     WHEN ld.ket_qua_tra = \'on_time\' THEN \'Tra dung han\'
                     WHEN ld.ngay_tra > ld.han_tra THEN \'Tra tre\' ELSE \'Tra dung han\' END AS ket_qua_tra,
                CASE WHEN ld.ket_qua_tra IS NOT NULL THEN ld.so_ngay_tre
                     ELSE GREATEST(DATEDIFF(ld.ngay_tra, ld.han_tra), 0) END AS so_ngay_tre
         FROM chi_tiet_muon_sach ld
         JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
         JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         JOIN ban_sach c ON c.ma = ld.ma_ban_sach
         JOIN dau_sach b ON b.ma = c.ma_dau_sach
         WHERE ld.ngay_tra IS NOT NULL
         ORDER BY ld.ngay_tra DESC'
    );
    return $statement->fetchAll();
}

function active_book_loans(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT ld.ma AS ma_chi_tiet_muon_sach, lr.ma AS ma_phieu_muon_sach, b.ten_sach, c.ma_vach, s.ma_sinh_vien,
                a.ho_ten AS student_name, ld.ngay_muon, ld.han_tra,
                ld.so_lan_gia_han,
                CASE WHEN ld.han_tra < CURDATE() THEN \'Qua han\' ELSE \'Dang muon\' END AS loan_status,
                DATEDIFF(CURDATE(), ld.han_tra) AS overdue_days
         FROM chi_tiet_muon_sach ld
         JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
         JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         JOIN ban_sach c ON c.ma = ld.ma_ban_sach
         JOIN dau_sach b ON b.ma = c.ma_dau_sach
         WHERE ld.ngay_tra IS NULL
         ORDER BY (ld.han_tra < CURDATE()) DESC, ld.han_tra ASC, ld.ma ASC'
    );
    return $statement->fetchAll();
}

function active_equipment_loans(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT eld.ma AS ma_chi_tiet_muon_thiet_bi, e.ten, e.loai_thiet_bi,
                eld.so_luong, s.ma_sinh_vien, a.ho_ten AS student_name,
                eld.ngay_muon, eld.han_tra,
                CASE WHEN eld.han_tra < CURDATE() THEN \'Qua han\' ELSE \'Dang muon\' END AS loan_status,
                DATEDIFF(CURDATE(), eld.han_tra) AS overdue_days
         FROM chi_tiet_muon_thiet_bi eld
         JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
         JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
         JOIN sinh_vien s ON s.ma = el.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         WHERE eld.ngay_tra IS NULL
         ORDER BY (eld.han_tra < CURDATE()) DESC, eld.han_tra ASC, eld.ma ASC'
    );
    return $statement->fetchAll();
}

function room_usage_history(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT rr.ma AS ma_yeu_cau_dat_phong, r.ten AS room_name, r.loai_phong,
                s.ma_sinh_vien, a.ho_ten AS student_name, rr.ngay_su_dung,
                rr.gio_bat_dau, rr.gio_ket_thuc, rr.muc_dich, rr.trang_thai,
                rr.thoi_diem_xet_duyet
         FROM yeu_cau_dat_phong rr
         JOIN phong r ON r.ma = rr.ma_phong
         JOIN sinh_vien s ON s.ma = rr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         WHERE rr.trang_thai IN (\'approved\', \'completed\', \'rejected\')
         ORDER BY rr.ngay_su_dung DESC, rr.gio_bat_dau DESC, rr.ma DESC
         LIMIT 30'
    );
    return $statement->fetchAll();
}

function mark_room_completed(PDO $pdo, int $roomRequestId): array
{
    $pdo->beginTransaction();
    try {
        $request = $pdo->prepare(
            'SELECT rr.ma, rr.trang_thai, rr.ngay_su_dung, rr.gio_ket_thuc, r.ten AS room_name
             FROM yeu_cau_dat_phong rr
             JOIN phong r ON r.ma = rr.ma_phong
             WHERE rr.ma = :id
             FOR UPDATE'
        );
        $request->execute(['id' => $roomRequestId]);
        $room = $request->fetch();
        if (!$room) {
            throw new ApiException('Khong tim thay lich dat phong.', 404);
        }
        if ($room['status'] !== 'approved') {
            throw new ApiException('Chi lich dat phong da duoc duyet moi co the ket thuc.');
        }
        $update = $pdo->prepare('UPDATE yeu_cau_dat_phong SET trang_thai = \'completed\' WHERE ma = :id');
        $update->execute(['id' => $roomRequestId]);
        $pdo->commit();
        return [
            'room_request_id' => $roomRequestId,
            'room_name' => $room['room_name'],
            'status' => 'completed',
        ];
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }
}

function mark_book_return(PDO $pdo, int $loanDetailId): array
{
    $body = request_body();
    $condition = trim((string) ($body['condition_on_return'] ?? 'good'));
    if (!in_array($condition, ['good', 'worn', 'damaged', 'lost'], true)) {
        $condition = 'good';
    }
    $pdo->beginTransaction();
    try {
        $detail = $pdo->prepare(
            'SELECT ld.ma, ld.ma_phieu_muon_sach, ld.ma_ban_sach, ld.ngay_muon, ld.han_tra, ld.ngay_tra,
                    b.ten_sach, c.ma_vach, s.ma_sinh_vien, a.ho_ten AS student_name
             FROM chi_tiet_muon_sach ld
             JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
             JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
             JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
             JOIN ban_sach c ON c.ma = ld.ma_ban_sach
             JOIN dau_sach b ON b.ma = c.ma_dau_sach
             WHERE ld.ma = :id
             FOR UPDATE'
        );
        $detail->execute(['id' => $loanDetailId]);
        $loan = $detail->fetch();
        if (!$loan) {
            throw new ApiException('Khong tim thay chi tiet phieu muon sach.', 404);
        }
        if ($loan['return_date'] !== null) {
            throw new ApiException('Cuon sach nay da duoc ghi nhan tra.');
        }

        $today = date('Y-m-d');
        $returnDate = $today;
        if ($returnDate < $loan['borrow_date']) throw new ApiException('Ngày nhận trả không được trước ngày mượn.');
        $lateDays=resource_int($body+['late_days'=>0],'late_days',0,65535);
        $returnStatus=$lateDays>0?'late':'on_time';

        $update = $pdo->prepare(
            'UPDATE chi_tiet_muon_sach
             SET ngay_tra = :return_date, ket_qua_tra = :return_status, so_ngay_tre = :late_days,
                 trang_thai = \'returned\', tinh_trang_khi_tra = :condition
             WHERE ma = :id'
        );
        $update->execute([
            'return_date' => $returnDate,
            'return_status' => $returnStatus,
            'late_days' => $lateDays,
            'condition' => $condition,
            'id' => $loanDetailId,
        ]);

        $copyStatus = $condition === 'lost' ? 'lost' : ($condition === 'damaged' ? 'damaged' : 'available');
        $copy = $pdo->prepare('UPDATE ban_sach SET trang_thai = :status WHERE ma = :id');
        $copy->execute(['status' => $copyStatus, 'id' => $loan['copy_id']]);

        $receipt = $pdo->prepare(
            'UPDATE phieu_muon_sach
             SET trang_thai = CASE WHEN NOT EXISTS (
                 SELECT 1 FROM chi_tiet_muon_sach ld WHERE ld.ma_phieu_muon_sach = phieu_muon_sach.ma AND ld.ngay_tra IS NULL
             ) THEN \'completed\' ELSE \'open\' END
             WHERE ma = :id'
        );
        $receipt->execute(['id' => $loan['receipt_id']]);
        $pdo->commit();

        return [
            'loan_detail_id' => $loanDetailId,
            'title' => $loan['title'],
            'student_name' => $loan['student_name'],
            'return_date' => $returnDate,
            'return_status' => $returnStatus === 'late' ? 'Tra tre' : 'Tra dung han',
            'late_days' => $lateDays,
        ];
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }
}

function mark_equipment_return(PDO $pdo, int $equipmentDetailId): array
{
    $body = request_body();
    $condition = substr(trim((string) ($body['condition_on_return'] ?? 'Tot')), 0, 120);
    if ($condition === '') {
        $condition = 'Tot';
    }
    $pdo->beginTransaction();
    try {
        $detail = $pdo->prepare(
            'SELECT eld.ma, eld.ma_phieu_muon_thiet_bi, eld.ma_thiet_bi, eld.so_luong, eld.ngay_muon, eld.han_tra, eld.ngay_tra,
                    e.ten, s.ma_sinh_vien, a.ho_ten AS student_name
             FROM chi_tiet_muon_thiet_bi eld
             JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
             JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
             JOIN sinh_vien s ON s.ma = el.ma_ho_so_sinh_vien
             JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
             WHERE eld.ma = :id
             FOR UPDATE'
        );
        $detail->execute(['id' => $equipmentDetailId]);
        $loan = $detail->fetch();
        if (!$loan) {
            throw new ApiException('Khong tim thay chi tiet phieu muon thiet bi.', 404);
        }
        if ($loan['return_date'] !== null) {
            throw new ApiException('Thiet bi nay da duoc ghi nhan tra.');
        }

        $today = date('Y-m-d');
        $returnDate = $today;
        if ($returnDate < $loan['borrow_date']) throw new ApiException('Ngày nhận trả không được trước ngày mượn.');
        $lateDays=resource_int($body+['late_days'=>0],'late_days',0,65535);
        $returnStatus=$lateDays>0?'late':'on_time';

        $update = $pdo->prepare(
            'UPDATE chi_tiet_muon_thiet_bi
             SET ngay_tra = :return_date, ket_qua_tra = :return_status, so_ngay_tre = :late_days,
                 trang_thai = \'returned\', tinh_trang_khi_tra = :condition
             WHERE ma = :id'
        );
        $update->execute([
            'return_date' => $returnDate,
            'return_status' => $returnStatus,
            'late_days' => $lateDays,
            'condition' => $condition,
            'id' => $equipmentDetailId,
        ]);

        $equipment = $pdo->prepare(
            'UPDATE thiet_bi
             SET so_luong_san_sang = LEAST(tong_so_luong, so_luong_san_sang + :quantity),
                 trang_thai = CASE WHEN trang_thai IN (\'maintenance\',\'damaged\') THEN trang_thai ELSE \'available\' END
             WHERE ma = :id'
        );
        $equipment->execute(['quantity' => $loan['quantity'], 'id' => $loan['equipment_id']]);

        $parent = $pdo->prepare(
            'UPDATE phieu_muon_thiet_bi
             SET trang_thai = CASE WHEN NOT EXISTS (
                 SELECT 1 FROM chi_tiet_muon_thiet_bi eld WHERE eld.ma_phieu_muon_thiet_bi = phieu_muon_thiet_bi.ma AND eld.ngay_tra IS NULL
             ) THEN \'returned\' ELSE \'borrowed\' END
             WHERE ma = :id'
        );
        $parent->execute(['id' => $loan['loan_id']]);
        $pdo->commit();

        return [
            'equipment_detail_id' => $equipmentDetailId,
            'name' => $loan['name'],
            'student_name' => $loan['student_name'],
            'return_date' => $returnDate,
            'return_status' => $returnStatus === 'late' ? 'Tra tre' : 'Tra dung han',
            'late_days' => $lateDays,
        ];
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    }
}


function student_history(PDO $pdo, string $studentCode): array
{
    $user=require_login();
    if ($user['role']==='student' && $studentCode !== $user['student_code']) throw new ApiException('Bạn chỉ được xem lịch sử của mình.',403);
    $student = $pdo->prepare(
        'SELECT s.ma, s.ma_sinh_vien, a.ho_ten, s.khoa, s.lop
         FROM sinh_vien s JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         WHERE s.ma_sinh_vien = :code'
    );
    $student->execute(['code' => $studentCode]);
    $studentData = $student->fetch();
    if (!$studentData) {
        json_response(['message' => 'Khong tim thay sinh vien.'], 404);
    }

    $books = $pdo->prepare(
        'SELECT \'book\' AS resource_type, lr.ma AS ma_phieu_muon_sach, ld.ma AS ma_chi_tiet_muon_sach, b.ten_sach AS resource_name,
                ld.ngay_muon, ld.han_tra, ld.ngay_tra, ld.so_lan_gia_han,
                CASE WHEN ld.ngay_tra IS NULL AND ld.han_tra < CURDATE() THEN \'Qua han\'
                     WHEN ld.ngay_tra IS NULL THEN \'Dang muon\'
                     WHEN ld.ket_qua_tra = \'late\' THEN CONCAT(\'Tra tre \', ld.so_ngay_tre, \' ngay\')
                     WHEN ld.ket_qua_tra = \'on_time\' THEN \'Tra dung han\'
                     WHEN ld.ngay_tra > ld.han_tra THEN CONCAT(\'Tra tre \', DATEDIFF(ld.ngay_tra, ld.han_tra), \' ngay\')
                     ELSE \'Tra dung han\' END AS trang_thai
         FROM phieu_muon_sach lr
         JOIN chi_tiet_muon_sach ld ON ld.ma_phieu_muon_sach = lr.ma
         JOIN ban_sach c ON c.ma = ld.ma_ban_sach
         JOIN dau_sach b ON b.ma = c.ma_dau_sach
         WHERE lr.ma_ho_so_sinh_vien = :student_id
         ORDER BY ld.ngay_muon DESC'
    );
    $books->execute(['student_id' => $studentData['id']]);

    $equipment = $pdo->prepare(
        'SELECT \'equipment\' AS resource_type, el.ma AS ma_phieu_muon_sach, eld.ma AS ma_chi_tiet_muon_thiet_bi, e.ten AS resource_name,
                eld.ngay_muon, eld.han_tra, eld.ngay_tra, eld.so_luong,
                CASE WHEN eld.ngay_tra IS NULL AND eld.han_tra < CURDATE() THEN \'Qua han\'
                     WHEN eld.ngay_tra IS NULL THEN \'Dang muon\'
                     WHEN eld.ket_qua_tra = \'late\' THEN CONCAT(\'Tra tre \', eld.so_ngay_tre, \' ngay\')
                     WHEN eld.ket_qua_tra = \'on_time\' THEN \'Tra dung han\'
                     WHEN eld.ngay_tra > eld.han_tra THEN CONCAT(\'Tra tre \', DATEDIFF(eld.ngay_tra, eld.han_tra), \' ngay\')
                     ELSE \'Tra dung han\' END AS trang_thai
         FROM phieu_muon_thiet_bi el
         JOIN chi_tiet_muon_thiet_bi eld ON eld.ma_phieu_muon_thiet_bi = el.ma
         JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
         WHERE el.ma_ho_so_sinh_vien = :student_id
         ORDER BY eld.ngay_muon DESC'
    );
    $equipment->execute(['student_id' => $studentData['id']]);

    return [
        'student' => $studentData,
        'items' => array_merge($books->fetchAll(), $equipment->fetchAll()),
    ];
}

function loan_receipt_detail(PDO $pdo, int $receiptId): array
{
    $receipt = $pdo->prepare(
        'SELECT lr.ma, lr.ma_yeu_cau, lr.thoi_diem_dang_ky, lr.trang_thai, lr.ghi_chu,
                s.ma_sinh_vien, sa.ho_ten AS student_name,
                l.ma_thu_thu, la.ho_ten AS librarian_name
         FROM phieu_muon_sach lr
         JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
         JOIN tai_khoan sa ON sa.ma = s.ma_tai_khoan
         JOIN thu_thu l ON l.ma = lr.ma_ho_so_thu_thu
         JOIN tai_khoan la ON la.ma = l.ma_tai_khoan
         WHERE lr.ma = :id'
    );
    $receipt->execute(['id' => $receiptId]);
    $data = $receipt->fetch();
    if (!$data) {
        json_response(['message' => 'Khong tim thay phieu muon.'], 404);
    }

    $user=require_login();
    if ($user['role']==='student' && $data['student_code'] !== $user['student_code']) throw new ApiException('Bạn không có quyền xem phiếu mượn này.',403);

    $details = $pdo->prepare(
        'SELECT ld.ma, 1 AS so_luong, b.ten_sach, c.ma_vach, ld.ngay_muon, ld.han_tra,
                ld.ngay_tra, ld.ket_qua_tra, ld.so_ngay_tre,
                ld.so_lan_gia_han, ld.trang_thai
         FROM chi_tiet_muon_sach ld
         JOIN ban_sach c ON c.ma = ld.ma_ban_sach
         JOIN dau_sach b ON b.ma = c.ma_dau_sach
         WHERE ld.ma_phieu_muon_sach = :id ORDER BY ld.ma'
    );
    $details->execute(['id' => $receiptId]);
    $data['details'] = $details->fetchAll();
    $data['total_books'] = count($data['details']);
    return $data;
}

function available_rooms(PDO $pdo): array
{
    $date = normalize_date(query_string('date', date('Y-m-d')) ?? date('Y-m-d'), date('Y-m-d'));
    $start = request_time(query_string('start', '08:00') ?? '08:00');
    $end = request_time(query_string('end', '10:00') ?? '10:00');
    if ($start >= $end) {
        throw new ApiException('Giờ kết thúc phải sau giờ bắt đầu.');
    }
    $type = query_string('type');
    $capacity = query_string('capacity');
    $params = [':date' => $date, ':start' => $start, ':end' => $end];
    $where = [
        "r.status = 'available'",
        'r.is_visible = 1', 'r.deleted_at IS NULL',
        'NOT EXISTS (
            SELECT 1 FROM yeu_cau_dat_phong rr
            WHERE rr.ma_phong = r.ma AND rr.ngay_su_dung = :date
              AND rr.trang_thai IN (\'pending\', \'approved\')
              AND rr.gio_bat_dau < :end AND rr.gio_ket_thuc > :start
        )',
    ];

    if ($type) {
        $where[] = 'r.room_type = :type';
        $params[':type'] = $type;
    }
    if ($capacity && ctype_digit($capacity)) {
        $where[] = 'r.capacity >= :capacity';
        $params[':capacity'] = (int) $capacity;
    }

    $statement = $pdo->prepare(
        'SELECT r.ma, r.ten, r.loai_phong, r.vi_tri, r.suc_chua, r.thiet_bi_di_kem,
                r.gio_hoat_dong, r.trang_thai, r.duong_dan_anh, r.anh_minh_hoa
         FROM phong r WHERE ' . implode(' AND ', $where) . ' ORDER BY r.suc_chua'
    );
    bind_optional($statement, $params);
    $statement->execute();
    return $statement->fetchAll();
}

function room_schedule(PDO $pdo, ?int $roomId = null): array
{
    $date = normalize_date(query_string('date', date('Y-m-d')) ?? date('Y-m-d'), date('Y-m-d'));
    $params = [':date' => $date];
    $roomFilter = resource_staff_access()?'':' AND r.hien_thi=1 AND r.thoi_diem_xoa IS NULL';
    if ($roomId !== null) {
        $roomFilter .= ' AND rr.ma_phong = :room_id';
        $params[':room_id'] = $roomId;
    }

    $statement = $pdo->prepare(
        "SELECT rr.ma AS ma_yeu_cau_dat_phong, r.ma AS ma_phong, r.ten AS room_name,
                r.loai_phong, rr.ngay_su_dung, rr.gio_bat_dau, rr.gio_ket_thuc, rr.muc_dich,
                rr.trang_thai, s.ma_sinh_vien, a.ho_ten AS student_name
         FROM yeu_cau_dat_phong rr
         JOIN phong r ON r.ma = rr.ma_phong
         JOIN sinh_vien s ON s.ma = rr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         WHERE rr.ngay_su_dung = :date
           AND rr.trang_thai IN ('pending', 'approved', 'completed')
           $roomFilter
         ORDER BY r.ten, rr.gio_bat_dau, rr.gio_ket_thuc"
    );
    $statement->execute($params);
    $rows=$statement->fetchAll();
    $user=require_login();
    if ($user['role']==='student') {
        foreach ($rows as &$row) {
            if ($row['student_code'] !== $user['student_code']) {
                $row['student_code']=null; $row['student_name']='Đã được đặt';
                $row['purpose']='Khung giờ đã có người sử dụng'; $row['room_request_id']=null;
            }
        }
        unset($row);
    }
    return $rows;
}

function room_requests(PDO $pdo, int $limit = 50): array
{
    $limit = max(1, min($limit, 100));
    $status = query_string('status');
    $params = [];
    $where = '';
    $user=require_login();
    if ($status) {
        $where = 'WHERE rr.trang_thai = :status';
        $params[':status'] = $status;
    }

    if ($user['role']==='student') {
        $where .= ($where === '' ? 'WHERE ' : ' AND ') . 'rr.student_id = :own_student';
        $params[':own_student']=(int)$user['student_id'];
    }
    $statement = $pdo->prepare(
        "SELECT rr.ma, rr.ngay_su_dung, rr.gio_bat_dau, rr.gio_ket_thuc, rr.muc_dich, rr.trang_thai,
                r.ten AS room_name, r.loai_phong, r.suc_chua,
                s.ma_sinh_vien, a.ho_ten AS student_name
         FROM yeu_cau_dat_phong rr
         JOIN phong r ON r.ma = rr.ma_phong
         JOIN sinh_vien s ON s.ma = rr.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         $where
         ORDER BY rr.ngay_su_dung ASC, rr.gio_bat_dau ASC
         LIMIT :limit"
    );
    bind_optional($statement, $params);
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function available_equipment(PDO $pdo): array
{
    $type = query_string('type');
    $params = [];
    $where = ["e.available_quantity > 0", "e.status = 'available'",'e.is_visible=1','e.deleted_at IS NULL'];
    if ($type) {
        $where[] = 'e.equipment_type = :type';
        $params[':type'] = $type;
    }

    $statement = $pdo->prepare(
        'SELECT e.ma, e.ten, e.loai_thiet_bi, e.hang_san_xuat, e.tong_so_luong,
                e.so_luong_san_sang, e.vi_tri_luu_tru, e.so_se_ri, e.trang_thai, e.duong_dan_anh, e.anh_minh_hoa
         FROM thiet_bi e WHERE ' . implode(' AND ', $where) . ' ORDER BY e.so_luong_san_sang DESC, e.ten'
    );
    bind_optional($statement, $params);
    $statement->execute();
    return $statement->fetchAll();
}

function overdue_equipment(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT eld.ma, e.ten, e.loai_thiet_bi, eld.so_luong, eld.ngay_muon,
                eld.han_tra, DATEDIFF(CURDATE(), eld.han_tra) AS overdue_days,
                s.ma_sinh_vien, a.ho_ten AS student_name, el.ma AS ma_phieu_muon_thiet_bi
         FROM chi_tiet_muon_thiet_bi eld
         JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
         JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
         JOIN sinh_vien s ON s.ma = el.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         WHERE eld.ngay_tra IS NULL AND eld.han_tra < CURDATE()
         ORDER BY overdue_days DESC'
    );
    return $statement->fetchAll();
}

function returned_equipment(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT eld.ma AS ma_chi_tiet_muon_thiet_bi, e.ten, eld.so_luong,
                s.ma_sinh_vien, a.ho_ten AS student_name, eld.ngay_muon,
                eld.han_tra, eld.ngay_tra,
                CASE WHEN eld.ket_qua_tra = \'late\' THEN \'Tra tre\'
                     WHEN eld.ket_qua_tra = \'on_time\' THEN \'Tra dung han\'
                     WHEN eld.ngay_tra > eld.han_tra THEN \'Tra tre\' ELSE \'Tra dung han\' END AS ket_qua_tra,
                CASE WHEN eld.ket_qua_tra IS NOT NULL THEN eld.so_ngay_tre
                     ELSE GREATEST(DATEDIFF(eld.ngay_tra, eld.han_tra), 0) END AS so_ngay_tre
         FROM chi_tiet_muon_thiet_bi eld
         JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
         JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
         JOIN sinh_vien s ON s.ma = el.ma_ho_so_sinh_vien
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         WHERE eld.ngay_tra IS NOT NULL
         ORDER BY eld.ngay_tra DESC
         LIMIT 20'
    );
    return $statement->fetchAll();
}

function overdue_students(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT s.ma_sinh_vien, a.ho_ten,
                COALESCE(book_counts.book_overdue, 0) AS overdue_books,
                COALESCE(equipment_counts.equipment_overdue, 0) AS overdue_equipment
         FROM sinh_vien s
         JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
         LEFT JOIN (
             SELECT lr.ma_ho_so_sinh_vien, COUNT(*) AS book_overdue
             FROM phieu_muon_sach lr JOIN chi_tiet_muon_sach ld ON ld.ma_phieu_muon_sach = lr.ma
             WHERE ld.ngay_tra IS NULL AND ld.han_tra < CURDATE()
             GROUP BY lr.ma_ho_so_sinh_vien
         ) book_counts ON book_counts.ma_ho_so_sinh_vien = s.ma
         LEFT JOIN (
             SELECT el.ma_ho_so_sinh_vien, COUNT(*) AS equipment_overdue
             FROM phieu_muon_thiet_bi el JOIN chi_tiet_muon_thiet_bi eld ON eld.ma_phieu_muon_thiet_bi = el.ma
             WHERE eld.ngay_tra IS NULL AND eld.han_tra < CURDATE()
             GROUP BY el.ma_ho_so_sinh_vien
         ) equipment_counts ON equipment_counts.ma_ho_so_sinh_vien = s.ma
         WHERE book_counts.book_overdue IS NOT NULL OR equipment_counts.equipment_overdue IS NOT NULL
         ORDER BY overdue_books DESC, overdue_equipment DESC'
    );
    return $statement->fetchAll();
}

function accounts_list(PDO $pdo): array
{
    $statement = $pdo->query(
        'SELECT a.ma, a.ten_dang_nhap, a.ho_ten, a.thu_dien_tu, a.vai_tro,
                a.thoi_diem_dang_ky, s.ma_sinh_vien, s.khoa, s.lop,
                l.ma_thu_thu
         FROM tai_khoan a
         LEFT JOIN sinh_vien s ON s.ma_tai_khoan = a.ma
         LEFT JOIN thu_thu l ON l.ma_tai_khoan = a.ma
         ORDER BY FIELD(a.vai_tro, \'admin\', \'librarian\', \'student\'), a.ho_ten'
    );
    return $statement->fetchAll();
}

function top_books(PDO $pdo, int $limit = 10): array
{
    return popular_books($pdo, $limit);
}

function top_rooms(PDO $pdo, int $limit = 10): array
{
    $limit = max(1, min($limit, 100));
    $statement = $pdo->prepare(
        'SELECT r.ma, r.ten, r.loai_phong, r.suc_chua, COUNT(rr.ma) AS booking_count
         FROM phong r LEFT JOIN yeu_cau_dat_phong rr ON rr.ma_phong = r.ma AND rr.trang_thai IN (\'approved\', \'completed\')
         GROUP BY r.ma, r.ten, r.loai_phong, r.suc_chua
         ORDER BY booking_count DESC, r.ten
         LIMIT :limit'
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function top_equipment(PDO $pdo, int $limit = 10): array
{
    $limit = max(1, min($limit, 100));
    $statement = $pdo->prepare(
        'SELECT e.ma, e.ten, e.loai_thiet_bi, COALESCE(SUM(eld.so_luong), 0) AS borrow_count
         FROM thiet_bi e LEFT JOIN chi_tiet_muon_thiet_bi eld ON eld.ma_thiet_bi = e.ma
         GROUP BY e.ma, e.ten, e.loai_thiet_bi
         ORDER BY borrow_count DESC, e.ten
         LIMIT :limit'
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}
