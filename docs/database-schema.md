# Lược đồ triển khai Nexus

Sinh tự động bằng `php scripts/document-schema.php` từ metadata MySQL; không chứa dữ liệu cá nhân. Nguồn khởi tạo: `database/schema.sql`; CSDL cũ nâng cấp bằng `scripts/migrate-circulation.php --apply` và `scripts/migrate-extension-requests.php --apply`.

Số bảng: **26**. Cùng một tập metadata tạo tài liệu này và `database-erd.mmd`; dùng hai tệp này khi cập nhật báo cáo và slide.

## `accounts`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `username` | `varchar(50)` | NO | UK | — |
| `password` | `varchar(100)` | NO |  | — |
| `full_name` | `varchar(120)` | NO |  | — |
| `date_of_birth` | `date` | YES |  | — |
| `email` | `varchar(120)` | YES |  | — |
| `phone` | `varchar(30)` | YES |  | — |
| `address` | `varchar(255)` | YES |  | — |
| `registered_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `role` | `enum('student','librarian','admin')` | NO |  | — |

## `authors`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `full_name` | `varchar(160)` | NO |  | — |
| `date_of_birth` | `date` | YES |  | — |
| `nationality` | `varchar(80)` | YES |  | — |
| `biography` | `text` | YES |  | — |

## `book_authors`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `book_id` | `int unsigned` | NO | PK, FK | — |
| `author_id` | `int unsigned` | NO | PK, FK | — |

## `book_copies`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `book_id` | `int unsigned` | NO | FK | — |
| `barcode` | `varchar(40)` | NO | UK | — |
| `storage_location` | `varchar(120)` | NO |  | — |
| `condition_status` | `enum('good','worn','damaged','lost')` | NO |  | good |
| `status` | `enum('available','borrowed','damaged','lost')` | NO |  | available |
| `is_visible` | `tinyint(1)` | NO |  | 1 |
| `deleted_at` | `datetime` | YES |  | — |

## `book_genres`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `book_id` | `int unsigned` | NO | PK, FK | — |
| `genre_id` | `int unsigned` | NO | PK, FK | — |

## `book_keywords`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `book_id` | `int unsigned` | NO | PK, FK | — |
| `keyword_id` | `int unsigned` | NO | PK, FK | — |

## `book_loan_request_items`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `request_id` | `int unsigned` | NO | FK | — |
| `book_id` | `int unsigned` | NO | FK | — |
| `quantity` | `int unsigned` | NO |  | 1 |
| `requested_due_date` | `date` | NO |  | — |

- `chk_book_request_quantity`: `(`quantity` > 0)`

## `book_loan_requests`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `student_id` | `int unsigned` | NO | FK | — |
| `librarian_id` | `int unsigned` | YES | FK | — |
| `requested_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `note` | `varchar(255)` | YES |  | — |
| `status` | `enum('pending','approved','rejected','cancelled')` | NO |  | pending |
| `reviewed_at` | `datetime` | YES |  | — |
| `review_note` | `varchar(255)` | YES |  | — |
| `source` | `enum('online','counter')` | NO |  | online |

## `books`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `title` | `varchar(240)` | NO |  | — |
| `publication_year` | `year` | YES |  | — |
| `language` | `varchar(60)` | NO |  | — |
| `summary` | `text` | YES |  | — |
| `pages` | `int unsigned` | YES |  | — |
| `cover_image` | `varchar(255)` | YES |  | — |
| `description` | `text` | YES |  | — |
| `publisher_id` | `int unsigned` | NO | FK | — |
| `is_visible` | `tinyint(1)` | NO |  | 1 |
| `deleted_at` | `datetime` | YES |  | — |

- `chk_books_pages`: `((`pages` is null) or (`pages` > 0))`

## `ebooks`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `book_id` | `int unsigned` | NO | UK, FK | — |
| `file_format` | `varchar(20)` | NO |  | — |
| `file_size_mb` | `decimal(8,2)` | YES |  | — |
| `resolution` | `varchar(40)` | YES |  | — |
| `file_path` | `varchar(255)` | YES |  | — |

- `chk_ebooks_size`: `((`file_size_mb` is null) or (`file_size_mb` > 0))`

## `equipment`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `name` | `varchar(160)` | NO |  | — |
| `equipment_type` | `varchar(100)` | NO |  | — |
| `manufacturer` | `varchar(120)` | YES |  | — |
| `description` | `text` | YES |  | — |
| `usage_guide` | `text` | YES |  | — |
| `total_quantity` | `int unsigned` | NO |  | 1 |
| `available_quantity` | `int unsigned` | NO |  | 1 |
| `storage_location` | `varchar(160)` | YES |  | — |
| `serial_number` | `varchar(120)` | YES |  | — |
| `status` | `enum('available','borrowed','maintenance','damaged','unavailable')` | NO |  | available |
| `is_visible` | `tinyint(1)` | NO |  | 1 |
| `deleted_at` | `datetime` | YES |  | — |
| `image_path` | `varchar(255)` | YES |  | — |
| `image_is_illustration` | `tinyint(1)` | NO |  | 0 |
| `unavailable_quantity` | `int unsigned` | NO |  | 0 |

- `chk_equipment_quantities`: `((`total_quantity` > 0) and (`available_quantity` >= 0) and (`available_quantity` <= `total_quantity`))`

- `chk_equipment_stock_buckets`: `((`available_quantity` + `unavailable_quantity`) <= `total_quantity`)`

## `equipment_loan_details`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `loan_id` | `int unsigned` | NO | FK | — |
| `equipment_id` | `int unsigned` | NO | FK | — |
| `quantity` | `int unsigned` | NO |  | 1 |
| `borrow_date` | `date` | NO |  | — |
| `due_date` | `date` | NO |  | — |
| `return_date` | `date` | YES |  | — |
| `return_status` | `enum('on_time','late')` | YES |  | — |
| `late_days` | `smallint unsigned` | NO |  | 0 |
| `condition_on_borrow` | `varchar(120)` | YES |  | — |
| `condition_on_return` | `varchar(120)` | YES |  | — |
| `status` | `enum('borrowed','returned','overdue')` | NO |  | borrowed |

- `chk_equipment_loan_dates`: `((`borrow_date` >= _utf8mb4\'1000-01-01\') and (`due_date` >= `borrow_date`) and ((`return_date` is null) or (`return_date` >= `borrow_date`)))`

- `chk_equipment_loan_quantity`: `(`quantity` > 0)`

- `chk_equipment_return_result`: `((`return_date` is null) or ((`late_days` = greatest((to_days(`return_date`) - to_days(`due_date`)),0)) and (`return_status` = if((`return_date` > `due_date`),_utf8mb4\'late\',_utf8mb4\'on_time\'))))`

- `chk_equipment_return_state`: `(((`return_date` is null) and (`status` in (_utf8mb4\'borrowed\',_utf8mb4\'overdue\')) and (`return_status` is null) and (`late_days` = 0) and (`condition_on_return` is null)) or ((`return_date` is not null) and (`status` = _utf8mb4\'returned\') and (`return_status` is not null) and (`condition_on_return` is not null) and (char_length(trim(`condition_on_return`)) > 0)))`

## `equipment_loan_request_items`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `request_id` | `int unsigned` | NO | FK | — |
| `equipment_id` | `int unsigned` | NO | FK | — |
| `quantity` | `int unsigned` | NO |  | 1 |
| `requested_due_date` | `date` | NO |  | — |

- `chk_equipment_request_quantity`: `(`quantity` > 0)`

## `equipment_loan_requests`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `student_id` | `int unsigned` | NO | FK | — |
| `librarian_id` | `int unsigned` | YES | FK | — |
| `requested_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `note` | `varchar(255)` | YES |  | — |
| `status` | `enum('pending','approved','rejected','cancelled')` | NO |  | pending |
| `reviewed_at` | `datetime` | YES |  | — |
| `review_note` | `varchar(255)` | YES |  | — |
| `source` | `enum('online','counter')` | NO |  | online |

## `equipment_loans`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `student_id` | `int unsigned` | NO | FK | — |
| `librarian_id` | `int unsigned` | NO | FK | — |
| `registered_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `note` | `varchar(255)` | YES |  | — |
| `status` | `enum('borrowed','returned','overdue')` | NO |  | borrowed |
| `request_id` | `int unsigned` | YES | UK, FK | — |

## `extension_requests`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `loan_detail_id` | `int unsigned` | NO | FK | — |
| `old_due_date` | `date` | NO |  | — |
| `requested_due_date` | `date` | NO |  | — |
| `reason` | `varchar(500)` | NO |  |  |
| `status` | `enum('pending','approved','rejected')` | NO |  | pending |
| `requested_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `librarian_id` | `int unsigned` | YES | FK | — |
| `reviewed_at` | `datetime` | YES |  | — |
| `review_note` | `varchar(500)` | YES |  | — |
| `extension_id` | `int unsigned` | YES | UK, FK | — |
| `pending_loan_id` | `int unsigned` | YES | UK | (case when (`status` = _utf8mb4\'pending\') then `loan_detail_id` else NULL end) |

- `chk_extension_request_dates`: `(`requested_due_date` > `old_due_date`)`

- `chk_extension_request_review`: `(((`status` = _utf8mb4\'pending\') and (`librarian_id` is null) and (`reviewed_at` is null) and (`extension_id` is null)) or ((`status` = _utf8mb4\'approved\') and (`librarian_id` is not null) and (`reviewed_at` is not null) and (`extension_id` is not null)) or ((`status` = _utf8mb4\'rejected\') and (`librarian_id` is not null) and (`reviewed_at` is not null) and (`extension_id` is null)))`

## `extensions`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `loan_detail_id` | `int unsigned` | NO | FK | — |
| `librarian_id` | `int unsigned` | NO | FK | — |
| `old_due_date` | `date` | NO |  | — |
| `new_due_date` | `date` | NO |  | — |
| `extension_date` | `date` | NO |  | — |

- `chk_extensions_dates`: `((`old_due_date` >= _utf8mb4\'1000-01-01\') and (`new_due_date` > `old_due_date`) and (`extension_date` >= _utf8mb4\'1000-01-01\'))`

## `genres`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `name` | `varchar(100)` | NO | UK | — |
| `description` | `varchar(255)` | YES |  | — |

## `keywords`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `name` | `varchar(100)` | NO | UK | — |

## `librarians`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `account_id` | `int unsigned` | NO | UK, FK | — |
| `librarian_code` | `varchar(30)` | NO | UK | — |

## `loan_details`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `receipt_id` | `int unsigned` | NO | FK | — |
| `copy_id` | `int unsigned` | NO | FK | — |
| `borrow_date` | `date` | NO |  | — |
| `due_date` | `date` | NO |  | — |
| `return_date` | `date` | YES |  | — |
| `return_status` | `enum('on_time','late')` | YES |  | — |
| `late_days` | `smallint unsigned` | NO |  | 0 |
| `extension_count` | `tinyint unsigned` | NO |  | 0 |
| `status` | `enum('borrowed','returned','overdue')` | NO |  | borrowed |
| `condition_on_return` | `enum('good','worn','damaged','lost')` | YES |  | — |
| `active_copy_id` | `int unsigned` | YES | UK | (case when (`return_date` is null) then `copy_id` else NULL end) |

- `chk_loan_dates`: `((`borrow_date` >= _utf8mb4\'1000-01-01\') and (`due_date` >= `borrow_date`) and ((`return_date` is null) or (`return_date` >= `borrow_date`)))`

- `chk_loan_extensions`: `(`extension_count` <= 3)`

- `chk_loan_return_result`: `((`return_date` is null) or ((`late_days` = greatest((to_days(`return_date`) - to_days(`due_date`)),0)) and (`return_status` = if((`return_date` > `due_date`),_utf8mb4\'late\',_utf8mb4\'on_time\'))))`

- `chk_loan_return_state`: `(((`return_date` is null) and (`status` in (_utf8mb4\'borrowed\',_utf8mb4\'overdue\')) and (`return_status` is null) and (`late_days` = 0) and (`condition_on_return` is null)) or ((`return_date` is not null) and (`status` = _utf8mb4\'returned\') and (`return_status` is not null) and (`condition_on_return` is not null) and (char_length(trim(`condition_on_return`)) > 0)))`

## `loan_receipts`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `student_id` | `int unsigned` | NO | FK | — |
| `librarian_id` | `int unsigned` | NO | FK | — |
| `registered_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `note` | `varchar(255)` | YES |  | — |
| `status` | `enum('open','completed')` | NO |  | open |
| `request_id` | `int unsigned` | YES | UK, FK | — |

## `publishers`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `name` | `varchar(160)` | NO |  | — |
| `address` | `varchar(255)` | YES |  | — |
| `email` | `varchar(120)` | YES |  | — |
| `phone` | `varchar(30)` | YES |  | — |

## `room_requests`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `student_id` | `int unsigned` | NO | FK | — |
| `room_id` | `int unsigned` | NO | FK | — |
| `librarian_id` | `int unsigned` | YES | FK | — |
| `use_date` | `date` | NO |  | — |
| `start_time` | `time` | NO |  | — |
| `end_time` | `time` | NO |  | — |
| `purpose` | `varchar(255)` | NO |  | — |
| `status` | `enum('pending','approved','rejected','cancelled','completed')` | NO |  | pending |
| `created_at` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `reviewed_at` | `datetime` | YES |  | — |
| `review_note` | `varchar(255)` | YES |  | — |

- `chk_room_request_time`: `((`use_date` >= _utf8mb4\'1000-01-01\') and (`start_time` >= _utf8mb4\'00:00:00\') and (`start_time` < `end_time`) and (`end_time` <= _utf8mb4\'24:00:00\'))`

## `rooms`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `name` | `varchar(100)` | NO |  | — |
| `room_type` | `enum('classroom','meeting_room')` | NO |  | — |
| `location` | `varchar(160)` | NO |  | — |
| `capacity` | `int unsigned` | NO |  | — |
| `included_equipment` | `varchar(255)` | YES |  | — |
| `operating_hours` | `varchar(120)` | YES |  | — |
| `status` | `enum('available','maintenance','inactive')` | NO |  | available |
| `is_visible` | `tinyint(1)` | NO |  | 1 |
| `deleted_at` | `datetime` | YES |  | — |
| `image_path` | `varchar(255)` | YES |  | — |
| `image_is_illustration` | `tinyint(1)` | NO |  | 0 |

- `chk_rooms_capacity`: `(`capacity` > 0)`

## `students`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `id` | `int unsigned` | NO | PK | — |
| `account_id` | `int unsigned` | NO | UK, FK | — |
| `student_code` | `varchar(30)` | NO | UK | — |
| `faculty` | `varchar(120)` | NO |  | — |
| `class_name` | `varchar(80)` | NO |  | — |

## Liên kết khóa ngoại

| Bảng con / cột | Bảng cha / cột | Ràng buộc |
|---|---|---|
| `book_authors.author_id` | `authors.id` | `fk_book_authors_author` |
| `book_authors.book_id` | `books.id` | `fk_book_authors_book` |
| `book_copies.book_id` | `books.id` | `fk_book_copies_book` |
| `book_genres.book_id` | `books.id` | `fk_book_genres_book` |
| `book_genres.genre_id` | `genres.id` | `fk_book_genres_genre` |
| `book_keywords.book_id` | `books.id` | `fk_book_keywords_book` |
| `book_keywords.keyword_id` | `keywords.id` | `fk_book_keywords_keyword` |
| `book_loan_request_items.book_id` | `books.id` | `fk_book_loan_request_items_book` |
| `book_loan_request_items.request_id` | `book_loan_requests.id` | `fk_book_loan_request_items_request` |
| `book_loan_requests.librarian_id` | `librarians.id` | `fk_book_loan_requests_librarian` |
| `book_loan_requests.student_id` | `students.id` | `fk_book_loan_requests_student` |
| `books.publisher_id` | `publishers.id` | `fk_books_publisher` |
| `ebooks.book_id` | `books.id` | `fk_ebooks_book` |
| `equipment_loan_details.equipment_id` | `equipment.id` | `fk_equipment_loan_details_equipment` |
| `equipment_loan_details.loan_id` | `equipment_loans.id` | `fk_equipment_loan_details_loan` |
| `equipment_loan_request_items.equipment_id` | `equipment.id` | `fk_equipment_loan_request_items_equipment` |
| `equipment_loan_request_items.request_id` | `equipment_loan_requests.id` | `fk_equipment_loan_request_items_request` |
| `equipment_loan_requests.librarian_id` | `librarians.id` | `fk_equipment_loan_requests_librarian` |
| `equipment_loan_requests.student_id` | `students.id` | `fk_equipment_loan_requests_student` |
| `equipment_loans.librarian_id` | `librarians.id` | `fk_equipment_loans_librarian` |
| `equipment_loans.request_id` | `equipment_loan_requests.id` | `fk_equipment_loans_request` |
| `equipment_loans.student_id` | `students.id` | `fk_equipment_loans_student` |
| `extension_requests.loan_detail_id` | `loan_details.id` | `fk_extension_request_loan` |
| `extension_requests.extension_id` | `extensions.id` | `fk_extension_request_result` |
| `extension_requests.librarian_id` | `librarians.id` | `fk_extension_request_staff` |
| `extensions.loan_detail_id` | `loan_details.id` | `fk_extensions_detail` |
| `extensions.librarian_id` | `librarians.id` | `fk_extensions_librarian` |
| `librarians.account_id` | `accounts.id` | `fk_librarians_account` |
| `loan_details.copy_id` | `book_copies.id` | `fk_loan_details_copy` |
| `loan_details.receipt_id` | `loan_receipts.id` | `fk_loan_details_receipt` |
| `loan_receipts.librarian_id` | `librarians.id` | `fk_loan_receipts_librarian` |
| `loan_receipts.request_id` | `book_loan_requests.id` | `fk_loan_receipts_request` |
| `loan_receipts.student_id` | `students.id` | `fk_loan_receipts_student` |
| `room_requests.librarian_id` | `librarians.id` | `fk_room_requests_librarian` |
| `room_requests.room_id` | `rooms.id` | `fk_room_requests_room` |
| `room_requests.student_id` | `students.id` | `fk_room_requests_student` |
| `students.account_id` | `accounts.id` | `fk_students_account` |
