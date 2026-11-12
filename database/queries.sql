USE resource_center;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Read-only examples. In PHP, bind these values with PDO placeholders.
SET @book_search = '%PHP%';
SET @ngay_su_dung = CURDATE();
SET @gio_bat_dau = '09:00:00';
SET @gio_ket_thuc = '11:00:00';

-- Public discovery filters visible/non-deleted resources.
-- Loan/request history deliberately keeps hidden and deleted resource references.

-- 1. Tim kiem va loc sach theo nhieu dieu kien.
SELECT b.ma, b.ten_sach, b.ngon_ngu, b.nam_xuat_ban,
       p.ten AS publisher,
       (
           SELECT GROUP_CONCAT(DISTINCT a.ho_ten ORDER BY a.ho_ten SEPARATOR ', ')
           FROM dau_sach_tac_gia ba
           JOIN tac_gia a ON a.ma = ba.ma_tac_gia
           WHERE ba.ma_dau_sach = b.ma
       ) AS tac_gia,
       (
           SELECT GROUP_CONCAT(DISTINCT g.ten ORDER BY g.ten SEPARATOR ', ')
           FROM dau_sach_the_loai bg
           JOIN the_loai g ON g.ma = bg.ma_the_loai
           WHERE bg.ma_dau_sach = b.ma
       ) AS the_loai
FROM dau_sach b
JOIN nha_xuat_ban p ON p.ma = b.ma_nha_xuat_ban
WHERE b.ten_sach LIKE @book_search
  AND b.hien_thi = 1
  AND b.thoi_diem_xoa IS NULL
ORDER BY b.ma DESC;

-- 2. Liet ke sach da tra, ke ca sach tra tre.
SELECT b.ten_sach, s.ma_sinh_vien, ld.ngay_muon, ld.han_tra, ld.ngay_tra,
       CASE WHEN ld.ket_qua_tra = 'late' THEN 'Tra tre'
            WHEN ld.ket_qua_tra = 'on_time' THEN 'Tra dung han'
            WHEN ld.ngay_tra > ld.han_tra THEN 'Tra tre' ELSE 'Tra dung han' END AS ket_qua_tra,
       CASE WHEN ld.ket_qua_tra = 'late' THEN ld.so_ngay_tre
            ELSE GREATEST(DATEDIFF(ld.ngay_tra, ld.han_tra), 0) END AS so_ngay_tre
FROM chi_tiet_muon_sach ld
JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
JOIN ban_sach c ON c.ma = ld.ma_ban_sach
JOIN dau_sach b ON b.ma = c.ma_dau_sach
WHERE ld.ngay_tra IS NOT NULL;

-- 3. Sach dang qua han, moi dong la mot cuon trong chi tiet phieu.
SELECT b.ten_sach, s.ma_sinh_vien, ld.han_tra,
       DATEDIFF(CURDATE(), ld.han_tra) AS overdue_days
FROM chi_tiet_muon_sach ld
JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
JOIN ban_sach c ON c.ma = ld.ma_ban_sach
JOIN dau_sach b ON b.ma = c.ma_dau_sach
WHERE ld.ngay_tra IS NULL AND ld.han_tra < CURDATE()
ORDER BY overdue_days DESC;

-- 4. Phong trong trong khoang thoi gian.
SELECT r.ma, r.ten, r.loai_phong, r.vi_tri, r.suc_chua,
       r.thiet_bi_di_kem, r.gio_hoat_dong
FROM phong r
WHERE r.trang_thai = 'available'
  AND r.hien_thi = 1
  AND r.thoi_diem_xoa IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM yeu_cau_dat_phong rr
      WHERE rr.ma_phong = r.ma
        AND rr.ngay_su_dung = @ngay_su_dung
        AND rr.trang_thai IN ('pending', 'approved')
        AND rr.gio_bat_dau < @gio_ket_thuc
        AND rr.gio_ket_thuc > @gio_bat_dau
  );

-- 5. Sach duoc muon nhieu nhat.
SELECT b.ten_sach, COUNT(ld.ma) AS borrow_count
FROM dau_sach b
JOIN ban_sach c ON c.ma_dau_sach = b.ma
JOIN chi_tiet_muon_sach ld ON ld.ma_ban_sach = c.ma
WHERE b.hien_thi = 1
  AND b.thoi_diem_xoa IS NULL
GROUP BY b.ma, b.ten_sach
ORDER BY borrow_count DESC;

-- 6. Sinh vien co sach hoac thiet bi qua han.
SELECT s.ma_sinh_vien, a.ho_ten,
       COALESCE(book_counts.book_overdue, 0) AS overdue_books,
       COALESCE(equipment_counts.equipment_overdue, 0) AS overdue_equipment
FROM sinh_vien s
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
LEFT JOIN (
    SELECT lr.ma_ho_so_sinh_vien, COUNT(*) AS book_overdue
    FROM phieu_muon_sach lr JOIN chi_tiet_muon_sach ld ON ld.ma_phieu_muon_sach = lr.ma
    WHERE ld.ngay_tra IS NULL AND ld.han_tra < CURDATE()
    GROUP BY lr.ma_ho_so_sinh_vien
) book_counts ON book_counts.ma_ho_so_sinh_vien = s.ma
LEFT JOIN (
    SELECT el.ma_ho_so_sinh_vien, COUNT(*) AS equipment_overdue
    FROM phieu_muon_thiet_bi el JOIN chi_tiet_muon_thiet_bi eld ON eld.ma_phieu_muon_thiet_bi = el.ma
    WHERE eld.ngay_tra IS NULL AND eld.han_tra < CURDATE()
    GROUP BY el.ma_ho_so_sinh_vien
) equipment_counts ON equipment_counts.ma_ho_so_sinh_vien = s.ma
WHERE book_counts.book_overdue IS NOT NULL OR equipment_counts.equipment_overdue IS NOT NULL;

-- 7. Danh sach yeu cau muon sach dang cho thu thu duyet.
SELECT r.ma AS ma_yeu_cau, s.ma_sinh_vien, a.ho_ten,
       GROUP_CONCAT(CONCAT(b.ten_sach, ' - han ', DATE_FORMAT(i.han_tra_de_nghi, '%d/%m/%Y')) ORDER BY i.ma SEPARATOR '; ') AS requested_books,
       r.thoi_diem_gui_yeu_cau, r.ghi_chu
FROM yeu_cau_muon_sach r
JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
JOIN chi_tiet_yeu_cau_muon_sach i ON i.ma_yeu_cau = r.ma
JOIN dau_sach b ON b.ma = i.ma_dau_sach
WHERE r.trang_thai = 'pending'
GROUP BY r.ma, s.ma_sinh_vien, a.ho_ten, r.thoi_diem_gui_yeu_cau, r.ghi_chu
ORDER BY r.thoi_diem_gui_yeu_cau;

-- 8. Danh sach yeu cau muon thiet bi dang cho thu thu duyet.
SELECT r.ma AS ma_yeu_cau, s.ma_sinh_vien, a.ho_ten,
       GROUP_CONCAT(CONCAT(e.ten, ' x', i.so_luong, ' - han ', DATE_FORMAT(i.han_tra_de_nghi, '%d/%m/%Y')) ORDER BY i.ma SEPARATOR '; ') AS requested_equipment,
       r.thoi_diem_gui_yeu_cau, r.ghi_chu
FROM yeu_cau_muon_thiet_bi r
JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
JOIN chi_tiet_yeu_cau_muon_thiet_bi i ON i.ma_yeu_cau = r.ma
JOIN thiet_bi e ON e.ma = i.ma_thiet_bi
WHERE r.trang_thai = 'pending'
GROUP BY r.ma, s.ma_sinh_vien, a.ho_ten, r.thoi_diem_gui_yeu_cau, r.ghi_chu
ORDER BY r.thoi_diem_gui_yeu_cau;

-- 9. Danh sach yeu cau dat phong dang cho thu thu duyet.
SELECT rr.ma AS ma_yeu_cau, s.ma_sinh_vien, a.ho_ten, r.ten AS room_name,
       rr.ngay_su_dung, rr.gio_bat_dau, rr.gio_ket_thuc, rr.muc_dich, rr.thoi_diem_tao
FROM yeu_cau_dat_phong rr
JOIN sinh_vien s ON s.ma = rr.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
JOIN phong r ON r.ma = rr.ma_phong
WHERE rr.trang_thai = 'pending'
ORDER BY rr.ngay_su_dung, rr.gio_bat_dau;

-- 10. Lich su cac yeu cau da duoc thu thu xu ly.
SELECT 'Muon sach' AS request_type, r.ma AS ma_yeu_cau, s.ma_sinh_vien,
       a.ho_ten AS student_name, r.trang_thai, r.thoi_diem_xet_duyet,
       la.ho_ten AS librarian_name, r.ghi_chu_xet_duyet,
       GROUP_CONCAT(b.ten_sach SEPARATOR '; ') AS resources
FROM yeu_cau_muon_sach r
JOIN sinh_vien s ON s.ma = r.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
LEFT JOIN thu_thu l ON l.ma = r.ma_ho_so_thu_thu
LEFT JOIN tai_khoan la ON la.ma = l.ma_tai_khoan
JOIN chi_tiet_yeu_cau_muon_sach i ON i.ma_yeu_cau = r.ma
JOIN dau_sach b ON b.ma = i.ma_dau_sach
WHERE r.trang_thai IN ('approved', 'rejected')
GROUP BY r.ma, s.ma_sinh_vien, a.ho_ten, r.trang_thai, r.thoi_diem_xet_duyet, la.ho_ten, r.ghi_chu_xet_duyet
ORDER BY r.thoi_diem_xet_duyet DESC;

-- 11. Tai nguyen dang muon de thu thu ghi nhan ngay tra.
SELECT 'Sach' AS resource_type, ld.ma AS detail_id, b.ten_sach AS resource_name,
       s.ma_sinh_vien, a.ho_ten AS student_name, ld.han_tra,
       CASE WHEN ld.han_tra < CURDATE() THEN 'Qua han' ELSE 'Dang muon' END AS loan_status
FROM chi_tiet_muon_sach ld
JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
JOIN ban_sach c ON c.ma = ld.ma_ban_sach
JOIN dau_sach b ON b.ma = c.ma_dau_sach
WHERE ld.ngay_tra IS NULL
UNION ALL
SELECT 'Thiet bi', eld.ma, e.ten, s.ma_sinh_vien, a.ho_ten, eld.han_tra,
       CASE WHEN eld.han_tra < CURDATE() THEN 'Qua han' ELSE 'Dang muon' END
FROM chi_tiet_muon_thiet_bi eld
JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
JOIN sinh_vien s ON s.ma = el.ma_ho_so_sinh_vien
JOIN tai_khoan a ON a.ma = s.ma_tai_khoan
WHERE eld.ngay_tra IS NULL;

-- 12. Danh sach da tra va ket qua dung han hay tre han.
SELECT 'Sach' AS resource_type, b.ten_sach AS resource_name, s.ma_sinh_vien,
       ld.han_tra, ld.ngay_tra,
       CASE WHEN ld.ket_qua_tra = 'late' THEN 'Tra tre'
            WHEN ld.ket_qua_tra = 'on_time' THEN 'Tra dung han'
            WHEN ld.ngay_tra > ld.han_tra THEN 'Tra tre' ELSE 'Tra dung han' END AS ket_qua_tra,
       CASE WHEN ld.ket_qua_tra = 'late' THEN ld.so_ngay_tre
            ELSE GREATEST(DATEDIFF(ld.ngay_tra, ld.han_tra), 0) END AS so_ngay_tre
FROM chi_tiet_muon_sach ld
JOIN phieu_muon_sach lr ON lr.ma = ld.ma_phieu_muon_sach
JOIN sinh_vien s ON s.ma = lr.ma_ho_so_sinh_vien
JOIN ban_sach c ON c.ma = ld.ma_ban_sach
JOIN dau_sach b ON b.ma = c.ma_dau_sach
WHERE ld.ngay_tra IS NOT NULL
UNION ALL
SELECT 'Thiet bi', e.ten, s.ma_sinh_vien, eld.han_tra, eld.ngay_tra,
       CASE WHEN eld.ket_qua_tra = 'late' THEN 'Tra tre'
            WHEN eld.ket_qua_tra = 'on_time' THEN 'Tra dung han'
            WHEN eld.ngay_tra > eld.han_tra THEN 'Tra tre' ELSE 'Tra dung han' END,
       CASE WHEN eld.ket_qua_tra = 'late' THEN eld.so_ngay_tre
            ELSE GREATEST(DATEDIFF(eld.ngay_tra, eld.han_tra), 0) END
FROM chi_tiet_muon_thiet_bi eld
JOIN phieu_muon_thiet_bi el ON el.ma = eld.ma_phieu_muon_thiet_bi
JOIN thiet_bi e ON e.ma = eld.ma_thiet_bi
JOIN sinh_vien s ON s.ma = el.ma_ho_so_sinh_vien
WHERE eld.ngay_tra IS NOT NULL
ORDER BY ngay_tra DESC;
