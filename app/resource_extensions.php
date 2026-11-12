<?php
declare(strict_types=1);

function resource_extensions_list(PDO $pdo): array
{
    $user = require_login();
    if ($user['role'] !== 'student') require_staff();
    $where = $user['role'] === 'student' ? 'WHERE s.id=?' : '';
    $q = $pdo->prepare("SELECT x.*, IF(x.room_request_id IS NULL,'equipment','room') AS resource_type,
        COALESCE(e.name,r.name) AS title, s.student_code,a.full_name AS student_name,
        staff.full_name AS librarian_name, d.return_date, rr.status AS booking_status
        FROM resource_extension_requests x
        LEFT JOIN equipment_loan_details d ON d.id=x.equipment_detail_id
        LEFT JOIN equipment_loans el ON el.id=d.loan_id
        LEFT JOIN equipment e ON e.id=d.equipment_id
        LEFT JOIN room_requests rr ON rr.id=x.room_request_id LEFT JOIN rooms r ON r.id=rr.room_id
        JOIN students s ON s.id=COALESCE(el.student_id,rr.student_id)
        JOIN accounts a ON a.id=s.account_id
        LEFT JOIN librarians l ON l.id=x.librarian_id LEFT JOIN accounts staff ON staff.id=l.account_id
        $where ORDER BY (x.status='pending') DESC,x.id DESC");
    $q->execute($where ? [$user['student_id']] : []);
    return $q->fetchAll();
}

// Lock the existing loan/booking first, matching the return and room-approval paths.
function resource_extension_target(PDO $pdo, string $type, int $id): array
{
    if ($type === 'equipment') {
        $q=$pdo->prepare('SELECT d.*,el.student_id FROM equipment_loan_details d JOIN equipment_loans el ON el.id=d.loan_id WHERE d.id=? FOR UPDATE');
    } else {
        $q=$pdo->prepare('SELECT * FROM room_requests WHERE id=? FOR UPDATE');
    }
    $q->execute([$id]); $target=$q->fetch();
    if (!$target) throw new ApiException('Không tìm thấy tài nguyên đang mượn.',404);
    return $target;
}

function resource_extension_validate(PDO $pdo, string $type, array $target, string $deadline): void
{
    if ($type === 'equipment') {
        if ($target['return_date'] !== null) throw new ApiException('Thiết bị đã trả không thể gia hạn.',409);
        if (substr($deadline,0,10) < date('Y-m-d')) throw new ApiException('Hạn đề nghị đã qua.',409);
    } else {
        if ($target['status'] !== 'approved') throw new ApiException('Chỉ gia hạn lịch phòng đã duyệt và chưa kết thúc.',409);
        $old=$target['use_date'].' '.$target['end_time'];
        // 24:00 belongs to the end of the booking day; MySQL normalizes the datetime.
        if (strtotime($old) <= time()) throw new ApiException('Lịch phòng đã hết giờ sử dụng.',409);
        $q=$pdo->prepare('SELECT status,is_visible,deleted_at FROM rooms WHERE id=? FOR UPDATE');
        $q->execute([$target['room_id']]); $room=$q->fetch();
        if (!$room || $room['status']!=='available' || !$room['is_visible'] || $room['deleted_at']) throw new ApiException('Phòng không còn sẵn sàng để gia hạn.',409);
        $end=date('Y-m-d',strtotime($deadline)) > $target['use_date'] ? '24:00:00' : substr($deadline,11);
        $q=$pdo->prepare("SELECT id FROM room_requests WHERE room_id=? AND use_date=? AND id<>? AND status='approved' AND start_time<? AND end_time>? LIMIT 1 FOR UPDATE");
        $q->execute([$target['room_id'],$target['use_date'],$target['id'],$end,$target['start_time']]);
        if ($q->fetch()) throw new ApiException('Giờ gia hạn trùng lịch phòng đã duyệt. Hãy chọn giờ kết thúc khác.',409);
    }
}

function resource_extension_deadline(string $type, array $target): string
{
    return $type==='equipment' ? $target['due_date'].' 00:00:00' : date('Y-m-d H:i:s',strtotime($target['use_date'].' '.$target['end_time']));
}

function resource_extension_create(PDO $pdo, array $body): array
{
    $student=require_role('student');
    $type=$body['resource_type']??'';
    if (!in_array($type,['equipment','room'],true)) throw new ApiException('Loại tài nguyên không hợp lệ.');
    $id=resource_int($body,'target_id',1,PHP_INT_MAX);
    $reason=resource_text($body,'reason',500)??'';
    $column=$type==='equipment' ? 'equipment_detail_id' : 'room_request_id';
    $pdo->beginTransaction();
    try {
        $target=resource_extension_target($pdo,$type,$id);
        if ((int)$target['student_id']!==(int)$student['student_id']) throw new ApiException('Bạn chỉ được gia hạn tài nguyên của mình.',403);
        if ($type==='equipment') {
            $date=(string)($body['new_due_date']??'');
            $parsed=DateTimeImmutable::createFromFormat('!Y-m-d',$date);
            if (!$parsed || $parsed->format('Y-m-d')!==$date) throw new ApiException('Hạn trả đề nghị không hợp lệ.');
            $deadline=$date.' 00:00:00';
        } else {
            $end=(string)($body['new_end_time']??'');
            if (!preg_match('/^(?:[01][0-9]|2[0-3]):[0-5][0-9]$|^24:00$/D',$end)) throw new ApiException('Giờ kết thúc phải từ 00:00 đến 24:00.');
            $deadline=date('Y-m-d H:i:s',strtotime($target['use_date'].' '.$end));
        }
        $old=resource_extension_deadline($type,$target);
        if ($deadline <= $old) throw new ApiException('Hạn đề nghị phải sau hạn hiện tại.');
        resource_extension_validate($pdo,$type,$target,$deadline);
        $q=$pdo->prepare("SELECT status FROM resource_extension_requests WHERE $column=?");$q->execute([$id]);
        $statuses=$q->fetchAll(PDO::FETCH_COLUMN);
        if (in_array('pending',$statuses,true)) throw new ApiException('Đã có yêu cầu gia hạn chờ duyệt.',409);
        if (count(array_filter($statuses,fn($s)=>$s==='approved'))>=3) throw new ApiException('Đã đạt tối đa 3 lần gia hạn.');
        $q=$pdo->prepare("INSERT INTO resource_extension_requests ($column,old_deadline,requested_deadline,reason) VALUES (?,?,?,?)");
        $q->execute([$id,$old,$deadline,$reason]);$requestId=(int)$pdo->lastInsertId();
        $pdo->commit(); return ['id'=>$requestId,'status'=>'pending'];
    } catch(Throwable $e) { if($pdo->inTransaction())$pdo->rollBack(); throw $e; }
}

function resource_extension_review(PDO $pdo,int $id,array $body): array
{
    $staff=require_role('librarian');
    if (empty($staff['librarian_id'])) throw new ApiException('Tài khoản chưa có hồ sơ thủ thư.',403);
    $status=$body['status']??'';$note=resource_text($body,'review_note',500)??'';
    if (!in_array($status,['approved','rejected'],true)) throw new ApiException('Chọn duyệt hoặc từ chối.');
    if ($status==='rejected' && $note==='') throw new ApiException('Khi từ chối cần nhập lý do.');
    $pdo->beginTransaction();
    try {
        $q=$pdo->prepare('SELECT * FROM resource_extension_requests WHERE id=?');$q->execute([$id]);$request=$q->fetch();
        if (!$request) throw new ApiException('Không tìm thấy yêu cầu.',404);
        $type=$request['room_request_id'] ? 'room' : 'equipment';
        $column=$type==='equipment' ? 'equipment_detail_id' : 'room_request_id';
        $target=resource_extension_target($pdo,$type,(int)$request[$column]);
        $q=$pdo->prepare('SELECT * FROM resource_extension_requests WHERE id=? FOR UPDATE');$q->execute([$id]);$request=$q->fetch();
        if ($request['status']!=='pending') throw new ApiException('Yêu cầu đã được xử lý.',409);
        if ($status==='approved') {
            if (resource_extension_deadline($type,$target)!==$request['old_deadline']) throw new ApiException('Hạn hiện tại đã thay đổi. Hãy từ chối yêu cầu cũ.',409);
            resource_extension_validate($pdo,$type,$target,$request['requested_deadline']);
            if ($type==='equipment') {
                $q=$pdo->prepare('UPDATE equipment_loan_details SET due_date=? WHERE id=?');
                $q->execute([substr($request['requested_deadline'],0,10),$target['id']]);
            } else {
                $end=substr($request['requested_deadline'],0,10)>$target['use_date'] ? '24:00:00' : substr($request['requested_deadline'],11);
                $q=$pdo->prepare('UPDATE room_requests SET end_time=? WHERE id=?');$q->execute([$end,$target['id']]);
            }
        }
        $q=$pdo->prepare('UPDATE resource_extension_requests SET status=?,librarian_id=?,reviewed_at=NOW(),review_note=? WHERE id=?');
        $q->execute([$status,$staff['librarian_id'],$note,$id]);$pdo->commit();
        return ['id'=>$id,'status'=>$status];
    } catch(Throwable $e) { if($pdo->inTransaction())$pdo->rollBack(); throw $e; }
}
