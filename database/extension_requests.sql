CREATE TABLE IF NOT EXISTS yeu_cau_gia_han_sach (
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
