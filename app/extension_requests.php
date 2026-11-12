<?php
declare(strict_types=1);

function extension_requests_list(PDO $pdo): array
{
    $user=require_login();
    $where='';$params=[];
    if ($user['role']==='student') {$where=' WHERE lr.ma_ho_so_sinh_vien=?';$params[]=$user['student_id'];}
    else require_staff();
    $q=$pdo->prepare("SELECT r.*,b.ten_sach,c.ma_vach,s.ma_sinh_vien,a.ho_ten AS student_name,
        ld.ngay_tra,ld.han_tra AS current_due_date,staff.ho_ten AS librarian_name
        FROM yeu_cau_gia_han_sach r JOIN chi_tiet_muon_sach ld ON ld.ma=r.ma_chi_tiet_muon_sach
        JOIN phieu_muon_sach lr ON lr.ma=ld.ma_phieu_muon_sach JOIN sinh_vien s ON s.ma=lr.ma_ho_so_sinh_vien
        JOIN tai_khoan a ON a.ma=s.ma_tai_khoan JOIN ban_sach c ON c.ma=ld.ma_ban_sach
        JOIN dau_sach b ON b.ma=c.ma_dau_sach LEFT JOIN thu_thu l ON l.ma=r.ma_ho_so_thu_thu
        LEFT JOIN tai_khoan staff ON staff.ma=l.ma_tai_khoan $where
        ORDER BY (r.trang_thai='pending') DESC,r.ma DESC");
    $q->execute($params);return $q->fetchAll();
}

function extension_request_create(PDO $pdo, int $loanId, array $body): array
{
    $student=require_role('student');
    $date=trim((string)($body['new_due_date']??''));
    $parsed=DateTimeImmutable::createFromFormat('!Y-m-d',$date);
    if (!$parsed || $parsed->format('Y-m-d')!==$date || $date<date('Y-m-d')) throw new ApiException('Hạn đề nghị phải là ngày hợp lệ, từ hôm nay trở đi.');
    $reason=resource_text($body,'reason',500)??'';
    $pdo->beginTransaction();
    try {
        $q=$pdo->prepare('SELECT ld.*,lr.ma_ho_so_sinh_vien FROM chi_tiet_muon_sach ld JOIN phieu_muon_sach lr ON lr.ma=ld.ma_phieu_muon_sach WHERE ld.ma=? FOR UPDATE');
        $q->execute([$loanId]);$loan=$q->fetch();
        if (!$loan) throw new ApiException('Không tìm thấy khoản mượn.',404);
        if ((int)$loan['student_id']!==(int)$student['student_id']) throw new ApiException('Bạn chỉ được gia hạn sách của mình.',403);
        if ($loan['return_date']!==null) throw new ApiException('Sách đã trả không thể gia hạn.');
        if ((int)$loan['extension_count']>=3) throw new ApiException('Sách đã đạt tối đa 3 lần gia hạn.');
        if ($date<=$loan['due_date']) throw new ApiException('Hạn đề nghị phải sau hạn trả hiện tại.');
        $q=$pdo->prepare('SELECT ma FROM yeu_cau_gia_han_sach WHERE ma_chi_tiet_muon_sach=? AND trang_thai=\'pending\'');$q->execute([$loanId]);
        if ($q->fetch()) throw new ApiException('Sách này đã có yêu cầu gia hạn chờ duyệt.',409);
        $q=$pdo->prepare('INSERT INTO yeu_cau_gia_han_sach (ma_chi_tiet_muon_sach,han_tra_cu,han_tra_de_nghi,ly_do) VALUES (?,?,?,?)');
        $q->execute([$loanId,$loan['due_date'],$date,$reason]);$id=(int)$pdo->lastInsertId();
        $pdo->commit();return ['id'=>$id,'status'=>'pending'];
    } catch(Throwable $e) {if($pdo->inTransaction())$pdo->rollBack();throw $e;}
}

function extension_request_review(PDO $pdo,int $id,array $body): array
{
    $staff=require_role('librarian');
    if (empty($staff['librarian_id'])) throw new ApiException('Tài khoản chưa có hồ sơ thủ thư.',403);
    $status=$body['status']??'';
    if (!in_array($status,['approved','rejected'],true)) throw new ApiException('Chọn duyệt hoặc từ chối.');
    $note=resource_text($body,'review_note',500)??'';
    if ($status==='rejected' && $note==='') throw new ApiException('Khi từ chối cần nhập lý do.');
    $pdo->beginTransaction();
    try {
        // Use the same loan-first lock order as creation and direct loan updates.
        $q=$pdo->prepare('SELECT ma_chi_tiet_muon_sach FROM yeu_cau_gia_han_sach WHERE ma=?');$q->execute([$id]);$loanId=$q->fetchColumn();
        if (!$loanId) throw new ApiException('Không tìm thấy yêu cầu.',404);
        $q=$pdo->prepare('SELECT * FROM chi_tiet_muon_sach WHERE ma=? FOR UPDATE');$q->execute([$loanId]);$loan=$q->fetch();
        $q=$pdo->prepare('SELECT * FROM yeu_cau_gia_han_sach WHERE ma=? FOR UPDATE');$q->execute([$id]);$request=$q->fetch();
        if ($request['status']!=='pending') throw new ApiException('Yêu cầu đã được xử lý.',409);
        $extensionId=null;
        if ($status==='approved') {
            if ($loan['return_date']!==null) throw new ApiException('Sách đã trả; hãy từ chối yêu cầu này.',409);
            if ((int)$loan['extension_count']>=3) throw new ApiException('Sách đã đạt tối đa 3 lần gia hạn.',409);
            if ($loan['due_date']!==$request['old_due_date'] || $request['requested_due_date']<date('Y-m-d')) throw new ApiException('Hạn trả đã thay đổi hoặc ngày đề nghị đã qua; hãy từ chối yêu cầu này.',409);
            $q=$pdo->prepare('INSERT INTO gia_han_sach (ma_chi_tiet_muon_sach,ma_ho_so_thu_thu,han_tra_cu,han_tra_moi,ngay_gia_han) VALUES (?,?,?,?,CURDATE())');
            $q->execute([$loanId,$staff['librarian_id'],$loan['due_date'],$request['requested_due_date']]);$extensionId=(int)$pdo->lastInsertId();
            $q=$pdo->prepare('UPDATE chi_tiet_muon_sach SET han_tra=?,so_lan_gia_han=so_lan_gia_han+1,trang_thai=\'borrowed\' WHERE ma=?');$q->execute([$request['requested_due_date'],$loanId]);
        }
        $q=$pdo->prepare('UPDATE yeu_cau_gia_han_sach SET trang_thai=?,ma_ho_so_thu_thu=?,thoi_diem_xet_duyet=NOW(),ghi_chu_xet_duyet=?,ma_gia_han=? WHERE ma=?');
        $q->execute([$status,$staff['librarian_id'],$note,$extensionId,$id]);
        $pdo->commit();return ['id'=>$id,'status'=>$status,'extension_id'=>$extensionId];
    } catch(Throwable $e) {if($pdo->inTransaction())$pdo->rollBack();throw $e;}
}
