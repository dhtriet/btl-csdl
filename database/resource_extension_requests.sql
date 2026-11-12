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
