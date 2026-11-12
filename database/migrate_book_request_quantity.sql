USE resource_center;

ALTER TABLE chi_tiet_yeu_cau_muon_sach
    ADD COLUMN so_luong INT UNSIGNED NOT NULL DEFAULT 1 AFTER ma_dau_sach;
