USE resource_center;

-- Remove the per-account activity flag without failing if it is already absent.
SET @drop_account_status = (
    SELECT IF(
        COUNT(*) > 0,
        'ALTER TABLE accounts DROP COLUMN status',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'accounts'
      AND column_name = 'status'
);
PREPARE account_status_statement FROM @drop_account_status;
EXECUTE account_status_statement;
DEALLOCATE PREPARE account_status_statement;

CREATE TABLE IF NOT EXISTS yeu_cau_muon_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    thoi_diem_gui_yeu_cau DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ghi_chu VARCHAR(255) NULL,
    trang_thai ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(255) NULL,
    CONSTRAINT fk_book_loan_requests_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_book_loan_requests_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    INDEX idx_book_loan_requests_student_status (ma_ho_so_sinh_vien, trang_thai),
    INDEX idx_book_loan_requests_status (trang_thai, thoi_diem_gui_yeu_cau)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chi_tiet_yeu_cau_muon_sach (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau INT UNSIGNED NOT NULL,
    ma_dau_sach INT UNSIGNED NOT NULL,
    han_tra_de_nghi DATE NOT NULL,
    CONSTRAINT fk_book_loan_request_items_request FOREIGN KEY (ma_yeu_cau) REFERENCES yeu_cau_muon_sach(ma) ON DELETE CASCADE,
    CONSTRAINT fk_book_loan_request_items_book FOREIGN KEY (ma_dau_sach) REFERENCES dau_sach(ma),
    UNIQUE KEY uq_book_loan_request_item (ma_yeu_cau, ma_dau_sach)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS yeu_cau_muon_thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_ho_so_sinh_vien INT UNSIGNED NOT NULL,
    ma_ho_so_thu_thu INT UNSIGNED NULL,
    thoi_diem_gui_yeu_cau DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ghi_chu VARCHAR(255) NULL,
    trang_thai ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    thoi_diem_xet_duyet DATETIME NULL,
    ghi_chu_xet_duyet VARCHAR(255) NULL,
    CONSTRAINT fk_equipment_loan_requests_student FOREIGN KEY (ma_ho_so_sinh_vien) REFERENCES sinh_vien(ma),
    CONSTRAINT fk_equipment_loan_requests_librarian FOREIGN KEY (ma_ho_so_thu_thu) REFERENCES thu_thu(ma),
    INDEX idx_equipment_loan_requests_student_status (ma_ho_so_sinh_vien, trang_thai),
    INDEX idx_equipment_loan_requests_status (trang_thai, thoi_diem_gui_yeu_cau)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chi_tiet_yeu_cau_muon_thiet_bi (
    ma INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    ma_yeu_cau INT UNSIGNED NOT NULL,
    ma_thiet_bi INT UNSIGNED NOT NULL,
    so_luong INT UNSIGNED NOT NULL DEFAULT 1,
    han_tra_de_nghi DATE NOT NULL,
    CONSTRAINT fk_equipment_loan_request_items_request FOREIGN KEY (ma_yeu_cau) REFERENCES yeu_cau_muon_thiet_bi(ma) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_loan_request_items_equipment FOREIGN KEY (ma_thiet_bi) REFERENCES thiet_bi(ma),
    UNIQUE KEY uq_equipment_loan_request_item (ma_yeu_cau, ma_thiet_bi)
) ENGINE=InnoDB;
