<?php
declare(strict_types=1);

function circulation_equipment_status(string $current, int $available, int $active): string
{
    if (in_array($current, ['maintenance', 'damaged'], true)) return $current;
    return $available > 0 ? 'available' : ($active > 0 ? 'borrowed' : 'unavailable');
}

function inventory_record(PDO $pdo, int $id, bool $lock = false): array
{
    $q = $pdo->prepare('SELECT id,name,total_quantity,available_quantity,unavailable_quantity,status,inventory_verified_at FROM equipment WHERE id=? AND deleted_at IS NULL'.($lock ? ' FOR UPDATE' : ''));
    $q->execute([$id]);
    $row = $q->fetch();
    if (!$row) throw new ApiException('Không tìm thấy thiết bị.', 404);
    $q = $pdo->prepare('SELECT COALESCE(SUM(quantity),0) FROM equipment_loan_details WHERE equipment_id=? AND return_date IS NULL');
    $q->execute([$id]);
    $row['on_loan_quantity'] = (int)$q->fetchColumn();
    $row['difference'] = (int)$row['total_quantity'] - (int)$row['available_quantity'] - (int)$row['unavailable_quantity'] - $row['on_loan_quantity'];
    $row['version'] = hash('sha256', json_encode($row));
    return $row;
}

function inventory_overview(PDO $pdo): array
{
    require_staff();
    $rows = [];
    foreach ($pdo->query('SELECT id FROM equipment WHERE deleted_at IS NULL ORDER BY name')->fetchAll(PDO::FETCH_COLUMN) as $id) $rows[] = inventory_record($pdo, (int)$id);
    return $rows;
}

function inventory_history(PDO $pdo, int $id): array
{
    require_staff();
    $q = $pdo->prepare('SELECT h.*,a.full_name AS actor_name FROM equipment_inventory_adjustments h LEFT JOIN accounts a ON a.id=h.actor_account_id WHERE h.equipment_id=? ORDER BY h.id DESC LIMIT 100');
    $q->execute([$id]);
    return $q->fetchAll();
}

function reconcile_inventory(PDO $pdo, int $id, array $body): array
{
    $user = require_staff();
    $total = resource_int($body, 'total_quantity', 1, 1000000);
    $available = resource_int($body, 'available_quantity', 0, 1000000);
    $unavailable = resource_int($body, 'unavailable_quantity', 0, 1000000);
    $reason = resource_text($body, 'reason', 1000, true);
    $pdo->beginTransaction();
    try {
        $old = inventory_record($pdo, $id, true);
        if (!is_string($body['version'] ?? null) || !hash_equals($old['version'], $body['version'])) throw new ApiException('Tồn kho đã thay đổi. Tải lại và kiểm tra số đang mượn.', 409);
        if ($available + $unavailable + $old['on_loan_quantity'] !== $total) throw new ApiException('Tổng phải bằng sẵn sàng + đang mượn + không khả dụng.');
        $status = circulation_equipment_status($old['status'], $available, $old['on_loan_quantity']);
        $q = $pdo->prepare('UPDATE equipment SET total_quantity=?,available_quantity=?,unavailable_quantity=?,status=?,inventory_verified_at=NOW() WHERE id=?');
        $q->execute([$total, $available, $unavailable, $status, $id]);
        $q = $pdo->prepare("INSERT INTO equipment_inventory_adjustments (equipment_id,actor_account_id,event_type,old_total,old_available,old_unavailable,new_total,new_available,new_unavailable,on_loan_quantity,reason) VALUES (?,?,'reconciliation',?,?,?,?,?,?,?,?)");
        $q->execute([$id, $user['id'], $old['total_quantity'], $old['available_quantity'], $old['unavailable_quantity'], $total, $available, $unavailable, $old['on_loan_quantity'], $reason]);
        $pdo->commit();
        return inventory_record($pdo, $id);
    } catch (Throwable $e) { if ($pdo->inTransaction()) $pdo->rollBack(); throw $e; }
}

function circulation_readers(PDO $pdo): array
{
    require_staff();
    return $pdo->query("SELECT s.id,s.student_code,a.full_name,s.faculty,s.class_name FROM students s JOIN accounts a ON a.id=s.account_id WHERE a.role='student' ORDER BY s.student_code")->fetchAll();
}

function account_full_detail(PDO $pdo, int $id): array
{
    require_role('admin');
    $profile = profile_data($pdo, $id);
    $data = ['profile'=>$profile, 'history'=>null, 'rooms'=>[], 'handled_books'=>[], 'handled_equipment'=>[], 'extensions'=>[]];
    if ($profile['role'] === 'student') {
        $data['history'] = student_history($pdo, $profile['student_code']);
        $q = $pdo->prepare('SELECT r.id,ro.name,r.use_date,r.start_time,r.end_time,r.status,r.purpose FROM room_requests r JOIN rooms ro ON ro.id=r.room_id JOIN students s ON s.id=r.student_id WHERE s.account_id=? ORDER BY r.use_date DESC LIMIT 100');
        $q->execute([$id]); $data['rooms'] = $q->fetchAll();
    }
    if ($profile['role'] === 'librarian') {
        foreach (['handled_books'=>'loan_receipts', 'handled_equipment'=>'equipment_loans'] as $key=>$table) {
            $q = $pdo->prepare("SELECT p.id,p.request_id,p.registered_at,p.status,s.student_code,a.full_name AS student_name FROM $table p JOIN librarians l ON l.id=p.librarian_id JOIN students s ON s.id=p.student_id JOIN accounts a ON a.id=s.account_id WHERE l.account_id=? ORDER BY p.id DESC LIMIT 100");
            $q->execute([$id]); $data[$key] = $q->fetchAll();
        }
        $q = $pdo->prepare('SELECT e.id,e.loan_detail_id,e.old_due_date,e.new_due_date,e.extension_date FROM extensions e JOIN librarians l ON l.id=e.librarian_id WHERE l.account_id=? ORDER BY e.id DESC LIMIT 100');
        $q->execute([$id]); $data['extensions'] = $q->fetchAll();
        $q = $pdo->prepare('SELECT r.id,ro.name,r.use_date,r.start_time,r.end_time,r.status,r.purpose FROM room_requests r JOIN rooms ro ON ro.id=r.room_id JOIN librarians l ON l.id=r.librarian_id WHERE l.account_id=? ORDER BY r.use_date DESC LIMIT 100');
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
    $q = $pdo->prepare("SELECT r.id,r.student_id,r.source,r.status,r.requested_at,r.reviewed_at,r.review_note,s.student_code,a.full_name AS student_name,la.full_name AS librarian_name,p.id AS receipt_id FROM $table r JOIN students s ON s.id=r.student_id JOIN accounts a ON a.id=s.account_id LEFT JOIN librarians l ON l.id=r.librarian_id LEFT JOIN accounts la ON la.id=l.account_id LEFT JOIN $receiptTable p ON p.request_id=r.id WHERE r.id=?");
    $q->execute([$id]); $data = $q->fetch();
    if (!$data) throw new ApiException('Không tìm thấy yêu cầu.', 404);
    if ($user['role'] === 'student' && (int)$user['student_id'] !== (int)$data['student_id']) throw new ApiException('Bạn chỉ được xem yêu cầu của mình.', 403);
    $data['type'] = $type;
    $data['details'] = [];
    if ($data['receipt_id']) {
        if ($type === 'book') $data['details'] = loan_receipt_detail($pdo, (int)$data['receipt_id'])['details'];
        else {
            $q = $pdo->prepare('SELECT d.id,e.name AS title,d.quantity,d.borrow_date,d.due_date,d.return_date,d.status FROM equipment_loan_details d JOIN equipment e ON e.id=d.equipment_id WHERE d.loan_id=? ORDER BY d.id');
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
    $q = $pdo->prepare("SELECT s.id FROM students s JOIN accounts a ON a.id=s.account_id WHERE s.student_code=? AND a.role='student'");
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
    if ($kind === 'inventory' && $method === 'GET' && $id === null) json_response(['data'=>inventory_overview($pdo)]);
    if ($kind === 'inventory' && ctype_digit((string)$id)) {
        if ($method === 'GET') json_response(['data'=>inventory_history($pdo, (int)$id)]);
        if ($method === 'POST') json_response(['data'=>reconcile_inventory($pdo, (int)$id, request_body())]);
    }
    if ($kind === 'trace' && ctype_digit((string)$action) && $method === 'GET') json_response(['data'=>request_trace($pdo, (string)$id, (int)$action)]);
    throw new ApiException('Không tìm thấy chức năng.', 404);
}
