-- Read-only demo queries. Select the intended database in Workbench first.
SET @ma_yeu_cau = 9;
SET @ma_sinh_vien = 'SV001';
SET @ma_vach = 'PTIT-GIAUTIN-2018-01';

-- 1. Real constraints installed in this database.
SELECT TABLE_NAME,CONSTRAINT_NAME,CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA=DATABASE()
ORDER BY TABLE_NAME,CONSTRAINT_TYPE,CONSTRAINT_NAME;

-- 2. Current inventory buckets and independent consistency calculation.
SELECT e.ma,e.ten,e.tong_so_luong,e.so_luong_san_sang,
       COALESCE(active.so_luong,0) AS on_loan_quantity,e.so_luong_khong_kha_dung,
       e.tong_so_luong-e.so_luong_san_sang-e.so_luong_khong_kha_dung-COALESCE(active.so_luong,0) AS difference
FROM thiet_bi e
LEFT JOIN (
    SELECT ma_thiet_bi,SUM(so_luong) AS so_luong
    FROM chi_tiet_muon_thiet_bi WHERE ngay_tra IS NULL GROUP BY ma_thiet_bi
) active ON active.ma_thiet_bi=e.ma
WHERE e.thoi_diem_xoa IS NULL ORDER BY e.ten;

-- 3. Explicit request -> receipt -> physical copy -> reader path.
SELECT r.ma AS ma_yeu_cau,r.nguon_tao,r.trang_thai AS request_status,
       lr.ma AS ma_phieu_muon_sach,s.ma_sinh_vien,a.ho_ten,
       b.ten_sach,c.ma_vach,d.ngay_muon,d.han_tra,d.ngay_tra
FROM yeu_cau_muon_sach r
JOIN sinh_vien s ON s.ma=r.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma=s.ma_tai_khoan
LEFT JOIN phieu_muon_sach lr ON lr.ma_yeu_cau=r.ma
LEFT JOIN chi_tiet_muon_sach d ON d.ma_phieu_muon_sach=lr.ma
LEFT JOIN ban_sach c ON c.ma=d.ma_ban_sach
LEFT JOIN dau_sach b ON b.ma=c.ma_dau_sach
WHERE r.ma=@ma_yeu_cau ORDER BY d.ma;

-- 4. Current holder of a physical copy; no row means nobody currently holds it.
SELECT c.ma_vach,b.ten_sach,s.ma_sinh_vien,a.ho_ten,lr.ma AS ma_phieu_muon_sach,d.han_tra
FROM ban_sach c
JOIN dau_sach b ON b.ma=c.ma_dau_sach
JOIN chi_tiet_muon_sach d ON d.ma_ban_sach=c.ma AND d.ngay_tra IS NULL
JOIN phieu_muon_sach lr ON lr.ma=d.ma_phieu_muon_sach
JOIN sinh_vien s ON s.ma=lr.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma=s.ma_tai_khoan
WHERE c.ma_vach=@ma_vach;

-- 5. Complete reader identity, without authentication secrets.
SELECT s.ma_sinh_vien,a.ten_dang_nhap,a.ho_ten,a.ngay_sinh,a.thu_dien_tu,a.so_dien_thoai,a.dia_chi,s.khoa,s.lop
FROM sinh_vien s JOIN tai_khoan a ON a.ma=s.ma_tai_khoan
WHERE s.ma_sinh_vien=@ma_sinh_vien;
