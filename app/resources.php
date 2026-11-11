<?php
declare(strict_types=1);
require_once __DIR__.'/visibility.php';
require_once __DIR__.'/queries/resources.php';
require_once __DIR__.'/queries/books.php';

function require_staff(): array
{
    $user = require_login();
    if (!in_array($user['role'], ['admin', 'librarian'], true)) {
        throw new ApiException('Chỉ quản trị viên và thủ thư được quản lý tài nguyên.', 403);
    }
    return $user;
}

function managed_types(): array
{
    return [
        'books' => ['title', 'publisher_id', 'language', 'publication_year', 'pages', 'summary', 'description', 'cover_image','is_visible'],
        'copies' => ['book_id', 'barcode', 'storage_location', 'condition_status', 'status','is_visible'],
        'rooms' => ['name', 'room_type', 'location', 'capacity', 'included_equipment', 'operating_hours', 'status','is_visible','image_path','image_is_illustration'],
        'equipment' => ['name', 'equipment_type', 'manufacturer', 'description', 'usage_guide', 'total_quantity', 'available_quantity', 'storage_location', 'serial_number', 'status','is_visible','image_path','image_is_illustration'],
    ];
}

function managed_table(string $type): string
{
    if (!isset(managed_types()[$type])) throw new ApiException('Loại tài nguyên không hợp lệ.', 404);
    return $type === 'copies' ? 'book_copies' : $type;
}

function managed_record(PDO $pdo, string $type, int $id, bool $lock = false): array
{
    $table = managed_table($type);
    $query = $pdo->prepare("SELECT * FROM `$table` WHERE id = ? AND deleted_at IS NULL" . ($lock ? ' FOR UPDATE' : ''));
    $query->execute([$id]);
    $row = $query->fetch();
    if (!$row) throw new ApiException('Không tìm thấy tài nguyên.', 404);
    if ($type === 'books') {
        foreach (array_keys(book_relations()) as $relation) {
            $row[$relation] = array_column(book_relation_names($pdo, $relation, $id, false), 'name');
        }
    }
    $row['version'] = hash('sha256', json_encode($row, JSON_UNESCAPED_UNICODE));
    return $row;
}

function resource_text(array $body, string $field, int $max, bool $required = false): ?string
{
    if (isset($body[$field]) && !is_scalar($body[$field])) throw new ApiException("Dữ liệu $field không hợp lệ.");
    $value = trim((string) ($body[$field] ?? ''));
    if (($required && $value === '') || text_length($value) > $max) throw new ApiException("Trường $field bắt buộc hoặc vượt quá $max ký tự.");
    return $value === '' ? null : $value;
}

function resource_int(array $body, string $field, int $min, int $max, bool $nullable = false): ?int
{
    $raw = $body[$field] ?? '';
    if ($nullable && ($raw === '' || $raw === null)) return null;
    if (!is_scalar($raw) || filter_var($raw, FILTER_VALIDATE_INT) === false || (int) $raw < $min || (int) $raw > $max) throw new ApiException("Giá trị $field phải từ $min đến $max.");
    return (int) $raw;
}

function resource_enum(array $body, string $field, array $values): string
{
    if (!in_array($body[$field] ?? null, $values, true)) throw new ApiException("Trạng thái $field không hợp lệ.");
    return $body[$field];
}

function validate_resource(PDO $pdo, string $type, array $body, ?array $old): array
{
    $common=['is_visible'=>resource_visibility($body['is_visible'] ?? $old['is_visible'] ?? 1)];
    if (in_array($type,['rooms','equipment'],true)) {
        $image=array_key_exists('image_path',$body)?resource_text($body,'image_path',255):($old['image_path']??null);
        if ($image!==null && !preg_match('~^/uploads/resources/[a-f0-9]{32}\.(jpg|png|webp)$~D',$image)) throw new ApiException('Hãy tải ảnh bằng nút chọn ảnh.');
        $common+=['image_path'=>$image,'image_is_illustration'=>$image===null?0:resource_visibility($body['image_is_illustration'] ?? $old['image_is_illustration'] ?? 0)];
    }
    if ($type === 'books') {
        $data = [
            'title' => resource_text($body,'title',240,true),
            'publisher_id' => resource_int($body,'publisher_id',1,4294967295),
            'language' => resource_text($body,'language',60,true),
            'publication_year' => resource_int($body,'publication_year',1901,2155,true),
            'pages' => resource_int($body,'pages',1,1000000,true),
            'summary' => resource_text($body,'summary',10000),
            'description' => resource_text($body,'description',20000),
            'cover_image' => resource_text($body,'cover_image',255),
        ];
        if ($data['cover_image'] !== null && !preg_match('~^/uploads/covers/[a-f0-9]{32}\.(jpg|png|webp)$~D', $data['cover_image'])) {
            if (!$old || $data['cover_image'] !== $old['cover_image']) throw new ApiException('Hãy tải ảnh bìa bằng nút chọn ảnh.');
        }
        $q = $pdo->prepare('SELECT id FROM publishers WHERE id = ?'); $q->execute([$data['publisher_id']]);
        if (!$q->fetch()) throw new ApiException('Nhà xuất bản không tồn tại.');
        return $common+$data;
    }
    if ($type === 'copies') {
        $data = [
            'book_id' => $old ? (int)$old['book_id'] : resource_int($body,'book_id',1,4294967295),
            'barcode' => resource_text($body,'barcode',40,true),
            'storage_location' => resource_text($body,'storage_location',120,true),
            'condition_status' => resource_enum($body,'condition_status',['good','worn','damaged','lost']),
            'status' => resource_enum($body,'status',['available','borrowed','damaged','lost']),
        ];
        if ($old) {
            $q = $pdo->prepare('SELECT 1 FROM loan_details WHERE copy_id = ? AND return_date IS NULL LIMIT 1'); $q->execute([$old['id']]);
            if ($q->fetchColumn() !== false) throw new ApiException('Bản sách đang được mượn. Hãy ghi nhận trả trước khi chỉnh sửa.',409);
        }
        if ($data['status'] === 'borrowed') throw new ApiException('Trạng thái đang mượn do nghiệp vụ duyệt mượn quản lý.');
        if (in_array($data['condition_status'], ['damaged','lost'], true) && $data['status'] !== $data['condition_status']) throw new ApiException('Tình trạng hỏng/mất phải khớp trạng thái bản sách.');
        if ($data['status'] === 'available' && !in_array($data['condition_status'], ['good','worn'],true)) throw new ApiException('Bản sách không đủ điều kiện cho mượn.');
        $q=$pdo->prepare('SELECT id FROM books WHERE id = ? AND deleted_at IS NULL'); $q->execute([$data['book_id']]);
        if (!$q->fetch()) throw new ApiException('Đầu sách không tồn tại.');
        return $common+$data;
    }
    if ($type === 'rooms') {
        return $common+[
            'name'=>resource_text($body,'name',100,true),'room_type'=>resource_enum($body,'room_type',['classroom','meeting_room']),
            'location'=>resource_text($body,'location',160,true),'capacity'=>resource_int($body,'capacity',1,10000),
            'included_equipment'=>resource_text($body,'included_equipment',255),'operating_hours'=>resource_text($body,'operating_hours',120),
            'status'=>resource_enum($body,'status',['available','maintenance','inactive']),
        ];
    }
    $total = resource_int($body,'total_quantity',0,1000000);
    // Preserve units that are unavailable (on loan, damaged or withheld); an edit cannot manufacture stock.
    $unavailable = $old ? (int)$old['total_quantity'] - (int)$old['available_quantity'] : 0;
    if ($total < $unavailable) throw new ApiException("Tổng số lượng không được nhỏ hơn $unavailable đơn vị đang mượn/không khả dụng.",409);
    if ($total < 1) throw new ApiException('Tổng số lượng thiết bị phải lớn hơn 0.');
    $status = resource_enum($body,'status',['available','borrowed','maintenance','damaged','unavailable']);
    $available = $total - $unavailable;
    if (in_array($status,['available','borrowed','unavailable'],true)) $status = $available > 0 ? 'available' : (($old && (int)$old['unavailable_quantity'] === $unavailable) ? 'unavailable' : 'borrowed');
    return $common+[
        'name'=>resource_text($body,'name',160,true),'equipment_type'=>resource_text($body,'equipment_type',100,true),
        'manufacturer'=>resource_text($body,'manufacturer',120),'description'=>resource_text($body,'description',10000),
        'usage_guide'=>resource_text($body,'usage_guide',10000),'total_quantity'=>$total,'available_quantity'=>$available,
        'storage_location'=>resource_text($body,'storage_location',160),'serial_number'=>resource_text($body,'serial_number',120),'status'=>$status,
    ];
}

function resource_visibility(mixed $value): int
{
    if (!in_array($value,[0,1,'0','1'],true)) throw new ApiException('Hiển thị phải là Hiện hoặc Đã ẩn.');
    return (int)$value;
}

function resource_assert_deletable(PDO $pdo, string $type, int $id): void
{
    if (resource_has_open_transactions($pdo, $type, $id)) {
        throw new ApiException('Tài nguyên còn khoản mượn hoặc yêu cầu chưa xử lý. Hãy xử lý trước, hoặc dùng Đã ẩn để ngừng hiển thị.', 409);
    }
}

function save_book_names(PDO $pdo, int $bookId, array $body): void
{
    foreach (book_relations() as $table => $definition) {
        $pivot = $definition['pivot'];
        $foreignKey = $definition['foreign_key'];
        $column = $definition['column'];
        $maxLength = $definition['max_length'];
        $items = $body[$table] ?? [];
        if (!is_array($items) || count($items) > 30) {
            throw new ApiException('Danh sách tác giả/thể loại/từ khóa không hợp lệ.');
        }
        $names = array_unique(array_map(static function ($name) use ($maxLength): string {
            if (!is_string($name) || trim($name) === '' || text_length(trim($name)) > $maxLength) {
                throw new ApiException('Tên tác giả/thể loại/từ khóa không hợp lệ.');
            }
            return trim($name);
        }, $items));

        $delete = $pdo->prepare("DELETE FROM `$pivot` WHERE book_id = :book_id");
        $delete->execute(['book_id' => $bookId]);
        $find = $pdo->prepare("SELECT id FROM `$table` WHERE `$column` = :name ORDER BY id LIMIT 1");
        $insertSql = "INSERT INTO `$table` (`$column`) VALUES (:name)";
        // Unique genre/keyword names serialize concurrent inserts without renaming existing rows.
        if ($table !== 'authors') {
            $insertSql .= ' ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)';
        }
        $insert = $pdo->prepare($insertSql);
        $link = $pdo->prepare("INSERT INTO `$pivot` (book_id, `$foreignKey`) VALUES (:book_id, :related_id)");

        foreach ($names as $name) {
            $find->execute(['name' => $name]);
            $relatedId = $find->fetchColumn();
            if ($relatedId === false) {
                $insert->execute(['name' => $name]);
                $relatedId = $pdo->lastInsertId();
            }
            $link->execute(['book_id' => $bookId, 'related_id' => $relatedId]);
        }
    }
}

function manage_resources(PDO $pdo, string $method, ?string $type, ?string $rawId): void
{
    require_staff();
    if ($type === 'options' && $method === 'GET') {
        json_response(['data'=>[
            'publishers'=>$pdo->query('SELECT id,name FROM publishers ORDER BY name')->fetchAll(),
            'books'=>$pdo->query('SELECT id,title FROM books WHERE deleted_at IS NULL ORDER BY title')->fetchAll(),
        ]]);
    }
    if (in_array($type,['cover','image'],true) && $method === 'POST') {
        $file = $_FILES[$type==='cover'?'cover':'image'] ?? null;
        if (!$file || $file['error'] !== UPLOAD_ERR_OK || $file['size'] > 2*1024*1024) throw new ApiException('Ảnh bìa phải là JPG, PNG hoặc WebP, tối đa 2 MB.');
        $size = @getimagesize($file['tmp_name']);
        $mime = class_exists('finfo') ? (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']) : ($size['mime'] ?? '');
        $ext = ['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$mime] ?? null;
        if (!$ext || !$size || $size[0]>8000 || $size[1]>8000) throw new ApiException('Ảnh không hợp lệ hoặc kích thước vượt 8000px.');
        $category=$type==='cover'?'covers':'resources';
        $dir = __DIR__ . '/../public/uploads/'.$category;
        if (!is_dir($dir) && !mkdir($dir,0755,true)) throw new RuntimeException('Cannot create cover directory');
        $name=bin2hex(random_bytes(16)).'.'.$ext;
        if (!move_uploaded_file($file['tmp_name'], $dir.'/'.$name)) throw new RuntimeException('Cannot save cover');
        json_response(['data'=>['path'=>'/uploads/'.$category.'/'.$name]],201);
    }
    $table = managed_table((string)$type);
    $id = $rawId !== null && ctype_digit($rawId) ? (int)$rawId : null;
    if ($rawId !== null && (!$id || $id < 1)) throw new ApiException('Mã tài nguyên không hợp lệ.',404);
    if ($method === 'GET') {
        if ($id !== null) json_response(['data'=>managed_record($pdo,$type,$id)]);
        json_response(managed_resource_list(
            $pdo,
            $type,
            max(1, min(100000, (int) query_string('page', '1'))),
            trim(query_string('search', '') ?? ''),
            query_string('visibility', 'all') ?? 'all'
        ));
    }
    if (!in_array($method,['POST','PUT','PATCH','DELETE'],true) || ($method!=='POST') !== ($id!==null)) throw new ApiException('Phương thức không hỗ trợ.',405);
    $body=request_body();
    $pdo->beginTransaction();
    try {
        $old=$id!==null?managed_record($pdo,$type,$id,true):null;
        if ($old && (!is_string($body['version'] ?? null) || !hash_equals($old['version'],$body['version']))) throw new ApiException('Dữ liệu đã thay đổi bởi người khác. Đóng biểu mẫu, tải lại và mở bản mới trước khi sửa.',409);
        if ($method==='DELETE') {
            resource_assert_deletable($pdo,$type,$id);
            $delete = $pdo->prepare("UPDATE `$table` SET deleted_at = NOW(), is_visible = 0 WHERE id = :id");
            $delete->execute(['id' => $id]);
            $pdo->commit();json_response(['data'=>['id'=>$id,'deleted'=>true]]);
        }
        if ($method==='PATCH') {
            $visible=resource_visibility($body['is_visible'] ?? null);
            $visibility = $pdo->prepare("UPDATE `$table` SET is_visible = :visible WHERE id = :id");
            $visibility->execute(['visible' => $visible, 'id' => $id]);
            $saved=managed_record($pdo,$type,$id);$pdo->commit();json_response(['data'=>$saved]);
        }
        $data=validate_resource($pdo,$type,$body,$old);
        if ($old) {
            $fields=implode(',',array_map(static fn($key)=>"`$key` = ?",array_keys($data)));
            $pdo->prepare("UPDATE `$table` SET $fields WHERE id = ?")->execute([...array_values($data),$id]);
        } else {
            $columns=implode(',',array_map(static fn($key)=>"`$key`",array_keys($data))); $slots=implode(',',array_fill(0,count($data),'?'));
            $pdo->prepare("INSERT INTO `$table` ($columns) VALUES ($slots)")->execute(array_values($data)); $id=(int)$pdo->lastInsertId();
        }
        if ($type==='books') save_book_names($pdo,$id,$body);
        if ($type==='equipment' && (!$old || (int)$old['total_quantity'] !== (int)$data['total_quantity'])) {
            $active=$pdo->prepare('SELECT COALESCE(SUM(quantity),0) FROM equipment_loan_details WHERE equipment_id=? AND return_date IS NULL');
            $active->execute([$id]); $onLoan=(int)$active->fetchColumn();
            $blocked=(int)($old['unavailable_quantity'] ?? 0);
            if ((int)$data['total_quantity'] !== (int)$data['available_quantity']+$blocked+$onLoan) throw new ApiException('Tồn kho chưa cân bằng. Hãy kiểm tra số đang mượn và số không khả dụng trước khi sửa số lượng.',409);
        }
        $saved=managed_record($pdo,$type,$id);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        if ($error instanceof PDOException && ($error->errorInfo[1] ?? null)===1062) throw new ApiException('Mã vạch hoặc thông tin định danh đã tồn tại.',409);
        throw $error;
    }
    json_response(['data'=>$saved],$old?200:201);
}
