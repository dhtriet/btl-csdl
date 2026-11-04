<?php
declare(strict_types=1);
require_once __DIR__.'/learning_kit.php';
require_once __DIR__.'/queries/books.php';

function assistant_catalog(PDO $pdo): array
{
    return assistant_book_catalog($pdo);
}

function assistant_directory(): string
{
    $directory=__DIR__.'/../storage/assistant';
    if (!is_dir($directory) && !mkdir($directory,0700,true)) throw new ApiException('Không tạo được nơi lưu trợ lý.',503);
    return $directory;
}

function assistant_worker(array $payload): array
{
    $path=__DIR__.'/../storage/ai-config.json';
    $config=is_file($path)?json_decode(file_get_contents($path),true):[];
    $python=getenv('NEXUS_PYTHON') ?: ($config['python'] ?? 'python');
    $script=__DIR__.'/../scripts/chat_worker.py';
    $process=proc_open([$python,$script],[0=>['pipe','r'],1=>['pipe','w'],2=>['file',PHP_OS_FAMILY==='Windows'?'NUL':'/dev/null','a']],$pipes,dirname(__DIR__),null,['bypass_shell'=>true,'suppress_errors'=>true]);
    if (!is_resource($process)) throw new ApiException('Chưa khởi động được dịch vụ tra cứu sách.',503);
    fwrite($pipes[0],json_encode($payload,JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR));fclose($pipes[0]);
    $result=stream_get_contents($pipes[1]);fclose($pipes[1]);$code=proc_close($process);
    $data=json_decode($result,true);
    if (!is_array($data)) throw new ApiException('Dịch vụ tra cứu sách chưa sẵn sàng.',503);
    return $data;
}

function assistant_history_path(int $userId): string
{
    return assistant_directory().'/user-'.$userId.'.json';
}

function assistant_read_history(string $raw): array
{
    if ($raw==='') return ['threads'=>[]];
    $data=json_decode($raw,true);
    if (!is_array($data) || !isset($data['threads']) || !is_array($data['threads'])) throw new ApiException('Không đọc được lịch sử. Vui lòng liên hệ quản trị.',503);
    return $data;
}

function assistant_rate_limit(int $userId): void
{
    $file=fopen(assistant_directory().'/usage.json','c+');
    if (!$file || !flock($file,LOCK_EX)) throw new ApiException('Chưa kiểm tra được lượt sử dụng.',503);
    try {
        $data=json_decode(stream_get_contents($file),true) ?: [];
        $hour=date('Y-m-d-H');$day=date('Y-m-d');
        if (($data['day'] ?? '')!==$day) $data=['day'=>$day,'total'=>0,'users'=>[]];
        $user=$data['users'][(string)$userId] ?? ['hour'=>$hour,'count'=>0];
        if ($user['hour']!==$hour) $user=['hour'=>$hour,'count'=>0];
        if ($user['count']>=20 || $data['total']>=100) throw new ApiException('Trợ lý đã đạt giới hạn lượt hỏi. Hãy quay lại sau hoặc liên hệ quản trị.',429);
        $user['count']++;$data['total']++;$data['users'][(string)$userId]=$user;
        rewind($file);ftruncate($file,0);fwrite($file,json_encode($data));fflush($file);
    } finally { flock($file,LOCK_UN);fclose($file); }
}

function route_assistant(PDO $pdo, string $method, ?string $action): void
{
    $user=require_login();
    header('Cache-Control: private, no-store');
    if ($action==='learning-kit') route_learning_kit($pdo,$method,$user);
    if ($method==='GET' && $action==='threads') {
        $path=assistant_history_path((int)$user['id']);
        if (!is_file($path)) json_response(['data'=>[]]);
        $file=fopen($path,'r');flock($file,LOCK_SH);$data=assistant_read_history(stream_get_contents($file));flock($file,LOCK_UN);fclose($file);
        json_response(['data'=>array_values($data['threads'])]);
    }
    $catalog=assistant_catalog($pdo);
    if ($method==='GET' && $action==='status') {
        $status=assistant_worker(['action'=>'status','catalog'=>$catalog]);
        if (isset($status['error'])) throw new ApiException('Chưa đọc được chỉ mục sách.',503);
        json_response(['data'=>['books'=>$status['books'],'configured'=>$status['configured'],'can_reindex'=>in_array($user['role'],['admin','librarian'],true)]]);
    }
    if ($method==='POST' && $action==='index') {
        require_staff();set_time_limit(240);
        $lock=fopen(assistant_directory().'/index.lock','c+');
        if (!$lock || !flock($lock,LOCK_EX|LOCK_NB)) throw new ApiException('Chỉ mục đang được cập nhật. Hãy chờ hoàn tất.',409);
        try {$result=assistant_worker(['action'=>'index','catalog'=>$catalog]);}
        finally {flock($lock,LOCK_UN);fclose($lock);}
        if (isset($result['error'])) throw new ApiException('Chưa cập nhật được nguồn sách. Kiểm tra Python và pypdf.',503);
        json_response(['data'=>$result]);
    }
    if ($method!=='POST' || $action!=='chat') throw new ApiException('Không tìm thấy chức năng trợ lý.',404);
    $body=request_body();
    if (!is_string($body['message'] ?? null) || trim($body['message'])==='' || text_length($body['message'])>2000) throw new ApiException('Câu hỏi cần từ 1 đến 2.000 ký tự.');
    $mode=$body['mode'] ?? 'ask';
    if (!in_array($mode,['ask','summary','roadmap','outcomes'],true)) throw new ApiException('Chế độ hỏi không hợp lệ.');
    $bookIds=$body['book_ids'] ?? [];
    if (!is_array($bookIds) || count($bookIds)>3) throw new ApiException('Chọn tối đa 3 cuốn sách.');
    $bookIds=array_values(array_unique(array_map(static function($value): int {
        if (!is_int($value) || $value<1) throw new ApiException('Mã sách không hợp lệ.');return $value;
    },$bookIds)));
    $known=array_map('intval',array_column($catalog,'id'));
    foreach ($bookIds as $bookId) if (!in_array($bookId,$known,true)) throw new ApiException('Sách đã chọn không tồn tại.',404);
    $threadId=$body['thread_id'] ?? bin2hex(random_bytes(16));$requestId=$body['request_id'] ?? '';
    if (!is_string($threadId) || !preg_match('/^[a-f0-9]{32}$/D',$threadId) || !is_string($requestId) || !preg_match('/^[a-f0-9]{32}$/D',$requestId)) throw new ApiException('Mã hội thoại không hợp lệ.');
    $file=fopen(assistant_history_path((int)$user['id']),'c+');
    if (!$file || !flock($file,LOCK_EX|LOCK_NB)) throw new ApiException('Một câu hỏi của bạn đang được xử lý. Hãy chờ trả lời.',409);
    set_time_limit(100);
    try {
        $store=assistant_read_history(stream_get_contents($file));
        $thread=$store['threads'][$threadId] ?? ['id'=>$threadId,'title'=>'','messages'=>[],'book_ids'=>$bookIds,'mode'=>$mode,'updated_at'=>date(DATE_ATOM)];
        foreach ($thread['messages'] as $message) if (($message['request_id'] ?? '')===$requestId && $message['role']==='assistant') json_response(['data'=>['thread'=>$thread,'reply'=>$message]]);
        if (count($thread['messages'])>=40) throw new ApiException('Hội thoại đã đủ dài. Hãy tạo cuộc trò chuyện mới.');
        assistant_rate_limit((int)$user['id']);
        $history=array_map(static function($message) {
            preg_match('/^.{0,2500}/us',$message['text'],$excerpt);
            return ['role'=>$message['role'],'text'=>$excerpt[0] ?? ''];
        },array_slice($thread['messages'],-8));
        // Release PHP session before the network call; no credentials or profile data go into the prompt.
        session_write_close();
        $result=assistant_worker(['action'=>'chat','message'=>trim($body['message']),'mode'=>$mode,'book_ids'=>$bookIds,'history'=>$history,'catalog'=>$catalog]);
        if (isset($result['error'])) {
            error_log('assistant_failure '.json_encode([
                'code'=>$result['error'],
                'http_status'=>$result['http_status'] ?? null,
                'provider_status'=>$result['provider_status'] ?? null,
                'error_type'=>$result['error_type'] ?? null,
            ],JSON_UNESCAPED_UNICODE));
            $errors=[
                'provider_unavailable'=>'Trợ lý đang bận. Vui lòng thử lại sau.',
                'invalid_provider'=>'Trợ lý chưa sẵn sàng. Vui lòng liên hệ quản trị.',
                'request_too_large'=>'Câu hỏi kèm tài liệu vượt hạn mức AI. Hãy chọn ít sách hơn hoặc tạo hội thoại mới.',
                'provider_request'=>'Chưa xử lý được câu hỏi này. Hãy thử rút gọn hoặc tạo hội thoại mới.',
                'worker_failed'=>'Trợ lý đang gặp lỗi xử lý. Vui lòng thử lại sau.',
                'invalid_model'=>'Trợ lý chưa sẵn sàng. Vui lòng liên hệ quản trị.',
                'missing_key'=>'Trợ lý chưa được cấu hình trên server.',
                'invalid_key'=>'Key AI không hợp lệ. Quản trị cần cập nhật key.',
                'key_permission'=>'Key chưa được cấp quyền hoặc đã bị Google chặn. Quản trị cần kiểm tra key.',
                'quota'=>'Trợ lý đã đạt hạn mức sử dụng AI. Vui lòng thử lại sau ít phút.',
                'model_unavailable'=>'Model AI chưa sẵn sàng. Quản trị cần kiểm tra cấu hình.',
                'connection'=>'Trợ lý tạm thời chưa thể trả lời.',
                'invalid_response'=>'Trợ lý chưa nhận được câu trả lời đầy đủ. Hãy thử câu hỏi ngắn hơn.',
            ];
            throw new ApiException($errors[$result['error']] ?? 'Dịch vụ AI tạm thời chưa trả lời được. Vui lòng thử lại.', $result['error']==='quota'?429:503);
        }
        $thread['title']=$thread['title'] ?: (preg_replace('/\s+/u',' ',trim($body['message'])));
        $thread['book_ids']=$bookIds;$thread['mode']=$mode;$thread['updated_at']=date(DATE_ATOM);
        $thread['messages'][]=['role'=>'user','text'=>trim($body['message']),'created_at'=>date(DATE_ATOM)];
        $reply=['role'=>'assistant','text'=>$result['answer'],'sources'=>$result['sources'],'follow_ups'=>$result['follow_ups'],'grounding'=>$result['grounding'],'coverage'=>$result['coverage'],'request_id'=>$requestId,'created_at'=>date(DATE_ATOM)];
        $thread['messages'][]=$reply;$store['threads'][$threadId]=$thread;
        uasort($store['threads'],static fn($a,$b)=>strcmp($b['updated_at'],$a['updated_at']));
        $store['threads']=array_slice($store['threads'],0,20,true);
        $serialized=json_encode($store,JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
        rewind($file);ftruncate($file,0);if(fwrite($file,$serialized)===false) throw new ApiException('Câu trả lời chưa được lưu. Hãy thử lại.',503);fflush($file);
    } finally {flock($file,LOCK_UN);fclose($file);}
    json_response(['data'=>['thread'=>$thread,'reply'=>$reply]]);
}
