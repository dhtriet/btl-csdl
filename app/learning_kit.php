<?php
declare(strict_types=1);
require_once __DIR__ . '/queries/books.php';

function learning_kit_stock(PDO $pdo, array $kit): array
{
    $ids=array_column($kit['books'] ?? [],'id');
    if (!$ids) return $kit;
    $known = [];
    foreach (learning_book_stock($pdo, $ids) as $book) {
        $known[(int) $book['id']] = $book;
    }
    if (count($known)!==count($ids)) {
        $kit['books']=[];$kit['weeks']=[];$kit['sources']=[];
        $kit['intro']='Danh mục đã thay đổi hiển thị. Hãy tạo lại bộ học liệu để nhận các sách hiện còn công khai.';
        return $kit;
    }
    $kit['books']=array_values(array_filter(array_map(static function($book) use ($known) {
        if (!isset($known[$book['id']])) return null;
        $actual=$known[$book['id']];
        return array_merge($book,['title'=>$actual['title'],'authors'=>$actual['authors'] ?? '',
            'available_copies'=>(int)$actual['available_copies'],'has_ebook'=>(bool)$actual['has_ebook']]);
    },$kit['books'])));
    return $kit;
}

function route_learning_kit(PDO $pdo, string $method, array $user): void
{
    $path=assistant_directory().'/learning-kit-user-'.(int)$user['id'].'.json';
    if ($method==='GET') {
        if (!is_file($path)) json_response(['data'=>null]);
        $file=fopen($path,'r');
        if (!$file || !flock($file,LOCK_SH)) throw new ApiException('Chưa đọc được bộ học liệu.',503);
        try {$saved=json_decode(stream_get_contents($file),true);}
        finally {flock($file,LOCK_UN);fclose($file);}
        if (!is_array($saved) || !isset($saved['kit'])) throw new ApiException('Chưa đọc được bộ học liệu đã lưu.',503);
        json_response(['data'=>learning_kit_stock($pdo,$saved['kit'])]);
    }
    if ($method!=='POST') throw new ApiException('Phương thức không được hỗ trợ.',405);
    $body=request_body();$goal=$body['goal'] ?? null;
    if (!is_string($goal) || text_length(trim($goal))<10 || text_length($goal)>600) throw new ApiException('Mục tiêu cần từ 10 đến 600 ký tự.');
    $goal=trim($goal);$weeks=$body['weeks'] ?? null;$minutes=$body['minutes'] ?? null;$level=$body['level'] ?? '';
    if (!is_int($weeks) || $weeks<1 || $weeks>12) throw new ApiException('Thời gian học cần từ 1 đến 12 tuần.');
    if (!is_int($minutes) || $minutes<15 || $minutes>180) throw new ApiException('Thời lượng cần từ 15 đến 180 phút mỗi ngày.');
    $levels=['beginner'=>'Mới bắt đầu','intermediate'=>'Đã có nền tảng','advanced'=>'Muốn học chuyên sâu'];
    if (!is_string($level) || !isset($levels[$level])) throw new ApiException('Chọn trình độ hiện tại của bạn.');
    $requestId=$body['request_id'] ?? '';
    if (!is_string($requestId) || !preg_match('/^[a-f0-9]{32}$/D',$requestId)) throw new ApiException('Mã yêu cầu chưa hợp lệ.');
    $digest=hash('sha256',json_encode([$goal,$weeks,$minutes,$level]));
    $file=fopen($path,'c+');
    if (!$file || !flock($file,LOCK_EX|LOCK_NB)) {if ($file) fclose($file);throw new ApiException('Bộ học liệu đang được tạo. Hãy chờ hoàn tất.',409);}
    set_time_limit(100);
    try {
        $saved=json_decode(stream_get_contents($file),true);
        if (($saved['request_id'] ?? '')===$requestId && ($saved['digest'] ?? '')===$digest) {
            $kit=learning_kit_stock($pdo,$saved['kit']);
        } else {
            $catalog=assistant_catalog($pdo);assistant_rate_limit((int)$user['id']);
            session_write_close();
            $result=assistant_worker(['action'=>'chat','mode'=>'kit','message'=>$goal,'weeks'=>$weeks,'minutes'=>$minutes,'level'=>$levels[$level],
                'catalog'=>$catalog,'history'=>[]]);
            $noMatch=($result['error'] ?? '')==='no_matching_books';
            if (isset($result['error']) && !$noMatch) {
                $message=match($result['error']) {
                    'quota'=>'Trợ lý đã đạt hạn mức AI. Mục tiêu của bạn được giữ lại; hãy thử lại sau.',
                    'missing_key','invalid_key','key_permission','invalid_provider','invalid_model'=>'Trợ lý chưa sẵn sàng. Hãy liên hệ quản trị để kiểm tra cấu hình.',
                    'invalid_response'=>'Kế hoạch nhận được chưa đầy đủ. Hãy thử lại; bộ học liệu trước vẫn được giữ.',
                    default=>'Chưa tạo được bộ học liệu. Mục tiêu của bạn được giữ lại; hãy thử lại sau.'
                };
                throw new ApiException($message,$result['error']==='quota'?429:503);
            }
            $kit=['goal'=>$goal,'weeks_count'=>$weeks,'minutes'=>$minutes,'level'=>$level,'created_at'=>date(DATE_ATOM),
                'intro'=>$noMatch?'Chưa tìm thấy sách phù hợp trong kho. Hãy thử mục tiêu cụ thể hơn hoặc một chủ đề khác.':$result['answer'],
                'books'=>[],'weeks'=>$noMatch?[]:$result['weeks'],'sources'=>$noMatch?[]:$result['sources']];
            if (!$noMatch) foreach ($result['books'] as $book) $kit['books'][]=[
                'id'=>$book['book_id'],'reason'=>$book['reason'],'reading_focus'=>$book['reading_focus'],'source_ids'=>$book['source_ids']];
            $kit=learning_kit_stock($pdo,$kit);
            $serialized=json_encode(['request_id'=>$requestId,'digest'=>$digest,'kit'=>$kit],JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
            rewind($file);ftruncate($file,0);
            if (fwrite($file,$serialized)===false) throw new ApiException('Chưa lưu được bộ học liệu. Hãy thử lại.',503);
            fflush($file);
        }
    } finally {flock($file,LOCK_UN);fclose($file);}
    json_response(['data'=>$kit]);
}
