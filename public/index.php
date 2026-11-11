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
            "SELECT a.id, a.username, a.password, a.full_name, a.role,
                    s.id AS student_id, s.student_code, s.faculty, s.class_name,
                    l.id AS librarian_id, l.librarian_code
             FROM accounts a
             LEFT JOIN students s ON s.account_id = a.id
             LEFT JOIN librarians l ON l.account_id = a.id
             WHERE a.username = :username
             LIMIT 1"
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
            $upgrade=$pdo->prepare('UPDATE accounts SET password = ? WHERE id = ? AND password = ?');
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
                'SELECT a.full_name, s.faculty, s.class_name
                 FROM accounts a LEFT JOIN students s ON s.account_id = a.id
                 WHERE a.id = :id LIMIT 1'
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

    if ($resource==='extension-requests' && $method==='GET') json_response(['data'=>extension_requests_list($pdo)]);
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
            $q=$pdo->prepare("SELECT e.name, eld.quantity, DATEDIFF(CURDATE(),eld.due_date) AS overdue_days FROM equipment_loan_details eld JOIN equipment_loans el ON el.id=eld.loan_id JOIN equipment e ON e.id=eld.equipment_id WHERE el.student_id=? AND eld.return_date IS NULL AND eld.due_date<CURDATE() ORDER BY eld.due_date");
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
        "SELECT a.id, a.username, a.full_name, a.date_of_birth, a.email, a.phone,
                a.address, a.registered_at, a.role,
                s.student_code, s.faculty, s.class_name,
                l.librarian_code
         FROM accounts a
         LEFT JOIN students s ON s.account_id = a.id
         LEFT JOIN librarians l ON l.account_id = a.id
         WHERE a.id = :id
         LIMIT 1"
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
            'UPDATE accounts
             SET full_name = :full_name, date_of_birth = :date_of_birth, email = :email,
                 phone = :phone, address = :address
             WHERE id = :id'
        );
        $account->execute([
            'full_name' => $fullName,
            'date_of_birth' => $dateOfBirth,
            'email' => $email === '' ? null : $email,
            'phone' => $phone === '' ? null : $phone,
            'address' => $address === '' ? null : $address,
            'id' => $accountId,
        ]);

        $student = $pdo->prepare('UPDATE students SET faculty = :faculty, class_name = :class_name WHERE account_id = :account_id');
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
            "SELECT 'book' AS resource_type, b.title AS resource_name, ld.due_date, 1 AS quantity,
                    (ld.due_date < CURDATE()) AS overdue
             FROM loan_details ld
             JOIN loan_receipts lr ON lr.id = ld.receipt_id
             JOIN book_copies bc ON bc.id = ld.copy_id
             JOIN books b ON b.id = bc.book_id
             WHERE lr.student_id = :book_student AND ld.return_date IS NULL
             UNION ALL
             SELECT 'equipment' AS resource_type, e.name AS resource_name, eld.due_date, eld.quantity,
                    (eld.due_date < CURDATE()) AS overdue
             FROM equipment_loan_details eld
             JOIN equipment_loans el ON el.id = eld.loan_id
             JOIN equipment e ON e.id = eld.equipment_id
             WHERE el.student_id = :equipment_student AND eld.return_date IS NULL
             ORDER BY due_date ASC"
        );
        $loans->execute(['book_student' => $studentId, 'equipment_student' => $studentId]);
        $activeLoans = $loans->fetchAll();
        $rooms = $pdo->prepare(
            "SELECT rr.id, r.name, rr.use_date, rr.start_time, rr.end_time, rr.status
             FROM room_requests rr JOIN rooms r ON r.id = rr.room_id
             WHERE rr.student_id = :student AND rr.status IN ('pending', 'approved')
               AND (rr.use_date > CURDATE() OR (rr.use_date = CURDATE() AND rr.end_time > CURTIME()))
             ORDER BY rr.use_date, rr.start_time"
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
        "SELECT b.*, p.name AS publisher, p.address AS publisher_address,
                p.email AS publisher_email
         FROM books b JOIN publishers p ON p.id = b.publisher_id
         WHERE b.id = :id"
    );
    $statement->execute(['id' => $bookId]);
    $book = $statement->fetch();
    if (!$book) {
        json_response(['message' => 'Khong tim thay sach.'], 404);
    }

    $book['authors'] = book_relation_names($pdo, 'authors', $bookId);
    $book['genres'] = book_relation_names($pdo, 'genres', $bookId);
    $book['keywords'] = book_relation_names($pdo, 'keywords', $bookId);

    $ebook = $pdo->prepare('SELECT id, file_format, file_size_mb, resolution, file_path FROM ebooks WHERE book_id = :id');
    $ebook->execute(['id' => $bookId]);
    $book['ebook'] = $ebook->fetch() ?: null;

    $copyVisibility=resource_staff_access()?'':' AND is_visible = 1';
    $copies = $pdo->prepare('SELECT id, barcode, storage_location, condition_status, status FROM book_copies WHERE book_id = :id AND deleted_at IS NULL'.$copyVisibility.' ORDER BY barcode');
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
        "SELECT b.id, COUNT(c.id) AS available_count
         FROM books b
         LEFT JOIN book_copies c ON c.book_id = b.id AND c.status = 'available' AND c.is_visible = 1 AND c.deleted_at IS NULL
         WHERE b.id = :id AND b.is_visible = 1 AND b.deleted_at IS NULL
         GROUP BY b.id"
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
            'SELECT id FROM books WHERE id = ? AND is_visible = 1 AND deleted_at IS NULL FOR UPDATE'
        );
        foreach ($items as $item) {
            $guard->execute([$item['book_id']]);
            if (!$guard->fetchColumn()) throw new ApiException('Đầu sách đã ngừng hiển thị. Hãy tải lại kho sách.',409);
        }
        $request = $pdo->prepare('INSERT INTO book_loan_requests (student_id, note) VALUES (:student_id, :note)');
        $request->execute(['student_id' => $user['student_id'], 'note' => request_note($body)]);
        $requestId = (int) $pdo->lastInsertId();

        $detail = $pdo->prepare(
            'INSERT INTO book_loan_request_items (request_id, book_id, quantity, requested_due_date)
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
        "SELECT id
         FROM equipment
         WHERE id = :id AND status = 'available' AND is_visible=1 AND deleted_at IS NULL AND available_quantity >= :quantity"
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
            'SELECT id FROM equipment WHERE id = ? AND is_visible = 1 AND deleted_at IS NULL FOR UPDATE'
        );
        foreach ($items as $item) {
            $guard->execute([$item['equipment_id']]);
            if (!$guard->fetchColumn()) throw new ApiException('Thiết bị đã ngừng hiển thị. Hãy tải lại danh sách.',409);
        }
        $request = $pdo->prepare('INSERT INTO equipment_loan_requests (student_id, note) VALUES (:student_id, :note)');
        $request->execute(['student_id' => $user['student_id'], 'note' => request_note($body)]);
        $requestId = (int) $pdo->lastInsertId();

        $detail = $pdo->prepare(
            'INSERT INTO equipment_loan_request_items (request_id, equipment_id, quantity, requested_due_date)
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
        $room = $pdo->prepare('SELECT id FROM rooms WHERE id = :id AND status = \'available\' AND is_visible=1 AND deleted_at IS NULL FOR UPDATE');
        $room->execute(['id' => $roomId]);
        if (!$room->fetch()) {
            throw new ApiException('Phong nay khong con san sang.');
        }

        $conflict = $pdo->prepare(
            "SELECT 1 FROM room_requests
             WHERE room_id = :room_id AND use_date = :use_date
               AND status IN ('pending', 'approved')
               AND start_time < :end_time AND end_time > :start_time
             LIMIT 1"
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
            "INSERT INTO room_requests (student_id, room_id, use_date, start_time, end_time, purpose, status)
             VALUES (:student_id, :room_id, :use_date, :start_time, :end_time, :purpose, 'pending')"
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
        "SELECT 'book' AS request_type, r.id, r.requested_at, r.status, r.note, r.review_note,
                GROUP_CONCAT(CONCAT(b.title, ' · Số lượng: ', i.quantity, ' (hạn ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y'), ')') ORDER BY i.id SEPARATOR ' | ') AS items
         FROM book_loan_requests r
         JOIN book_loan_request_items i ON i.request_id = r.id
         JOIN books b ON b.id = i.book_id
         WHERE r.student_id = :book_student_id
         GROUP BY r.id, r.requested_at, r.status, r.note, r.review_note
         UNION ALL
         SELECT 'equipment' AS request_type, r.id, r.requested_at, r.status, r.note, r.review_note,
                GROUP_CONCAT(CONCAT(e.name, ' x', i.quantity, ' (hạn ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y'), ')') ORDER BY i.id SEPARATOR ' | ') AS items
         FROM equipment_loan_requests r
         JOIN equipment_loan_request_items i ON i.request_id = r.id
         JOIN equipment e ON e.id = i.equipment_id
         WHERE r.student_id = :equipment_student_id
         GROUP BY r.id, r.requested_at, r.status, r.note, r.review_note
         UNION ALL
         SELECT 'room' AS request_type, rr.id, rr.created_at AS requested_at, rr.status,
                NULL AS note, NULL AS review_note,
                CONCAT(r.name, ' - ', DATE_FORMAT(rr.use_date, '%d/%m/%Y'), ' ',
                       TIME_FORMAT(rr.start_time, '%H:%i'), '-', TIME_FORMAT(rr.end_time, '%H:%i'),
                       ' (', rr.purpose, ')') AS items
         FROM room_requests rr
         JOIN rooms r ON r.id = rr.room_id
         WHERE rr.student_id = :room_student_id
         ORDER BY requested_at DESC"
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
        "SELECT 'book' AS request_type, r.id, r.requested_at, 'Muon sach' AS request_label,
                a.full_name AS student_name, s.student_code,
                GROUP_CONCAT(CONCAT(b.title, ' · Số lượng: ', i.quantity, ' (hạn ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y'), ')') ORDER BY i.id SEPARATOR ' | ') AS items
         FROM book_loan_requests r
         JOIN students s ON s.id = r.student_id
         JOIN accounts a ON a.id = s.account_id
         JOIN book_loan_request_items i ON i.request_id = r.id
         JOIN books b ON b.id = i.book_id
         WHERE r.status = 'pending'
         GROUP BY r.id, r.requested_at, a.full_name, s.student_code
         UNION ALL
         SELECT 'equipment' AS request_type, r.id, r.requested_at, 'Muon thiet bi' AS request_label,
                a.full_name AS student_name, s.student_code,
                GROUP_CONCAT(CONCAT(e.name, ' x', i.quantity, ' (hạn ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y'), ')') ORDER BY i.id SEPARATOR ' | ') AS items
         FROM equipment_loan_requests r
         JOIN students s ON s.id = r.student_id
         JOIN accounts a ON a.id = s.account_id
         JOIN equipment_loan_request_items i ON i.request_id = r.id
         JOIN equipment e ON e.id = i.equipment_id
         WHERE r.status = 'pending'
         GROUP BY r.id, r.requested_at, a.full_name, s.student_code
         UNION ALL
         SELECT 'room' AS request_type, rr.id, rr.created_at AS requested_at, 'Dat phong' AS request_label,
                a.full_name AS student_name, s.student_code,
                CONCAT(r.name, ' - ', DATE_FORMAT(rr.use_date, '%d/%m/%Y'), ' ', TIME_FORMAT(rr.start_time, '%H:%i'), '-', TIME_FORMAT(rr.end_time, '%H:%i'), ' (', rr.purpose, ')') AS items
         FROM room_requests rr
         JOIN students s ON s.id = rr.student_id
         JOIN accounts a ON a.id = s.account_id
         JOIN rooms r ON r.id = rr.room_id
         WHERE rr.status = 'pending'
         ORDER BY requested_at ASC
         LIMIT :limit"
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function reviewed_borrow_requests(PDO $pdo, int $limit = 100): array
{
    $limit = max(1, min($limit, 200));
    $statement = $pdo->prepare(
        "SELECT * FROM (
            SELECT 'book' AS request_type, r.id, r.requested_at, r.reviewed_at, r.status,
                   r.note AS request_note, r.review_note,
                   'Muon sach' AS request_label, a.full_name AS student_name, s.student_code,
                   GROUP_CONCAT(CONCAT(b.title, ' · Số lượng: ', i.quantity, ' (hạn ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y'), ')') ORDER BY i.id SEPARATOR ' | ') AS items,
                   la.full_name AS librarian_name
            FROM book_loan_requests r
            JOIN students s ON s.id = r.student_id
            JOIN accounts a ON a.id = s.account_id
            LEFT JOIN librarians l ON l.id = r.librarian_id
            LEFT JOIN accounts la ON la.id = l.account_id
            JOIN book_loan_request_items i ON i.request_id = r.id
            JOIN books b ON b.id = i.book_id
            WHERE r.status IN ('approved', 'rejected')
            GROUP BY r.id, r.requested_at, r.reviewed_at, r.status, r.note, r.review_note,
                     a.full_name, s.student_code, la.full_name
            UNION ALL
            SELECT 'equipment' AS request_type, r.id, r.requested_at, r.reviewed_at, r.status,
                   r.note AS request_note, r.review_note,
                   'Muon thiet bi' AS request_label, a.full_name AS student_name, s.student_code,
                   GROUP_CONCAT(CONCAT(e.name, ' x', i.quantity, ' (hạn ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y'), ')') ORDER BY i.id SEPARATOR ' | ') AS items,
                   la.full_name AS librarian_name
            FROM equipment_loan_requests r
            JOIN students s ON s.id = r.student_id
            JOIN accounts a ON a.id = s.account_id
            LEFT JOIN librarians l ON l.id = r.librarian_id
            LEFT JOIN accounts la ON la.id = l.account_id
            JOIN equipment_loan_request_items i ON i.request_id = r.id
            JOIN equipment e ON e.id = i.equipment_id
            WHERE r.status IN ('approved', 'rejected')
            GROUP BY r.id, r.requested_at, r.reviewed_at, r.status, r.note, r.review_note,
                     a.full_name, s.student_code, la.full_name
            UNION ALL
            SELECT 'room' AS request_type, rr.id, rr.created_at AS requested_at, rr.reviewed_at,
                   rr.status, NULL AS request_note, rr.review_note,
                   'Dat phong' AS request_label, a.full_name AS student_name, s.student_code,
                   CONCAT(r.name, ' - ', DATE_FORMAT(rr.use_date, '%d/%m/%Y'), ' ',
                          TIME_FORMAT(rr.start_time, '%H:%i'), '-', TIME_FORMAT(rr.end_time, '%H:%i'),
                          ' (', rr.purpose, ')') AS items,
                   la.full_name AS librarian_name
            FROM room_requests rr
            JOIN students s ON s.id = rr.student_id
            JOIN accounts a ON a.id = s.account_id
            LEFT JOIN librarians l ON l.id = rr.librarian_id
            LEFT JOIN accounts la ON la.id = l.account_id
            JOIN rooms r ON r.id = rr.room_id
            WHERE rr.status IN ('approved', 'rejected', 'completed')
        ) reviewed_requests
        ORDER BY reviewed_at DESC, requested_at DESC
        LIMIT :limit"
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function review_borrow_request(PDO $pdo, string $type, int $requestId): array
{
    $librarian = require_role('librarian');
    if (empty($librarian['librarian_id'])) {
        throw new ApiException('Khong tim thay thong tin thu thu.', 403);
    }

    $body = request_body();
    $decision = (string) ($body['decision'] ?? '');
    if (!in_array($decision, ['approved', 'rejected'], true)) {
        throw new ApiException('Quyet dinh duyet khong hop le.');
    }

    return match ($type) {
        'book' => review_book_request($pdo, $requestId, (int) $librarian['librarian_id'], $decision, request_note($body)),
        'equipment' => review_equipment_request($pdo, $requestId, (int) $librarian['librarian_id'], $decision, request_note($body)),
        'room' => review_room_request($pdo, $requestId, (int) $librarian['librarian_id'], $decision, request_note($body)),
        default => throw new ApiException('Loai yeu cau khong hop le.'),
    };
}

function review_book_request(PDO $pdo, int $requestId, int $librarianId, string $decision, ?string $reviewNote): array
{
    $ownsTransaction = !$pdo->inTransaction();
    if ($ownsTransaction) $pdo->beginTransaction();
    try {
        $request = $pdo->prepare('SELECT * FROM book_loan_requests WHERE id = :id FOR UPDATE');
        $request->execute(['id' => $requestId]);
        $header = $request->fetch();
        if (!$header) {
            throw new ApiException('Khong tim thay yeu cau muon sach.', 404);
        }
        if ($header['status'] !== 'pending') {
            throw new ApiException('Yeu cau nay da duoc xu ly.');
        }

        if ($decision === 'rejected') {
            $update = $pdo->prepare(
                "UPDATE book_loan_requests
                 SET status = 'rejected', librarian_id = :librarian_id, reviewed_at = NOW(), review_note = :review_note
                 WHERE id = :id"
            );
            $update->execute(['librarian_id' => $librarianId, 'review_note' => $reviewNote, 'id' => $requestId]);
            if ($ownsTransaction) $pdo->commit();
            return ['id' => $requestId, 'type' => 'book', 'status' => 'rejected'];
        }

        $itemsStatement = $pdo->prepare('SELECT book_id, quantity, requested_due_date FROM book_loan_request_items WHERE request_id = :id ORDER BY book_id');
        $itemsStatement->execute(['id' => $requestId]);
        $items = $itemsStatement->fetchAll();
        if ($items === []) {
            throw new ApiException('Yeu cau muon sach khong co chi tiet.');
        }

        $copyStatement = $pdo->prepare(
            "SELECT id FROM book_copies
             WHERE book_id = :book_id AND status = 'available' AND is_visible=1 AND deleted_at IS NULL
             ORDER BY id FOR UPDATE"
        );
        $copies = [];
        $bookGuard = $pdo->prepare(
            'SELECT id FROM books WHERE id = ? AND is_visible = 1 AND deleted_at IS NULL FOR UPDATE'
        );
        foreach ($items as $item) {
            if ($item['requested_due_date'] <= date('Y-m-d')) {
                throw new ApiException('Han tra cua yeu cau da qua. Sinh vien can tao yeu cau moi.');
            }
            $bookGuard->execute([$item['book_id']]);
            if (!$bookGuard->fetchColumn()) throw new ApiException('Đầu sách đang ẩn hoặc đã xóa. Không thể duyệt yêu cầu.',409);
            $copyStatement->execute(['book_id' => $item['book_id']]);
            $availableCopies = $copyStatement->fetchAll();
            $quantity = (int) $item['quantity'];
            if (count($availableCopies) < $quantity) {
                throw new ApiException('Mot hoac nhieu sach khong con du so luong ban sao san sang.');
            }
            for ($copyIndex = 0; $copyIndex < $quantity; $copyIndex++) {
                $copies[] = ['copy_id' => (int) $availableCopies[$copyIndex]['id'], 'due_date' => $item['requested_due_date']];
            }
        }

        $receipt = $pdo->prepare(
            "INSERT INTO loan_receipts (student_id, librarian_id, note, status, request_id)
             VALUES (:student_id, :librarian_id, :note, 'open', :request_id)"
        );
        $receiptNote = substr(trim('Duyet yeu cau sach #' . $requestId . ' ' . (string) $header['note']), 0, 255);
        $receipt->execute(['student_id' => $header['student_id'], 'librarian_id' => $librarianId, 'note' => $receiptNote, 'request_id'=>$requestId]);
        $receiptId = (int) $pdo->lastInsertId();

        $loanDetail = $pdo->prepare(
            "INSERT INTO loan_details (receipt_id, copy_id, borrow_date, due_date, status)
             VALUES (:receipt_id, :copy_id, CURDATE(), :due_date, 'borrowed')"
        );
        $markBorrowed = $pdo->prepare("UPDATE book_copies SET status = 'borrowed' WHERE id = :id");
        foreach ($copies as $copy) {
            $loanDetail->execute(['receipt_id' => $receiptId, 'copy_id' => $copy['copy_id'], 'due_date' => $copy['due_date']]);
            $markBorrowed->execute(['id' => $copy['copy_id']]);
        }

        $update = $pdo->prepare(
            "UPDATE book_loan_requests
             SET status = 'approved', librarian_id = :librarian_id, reviewed_at = NOW(), review_note = :review_note
             WHERE id = :id"
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
        $request = $pdo->prepare('SELECT * FROM equipment_loan_requests WHERE id = :id FOR UPDATE');
        $request->execute(['id' => $requestId]);
        $header = $request->fetch();
        if (!$header) {
            throw new ApiException('Khong tim thay yeu cau muon thiet bi.', 404);
        }
        if ($header['status'] !== 'pending') {
            throw new ApiException('Yeu cau nay da duoc xu ly.');
        }

        if ($decision === 'rejected') {
            $update = $pdo->prepare(
                "UPDATE equipment_loan_requests
                 SET status = 'rejected', librarian_id = :librarian_id, reviewed_at = NOW(), review_note = :review_note
                 WHERE id = :id"
            );
            $update->execute(['librarian_id' => $librarianId, 'review_note' => $reviewNote, 'id' => $requestId]);
            if ($ownsTransaction) $pdo->commit();
            return ['id' => $requestId, 'type' => 'equipment', 'status' => 'rejected'];
        }

        $itemsStatement = $pdo->prepare(
            'SELECT equipment_id, quantity, requested_due_date FROM equipment_loan_request_items WHERE request_id = :id ORDER BY equipment_id'
        );
        $itemsStatement->execute(['id' => $requestId]);
        $items = $itemsStatement->fetchAll();
        if ($items === []) {
            throw new ApiException('Yeu cau muon thiet bi khong co chi tiet.');
        }

        $equipmentStatement = $pdo->prepare('SELECT id, available_quantity, status FROM equipment WHERE id = :id AND is_visible=1 AND deleted_at IS NULL FOR UPDATE');
        $equipmentUpdates = [];
        foreach ($items as $item) {
            if ($item['requested_due_date'] <= date('Y-m-d')) {
                throw new ApiException('Han tra cua yeu cau da qua. Sinh vien can tao yeu cau moi.');
            }
            $equipmentStatement->execute(['id' => $item['equipment_id']]);
            $equipment = $equipmentStatement->fetch();
            if (!$equipment || $equipment['status'] !== 'available' || (int) $equipment['available_quantity'] < (int) $item['quantity']) {
                throw new ApiException('Mot hoac nhieu thiet bi khong du so luong san sang.');
            }
            $equipmentUpdates[] = [
                'equipment_id' => (int) $equipment['id'],
                'quantity' => (int) $item['quantity'],
                'due_date' => $item['requested_due_date'],
                'available_quantity' => (int) $equipment['available_quantity'] - (int) $item['quantity'],
            ];
        }

        $loan = $pdo->prepare(
            "INSERT INTO equipment_loans (student_id, librarian_id, note, status, request_id)
             VALUES (:student_id, :librarian_id, :note, 'borrowed', :request_id)"
        );
        $loanNote = substr(trim('Duyet yeu cau thiet bi #' . $requestId . ' ' . (string) $header['note']), 0, 255);
        $loan->execute(['student_id' => $header['student_id'], 'librarian_id' => $librarianId, 'note' => $loanNote, 'request_id'=>$requestId]);
        $loanId = (int) $pdo->lastInsertId();

        $loanDetail = $pdo->prepare(
            "INSERT INTO equipment_loan_details (loan_id, equipment_id, quantity, borrow_date, due_date, condition_on_borrow, status)
             VALUES (:loan_id, :equipment_id, :quantity, CURDATE(), :due_date, 'Tot', 'borrowed')"
        );
        $updateEquipment = $pdo->prepare(
            'UPDATE equipment SET available_quantity = :available_quantity, status = :status WHERE id = :id'
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
            "UPDATE equipment_loan_requests
             SET status = 'approved', librarian_id = :librarian_id, reviewed_at = NOW(), review_note = :review_note
             WHERE id = :id"
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
        $request = $pdo->prepare('SELECT * FROM room_requests WHERE id = :id FOR UPDATE');
        $request->execute(['id' => $requestId]);
        $header = $request->fetch();
        if (!$header) {
            throw new ApiException('Khong tim thay yeu cau dat phong.', 404);
        }
        if ($header['status'] !== 'pending') {
            throw new ApiException('Yeu cau nay da duoc xu ly.');
        }

        if ($decision === 'approved') {
            $room = $pdo->prepare('SELECT status FROM rooms WHERE id = :id AND is_visible=1 AND deleted_at IS NULL FOR UPDATE');
            $room->execute(['id' => $header['room_id']]);
            $roomData = $room->fetch();
            if (!$roomData || $roomData['status'] !== 'available') {
                throw new ApiException('Phong nay khong con san sang de duyet.');
            }

            $conflict = $pdo->prepare(
                "SELECT 1 FROM room_requests
                 WHERE room_id = :room_id AND id <> :request_id AND use_date = :use_date
                   AND status = 'approved'
                   AND start_time < :end_time AND end_time > :start_time
             LIMIT 1"
            );
            $conflict->execute([
                'room_id' => $header['room_id'],
                'request_id' => $requestId,
                'use_date' => $header['use_date'],
                'start_time' => $header['start_time'],
                'end_time' => $header['end_time'],
            ]);
            if ($conflict->fetchColumn() !== false) {
                throw new ApiException('Phong da co lich duoc duyet trong khung gio nay.');
            }
        }

        $update = $pdo->prepare(
            'UPDATE room_requests
             SET status = :status, librarian_id = :librarian_id, reviewed_at = NOW(), review_note = :review_note
             WHERE id = :id'
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
        "SELECT ld.id AS loan_detail_id, b.id AS book_id, b.title, c.barcode,
                s.student_code, a.full_name AS student_name, ld.borrow_date,
                ld.due_date, DATEDIFF(CURDATE(), ld.due_date) AS overdue_days,
                ld.extension_count, lr.id AS receipt_id
         FROM loan_details ld
         JOIN loan_receipts lr ON lr.id = ld.receipt_id
         JOIN students s ON s.id = lr.student_id
         JOIN accounts a ON a.id = s.account_id
         JOIN book_copies c ON c.id = ld.copy_id
         JOIN books b ON b.id = c.book_id
         WHERE ld.return_date IS NULL AND ld.due_date < CURDATE()
         ORDER BY overdue_days DESC, ld.due_date ASC"
    );
    return $statement->fetchAll();
}

function returned_books(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT ld.id AS loan_detail_id, lr.id AS receipt_id, b.title, c.barcode, s.student_code,
                a.full_name AS student_name, ld.borrow_date, ld.due_date,
                ld.return_date, ld.extension_count,
                CASE WHEN ld.return_status = 'late' THEN 'Tra tre'
                     WHEN ld.return_status = 'on_time' THEN 'Tra dung han'
                     WHEN ld.return_date > ld.due_date THEN 'Tra tre' ELSE 'Tra dung han' END AS return_status,
                CASE WHEN ld.return_status = 'late' THEN ld.late_days
                     ELSE GREATEST(DATEDIFF(ld.return_date, ld.due_date), 0) END AS late_days
         FROM loan_details ld
         JOIN loan_receipts lr ON lr.id = ld.receipt_id
         JOIN students s ON s.id = lr.student_id
         JOIN accounts a ON a.id = s.account_id
         JOIN book_copies c ON c.id = ld.copy_id
         JOIN books b ON b.id = c.book_id
         WHERE ld.return_date IS NOT NULL
         ORDER BY ld.return_date DESC"
    );
    return $statement->fetchAll();
}

function active_book_loans(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT ld.id AS loan_detail_id, lr.id AS receipt_id, b.title, c.barcode, s.student_code,
                a.full_name AS student_name, ld.borrow_date, ld.due_date,
                ld.extension_count,
                CASE WHEN ld.due_date < CURDATE() THEN 'Qua han' ELSE 'Dang muon' END AS loan_status,
                DATEDIFF(CURDATE(), ld.due_date) AS overdue_days
         FROM loan_details ld
         JOIN loan_receipts lr ON lr.id = ld.receipt_id
         JOIN students s ON s.id = lr.student_id
         JOIN accounts a ON a.id = s.account_id
         JOIN book_copies c ON c.id = ld.copy_id
         JOIN books b ON b.id = c.book_id
         WHERE ld.return_date IS NULL
         ORDER BY (ld.due_date < CURDATE()) DESC, ld.due_date ASC, ld.id ASC"
    );
    return $statement->fetchAll();
}

function active_equipment_loans(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT eld.id AS equipment_detail_id, e.name, e.equipment_type,
                eld.quantity, s.student_code, a.full_name AS student_name,
                eld.borrow_date, eld.due_date,
                CASE WHEN eld.due_date < CURDATE() THEN 'Qua han' ELSE 'Dang muon' END AS loan_status,
                DATEDIFF(CURDATE(), eld.due_date) AS overdue_days
         FROM equipment_loan_details eld
         JOIN equipment_loans el ON el.id = eld.loan_id
         JOIN equipment e ON e.id = eld.equipment_id
         JOIN students s ON s.id = el.student_id
         JOIN accounts a ON a.id = s.account_id
         WHERE eld.return_date IS NULL
         ORDER BY (eld.due_date < CURDATE()) DESC, eld.due_date ASC, eld.id ASC"
    );
    return $statement->fetchAll();
}

function room_usage_history(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT rr.id AS room_request_id, r.name AS room_name, r.room_type,
                s.student_code, a.full_name AS student_name, rr.use_date,
                rr.start_time, rr.end_time, rr.purpose, rr.status,
                rr.reviewed_at
         FROM room_requests rr
         JOIN rooms r ON r.id = rr.room_id
         JOIN students s ON s.id = rr.student_id
         JOIN accounts a ON a.id = s.account_id
         WHERE rr.status IN ('approved', 'completed', 'rejected')
         ORDER BY rr.use_date DESC, rr.start_time DESC, rr.id DESC
         LIMIT 30"
    );
    return $statement->fetchAll();
}

function mark_room_completed(PDO $pdo, int $roomRequestId): array
{
    $pdo->beginTransaction();
    try {
        $request = $pdo->prepare(
            "SELECT rr.id, rr.status, rr.use_date, rr.end_time, r.name AS room_name
             FROM room_requests rr
             JOIN rooms r ON r.id = rr.room_id
             WHERE rr.id = :id
             FOR UPDATE"
        );
        $request->execute(['id' => $roomRequestId]);
        $room = $request->fetch();
        if (!$room) {
            throw new ApiException('Khong tim thay lich dat phong.', 404);
        }
        if ($room['status'] !== 'approved') {
            throw new ApiException('Chi lich dat phong da duoc duyet moi co the ket thuc.');
        }
        $update = $pdo->prepare("UPDATE room_requests SET status = 'completed' WHERE id = :id");
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
            "SELECT ld.id, ld.receipt_id, ld.copy_id, ld.borrow_date, ld.due_date, ld.return_date,
                    b.title, c.barcode, s.student_code, a.full_name AS student_name
             FROM loan_details ld
             JOIN loan_receipts lr ON lr.id = ld.receipt_id
             JOIN students s ON s.id = lr.student_id
             JOIN accounts a ON a.id = s.account_id
             JOIN book_copies c ON c.id = ld.copy_id
             JOIN books b ON b.id = c.book_id
             WHERE ld.id = :id
             FOR UPDATE"
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
        $computed=integrity_return_result($loan['due_date'],$returnDate);
        $returnStatus=$computed['return_status'];$lateDays=$computed['late_days'];

        $update = $pdo->prepare(
            "UPDATE loan_details
             SET return_date = :return_date, return_status = :return_status, late_days = :late_days,
                 status = 'returned', condition_on_return = :condition
             WHERE id = :id"
        );
        $update->execute([
            'return_date' => $returnDate,
            'return_status' => $returnStatus,
            'late_days' => $lateDays,
            'condition' => $condition,
            'id' => $loanDetailId,
        ]);

        $copyStatus = $condition === 'lost' ? 'lost' : ($condition === 'damaged' ? 'damaged' : 'available');
        $copy = $pdo->prepare('UPDATE book_copies SET status = :status WHERE id = :id');
        $copy->execute(['status' => $copyStatus, 'id' => $loan['copy_id']]);

        $receipt = $pdo->prepare(
            "UPDATE loan_receipts
             SET status = CASE WHEN NOT EXISTS (
                 SELECT 1 FROM loan_details ld WHERE ld.receipt_id = loan_receipts.id AND ld.return_date IS NULL
             ) THEN 'completed' ELSE 'open' END
             WHERE id = :id"
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
            "SELECT eld.id, eld.loan_id, eld.equipment_id, eld.quantity, eld.borrow_date, eld.due_date, eld.return_date,
                    e.name, s.student_code, a.full_name AS student_name
             FROM equipment_loan_details eld
             JOIN equipment_loans el ON el.id = eld.loan_id
             JOIN equipment e ON e.id = eld.equipment_id
             JOIN students s ON s.id = el.student_id
             JOIN accounts a ON a.id = s.account_id
             WHERE eld.id = :id
             FOR UPDATE"
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
        $computed=integrity_return_result($loan['due_date'],$returnDate);
        $returnStatus=$computed['return_status'];$lateDays=$computed['late_days'];

        $update = $pdo->prepare(
            "UPDATE equipment_loan_details
             SET return_date = :return_date, return_status = :return_status, late_days = :late_days,
                 status = 'returned', condition_on_return = :condition
             WHERE id = :id"
        );
        $update->execute([
            'return_date' => $returnDate,
            'return_status' => $returnStatus,
            'late_days' => $lateDays,
            'condition' => $condition,
            'id' => $equipmentDetailId,
        ]);

        $equipment = $pdo->prepare(
            "UPDATE equipment
             SET available_quantity = LEAST(total_quantity, available_quantity + :quantity),
                 status = CASE WHEN status IN ('maintenance','damaged') THEN status ELSE 'available' END
             WHERE id = :id"
        );
        $equipment->execute(['quantity' => $loan['quantity'], 'id' => $loan['equipment_id']]);

        $parent = $pdo->prepare(
            "UPDATE equipment_loans
             SET status = CASE WHEN NOT EXISTS (
                 SELECT 1 FROM equipment_loan_details eld WHERE eld.loan_id = equipment_loans.id AND eld.return_date IS NULL
             ) THEN 'returned' ELSE 'borrowed' END
             WHERE id = :id"
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
        "SELECT s.id, s.student_code, a.full_name, s.faculty, s.class_name
         FROM students s JOIN accounts a ON a.id = s.account_id
         WHERE s.student_code = :code"
    );
    $student->execute(['code' => $studentCode]);
    $studentData = $student->fetch();
    if (!$studentData) {
        json_response(['message' => 'Khong tim thay sinh vien.'], 404);
    }

    $books = $pdo->prepare(
        "SELECT 'book' AS resource_type, lr.id AS receipt_id, ld.id AS loan_detail_id, b.title AS resource_name,
                ld.borrow_date, ld.due_date, ld.return_date, ld.extension_count,
                CASE WHEN ld.return_date IS NULL AND ld.due_date < CURDATE() THEN 'Qua han'
                     WHEN ld.return_date IS NULL THEN 'Dang muon'
                     WHEN ld.return_status = 'late' THEN CONCAT('Tra tre ', ld.late_days, ' ngay')
                     WHEN ld.return_status = 'on_time' THEN 'Tra dung han'
                     WHEN ld.return_date > ld.due_date THEN CONCAT('Tra tre ', DATEDIFF(ld.return_date, ld.due_date), ' ngay')
                     ELSE 'Tra dung han' END AS status
         FROM loan_receipts lr
         JOIN loan_details ld ON ld.receipt_id = lr.id
         JOIN book_copies c ON c.id = ld.copy_id
         JOIN books b ON b.id = c.book_id
         WHERE lr.student_id = :student_id
         ORDER BY ld.borrow_date DESC"
    );
    $books->execute(['student_id' => $studentData['id']]);

    $equipment = $pdo->prepare(
        "SELECT 'equipment' AS resource_type, el.id AS receipt_id, e.name AS resource_name,
                eld.borrow_date, eld.due_date, eld.return_date, eld.quantity,
                CASE WHEN eld.return_date IS NULL AND eld.due_date < CURDATE() THEN 'Qua han'
                     WHEN eld.return_date IS NULL THEN 'Dang muon'
                     WHEN eld.return_status = 'late' THEN CONCAT('Tra tre ', eld.late_days, ' ngay')
                     WHEN eld.return_status = 'on_time' THEN 'Tra dung han'
                     WHEN eld.return_date > eld.due_date THEN CONCAT('Tra tre ', DATEDIFF(eld.return_date, eld.due_date), ' ngay')
                     ELSE 'Tra dung han' END AS status
         FROM equipment_loans el
         JOIN equipment_loan_details eld ON eld.loan_id = el.id
         JOIN equipment e ON e.id = eld.equipment_id
         WHERE el.student_id = :student_id
         ORDER BY eld.borrow_date DESC"
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
        "SELECT lr.id, lr.request_id, lr.registered_at, lr.status, lr.note,
                s.student_code, sa.full_name AS student_name,
                l.librarian_code, la.full_name AS librarian_name
         FROM loan_receipts lr
         JOIN students s ON s.id = lr.student_id
         JOIN accounts sa ON sa.id = s.account_id
         JOIN librarians l ON l.id = lr.librarian_id
         JOIN accounts la ON la.id = l.account_id
         WHERE lr.id = :id"
    );
    $receipt->execute(['id' => $receiptId]);
    $data = $receipt->fetch();
    if (!$data) {
        json_response(['message' => 'Khong tim thay phieu muon.'], 404);
    }

    $user=require_login();
    if ($user['role']==='student' && $data['student_code'] !== $user['student_code']) throw new ApiException('Bạn không có quyền xem phiếu mượn này.',403);

    $details = $pdo->prepare(
        "SELECT ld.id, 1 AS quantity, b.title, c.barcode, ld.borrow_date, ld.due_date,
                ld.return_date, ld.return_status, ld.late_days,
                ld.extension_count, ld.status
         FROM loan_details ld
         JOIN book_copies c ON c.id = ld.copy_id
         JOIN books b ON b.id = c.book_id
         WHERE ld.receipt_id = :id ORDER BY ld.id"
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
        "NOT EXISTS (
            SELECT 1 FROM room_requests rr
            WHERE rr.room_id = r.id AND rr.use_date = :date
              AND rr.status IN ('pending', 'approved')
              AND rr.start_time < :end AND rr.end_time > :start
        )",
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
        'SELECT r.id, r.name, r.room_type, r.location, r.capacity, r.included_equipment,
                r.operating_hours, r.status, r.image_path, r.image_is_illustration
         FROM rooms r WHERE ' . implode(' AND ', $where) . ' ORDER BY r.capacity'
    );
    bind_optional($statement, $params);
    $statement->execute();
    return $statement->fetchAll();
}

function room_schedule(PDO $pdo, ?int $roomId = null): array
{
    $date = normalize_date(query_string('date', date('Y-m-d')) ?? date('Y-m-d'), date('Y-m-d'));
    $params = [':date' => $date];
    $roomFilter = resource_staff_access()?'':' AND r.is_visible=1 AND r.deleted_at IS NULL';
    if ($roomId !== null) {
        $roomFilter .= ' AND rr.room_id = :room_id';
        $params[':room_id'] = $roomId;
    }

    $statement = $pdo->prepare(
        "SELECT rr.id AS room_request_id, r.id AS room_id, r.name AS room_name,
                r.room_type, rr.use_date, rr.start_time, rr.end_time, rr.purpose,
                rr.status, s.student_code, a.full_name AS student_name
         FROM room_requests rr
         JOIN rooms r ON r.id = rr.room_id
         JOIN students s ON s.id = rr.student_id
         JOIN accounts a ON a.id = s.account_id
         WHERE rr.use_date = :date
           AND rr.status IN ('pending', 'approved', 'completed')
           $roomFilter
         ORDER BY r.name, rr.start_time, rr.end_time"
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
        $where = 'WHERE rr.status = :status';
        $params[':status'] = $status;
    }

    if ($user['role']==='student') {
        $where .= ($where === '' ? 'WHERE ' : ' AND ') . 'rr.student_id = :own_student';
        $params[':own_student']=(int)$user['student_id'];
    }
    $statement = $pdo->prepare(
        "SELECT rr.id, rr.use_date, rr.start_time, rr.end_time, rr.purpose, rr.status,
                r.name AS room_name, r.room_type, r.capacity,
                s.student_code, a.full_name AS student_name
         FROM room_requests rr
         JOIN rooms r ON r.id = rr.room_id
         JOIN students s ON s.id = rr.student_id
         JOIN accounts a ON a.id = s.account_id
         $where
         ORDER BY rr.use_date ASC, rr.start_time ASC
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
        'SELECT e.id, e.name, e.equipment_type, e.manufacturer, e.total_quantity,
                e.available_quantity, e.storage_location, e.serial_number, e.status, e.image_path, e.image_is_illustration
         FROM equipment e WHERE ' . implode(' AND ', $where) . ' ORDER BY e.available_quantity DESC, e.name'
    );
    bind_optional($statement, $params);
    $statement->execute();
    return $statement->fetchAll();
}

function overdue_equipment(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT eld.id, e.name, e.equipment_type, eld.quantity, eld.borrow_date,
                eld.due_date, DATEDIFF(CURDATE(), eld.due_date) AS overdue_days,
                s.student_code, a.full_name AS student_name, el.id AS loan_id
         FROM equipment_loan_details eld
         JOIN equipment_loans el ON el.id = eld.loan_id
         JOIN equipment e ON e.id = eld.equipment_id
         JOIN students s ON s.id = el.student_id
         JOIN accounts a ON a.id = s.account_id
         WHERE eld.return_date IS NULL AND eld.due_date < CURDATE()
         ORDER BY overdue_days DESC"
    );
    return $statement->fetchAll();
}

function returned_equipment(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT eld.id AS equipment_detail_id, e.name, eld.quantity,
                s.student_code, a.full_name AS student_name, eld.borrow_date,
                eld.due_date, eld.return_date,
                CASE WHEN eld.return_status = 'late' THEN 'Tra tre'
                     WHEN eld.return_status = 'on_time' THEN 'Tra dung han'
                     WHEN eld.return_date > eld.due_date THEN 'Tra tre' ELSE 'Tra dung han' END AS return_status,
                CASE WHEN eld.return_status = 'late' THEN eld.late_days
                     ELSE GREATEST(DATEDIFF(eld.return_date, eld.due_date), 0) END AS late_days
         FROM equipment_loan_details eld
         JOIN equipment_loans el ON el.id = eld.loan_id
         JOIN equipment e ON e.id = eld.equipment_id
         JOIN students s ON s.id = el.student_id
         JOIN accounts a ON a.id = s.account_id
         WHERE eld.return_date IS NOT NULL
         ORDER BY eld.return_date DESC
         LIMIT 20"
    );
    return $statement->fetchAll();
}

function overdue_students(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT s.student_code, a.full_name,
                COALESCE(book_counts.book_overdue, 0) AS overdue_books,
                COALESCE(equipment_counts.equipment_overdue, 0) AS overdue_equipment
         FROM students s
         JOIN accounts a ON a.id = s.account_id
         LEFT JOIN (
             SELECT lr.student_id, COUNT(*) AS book_overdue
             FROM loan_receipts lr JOIN loan_details ld ON ld.receipt_id = lr.id
             WHERE ld.return_date IS NULL AND ld.due_date < CURDATE()
             GROUP BY lr.student_id
         ) book_counts ON book_counts.student_id = s.id
         LEFT JOIN (
             SELECT el.student_id, COUNT(*) AS equipment_overdue
             FROM equipment_loans el JOIN equipment_loan_details eld ON eld.loan_id = el.id
             WHERE eld.return_date IS NULL AND eld.due_date < CURDATE()
             GROUP BY el.student_id
         ) equipment_counts ON equipment_counts.student_id = s.id
         WHERE book_counts.book_overdue IS NOT NULL OR equipment_counts.equipment_overdue IS NOT NULL
         ORDER BY overdue_books DESC, overdue_equipment DESC"
    );
    return $statement->fetchAll();
}

function accounts_list(PDO $pdo): array
{
    $statement = $pdo->query(
        "SELECT a.id, a.username, a.full_name, a.email, a.role,
                a.registered_at, s.student_code, s.faculty, s.class_name,
                l.librarian_code
         FROM accounts a
         LEFT JOIN students s ON s.account_id = a.id
         LEFT JOIN librarians l ON l.account_id = a.id
         ORDER BY FIELD(a.role, 'admin', 'librarian', 'student'), a.full_name"
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
        "SELECT r.id, r.name, r.room_type, r.capacity, COUNT(rr.id) AS booking_count
         FROM rooms r LEFT JOIN room_requests rr ON rr.room_id = r.id AND rr.status IN ('approved', 'completed')
         GROUP BY r.id, r.name, r.room_type, r.capacity
         ORDER BY booking_count DESC, r.name
         LIMIT :limit"
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}

function top_equipment(PDO $pdo, int $limit = 10): array
{
    $limit = max(1, min($limit, 100));
    $statement = $pdo->prepare(
        "SELECT e.id, e.name, e.equipment_type, COALESCE(SUM(eld.quantity), 0) AS borrow_count
         FROM equipment e LEFT JOIN equipment_loan_details eld ON eld.equipment_id = e.id
         GROUP BY e.id, e.name, e.equipment_type
         ORDER BY borrow_count DESC, e.name
         LIMIT :limit"
    );
    $statement->bindValue('limit', $limit, PDO::PARAM_INT);
    $statement->execute();
    return $statement->fetchAll();
}
