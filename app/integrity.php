<?php
declare(strict_types=1);

function integrity_rules(): array
{
    $dates="borrow_date >= '1000-01-01' AND due_date >= borrow_date AND (return_date IS NULL OR return_date >= borrow_date)";
    $state="(return_date IS NULL AND status IN ('borrowed','overdue') AND return_status IS NULL AND late_days=0 AND condition_on_return IS NULL) OR (return_date IS NOT NULL AND status='returned' AND return_status IS NOT NULL AND condition_on_return IS NOT NULL AND CHAR_LENGTH(TRIM(condition_on_return))>0)";
    $result="return_date IS NULL OR return_status=IF(late_days>0,'late','on_time')";
    return [
        'books'=>['chk_books_pages'=>'pages IS NULL OR pages > 0'],
        'ebooks'=>['chk_ebooks_size'=>'file_size_mb IS NULL OR file_size_mb > 0'],
        'book_loan_request_items'=>['chk_book_request_quantity'=>'quantity > 0'],
        'equipment_loan_request_items'=>['chk_equipment_request_quantity'=>'quantity > 0'],
        'equipment'=>['chk_equipment_quantities'=>'total_quantity > 0 AND available_quantity >= 0 AND available_quantity <= total_quantity'],
        'rooms'=>['chk_rooms_capacity'=>'capacity > 0'],
        'room_requests'=>['chk_room_request_time'=>"use_date >= '1000-01-01' AND start_time >= '00:00:00' AND start_time < end_time AND end_time <= '24:00:00'"],
        'extensions'=>['chk_extensions_dates'=>"old_due_date >= '1000-01-01' AND new_due_date > old_due_date AND extension_date >= '1000-01-01'"],
        'loan_details'=>[
            'chk_loan_dates'=>$dates,
            'chk_loan_extensions'=>'extension_count <= 3',
            'chk_loan_return_state'=>$state,
            'chk_loan_return_result'=>$result,
        ],
        'equipment_loan_details'=>[
            'chk_equipment_loan_quantity'=>'quantity > 0',
            'chk_equipment_loan_dates'=>$dates,
            'chk_equipment_return_state'=>$state,
            'chk_equipment_return_result'=>$result,
        ],
    ];
}

function integrity_return_result(string $dueDate, string $returnDate): array
{
    $due=new DateTimeImmutable($dueDate);$returned=new DateTimeImmutable($returnDate);
    $days=max(0,(int)$due->diff($returned)->format('%r%a'));
    return ['return_status'=>$days>0?'late':'on_time','late_days'=>$days];
}

function integrity_api_error(PDOException $error): ?array
{
    $code=(int)($error->errorInfo[1] ?? 0);
    if ($code===1062 && str_contains($error->getMessage(),'uq_loan_details_active_copy')) {
        return ['message'=>'Bản sách đã có lượt mượn chưa trả. Hãy tải lại danh sách.', 'status'=>409];
    }
    if ($code===3819) return ['message'=>'Dữ liệu không thỏa ràng buộc số lượng, ngày hoặc trạng thái. Hãy kiểm tra lại.', 'status'=>422];
    return null;
}
