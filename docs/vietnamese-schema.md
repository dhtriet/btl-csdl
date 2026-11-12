# CSDL Nexus với tên tiếng Việt

Tên bảng/cột vật lý dùng **tiếng Việt không dấu, snake_case**. Dữ liệu, số lượng bản ghi và các liên kết được giữ nguyên. `database/schema.sql` và các tệp SQL trong `database/` dùng tên mới. [Từ điển đầy đủ](database-schema.md) và [sơ đồ ERD](database-erd.mmd) lấy từ metadata CSDL hiện hành.

Ảnh sơ đồ cũ là bản trước khi bổ sung các luồng gia hạn. Mô hình hiện hành có 27 bảng; không bỏ bảng nghiệp vụ mới chỉ để giống ảnh cũ.

## Tên bảng

| Tên cũ | Tên tiếng Việt trong SQL | Nghiệp vụ |
|---|---|---|
| `accounts` | `tai_khoan` | Tài khoản |
| `students` | `sinh_vien` | Sinh viên |
| `librarians` | `thu_thu` | Thủ thư |
| `publishers` | `nha_xuat_ban` | Nhà xuất bản |
| `authors` | `tac_gia` | Tác giả |
| `genres` | `the_loai` | Thể loại |
| `keywords` | `tu_khoa` | Từ khóa |
| `books` | `dau_sach` | Đầu sách |
| `book_authors` | `dau_sach_tac_gia` | Đầu sách – tác giả |
| `book_genres` | `dau_sach_the_loai` | Đầu sách – thể loại |
| `book_keywords` | `dau_sach_tu_khoa` | Đầu sách – từ khóa |
| `ebooks` | `sach_dien_tu` | Sách điện tử |
| `book_copies` | `ban_sach` | Bản sách |
| `book_loan_requests` | `yeu_cau_muon_sach` | Yêu cầu mượn sách |
| `book_loan_request_items` | `chi_tiet_yeu_cau_muon_sach` | Chi tiết yêu cầu mượn sách |
| `loan_receipts` | `phieu_muon_sach` | Phiếu mượn sách |
| `loan_details` | `chi_tiet_muon_sach` | Chi tiết mượn sách |
| `extensions` | `gia_han_sach` | Gia hạn sách |
| `extension_requests` | `yeu_cau_gia_han_sach` | Yêu cầu gia hạn sách |
| `rooms` | `phong` | Phòng |
| `room_requests` | `yeu_cau_dat_phong` | Yêu cầu đặt phòng |
| `equipment` | `thiet_bi` | Thiết bị |
| `equipment_loan_requests` | `yeu_cau_muon_thiet_bi` | Yêu cầu mượn thiết bị |
| `equipment_loan_request_items` | `chi_tiet_yeu_cau_muon_thiet_bi` | Chi tiết yêu cầu mượn thiết bị |
| `equipment_loans` | `phieu_muon_thiet_bi` | Phiếu mượn thiết bị |
| `equipment_loan_details` | `chi_tiet_muon_thiet_bi` | Chi tiết mượn thiết bị |
| `resource_extension_requests` | `yeu_cau_gia_han_tai_nguyen` | Yêu cầu gia hạn tài nguyên |

## Tên cột

`ma` là khóa chính của từng bảng; `ma_sinh_vien` và `ma_thu_thu` là mã nghiệp vụ. `ma_ho_so_sinh_vien` / `ma_ho_so_thu_thu` là FK trỏ đến khóa chính hồ sơ. `han_tra` là ngày hẹn trả; `ngay_tra` là ngày trả thực tế; `so_ngay_tre` là số ngày thủ thư xác nhận. Các cột bắt đầu `khoa_cho_duyet_` và `khoa_ban_sach_dang_muon` là cột sinh phục vụ UNIQUE, không phải dữ liệu nhập tay.

| Tên cũ | Tên tiếng Việt trong SQL |
|---|---|
| `id` | `ma` |
| `username` | `ten_dang_nhap` |
| `password` | `mat_khau` |
| `full_name` | `ho_ten` |
| `date_of_birth` | `ngay_sinh` |
| `email` | `thu_dien_tu` |
| `phone` | `so_dien_thoai` |
| `address` | `dia_chi` |
| `registered_at` | `thoi_diem_dang_ky` |
| `role` | `vai_tro` |
| `account_id` | `ma_tai_khoan` |
| `student_code` | `ma_sinh_vien` |
| `faculty` | `khoa` |
| `class_name` | `lop` |
| `librarian_code` | `ma_thu_thu` |
| `name` | `ten` |
| `nationality` | `quoc_tich` |
| `biography` | `tieu_su` |
| `description` | `mo_ta` |
| `is_visible` | `hien_thi` |
| `deleted_at` | `thoi_diem_xoa` |
| `title` | `ten_sach` |
| `publication_year` | `nam_xuat_ban` |
| `language` | `ngon_ngu` |
| `summary` | `tom_tat` |
| `pages` | `so_trang` |
| `cover_image` | `anh_bia` |
| `publisher_id` | `ma_nha_xuat_ban` |
| `book_id` | `ma_dau_sach` |
| `author_id` | `ma_tac_gia` |
| `genre_id` | `ma_the_loai` |
| `keyword_id` | `ma_tu_khoa` |
| `file_format` | `dinh_dang_tep` |
| `file_size_mb` | `dung_luong_mb` |
| `resolution` | `do_phan_giai` |
| `file_path` | `duong_dan_tep` |
| `barcode` | `ma_vach` |
| `storage_location` | `vi_tri_luu_tru` |
| `condition_status` | `tinh_trang` |
| `status` | `trang_thai` |
| `student_id` | `ma_ho_so_sinh_vien` |
| `librarian_id` | `ma_ho_so_thu_thu` |
| `requested_at` | `thoi_diem_gui_yeu_cau` |
| `note` | `ghi_chu` |
| `source` | `nguon_tao` |
| `reviewed_at` | `thoi_diem_xet_duyet` |
| `review_note` | `ghi_chu_xet_duyet` |
| `request_id` | `ma_yeu_cau` |
| `quantity` | `so_luong` |
| `requested_due_date` | `han_tra_de_nghi` |
| `receipt_id` | `ma_phieu_muon_sach` |
| `copy_id` | `ma_ban_sach` |
| `borrow_date` | `ngay_muon` |
| `due_date` | `han_tra` |
| `return_date` | `ngay_tra` |
| `return_status` | `ket_qua_tra` |
| `late_days` | `so_ngay_tre` |
| `extension_count` | `so_lan_gia_han` |
| `condition_on_return` | `tinh_trang_khi_tra` |
| `loan_detail_id` | `ma_chi_tiet_muon_sach` |
| `old_due_date` | `han_tra_cu` |
| `new_due_date` | `han_tra_moi` |
| `extension_date` | `ngay_gia_han` |
| `reason` | `ly_do` |
| `extension_id` | `ma_gia_han` |
| `pending_loan_id` | `khoa_cho_duyet_muon_sach` |
| `image_path` | `duong_dan_anh` |
| `image_is_illustration` | `anh_minh_hoa` |
| `room_type` | `loai_phong` |
| `location` | `vi_tri` |
| `capacity` | `suc_chua` |
| `included_equipment` | `thiet_bi_di_kem` |
| `operating_hours` | `gio_hoat_dong` |
| `room_id` | `ma_phong` |
| `use_date` | `ngay_su_dung` |
| `start_time` | `gio_bat_dau` |
| `end_time` | `gio_ket_thuc` |
| `purpose` | `muc_dich` |
| `created_at` | `thoi_diem_tao` |
| `equipment_type` | `loai_thiet_bi` |
| `manufacturer` | `hang_san_xuat` |
| `usage_guide` | `huong_dan_su_dung` |
| `total_quantity` | `tong_so_luong` |
| `available_quantity` | `so_luong_san_sang` |
| `unavailable_quantity` | `so_luong_khong_kha_dung` |
| `serial_number` | `so_se_ri` |
| `equipment_id` | `ma_thiet_bi` |
| `loan_id` | `ma_phieu_muon_thiet_bi` |
| `condition_on_borrow` | `tinh_trang_khi_muon` |
| `equipment_detail_id` | `ma_chi_tiet_muon_thiet_bi` |
| `room_request_id` | `ma_yeu_cau_dat_phong` |
| `old_deadline` | `han_su_dung_cu` |
| `requested_deadline` | `han_su_dung_de_nghi` |
| `pending_equipment_id` | `khoa_cho_duyet_thiet_bi` |
| `pending_room_id` | `khoa_cho_duyet_phong` |
| `active_copy_id` | `khoa_ban_sach_dang_muon` |

## Mã nguồn và tương thích

Các câu SQL trong PHP đã dùng tên tiếng Việt. `app/sql_names.php` dùng một ánh xạ chung từ `database/vietnamese-identifiers.json` để xử lý tên động và hỗ trợ giai đoạn nâng cấp. Bộ phân tích không thay đổi chuỗi dữ liệu, giá trị ENUM, chú thích hay tham số `:username`, `:book_id`.

Khóa JSON của API, đường dẫn API và tên trường form vẫn giữ hợp đồng hiện có. Ví dụ `/api/books` trả `id`, `title`; SQL đọc `dau_sach.ma`, `dau_sach.ten_sach`. Lớp PDO chuẩn hóa tên cột kết quả về khóa API. Chỉ mục SQLite của chatbot là kho tìm kiếm riêng, giữ cấu trúc riêng; không đổi tên nhầm với bảng MySQL.

Tên FK/CHECK/UNIQUE cũ được giữ để các kiểm tra lỗi và migration lịch sử vẫn hoạt động. Quan hệ FK, CHECK và UNIQUE trên cột sinh được dựng lại và xác minh; không tắt ràng buộc nghiệp vụ trong bản triển khai.

## Nâng cấp database có dữ liệu

```powershell
php scripts/migrate-vietnamese-schema.php
php scripts/migrate-vietnamese-schema.php --apply
```

Runner tạo snapshot SQL và kế hoạch DDL trước thay đổi. Migration đổi tên cột, giữ các khóa sinh và ràng buộc, rồi đổi 27 tên bảng bằng một lệnh RENAME TABLE. MySQL và MariaDB đã được kiểm thử riêng. Chạy lại sau khi hoàn tất không đổi thêm gì. Không nạp schema/seed ghi đè dữ liệu đang dùng.

Nếu cần quay về tên cũ có kiểm soát:

```powershell
php scripts/migrate-vietnamese-schema.php --apply --rollback
```

Nên tạm dừng thao tác ghi trong lúc chạy DDL. Khi lỗi giữa chừng, dừng ghi và dùng snapshot/kế hoạch DDL để khôi phục trước khi tiếp tục; không bỏ qua lỗi migration. Mã ứng dụng đọc được cả lược đồ tiếng Anh hoàn chỉnh và tiếng Việt hoàn chỉnh để phục vụ triển khai chuyển tiếp.

Trong MySQL Workbench, Refresh Schemas để xem tên mới. Sơ đồ EER đã lưu từ trước không tự đổi theo database: Reverse Engineer lại từ schema đã nâng cấp để tạo sơ đồ đúng tên mới.

## Kiểm thử

- `php tests/sql-names.php`: tên SQL, chuỗi dữ liệu, placeholder, chú thích và khóa API.
- `tests/vietnamese-schema.php`: chỉ chạy database test; so sánh toàn bộ giá trị của 27 bảng trước/sau, số ràng buộc và tính chạy lại an toàn.
- `tests/schema-circulation.php`: khởi tạo schema tiếng Việt, seed, FK/CHECK/UNIQUE và migration nghiệp vụ.
- Các bộ HTTP mượn/trả, gia hạn sách, thiết bị và phòng kiểm tra API sau khi đổi tên.
