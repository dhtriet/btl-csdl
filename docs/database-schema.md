# Lược đồ triển khai Nexus

Sinh tự động bằng `php scripts/document-schema.php` từ metadata MySQL; không chứa dữ liệu cá nhân. Nguồn khởi tạo: `database/schema.sql`; CSDL cũ nâng cấp bằng `scripts/migrate-circulation.php --apply` và `scripts/migrate-extension-requests.php --apply`, `scripts/migrate-resource-extensions.php --apply`.

Tên bảng/cột vật lý dùng tiếng Việt không dấu; database cũ nâng cấp bằng `php scripts/migrate-vietnamese-schema.php --apply`. Xem [bảng đối chiếu](vietnamese-schema.md).

Số bảng: **27**. Cùng một tập metadata tạo tài liệu này và `database-erd.mmd`; dùng hai tệp này khi cập nhật báo cáo và slide.

## `ban_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_dau_sach` | `int unsigned` | NO | FK | — |
| `ma_vach` | `varchar(40)` | NO | UK | — |
| `vi_tri_luu_tru` | `varchar(120)` | NO |  | — |
| `tinh_trang` | `enum('good','worn','damaged','lost')` | NO |  | good |
| `trang_thai` | `enum('available','borrowed','damaged','lost')` | NO |  | available |
| `hien_thi` | `tinyint(1)` | NO |  | 1 |
| `thoi_diem_xoa` | `datetime` | YES |  | — |

## `chi_tiet_muon_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_phieu_muon_sach` | `int unsigned` | NO | FK | — |
| `ma_ban_sach` | `int unsigned` | NO | FK | — |
| `ngay_muon` | `date` | NO |  | — |
| `han_tra` | `date` | NO |  | — |
| `ngay_tra` | `date` | YES |  | — |
| `ket_qua_tra` | `enum('on_time','late')` | YES |  | — |
| `so_ngay_tre` | `smallint unsigned` | NO |  | 0 |
| `so_lan_gia_han` | `tinyint unsigned` | NO |  | 0 |
| `trang_thai` | `enum('borrowed','returned','overdue')` | NO |  | borrowed |
| `tinh_trang_khi_tra` | `enum('good','worn','damaged','lost')` | YES |  | — |
| `khoa_ban_sach_dang_muon` | `int unsigned` | YES | UK | (case when (`ngay_tra` is null) then `ma_ban_sach` else NULL end) |

- `chk_loan_dates`: `((`ngay_muon` >= _utf8mb4\'1000-01-01\') and (`han_tra` >= `ngay_muon`) and ((`ngay_tra` is null) or (`ngay_tra` >= `ngay_muon`)))`

- `chk_loan_extensions`: `(`so_lan_gia_han` <= 3)`

- `chk_loan_return_result`: `((`ngay_tra` is null) or (`ket_qua_tra` = if((`so_ngay_tre` > 0),_utf8mb4\'late\',_utf8mb4\'on_time\')))`

- `chk_loan_return_state`: `(((`ngay_tra` is null) and (`trang_thai` in (_utf8mb4\'borrowed\',_utf8mb4\'overdue\')) and (`ket_qua_tra` is null) and (`so_ngay_tre` = 0) and (`tinh_trang_khi_tra` is null)) or ((`ngay_tra` is not null) and (`trang_thai` = _utf8mb4\'returned\') and (`ket_qua_tra` is not null) and (`tinh_trang_khi_tra` is not null) and (char_length(trim(`tinh_trang_khi_tra`)) > 0)))`

## `chi_tiet_muon_thiet_bi`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_phieu_muon_thiet_bi` | `int unsigned` | NO | FK | — |
| `ma_thiet_bi` | `int unsigned` | NO | FK | — |
| `so_luong` | `int unsigned` | NO |  | 1 |
| `ngay_muon` | `date` | NO |  | — |
| `han_tra` | `date` | NO |  | — |
| `ngay_tra` | `date` | YES |  | — |
| `ket_qua_tra` | `enum('on_time','late')` | YES |  | — |
| `so_ngay_tre` | `smallint unsigned` | NO |  | 0 |
| `tinh_trang_khi_muon` | `varchar(120)` | YES |  | — |
| `tinh_trang_khi_tra` | `varchar(120)` | YES |  | — |
| `trang_thai` | `enum('borrowed','returned','overdue')` | NO |  | borrowed |

- `chk_equipment_loan_dates`: `((`ngay_muon` >= _utf8mb4\'1000-01-01\') and (`han_tra` >= `ngay_muon`) and ((`ngay_tra` is null) or (`ngay_tra` >= `ngay_muon`)))`

- `chk_equipment_loan_quantity`: `(`so_luong` > 0)`

- `chk_equipment_return_result`: `((`ngay_tra` is null) or (`ket_qua_tra` = if((`so_ngay_tre` > 0),_utf8mb4\'late\',_utf8mb4\'on_time\')))`

- `chk_equipment_return_state`: `(((`ngay_tra` is null) and (`trang_thai` in (_utf8mb4\'borrowed\',_utf8mb4\'overdue\')) and (`ket_qua_tra` is null) and (`so_ngay_tre` = 0) and (`tinh_trang_khi_tra` is null)) or ((`ngay_tra` is not null) and (`trang_thai` = _utf8mb4\'returned\') and (`ket_qua_tra` is not null) and (`tinh_trang_khi_tra` is not null) and (char_length(trim(`tinh_trang_khi_tra`)) > 0)))`

## `chi_tiet_yeu_cau_muon_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_yeu_cau` | `int unsigned` | NO | FK | — |
| `ma_dau_sach` | `int unsigned` | NO | FK | — |
| `so_luong` | `int unsigned` | NO |  | 1 |
| `han_tra_de_nghi` | `date` | NO |  | — |

- `chk_book_request_quantity`: `(`so_luong` > 0)`

## `chi_tiet_yeu_cau_muon_thiet_bi`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_yeu_cau` | `int unsigned` | NO | FK | — |
| `ma_thiet_bi` | `int unsigned` | NO | FK | — |
| `so_luong` | `int unsigned` | NO |  | 1 |
| `han_tra_de_nghi` | `date` | NO |  | — |

- `chk_equipment_request_quantity`: `(`so_luong` > 0)`

## `dau_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten_sach` | `varchar(240)` | NO |  | — |
| `nam_xuat_ban` | `year` | YES |  | — |
| `ngon_ngu` | `varchar(60)` | NO |  | — |
| `tom_tat` | `text` | YES |  | — |
| `so_trang` | `int unsigned` | YES |  | — |
| `anh_bia` | `varchar(255)` | YES |  | — |
| `mo_ta` | `text` | YES |  | — |
| `ma_nha_xuat_ban` | `int unsigned` | NO | FK | — |
| `hien_thi` | `tinyint(1)` | NO |  | 1 |
| `thoi_diem_xoa` | `datetime` | YES |  | — |

- `chk_books_pages`: `((`so_trang` is null) or (`so_trang` > 0))`

## `dau_sach_tac_gia`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma_dau_sach` | `int unsigned` | NO | PK, FK | — |
| `ma_tac_gia` | `int unsigned` | NO | PK, FK | — |

## `dau_sach_the_loai`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma_dau_sach` | `int unsigned` | NO | PK, FK | — |
| `ma_the_loai` | `int unsigned` | NO | PK, FK | — |

## `dau_sach_tu_khoa`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma_dau_sach` | `int unsigned` | NO | PK, FK | — |
| `ma_tu_khoa` | `int unsigned` | NO | PK, FK | — |

## `gia_han_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_chi_tiet_muon_sach` | `int unsigned` | NO | FK | — |
| `ma_ho_so_thu_thu` | `int unsigned` | NO | FK | — |
| `han_tra_cu` | `date` | NO |  | — |
| `han_tra_moi` | `date` | NO |  | — |
| `ngay_gia_han` | `date` | NO |  | — |

- `chk_extensions_dates`: `((`han_tra_cu` >= _utf8mb4\'1000-01-01\') and (`han_tra_moi` > `han_tra_cu`) and (`ngay_gia_han` >= _utf8mb4\'1000-01-01\'))`

## `nha_xuat_ban`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten` | `varchar(160)` | NO |  | — |
| `dia_chi` | `varchar(255)` | YES |  | — |
| `thu_dien_tu` | `varchar(120)` | YES |  | — |
| `so_dien_thoai` | `varchar(30)` | YES |  | — |

## `phieu_muon_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_ho_so_sinh_vien` | `int unsigned` | NO | FK | — |
| `ma_ho_so_thu_thu` | `int unsigned` | NO | FK | — |
| `thoi_diem_dang_ky` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `ghi_chu` | `varchar(255)` | YES |  | — |
| `trang_thai` | `enum('open','completed')` | NO |  | open |
| `ma_yeu_cau` | `int unsigned` | YES | UK, FK | — |

## `phieu_muon_thiet_bi`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_ho_so_sinh_vien` | `int unsigned` | NO | FK | — |
| `ma_ho_so_thu_thu` | `int unsigned` | NO | FK | — |
| `thoi_diem_dang_ky` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `ghi_chu` | `varchar(255)` | YES |  | — |
| `trang_thai` | `enum('borrowed','returned','overdue')` | NO |  | borrowed |
| `ma_yeu_cau` | `int unsigned` | YES | UK, FK | — |

## `phong`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten` | `varchar(100)` | NO |  | — |
| `loai_phong` | `enum('classroom','meeting_room')` | NO |  | — |
| `vi_tri` | `varchar(160)` | NO |  | — |
| `suc_chua` | `int unsigned` | NO |  | — |
| `thiet_bi_di_kem` | `varchar(255)` | YES |  | — |
| `gio_hoat_dong` | `varchar(120)` | YES |  | — |
| `trang_thai` | `enum('available','maintenance','inactive')` | NO |  | available |
| `hien_thi` | `tinyint(1)` | NO |  | 1 |
| `thoi_diem_xoa` | `datetime` | YES |  | — |
| `duong_dan_anh` | `varchar(255)` | YES |  | — |
| `anh_minh_hoa` | `tinyint(1)` | NO |  | 0 |

- `chk_rooms_capacity`: `(`suc_chua` > 0)`

## `sach_dien_tu`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_dau_sach` | `int unsigned` | NO | UK, FK | — |
| `dinh_dang_tep` | `varchar(20)` | NO |  | — |
| `dung_luong_mb` | `decimal(8,2)` | YES |  | — |
| `do_phan_giai` | `varchar(40)` | YES |  | — |
| `duong_dan_tep` | `varchar(255)` | YES |  | — |

- `chk_ebooks_size`: `((`dung_luong_mb` is null) or (`dung_luong_mb` > 0))`

## `sinh_vien`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_tai_khoan` | `int unsigned` | NO | UK, FK | — |
| `ma_sinh_vien` | `varchar(30)` | NO | UK | — |
| `khoa` | `varchar(120)` | NO |  | — |
| `lop` | `varchar(80)` | NO |  | — |

## `tac_gia`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ho_ten` | `varchar(160)` | NO |  | — |
| `ngay_sinh` | `date` | YES |  | — |
| `quoc_tich` | `varchar(80)` | YES |  | — |
| `tieu_su` | `text` | YES |  | — |

## `tai_khoan`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten_dang_nhap` | `varchar(50)` | NO | UK | — |
| `mat_khau` | `varchar(100)` | NO |  | — |
| `ho_ten` | `varchar(120)` | NO |  | — |
| `ngay_sinh` | `date` | YES |  | — |
| `thu_dien_tu` | `varchar(120)` | YES |  | — |
| `so_dien_thoai` | `varchar(30)` | YES |  | — |
| `dia_chi` | `varchar(255)` | YES |  | — |
| `thoi_diem_dang_ky` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `vai_tro` | `enum('student','librarian','admin')` | NO |  | — |

## `the_loai`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten` | `varchar(100)` | NO | UK | — |
| `mo_ta` | `varchar(255)` | YES |  | — |

## `thiet_bi`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten` | `varchar(160)` | NO |  | — |
| `loai_thiet_bi` | `varchar(100)` | NO |  | — |
| `hang_san_xuat` | `varchar(120)` | YES |  | — |
| `mo_ta` | `text` | YES |  | — |
| `huong_dan_su_dung` | `text` | YES |  | — |
| `tong_so_luong` | `int unsigned` | NO |  | 1 |
| `so_luong_san_sang` | `int unsigned` | NO |  | 1 |
| `vi_tri_luu_tru` | `varchar(160)` | YES |  | — |
| `so_se_ri` | `varchar(120)` | YES |  | — |
| `trang_thai` | `enum('available','borrowed','maintenance','damaged','unavailable')` | NO |  | available |
| `hien_thi` | `tinyint(1)` | NO |  | 1 |
| `thoi_diem_xoa` | `datetime` | YES |  | — |
| `duong_dan_anh` | `varchar(255)` | YES |  | — |
| `anh_minh_hoa` | `tinyint(1)` | NO |  | 0 |
| `so_luong_khong_kha_dung` | `int unsigned` | NO |  | 0 |

- `chk_equipment_quantities`: `((`tong_so_luong` > 0) and (`so_luong_san_sang` >= 0) and (`so_luong_san_sang` <= `tong_so_luong`))`

- `chk_equipment_stock_buckets`: `((`so_luong_san_sang` + `so_luong_khong_kha_dung`) <= `tong_so_luong`)`

## `thu_thu`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_tai_khoan` | `int unsigned` | NO | UK, FK | — |
| `ma_thu_thu` | `varchar(30)` | NO | UK | — |

## `tu_khoa`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ten` | `varchar(100)` | NO | UK | — |

## `yeu_cau_dat_phong`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_ho_so_sinh_vien` | `int unsigned` | NO | FK | — |
| `ma_phong` | `int unsigned` | NO | FK | — |
| `ma_ho_so_thu_thu` | `int unsigned` | YES | FK | — |
| `ngay_su_dung` | `date` | NO |  | — |
| `gio_bat_dau` | `time` | NO |  | — |
| `gio_ket_thuc` | `time` | NO |  | — |
| `muc_dich` | `varchar(255)` | NO |  | — |
| `trang_thai` | `enum('pending','approved','rejected','cancelled','completed')` | NO |  | pending |
| `thoi_diem_tao` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `thoi_diem_xet_duyet` | `datetime` | YES |  | — |
| `ghi_chu_xet_duyet` | `varchar(255)` | YES |  | — |

- `chk_room_request_time`: `((`ngay_su_dung` >= _utf8mb4\'1000-01-01\') and (`gio_bat_dau` >= _utf8mb4\'00:00:00\') and (`gio_bat_dau` < `gio_ket_thuc`) and (`gio_ket_thuc` <= _utf8mb4\'24:00:00\'))`

## `yeu_cau_gia_han_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_chi_tiet_muon_sach` | `int unsigned` | NO | FK | — |
| `han_tra_cu` | `date` | NO |  | — |
| `han_tra_de_nghi` | `date` | NO |  | — |
| `ly_do` | `varchar(500)` | NO |  |  |
| `trang_thai` | `enum('pending','approved','rejected')` | NO |  | pending |
| `thoi_diem_gui_yeu_cau` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `ma_ho_so_thu_thu` | `int unsigned` | YES | FK | — |
| `thoi_diem_xet_duyet` | `datetime` | YES |  | — |
| `ghi_chu_xet_duyet` | `varchar(500)` | YES |  | — |
| `ma_gia_han` | `int unsigned` | YES | UK, FK | — |
| `khoa_cho_duyet_muon_sach` | `int unsigned` | YES | UK | (case when (`trang_thai` = _utf8mb4\'pending\') then `ma_chi_tiet_muon_sach` else NULL end) |

- `chk_extension_request_dates`: `(`han_tra_de_nghi` > `han_tra_cu`)`

- `chk_extension_request_review`: `(((`trang_thai` = _utf8mb4\'pending\') and (`ma_ho_so_thu_thu` is null) and (`thoi_diem_xet_duyet` is null) and (`ma_gia_han` is null)) or ((`trang_thai` = _utf8mb4\'approved\') and (`ma_ho_so_thu_thu` is not null) and (`thoi_diem_xet_duyet` is not null) and (`ma_gia_han` is not null)) or ((`trang_thai` = _utf8mb4\'rejected\') and (`ma_ho_so_thu_thu` is not null) and (`thoi_diem_xet_duyet` is not null) and (`ma_gia_han` is null)))`

## `yeu_cau_gia_han_tai_nguyen`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_chi_tiet_muon_thiet_bi` | `int unsigned` | YES | FK | — |
| `ma_yeu_cau_dat_phong` | `int unsigned` | YES | FK | — |
| `han_su_dung_cu` | `datetime` | NO |  | — |
| `han_su_dung_de_nghi` | `datetime` | NO |  | — |
| `ly_do` | `varchar(500)` | NO |  |  |
| `trang_thai` | `enum('pending','approved','rejected')` | NO |  | pending |
| `thoi_diem_gui_yeu_cau` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `ma_ho_so_thu_thu` | `int unsigned` | YES | FK | — |
| `thoi_diem_xet_duyet` | `datetime` | YES |  | — |
| `ghi_chu_xet_duyet` | `varchar(500)` | YES |  | — |
| `khoa_cho_duyet_thiet_bi` | `int unsigned` | YES | UK | (case when (`trang_thai` = _utf8mb4\'pending\') then `ma_chi_tiet_muon_thiet_bi` else NULL end) |
| `khoa_cho_duyet_phong` | `int unsigned` | YES | UK | (case when (`trang_thai` = _utf8mb4\'pending\') then `ma_yeu_cau_dat_phong` else NULL end) |

- `chk_resource_extension_deadline`: `(`han_su_dung_de_nghi` > `han_su_dung_cu`)`

- `chk_resource_extension_review`: `(((`trang_thai` = _utf8mb4\'pending\') and (`ma_ho_so_thu_thu` is null) and (`thoi_diem_xet_duyet` is null)) or ((`trang_thai` in (_utf8mb4\'approved\',_utf8mb4\'rejected\')) and (`ma_ho_so_thu_thu` is not null) and (`thoi_diem_xet_duyet` is not null)))`

- `chk_resource_extension_target`: `(((`ma_chi_tiet_muon_thiet_bi` is not null) + (`ma_yeu_cau_dat_phong` is not null)) = 1)`

## `yeu_cau_muon_sach`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_ho_so_sinh_vien` | `int unsigned` | NO | FK | — |
| `ma_ho_so_thu_thu` | `int unsigned` | YES | FK | — |
| `thoi_diem_gui_yeu_cau` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `ghi_chu` | `varchar(255)` | YES |  | — |
| `trang_thai` | `enum('pending','approved','rejected','cancelled')` | NO |  | pending |
| `thoi_diem_xet_duyet` | `datetime` | YES |  | — |
| `ghi_chu_xet_duyet` | `varchar(255)` | YES |  | — |
| `nguon_tao` | `enum('online','counter')` | NO |  | online |

## `yeu_cau_muon_thiet_bi`

| Thuộc tính | Kiểu | NULL | Khóa | Mặc định / suy diễn |
|---|---|---|---|---|
| `ma` | `int unsigned` | NO | PK | — |
| `ma_ho_so_sinh_vien` | `int unsigned` | NO | FK | — |
| `ma_ho_so_thu_thu` | `int unsigned` | YES | FK | — |
| `thoi_diem_gui_yeu_cau` | `datetime` | NO |  | CURRENT_TIMESTAMP |
| `ghi_chu` | `varchar(255)` | YES |  | — |
| `trang_thai` | `enum('pending','approved','rejected','cancelled')` | NO |  | pending |
| `thoi_diem_xet_duyet` | `datetime` | YES |  | — |
| `ghi_chu_xet_duyet` | `varchar(255)` | YES |  | — |
| `nguon_tao` | `enum('online','counter')` | NO |  | online |

## Liên kết khóa ngoại

| Bảng con / cột | Bảng cha / cột | Ràng buộc |
|---|---|---|
| `ban_sach.ma_dau_sach` | `dau_sach.ma` | `fk_book_copies_book` |
| `chi_tiet_muon_sach.ma_ban_sach` | `ban_sach.ma` | `fk_loan_details_copy` |
| `chi_tiet_muon_sach.ma_phieu_muon_sach` | `phieu_muon_sach.ma` | `fk_loan_details_receipt` |
| `chi_tiet_muon_thiet_bi.ma_thiet_bi` | `thiet_bi.ma` | `fk_equipment_loan_details_equipment` |
| `chi_tiet_muon_thiet_bi.ma_phieu_muon_thiet_bi` | `phieu_muon_thiet_bi.ma` | `fk_equipment_loan_details_loan` |
| `chi_tiet_yeu_cau_muon_sach.ma_dau_sach` | `dau_sach.ma` | `fk_book_loan_request_items_book` |
| `chi_tiet_yeu_cau_muon_sach.ma_yeu_cau` | `yeu_cau_muon_sach.ma` | `fk_book_loan_request_items_request` |
| `chi_tiet_yeu_cau_muon_thiet_bi.ma_thiet_bi` | `thiet_bi.ma` | `fk_equipment_loan_request_items_equipment` |
| `chi_tiet_yeu_cau_muon_thiet_bi.ma_yeu_cau` | `yeu_cau_muon_thiet_bi.ma` | `fk_equipment_loan_request_items_request` |
| `dau_sach.ma_nha_xuat_ban` | `nha_xuat_ban.ma` | `fk_books_publisher` |
| `dau_sach_tac_gia.ma_tac_gia` | `tac_gia.ma` | `fk_book_authors_author` |
| `dau_sach_tac_gia.ma_dau_sach` | `dau_sach.ma` | `fk_book_authors_book` |
| `dau_sach_the_loai.ma_dau_sach` | `dau_sach.ma` | `fk_book_genres_book` |
| `dau_sach_the_loai.ma_the_loai` | `the_loai.ma` | `fk_book_genres_genre` |
| `dau_sach_tu_khoa.ma_dau_sach` | `dau_sach.ma` | `fk_book_keywords_book` |
| `dau_sach_tu_khoa.ma_tu_khoa` | `tu_khoa.ma` | `fk_book_keywords_keyword` |
| `gia_han_sach.ma_chi_tiet_muon_sach` | `chi_tiet_muon_sach.ma` | `fk_extensions_detail` |
| `gia_han_sach.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_extensions_librarian` |
| `phieu_muon_sach.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_loan_receipts_librarian` |
| `phieu_muon_sach.ma_yeu_cau` | `yeu_cau_muon_sach.ma` | `fk_loan_receipts_request` |
| `phieu_muon_sach.ma_ho_so_sinh_vien` | `sinh_vien.ma` | `fk_loan_receipts_student` |
| `phieu_muon_thiet_bi.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_equipment_loans_librarian` |
| `phieu_muon_thiet_bi.ma_yeu_cau` | `yeu_cau_muon_thiet_bi.ma` | `fk_equipment_loans_request` |
| `phieu_muon_thiet_bi.ma_ho_so_sinh_vien` | `sinh_vien.ma` | `fk_equipment_loans_student` |
| `sach_dien_tu.ma_dau_sach` | `dau_sach.ma` | `fk_ebooks_book` |
| `sinh_vien.ma_tai_khoan` | `tai_khoan.ma` | `fk_students_account` |
| `thu_thu.ma_tai_khoan` | `tai_khoan.ma` | `fk_librarians_account` |
| `yeu_cau_dat_phong.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_room_requests_librarian` |
| `yeu_cau_dat_phong.ma_phong` | `phong.ma` | `fk_room_requests_room` |
| `yeu_cau_dat_phong.ma_ho_so_sinh_vien` | `sinh_vien.ma` | `fk_room_requests_student` |
| `yeu_cau_gia_han_sach.ma_chi_tiet_muon_sach` | `chi_tiet_muon_sach.ma` | `fk_extension_request_loan` |
| `yeu_cau_gia_han_sach.ma_gia_han` | `gia_han_sach.ma` | `fk_extension_request_result` |
| `yeu_cau_gia_han_sach.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_extension_request_staff` |
| `yeu_cau_gia_han_tai_nguyen.ma_chi_tiet_muon_thiet_bi` | `chi_tiet_muon_thiet_bi.ma` | `fk_resource_extension_equipment` |
| `yeu_cau_gia_han_tai_nguyen.ma_yeu_cau_dat_phong` | `yeu_cau_dat_phong.ma` | `fk_resource_extension_room` |
| `yeu_cau_gia_han_tai_nguyen.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_resource_extension_staff` |
| `yeu_cau_muon_sach.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_book_loan_requests_librarian` |
| `yeu_cau_muon_sach.ma_ho_so_sinh_vien` | `sinh_vien.ma` | `fk_book_loan_requests_student` |
| `yeu_cau_muon_thiet_bi.ma_ho_so_thu_thu` | `thu_thu.ma` | `fk_equipment_loan_requests_librarian` |
| `yeu_cau_muon_thiet_bi.ma_ho_so_sinh_vien` | `sinh_vien.ma` | `fk_equipment_loan_requests_student` |
