<?php
declare(strict_types=1);

function extension_requests_list(PDO $pdo): array
{
    $user=require_login();
    $where='';$params=[];
    if ($user['role']==='student') {$where=' WHERE lr.student_id=?';$params[]=$user['student_id'];}
    else require_staff();
    $q=$pdo->prepare("SELECT r.*,b.title,c.barcode,s.student_code,a.full_name AS student_name,
        ld.return_date,ld.due_date AS current_due_date,staff.full_name AS librarian_name
        FROM extension_requests r JOIN loan_details ld ON ld.id=r.loan_detail_id
        JOIN loan_receipts lr ON lr.id=ld.receipt_id JOIN students s ON s.id=lr.student_id
        JOIN accounts a ON a.id=s.account_id JOIN book_copies c ON c.id=ld.copy_id
        JOIN books b ON b.id=c.book_id LEFT JOIN librarians l ON l.id=r.librarian_id
        LEFT JOIN accounts staff ON staff.id=l.account_id $where
        ORDER BY (r.status='pending') DESC,r.id DESC");
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
        $q=$pdo->prepare('SELECT ld.*,lr.student_id FROM loan_details ld JOIN loan_receipts lr ON lr.id=ld.receipt_id WHERE ld.id=? FOR UPDATE');
        $q->execute([$loanId]);$loan=$q->fetch();
        if (!$loan) throw new ApiException('Không tìm thấy khoản mượn.',404);
        if ((int)$loan['student_id']!==(int)$student['student_id']) throw new ApiException('Bạn chỉ được gia hạn sách của mình.',403);
        if ($loan['return_date']!==null) throw new ApiException('Sách đã trả không thể gia hạn.');
        if ((int)$loan['extension_count']>=3) throw new ApiException('Sách đã đạt tối đa 3 lần gia hạn.');
        if ($date<=$loan['due_date']) throw new ApiException('Hạn đề nghị phải sau hạn trả hiện tại.');
        $q=$pdo->prepare("SELECT id FROM extension_requests WHERE loan_detail_id=? AND status='pending'");$q->execute([$loanId]);
        if ($q->fetch()) throw new ApiException('Sách này đã có yêu cầu gia hạn chờ duyệt.',409);
        $q=$pdo->prepare('INSERT INTO extension_requests (loan_detail_id,old_due_date,requested_due_date,reason) VALUES (?,?,?,?)');
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
        $q=$pdo->prepare('SELECT loan_detail_id FROM extension_requests WHERE id=?');$q->execute([$id]);$loanId=$q->fetchColumn();
        if (!$loanId) throw new ApiException('Không tìm thấy yêu cầu.',404);
        $q=$pdo->prepare('SELECT * FROM loan_details WHERE id=? FOR UPDATE');$q->execute([$loanId]);$loan=$q->fetch();
        $q=$pdo->prepare('SELECT * FROM extension_requests WHERE id=? FOR UPDATE');$q->execute([$id]);$request=$q->fetch();
        if ($request['status']!=='pending') throw new ApiException('Yêu cầu đã được xử lý.',409);
        $extensionId=null;
        if ($status==='approved') {
            if ($loan['return_date']!==null) throw new ApiException('Sách đã trả; hãy từ chối yêu cầu này.',409);
            if ((int)$loan['extension_count']>=3) throw new ApiException('Sách đã đạt tối đa 3 lần gia hạn.',409);
            if ($loan['due_date']!==$request['old_due_date'] || $request['requested_due_date']<date('Y-m-d')) throw new ApiException('Hạn trả đã thay đổi hoặc ngày đề nghị đã qua; hãy từ chối yêu cầu này.',409);
            $q=$pdo->prepare('INSERT INTO extensions (loan_detail_id,librarian_id,old_due_date,new_due_date,extension_date) VALUES (?,?,?,?,CURDATE())');
            $q->execute([$loanId,$staff['librarian_id'],$loan['due_date'],$request['requested_due_date']]);$extensionId=(int)$pdo->lastInsertId();
            $q=$pdo->prepare("UPDATE loan_details SET due_date=?,extension_count=extension_count+1,status='borrowed' WHERE id=?");$q->execute([$request['requested_due_date'],$loanId]);
        }
        $q=$pdo->prepare('UPDATE extension_requests SET status=?,librarian_id=?,reviewed_at=NOW(),review_note=?,extension_id=? WHERE id=?');
        $q->execute([$status,$staff['librarian_id'],$note,$extensionId,$id]);
        $pdo->commit();return ['id'=>$id,'status'=>$status,'extension_id'=>$extensionId];
    } catch(Throwable $e) {if($pdo->inTransaction())$pdo->rollBack();throw $e;}
}
