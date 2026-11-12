<?php
declare(strict_types=1);

function circulation_readers(PDO $pdo): array
{
    require_staff();
    return $pdo->query('SELECT s.ma,s.ma_sinh_vien,a.ho_ten,s.khoa,s.lop FROM sinh_vien s JOIN tai_khoan a ON a.ma=s.ma_tai_khoan WHERE a.vai_tro=\'student\' ORDER BY s.ma_sinh_vien')->fetchAll();
}

function account_full_detail(PDO $pdo, int $id): array
{
    require_role('admin');
    $profile = profile_data($pdo, $id);
    $data = ['profile'=>$profile, 'history'=>null, 'rooms'=>[], 'handled_books'=>[], 'handled_equipment'=>[], 'extensions'=>[]];
    if ($profile['role'] === 'student') {
        $data['history'] = student_history($pdo, $profile['student_code']);
        $q = $pdo->prepare('SELECT r.ma,ro.ten,r.ngay_su_dung,r.gio_bat_dau,r.gio_ket_thuc,r.trang_thai,r.muc_dich FROM yeu_cau_dat_phong r JOIN phong ro ON ro.ma=r.ma_phong JOIN sinh_vien s ON s.ma=r.ma_ho_so_sinh_vien WHERE s.ma_tai_khoan=? ORDER BY r.ngay_su_dung DESC LIMIT 100');
        $q->execute([$id]); $data['rooms'] = $q->fetchAll();
    }
    if ($profile['role'] === 'librarian') {
        foreach (['handled_books'=>'loan_receipts', 'handled_equipment'=>'equipment_loans'] as $key=>$table) {
            $q = $pdo->prepare("SELECT p.ma,p.ma_yeu_cau,p.thoi_diem_dang_ky,p.trang_thai,s.ma_sinh_vien,a.ho_ten AS student_name FROM $table p JOIN thu_thu l ON l.ma=p.ma_ho_so_thu_thu JOIN sinh_vien s ON s.ma=p.ma_ho_so_sinh_vien JOIN tai_khoan a ON a.ma=s.ma_tai_khoan WHERE l.ma_tai_khoan=? ORDER BY p.ma DESC LIMIT 100");
            $q->execute([$id]); $data[$key] = $q->fetchAll();
        }
        $q = $pdo->prepare('SELECT e.ma,e.ma_chi_tiet_muon_sach,e.han_tra_cu,e.han_tra_moi,e.ngay_gia_han FROM gia_han_sach e JOIN thu_thu l ON l.ma=e.ma_ho_so_thu_thu WHERE l.ma_tai_khoan=? ORDER BY e.ma DESC LIMIT 100');
        $q->execute([$id]); $data['extensions'] = $q->fetchAll();
        $q = $pdo->prepare('SELECT r.ma,ro.ten,r.ngay_su_dung,r.gio_bat_dau,r.gio_ket_thuc,r.trang_thai,r.muc_dich FROM yeu_cau_dat_phong r JOIN phong ro ON ro.ma=r.ma_phong JOIN thu_thu l ON l.ma=r.ma_ho_so_thu_thu WHERE l.ma_tai_khoan=? ORDER BY r.ngay_su_dung DESC LIMIT 100');
        $q->execute([$id]); $data['rooms'] = $q->fetchAll();
    }
    return $data;
}

function request_trace(PDO $pdo, string $type, int $id): array
{
    $user = require_login();
    if (!in_array($type, ['book', 'equipment'], true)) throw new ApiException('Loại phiếu không hợp lệ.', 404);
    $table = $type === 'book' ? 'book_loan_requests' : 'equipment_loan_requests';
    $receiptTable = $type === 'book' ? 'loan_receipts' : 'equipment_loans';
    $q = $pdo->prepare("SELECT r.ma,r.ma_ho_so_sinh_vien,r.nguon_tao,r.trang_thai,r.thoi_diem_gui_yeu_cau,r.thoi_diem_xet_duyet,r.ghi_chu_xet_duyet,s.ma_sinh_vien,a.ho_ten AS student_name,la.ho_ten AS librarian_name,p.ma AS ma_phieu_muon_sach FROM $table r JOIN sinh_vien s ON s.ma=r.ma_ho_so_sinh_vien JOIN tai_khoan a ON a.ma=s.ma_tai_khoan LEFT JOIN thu_thu l ON l.ma=r.ma_ho_so_thu_thu LEFT JOIN tai_khoan la ON la.ma=l.ma_tai_khoan LEFT JOIN $receiptTable p ON p.request_id=r.id WHERE r.id=?");
    $q->execute([$id]); $data = $q->fetch();
    if (!$data) throw new ApiException('Không tìm thấy yêu cầu.', 404);
    if ($user['role'] === 'student' && (int)$user['student_id'] !== (int)$data['student_id']) throw new ApiException('Bạn chỉ được xem yêu cầu của mình.', 403);
    $data['type'] = $type;
    $data['details'] = [];
    if ($data['receipt_id']) {
        if ($type === 'book') $data['details'] = loan_receipt_detail($pdo, (int)$data['receipt_id'])['details'];
        else {
            $q = $pdo->prepare('SELECT d.ma,e.ten AS ten_sach,d.so_luong,d.ngay_muon,d.han_tra,d.ngay_tra,d.trang_thai FROM chi_tiet_muon_thiet_bi d JOIN thiet_bi e ON e.ma=d.ma_thiet_bi WHERE d.ma_phieu_muon_thiet_bi=? ORDER BY d.ma');
            $q->execute([$data['receipt_id']]); $data['details'] = $q->fetchAll();
        }
    }
    return $data;
}

function create_counter_loan(PDO $pdo, array $body): array
{
    $staff = require_role('librarian');
    if (empty($staff['librarian_id'])) throw new ApiException('Tài khoản chưa có hồ sơ thủ thư hợp lệ.', 403);
    $type = $body['type'] ?? '';
    if (!in_array($type, ['book', 'equipment'], true)) throw new ApiException('Chọn sách hoặc thiết bị.');
    $code = resource_text($body, 'student_code', 30, true);
    $q = $pdo->prepare('SELECT s.ma FROM sinh_vien s JOIN tai_khoan a ON a.ma=s.ma_tai_khoan WHERE s.ma_sinh_vien=? AND a.vai_tro=\'student\'');
    $q->execute([$code]); $studentId = $q->fetchColumn();
    if (!$studentId) throw new ApiException('Không tìm thấy sinh viên.', 404);
    if (is_array($body['items'] ?? null)) foreach ($body['items'] as $item) {
        if (!is_array($item)) throw new ApiException('Chi tiết tài nguyên không hợp lệ.');
        resource_int($item, 'quantity', 1, 1000000);
    }
    $items = $type === 'book' ? book_request_items($body) : equipment_request_items($body);
    $note = resource_text($body, 'note', 255);
    $requestTable = $type === 'book' ? 'book_loan_requests' : 'equipment_loan_requests';
    $itemTable = $type === 'book' ? 'book_loan_request_items' : 'equipment_loan_request_items';
    $resourceId = $type === 'book' ? 'book_id' : 'equipment_id';
    $pdo->beginTransaction();
    try {
        $q = $pdo->prepare("INSERT INTO $requestTable (student_id,note,source) VALUES (?,?,'counter')");
        $q->execute([$studentId, $note]); $requestId = (int)$pdo->lastInsertId();
        $q = $pdo->prepare("INSERT INTO $itemTable (request_id,$resourceId,quantity,requested_due_date) VALUES (?,?,?,?)");
        foreach ($items as $item) $q->execute([$requestId, $item[$resourceId], $item['quantity'], $item['requested_due_date']]);
        $result = $type === 'book'
            ? review_book_request($pdo, $requestId, (int)$staff['librarian_id'], 'approved', 'Lập phiếu trực tiếp tại quầy')
            : review_equipment_request($pdo, $requestId, (int)$staff['librarian_id'], 'approved', 'Lập phiếu trực tiếp tại quầy');
        $pdo->commit();
        return $result;
    } catch (Throwable $e) { if ($pdo->inTransaction()) $pdo->rollBack(); throw $e; }
}

function route_circulation(PDO $pdo, string $method, ?string $kind, ?string $id, ?string $action): never
{
    if ($kind === 'readers' && $method === 'GET') json_response(['data'=>circulation_readers($pdo)]);
    if ($kind === 'counter-loans' && $method === 'POST') json_response(['data'=>create_counter_loan($pdo, request_body())], 201);
    if ($kind === 'trace' && ctype_digit((string)$action) && $method === 'GET') json_response(['data'=>request_trace($pdo, (string)$id, (int)$action)]);
    throw new ApiException('Không tìm thấy chức năng.', 404);
}
