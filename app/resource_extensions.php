<?php
declare(strict_types=1);

function resource_extensions_list(PDO $pdo): array
{
    $user = require_login();
    if ($user['role'] !== 'student') require_staff();
    $where = $user['role'] === 'student' ? 'WHERE s.ma=?' : '';
    $q = $pdo->prepare("SELECT x.*, IF(x.ma_yeu_cau_dat_phong IS NULL,'equipment','room') AS resource_type,
        COALESCE(e.ten,r.ten) AS ten_sach, s.ma_sinh_vien,a.ho_ten AS student_name,
        staff.ho_ten AS librarian_name, d.ngay_tra, rr.trang_thai AS booking_status
        FROM yeu_cau_gia_han_tai_nguyen x
        LEFT JOIN chi_tiet_muon_thiet_bi d ON d.ma=x.ma_chi_tiet_muon_thiet_bi
        LEFT JOIN phieu_muon_thiet_bi el ON el.ma=d.ma_phieu_muon_thiet_bi
        LEFT JOIN thiet_bi e ON e.ma=d.ma_thiet_bi
        LEFT JOIN yeu_cau_dat_phong rr ON rr.ma=x.ma_yeu_cau_dat_phong LEFT JOIN phong r ON r.ma=rr.ma_phong
        JOIN sinh_vien s ON s.ma=COALESCE(el.ma_ho_so_sinh_vien,rr.ma_ho_so_sinh_vien)
        JOIN tai_khoan a ON a.ma=s.ma_tai_khoan
        LEFT JOIN thu_thu l ON l.ma=x.ma_ho_so_thu_thu LEFT JOIN tai_khoan staff ON staff.ma=l.ma_tai_khoan
        $where ORDER BY (x.trang_thai='pending') DESC,x.ma DESC");
    $q->execute($where ? [$user['student_id']] : []);
    return $q->fetchAll();
}

// Lock the existing loan/booking first, matching the return and room-approval paths.
function resource_extension_target(PDO $pdo, string $type, int $id): array
{
    if ($type === 'equipment') {
        $q=$pdo->prepare('SELECT d.*,el.ma_ho_so_sinh_vien FROM chi_tiet_muon_thiet_bi d JOIN phieu_muon_thiet_bi el ON el.ma=d.ma_phieu_muon_thiet_bi WHERE d.ma=? FOR UPDATE');
    } else {
        $q=$pdo->prepare('SELECT * FROM yeu_cau_dat_phong WHERE ma=? FOR UPDATE');
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
        $q=$pdo->prepare('SELECT trang_thai,hien_thi,thoi_diem_xoa FROM phong WHERE ma=? FOR UPDATE');
        $q->execute([$target['room_id']]); $room=$q->fetch();
        if (!$room || $room['status']!=='available' || !$room['is_visible'] || $room['deleted_at']) throw new ApiException('Phòng không còn sẵn sàng để gia hạn.',409);
        $end=date('Y-m-d',strtotime($deadline)) > $target['use_date'] ? '24:00:00' : substr($deadline,11);
        $q=$pdo->prepare('SELECT ma FROM yeu_cau_dat_phong WHERE ma_phong=? AND ngay_su_dung=? AND ma<>? AND trang_thai=\'approved\' AND gio_bat_dau<? AND gio_ket_thuc>? LIMIT 1 FOR UPDATE');
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
        $q=$pdo->prepare("SELECT trang_thai FROM yeu_cau_gia_han_tai_nguyen WHERE $column=?");$q->execute([$id]);
        $statuses=$q->fetchAll(PDO::FETCH_COLUMN);
        if (in_array('pending',$statuses,true)) throw new ApiException('Đã có yêu cầu gia hạn chờ duyệt.',409);
        if (count(array_filter($statuses,fn($s)=>$s==='approved'))>=3) throw new ApiException('Đã đạt tối đa 3 lần gia hạn.');
        $q=$pdo->prepare("INSERT INTO yeu_cau_gia_han_tai_nguyen ($column,old_deadline,requested_deadline,reason) VALUES (?,?,?,?)");
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
        $q=$pdo->prepare('SELECT * FROM yeu_cau_gia_han_tai_nguyen WHERE ma=?');$q->execute([$id]);$request=$q->fetch();
        if (!$request) throw new ApiException('Không tìm thấy yêu cầu.',404);
        $type=$request['room_request_id'] ? 'room' : 'equipment';
        $column=$type==='equipment' ? 'equipment_detail_id' : 'room_request_id';
        $target=resource_extension_target($pdo,$type,(int)$request[$column]);
        $q=$pdo->prepare('SELECT * FROM yeu_cau_gia_han_tai_nguyen WHERE ma=? FOR UPDATE');$q->execute([$id]);$request=$q->fetch();
        if ($request['status']!=='pending') throw new ApiException('Yêu cầu đã được xử lý.',409);
        if ($status==='approved') {
            if (resource_extension_deadline($type,$target)!==$request['old_deadline']) throw new ApiException('Hạn hiện tại đã thay đổi. Hãy từ chối yêu cầu cũ.',409);
            resource_extension_validate($pdo,$type,$target,$request['requested_deadline']);
            if ($type==='equipment') {
                $q=$pdo->prepare('UPDATE chi_tiet_muon_thiet_bi SET han_tra=? WHERE ma=?');
                $q->execute([substr($request['requested_deadline'],0,10),$target['id']]);
            } else {
                $end=substr($request['requested_deadline'],0,10)>$target['use_date'] ? '24:00:00' : substr($request['requested_deadline'],11);
                $q=$pdo->prepare('UPDATE yeu_cau_dat_phong SET gio_ket_thuc=? WHERE ma=?');$q->execute([$end,$target['id']]);
            }
        }
        $q=$pdo->prepare('UPDATE yeu_cau_gia_han_tai_nguyen SET trang_thai=?,ma_ho_so_thu_thu=?,thoi_diem_xet_duyet=NOW(),ghi_chu_xet_duyet=? WHERE ma=?');
        $q->execute([$status,$staff['librarian_id'],$note,$id]);$pdo->commit();
        return ['id'=>$id,'status'=>$status];
    } catch(Throwable $e) { if($pdo->inTransaction())$pdo->rollBack(); throw $e; }
}
