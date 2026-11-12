CREATE DATABASE IF NOT EXISTS resource_center
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE resource_center;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS yeu_cau_gia_han_tai_nguyen;
DROP TABLE IF EXISTS chi_tiet_yeu_cau_muon_thiet_bi;
DROP TABLE IF EXISTS yeu_cau_muon_thiet_bi;
DROP TABLE IF EXISTS chi_tiet_yeu_cau_muon_sach;
DROP TABLE IF EXISTS yeu_cau_muon_sach;
DROP TABLE IF EXISTS chi_tiet_muon_thiet_bi;
DROP TABLE IF EXISTS phieu_muon_thiet_bi;
DROP TABLE IF EXISTS yeu_cau_dat_phong;
DROP TABLE IF EXISTS yeu_cau_gia_han_sach;
DROP TABLE IF EXISTS gia_han_sach;
DROP TABLE IF EXISTS chi_tiet_muon_sach;
DROP TABLE IF EXISTS phieu_muon_sach;
DROP TABLE IF EXISTS ban_sach;
DROP TABLE IF EXISTS sach_dien_tu;
DROP TABLE IF EXISTS dau_sach_tu_khoa;
DROP TABLE IF EXISTS dau_sach_the_loai;
DROP TABLE IF EXISTS dau_sach_tac_gia;
DROP TABLE IF EXISTS tu_khoa;
DROP TABLE IF EXISTS the_loai;
DROP TABLE IF EXISTS dau_sach;
DROP TABLE IF EXISTS tac_gia;
DROP TABLE IF EXISTS nha_xuat_ban;
DROP TABLE IF EXISTS thiet_bi;
DROP TABLE IF EXISTS phong;
DROP TABLE IF EXISTS sinh_vien;
DROP TABLE IF EXISTS thu_thu;
DROP TABLE IF EXISTS tai_khoan;

CREATE TABLE tai_khoan (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ten_dang_nhap VARCHAR(50) NOT NULL UNIQUE,
    mat_khau VARCHAR(100) NOT NULL,
    ho_ten VARCHAR(120) NOT NULL,
    ngay_sinh DATE NULL,
    thu_dien_tu VARCHAR(120) NULL,
    so_dien_thoai VARCHAR(30) NULL,
    dia_chi VARCHAR(255) NULL,
    thoi_diem_dang_ky DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    vai_tro ENUM('student', 'librarian', 'admin') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE sinh_vien (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_tai_khoan INT UNSIGNED NOT NULL UNIQUE,
    ma_sinh_vien VARCHAR(30) NOT NULL UNIQUE,
    khoa VARCHAR(120) NOT NULL,
    lop VARCHAR(80) NOT NULL,
    CONSTRAINT fk_students_account FOREIGN KEY (ma_tai_khoan) REFERENCES tai_khoan(ma)
) ENGINE=InnoDB;

CREATE TABLE thu_thu (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_tai_khoan INT UNSIGNED NOT NULL UNIQUE,
    ma_thu_thu VARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT fk_librarians_account FOREIGN KEY (ma_tai_khoan) REFERENCES tai_khoan(ma)
) ENGINE=InnoDB;

CREATE TABLE nha_xuat_ban (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(160) NOT NULL,
    dia_chi VARCHAR(255) NULL,
    thu_dien_tu VARCHAR(120) NULL,
    so_dien_thoai VARCHAR(30) NULL
) ENGINE=InnoDB;

CREATE TABLE tac_gia (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ho_ten VARCHAR(160) NOT NULL,
    ngay_sinh DATE NULL,
    quoc_tich VARCHAR(80) NULL,
    tieu_su TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE the_loai (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(100) NOT NULL UNIQUE,
    mo_ta VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE tu_khoa (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ten VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE dau_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hien_thi TINYINT(1) NOT NULL DEFAULT 1,
    thoi_diem_xoa DATETIME NULL,
    ten_sach VARCHAR(240) NOT NULL,
    nam_xuat_ban YEAR NULL,
    ngon_ngu VARCHAR(60) NOT NULL,
    tom_tat TEXT NULL,
    so_trang INT UNSIGNED NULL,
    anh_bia VARCHAR(255) NULL,
    mo_ta TEXT NULL,
    ma_nha_xuat_ban INT UNSIGNED NOT NULL,
    CONSTRAINT fk_books_publisher FOREIGN KEY (ma_nha_xuat_ban) REFERENCES nha_xuat_ban(ma),
    INDEX idx_books_title (ten_sach),
    INDEX idx_books_language (ngon_ngu),
    INDEX idx_books_year (nam_xuat_ban)
) ENGINE=InnoDB;

CREATE TABLE dau_sach_tac_gia (
    ma_dau_sach INT UNSIGNED NOT NULL,
    ma_tac_gia INT UNSIGNED NOT NULL,
    PRIMARY KEY (ma_dau_sach, ma_tac_gia),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (ma_tac_gia) REFERENCES tac_gia(ma) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE dau_sach_the_loai (
    ma_dau_sach INT UNSIGNED NOT NULL,
    ma_the_loai INT UNSIGNED NOT NULL,
    PRIMARY KEY (ma_dau_sach, ma_the_loai),
    CONSTRAINT fk_book_genres_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_book_genres_genre FOREIGN KEY (ma_the_loai) REFERENCES the_loai(ma) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE dau_sach_tu_khoa (
    ma_dau_sach INT UNSIGNED NOT NULL,
    ma_tu_khoa INT UNSIGNED NOT NULL,
    PRIMARY KEY (ma_dau_sach, ma_tu_khoa),
    CONSTRAINT fk_book_keywords_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_book_keywords_keyword FOREIGN KEY (ma_tu_khoa) REFERENCES tu_khoa(ma) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sach_dien_tu (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_dau_sach INT UNSIGNED NOT NULL UNIQUE,
    dinh_dang_tep VARCHAR(20) NOT NULL,
    dung_luong_mb DECIMAL(8, 2) NULL,
    do_phan_giai VARCHAR(40) NULL,
    duong_dan_tep VARCHAR(255) NULL,
    CONSTRAINT fk_ebooks_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ban_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hien_thi TINYINT(1) NOT NULL DEFAULT 1,
    thoi_diem_xoa DATETIME NULL,
    ma_dau_sach INT UNSIGNED NOT NULL,
    ma_vach VARCHAR(40) NOT NULL UNIQUE,
    vi_tri_luu_tru VARCHAR(120) NOT NULL,
    tinh_trang ENUM('good', 'worn', 'damaged', 'lost') NOT NULL DEFAULT 'good',
    trang_thai ENUM('available', 'borrowed', 'damaged', 'lost') NOT NULL DEFAULT 'available',
    CONSTRAINT fk_book_copies_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma) ON DELETE CASCADE,
    INDEX idx_book_copies_status (trang_thai)
) ENGINE=InnoDB;

CREATE TABLE yeu_cau_muon_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    thoi_diem_gui_yeu_cau DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ghi_chu VARCHAR(255) NULL,
    nguon_tao ENUM('online','counter') NOT NULL DEFAULT 'online',
    trang_thai ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(255) NULL,
    CONSTRAINT fk_book_loan_requests_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_book_loan_requests_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    INDEX idx_book_loan_requests_student_status (ma_ho_so_sinh_vien, trang_thai),
    INDEX idx_book_loan_requests_status (trang_thai, thoi_diem_gui_yeu_cau)
) ENGINE=InnoDB;

CREATE TABLE chi_tiet_yeu_cau_muon_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau INT UNSIGNED NOT NULL,
    ma_dau_sach INT UNSIGNED NOT NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    han_tra_de_nghi DATE NOT NULL,
    CONSTRAINT fk_book_loan_request_items_request FOREIGN KEY (ma_yeu_cau) REFERENCES yeu_cau_muon_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_book_loan_request_items_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma),
    UNIQUE KEY uq_book_loan_request_item (ma_yeu_cau, ma_dau_sach)
) ENGINE=InnoDB;

CREATE TABLE phieu_muon_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau INT UNSIGNED NULL UNIQUE,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NOT NULL,
    thoi_diem_dang_ky DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ghi_chu VARCHAR(255) NULL,
    trang_thai ENUM('open', 'completed') NOT NULL DEFAULT 'open',
    CONSTRAINT fk_loan_receipts_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_loan_receipts_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    CONSTRAINT fk_loan_receipts_request FOREIGN KEY (ma_yeu_cau) REFERENCES yeu_cau_muon_sach(ma),
    INDEX idx_loan_receipts_student (ma_ho_so_sinh_vien)
) ENGINE=InnoDB;

CREATE TABLE chi_tiet_muon_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_phieu_muon_sach INT UNSIGNED NOT NULL,
    ma_ban_sach INT UNSIGNED NOT NULL,
    ngay_muon DATE NOT NULL,
    han_tra DATE NOT NULL,
    ngay_tra DATE NULL,
    ket_qua_tra ENUM('on_time', 'late') NULL,
    so_ngay_tre SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    so_lan_gia_han TINYINT UNSIGNED NOT NULL DEFAULT 0,
    trang_thai ENUM('borrowed', 'returned', 'overdue') NOT NULL DEFAULT 'borrowed',
    tinh_trang_khi_tra ENUM('good', 'worn', 'damaged', 'lost') NULL,
    CONSTRAINT fk_loan_details_receipt FOREIGN KEY (ma_phieu_muon_sach) REFERENCES phieu_muon_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_loan_details_copy FOREIGN KEY (ma_ban_sach) REFERENCES ban_sach(ma),
    INDEX idx_loan_details_due (han_tra, trang_thai),
    INDEX idx_loan_details_return (ngay_tra)
) ENGINE=InnoDB;

CREATE TABLE gia_han_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_chi_tiet_muon_sach INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NOT NULL,
    han_tra_cu DATE NOT NULL,
    han_tra_moi DATE NOT NULL,
    ngay_gia_han DATE NOT NULL,
    CONSTRAINT fk_extensions_detail FOREIGN KEY (ma_chi_tiet_muon_sach) REFERENCES chi_tiet_muon_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_extensions_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma)
) ENGINE=InnoDB;

CREATE TABLE yeu_cau_gia_han_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_chi_tiet_muon_sach INT UNSIGNED NOT NULL,
    han_tra_cu DATE NOT NULL,
    han_tra_de_nghi DATE NOT NULL,
    ly_do VARCHAR(500) NOT NULL DEFAULT '',
    trang_thai ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    thoi_diem_gui_yeu_cau DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(500) NULL,
    ma_gia_han INT UNSIGNED NULL UNIQUE,
    khoa_cho_duyet_muon_sach INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN trang_thai='pending' THEN ma_chi_tiet_muon_sach ELSE NULL END) STORED,
    UNIQUE KEY uq_extension_pending (khoa_cho_duyet_muon_sach),
    CONSTRAINT fk_extension_request_loan FOREIGN KEY (ma_chi_tiet_muon_sach) REFERENCES chi_tiet_muon_sach(ma),
    CONSTRAINT fk_extension_request_staff FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    CONSTRAINT fk_extension_request_result FOREIGN KEY (ma_gia_han) REFERENCES gia_han_sach(ma),
    CONSTRAINT chk_extension_request_dates CHECK (han_tra_de_nghi > han_tra_cu),
    CONSTRAINT chk_extension_request_review CHECK (
        (trang_thai='pending' AND ma_ho_so_thu_thu IS NULL AND thoi_diem_xet_duyet IS NULL AND ma_gia_han IS NULL)
        OR (trang_thai='approved' AND ma_ho_so_thu_thu IS NOT NULL AND thoi_diem_xet_duyet IS NOT NULL AND ma_gia_han IS NOT NULL)
        OR (trang_thai='rejected' AND ma_ho_so_thu_thu IS NOT NULL AND thoi_diem_xet_duyet IS NOT NULL AND ma_gia_han IS NULL)
    )
) ENGINE=InnoDB;

CREATE TABLE phong (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hien_thi TINYINT(1) NOT NULL DEFAULT 1,
    thoi_diem_xoa DATETIME NULL,
    duong_dan_anh VARCHAR(255) NULL,
    anh_minh_hoa TINYINT(1) NOT NULL DEFAULT 0,
    ten VARCHAR(100) NOT NULL,
    loai_phong ENUM('classroom', 'meeting_room') NOT NULL,
    vi_tri VARCHAR(160) NOT NULL,
    suc_chua INT UNSIGNED NOT NULL,
    thiet_bi_di_kem VARCHAR(255) NULL,
    gio_hoat_dong VARCHAR(120) NULL,
    trang_thai ENUM('available', 'maintenance', 'inactive') NOT NULL DEFAULT 'available',
    INDEX idx_rooms_type_capacity (loai_phong, suc_chua)
) ENGINE=InnoDB;

CREATE TABLE yeu_cau_dat_phong (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_phong INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    ngay_su_dung DATE NOT NULL,
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    muc_dich VARCHAR(255) NOT NULL,
    trang_thai ENUM('pending', 'approved', 'rejected', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    thoi_diem_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(255) NULL,
    CONSTRAINT fk_room_requests_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_room_requests_room FOREIGN KEY (ma_phong) REFERENCES phong(ma),
    CONSTRAINT fk_room_requests_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    INDEX idx_room_requests_schedule (ma_phong, ngay_su_dung, gio_bat_dau, gio_ket_thuc, trang_thai)
) ENGINE=InnoDB;

CREATE TABLE thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hien_thi TINYINT(1) NOT NULL DEFAULT 1,
    thoi_diem_xoa DATETIME NULL,
    duong_dan_anh VARCHAR(255) NULL,
    anh_minh_hoa TINYINT(1) NOT NULL DEFAULT 0,
    ten VARCHAR(160) NOT NULL,
    loai_thiet_bi VARCHAR(100) NOT NULL,
    hang_san_xuat VARCHAR(120) NULL,
    mo_ta TEXT NULL,
    huong_dan_su_dung TEXT NULL,
    tong_so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    so_luong_san_sang INT UNSIGNED NOT NULL DEFAULT 1,
    so_luong_khong_kha_dung INT UNSIGNED NOT NULL DEFAULT 0,
    vi_tri_luu_tru VARCHAR(160) NULL,
    so_se_ri VARCHAR(120) NULL,
    trang_thai ENUM('available', 'borrowed', 'maintenance', 'damaged', 'unavailable') NOT NULL DEFAULT 'available',
    INDEX idx_equipment_type_status (loai_thiet_bi, trang_thai)
) ENGINE=InnoDB;

CREATE TABLE yeu_cau_muon_thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    thoi_diem_gui_yeu_cau DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ghi_chu VARCHAR(255) NULL,
    nguon_tao ENUM('online','counter') NOT NULL DEFAULT 'online',
    trang_thai ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(255) NULL,
    CONSTRAINT fk_equipment_loan_requests_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_equipment_loan_requests_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    INDEX idx_equipment_loan_requests_student_status (ma_ho_so_sinh_vien, trang_thai),
    INDEX idx_equipment_loan_requests_status (trang_thai, thoi_diem_gui_yeu_cau)
) ENGINE=InnoDB;

CREATE TABLE chi_tiet_yeu_cau_muon_thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau INT UNSIGNED NOT NULL,
    ma_thiet_bi INT UNSIGNED NOT NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    han_tra_de_nghi DATE NOT NULL,
    CONSTRAINT fk_equipment_loan_request_items_request FOREIGN KEY (ma_yeu_cau) REFERENCES yeu_cau_muon_thiet_bi(ma) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_loan_request_items_equipment FOREIGN KEY (ma_thiet_bi) REFERENCES thiet_bi(ma),
    UNIQUE KEY uq_equipment_loan_request_item (ma_yeu_cau, ma_thiet_bi)
) ENGINE=InnoDB;

CREATE TABLE phieu_muon_thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau INT UNSIGNED NULL UNIQUE,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NOT NULL,
    thoi_diem_dang_ky DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ghi_chu VARCHAR(255) NULL,
    trang_thai ENUM('borrowed', 'returned', 'overdue') NOT NULL DEFAULT 'borrowed',
    CONSTRAINT fk_equipment_loans_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_equipment_loans_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    CONSTRAINT fk_equipment_loans_request FOREIGN KEY (ma_yeu_cau) REFERENCES yeu_cau_muon_thiet_bi(ma)
) ENGINE=InnoDB;

CREATE TABLE chi_tiet_muon_thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_phieu_muon_thiet_bi INT UNSIGNED NOT NULL,
    ma_thiet_bi INT UNSIGNED NOT NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    ngay_muon DATE NOT NULL,
    han_tra DATE NOT NULL,
    ngay_tra DATE NULL,
    ket_qua_tra ENUM('on_time', 'late') NULL,
    so_ngay_tre SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    tinh_trang_khi_muon VARCHAR(120) NULL,
    tinh_trang_khi_tra VARCHAR(120) NULL,
    trang_thai ENUM('borrowed', 'returned', 'overdue') NOT NULL DEFAULT 'borrowed',
    CONSTRAINT fk_equipment_loan_details_loan FOREIGN KEY (ma_phieu_muon_thiet_bi) REFERENCES phieu_muon_thiet_bi(ma) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_loan_details_equipment FOREIGN KEY (ma_thiet_bi) REFERENCES thiet_bi(ma),
    INDEX idx_equipment_loan_details_due (han_tra, trang_thai)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS yeu_cau_gia_han_tai_nguyen (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_chi_tiet_muon_thiet_bi INT UNSIGNED NULL,
    ma_yeu_cau_dat_phong INT UNSIGNED NULL,
    han_su_dung_cu DATETIME NOT NULL,
    han_su_dung_de_nghi DATETIME NOT NULL,
    ly_do VARCHAR(500) NOT NULL DEFAULT '',
    trang_thai ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    thoi_diem_gui_yeu_cau DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(500) NULL,
    khoa_cho_duyet_thiet_bi INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN trang_thai='pending' THEN ma_chi_tiet_muon_thiet_bi ELSE NULL END) STORED,
    khoa_cho_duyet_phong INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN trang_thai='pending' THEN ma_yeu_cau_dat_phong ELSE NULL END) STORED,
    UNIQUE KEY uq_resource_extension_equipment (khoa_cho_duyet_thiet_bi),
    UNIQUE KEY uq_resource_extension_room (khoa_cho_duyet_phong),
    CONSTRAINT fk_resource_extension_equipment FOREIGN KEY (ma_chi_tiet_muon_thiet_bi) REFERENCES chi_tiet_muon_thiet_bi(ma),
    CONSTRAINT fk_resource_extension_room FOREIGN KEY (ma_yeu_cau_dat_phong) REFERENCES yeu_cau_dat_phong(ma),
    CONSTRAINT fk_resource_extension_staff FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    CONSTRAINT chk_resource_extension_target CHECK ((ma_chi_tiet_muon_thiet_bi IS NOT NULL) + (ma_yeu_cau_dat_phong IS NOT NULL) = 1),
    CONSTRAINT chk_resource_extension_deadline CHECK (han_su_dung_de_nghi > han_su_dung_cu),
    CONSTRAINT chk_resource_extension_review CHECK (
        (trang_thai='pending' AND ma_ho_so_thu_thu IS NULL AND thoi_diem_xet_duyet IS NULL)
        OR (trang_thai IN ('approved','rejected') AND ma_ho_so_thu_thu IS NOT NULL AND thoi_diem_xet_duyet IS NOT NULL)
    )
) ENGINE=InnoDB;

-- Row invariants and one active loan per physical copy.
ALTER TABLE `dau_sach` ADD CONSTRAINT `chk_books_pages` CHECK (so_trang IS NULL OR so_trang > 0);
ALTER TABLE `sach_dien_tu` ADD CONSTRAINT `chk_ebooks_size` CHECK (dung_luong_mb IS NULL OR dung_luong_mb > 0);
ALTER TABLE `chi_tiet_yeu_cau_muon_sach` ADD CONSTRAINT `chk_book_request_quantity` CHECK (so_luong > 0);
ALTER TABLE `chi_tiet_yeu_cau_muon_thiet_bi` ADD CONSTRAINT `chk_equipment_request_quantity` CHECK (so_luong > 0);
ALTER TABLE `thiet_bi` ADD CONSTRAINT `chk_equipment_quantities` CHECK (tong_so_luong > 0 AND so_luong_san_sang >= 0 AND so_luong_san_sang <= tong_so_luong);
ALTER TABLE `phong` ADD CONSTRAINT `chk_rooms_capacity` CHECK (suc_chua > 0);
ALTER TABLE `yeu_cau_dat_phong` ADD CONSTRAINT `chk_room_request_time` CHECK (ngay_su_dung >= '1000-01-01' AND gio_bat_dau >= '00:00:00' AND gio_bat_dau < gio_ket_thuc AND gio_ket_thuc <= '24:00:00');
ALTER TABLE `gia_han_sach` ADD CONSTRAINT `chk_extensions_dates` CHECK (han_tra_cu >= '1000-01-01' AND han_tra_moi > han_tra_cu AND ngay_gia_han >= '1000-01-01');
ALTER TABLE `chi_tiet_muon_sach` ADD CONSTRAINT `chk_loan_dates` CHECK (ngay_muon >= '1000-01-01' AND han_tra >= ngay_muon AND (ngay_tra IS NULL OR ngay_tra >= ngay_muon));
ALTER TABLE `chi_tiet_muon_sach` ADD CONSTRAINT `chk_loan_extensions` CHECK (so_lan_gia_han <= 3);
ALTER TABLE `chi_tiet_muon_sach` ADD CONSTRAINT `chk_loan_return_state` CHECK ((ngay_tra IS NULL AND trang_thai IN ('borrowed','overdue') AND ket_qua_tra IS NULL AND so_ngay_tre=0 AND tinh_trang_khi_tra IS NULL) OR (ngay_tra IS NOT NULL AND trang_thai='returned' AND ket_qua_tra IS NOT NULL AND tinh_trang_khi_tra IS NOT NULL AND CHAR_LENGTH(TRIM(tinh_trang_khi_tra))>0));
ALTER TABLE `chi_tiet_muon_sach` ADD CONSTRAINT `chk_loan_return_result` CHECK (ngay_tra IS NULL OR ket_qua_tra=IF(so_ngay_tre>0,'late','on_time'));
ALTER TABLE `chi_tiet_muon_thiet_bi` ADD CONSTRAINT `chk_equipment_loan_quantity` CHECK (so_luong > 0);
ALTER TABLE `chi_tiet_muon_thiet_bi` ADD CONSTRAINT `chk_equipment_loan_dates` CHECK (ngay_muon >= '1000-01-01' AND han_tra >= ngay_muon AND (ngay_tra IS NULL OR ngay_tra >= ngay_muon));
ALTER TABLE `chi_tiet_muon_thiet_bi` ADD CONSTRAINT `chk_equipment_return_state` CHECK ((ngay_tra IS NULL AND trang_thai IN ('borrowed','overdue') AND ket_qua_tra IS NULL AND so_ngay_tre=0 AND tinh_trang_khi_tra IS NULL) OR (ngay_tra IS NOT NULL AND trang_thai='returned' AND ket_qua_tra IS NOT NULL AND tinh_trang_khi_tra IS NOT NULL AND CHAR_LENGTH(TRIM(tinh_trang_khi_tra))>0));
ALTER TABLE `chi_tiet_muon_thiet_bi` ADD CONSTRAINT `chk_equipment_return_result` CHECK (ngay_tra IS NULL OR ket_qua_tra=IF(so_ngay_tre>0,'late','on_time'));
ALTER TABLE chi_tiet_muon_sach ADD COLUMN khoa_ban_sach_dang_muon INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN ngay_tra IS NULL THEN ma_ban_sach ELSE NULL END) VIRTUAL, ADD UNIQUE KEY uq_loan_details_active_copy(khoa_ban_sach_dang_muon);
ALTER TABLE thiet_bi ADD CONSTRAINT chk_equipment_stock_buckets CHECK (so_luong_san_sang + so_luong_khong_kha_dung <= tong_so_luong);

SET FOREIGN_KEY_CHECKS = 1;
