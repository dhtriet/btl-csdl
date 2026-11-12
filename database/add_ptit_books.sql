USE resource_center;

-- Danh muc giao trinh PTIT va tai lieu tham khao duoc liet ke trong giao trinh Co so du lieu.
INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (SELECT 1 FROM nha_xuat_ban WHERE ten = 'Học viện Công nghệ Bưu chính Viễn thông');

INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'Addison-Wesley', 'Reading, Massachusetts'
WHERE NOT EXISTS (SELECT 1 FROM nha_xuat_ban WHERE ten = 'Addison-Wesley');

INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'Prentice Hall', 'Englewood Cliffs, New Jersey'
WHERE NOT EXISTS (SELECT 1 FROM nha_xuat_ban WHERE ten = 'Prentice Hall');

INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'McGraw-Hill/Irwin', 'New York'
WHERE NOT EXISTS (SELECT 1 FROM nha_xuat_ban WHERE ten = 'McGraw-Hill/Irwin');

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Phạm Thế Quế', 'Việt Nam', 'Tác giả biên soạn giáo trình Cơ sở dữ liệu của Học viện Công nghệ Bưu chính Viễn thông.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Phạm Thế Quế');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'C. J. Date', 'Anh'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'C. J. Date');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'Alfred V. Aho', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Alfred V. Aho');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'John E. Hopcroft', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'John E. Hopcroft');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'Jeffrey D. Ullman', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Jeffrey D. Ullman');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'Michael V. Mannino', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Michael V. Mannino');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'Abraham Silberschatz', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Abraham Silberschatz');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'Henry F. Korth', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Henry F. Korth');

INSERT INTO tac_gia (ho_ten, quoc_tich)
SELECT 'S. Sudarshan', 'Ấn Độ'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'S. Sudarshan');

INSERT INTO the_loai (ten, mo_ta)
SELECT 'Giáo trình', 'Tài liệu học tập và giáo trình đại học'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Giáo trình');

INSERT INTO tu_khoa (ten)
SELECT 'CSDL quan hệ'
WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'CSDL quan hệ');

INSERT INTO tu_khoa (ten)
SELECT 'Chuẩn hóa'
WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Chuẩn hóa');

INSERT INTO tu_khoa (ten)
SELECT 'Thiết kế CSDL'
WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Thiết kế CSDL');

INSERT INTO tu_khoa (ten)
SELECT 'Bảo mật CSDL'
WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Bảo mật CSDL');

INSERT INTO tu_khoa (ten)
SELECT 'PTIT'
WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'PTIT');

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'Cơ sở dữ liệu', 2006, 'Tiếng Việt',
       'Giáo trình giới thiệu hệ cơ sở dữ liệu, mô hình dữ liệu, CSDL quan hệ, chuẩn hóa, SQL, tối ưu hóa truy vấn và an toàn dữ liệu.',
       166, NULL,
       'Giáo trình dùng cho sinh viên hệ đào tạo đại học từ xa, lưu hành nội bộ; mã số 492CDL351.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Cơ sở dữ liệu' AND nam_xuat_ban = 2006);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'An Introduction to Database Systems', 1977, 'English',
       'Tài liệu tham khảo về các khái niệm và hệ thống cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [2] trong giáo trình Cơ sở dữ liệu PTIT.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Addison-Wesley'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'An Introduction to Database Systems' AND nam_xuat_ban = 1977);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'Principles of Database Systems', 1980, 'English',
       'Tài liệu tham khảo về nguyên lý hệ cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [9] trong giáo trình Cơ sở dữ liệu PTIT.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Prentice Hall'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Principles of Database Systems' AND nam_xuat_ban = 1980);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'Database Application Development and Design', 2001, 'English',
       'Tài liệu tham khảo về phát triển và thiết kế ứng dụng cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [10] trong giáo trình Cơ sở dữ liệu PTIT.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'McGraw-Hill/Irwin'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Database Application Development and Design' AND nam_xuat_ban = 2001);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'Database System Concepts', 2002, 'English',
       'Tài liệu tham khảo về khái niệm, thiết kế và vận hành hệ cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [11] trong giáo trình Cơ sở dữ liệu PTIT.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'McGraw-Hill/Irwin'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Database System Concepts' AND nam_xuat_ban = 2002);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'The Design and Analysis of Computer Algorithms', 1974, 'English',
       'Tài liệu tham khảo về thiết kế và phân tích thuật toán.',
       NULL, NULL, 'Tài liệu tham khảo [4] trong giáo trình Cơ sở dữ liệu PTIT.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Addison-Wesley'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'The Design and Analysis of Computer Algorithms' AND nam_xuat_ban = 1974);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Phạm Thế Quế'
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'C. J. Date'
WHERE b.ten_sach = 'An Introduction to Database Systems' AND b.nam_xuat_ban = 1977
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Jeffrey D. Ullman'
WHERE b.ten_sach = 'Principles of Database Systems' AND b.nam_xuat_ban = 1980
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Michael V. Mannino'
WHERE b.ten_sach = 'Database Application Development and Design' AND b.nam_xuat_ban = 2001
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Abraham Silberschatz'
WHERE b.ten_sach = 'Database System Concepts' AND b.nam_xuat_ban = 2002
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Henry F. Korth'
WHERE b.ten_sach = 'Database System Concepts' AND b.nam_xuat_ban = 2002
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'S. Sudarshan'
WHERE b.ten_sach = 'Database System Concepts' AND b.nam_xuat_ban = 2002
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Alfred V. Aho'
WHERE b.ten_sach = 'The Design and Analysis of Computer Algorithms' AND b.nam_xuat_ban = 1974
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'John E. Hopcroft'
WHERE b.ten_sach = 'The Design and Analysis of Computer Algorithms' AND b.nam_xuat_ban = 1974
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Jeffrey D. Ullman'
WHERE b.ten_sach = 'The Design and Analysis of Computer Algorithms' AND b.nam_xuat_ban = 1974
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten = 'Cơ sở dữ liệu'
WHERE b.ten_sach IN ('Cơ sở dữ liệu', 'An Introduction to Database Systems', 'Principles of Database Systems', 'Database Application Development and Design', 'Database System Concepts')
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten = 'Giáo trình'
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten = 'Thuật toán'
WHERE b.ten_sach = 'The Design and Analysis of Computer Algorithms'
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten = 'CSDL quan hệ'
WHERE b.ten_sach IN ('Cơ sở dữ liệu', 'An Introduction to Database Systems', 'Principles of Database Systems', 'Database System Concepts')
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten = 'SQL'
WHERE b.ten_sach IN ('Cơ sở dữ liệu', 'Database System Concepts')
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten = 'Chuẩn hóa'
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten = 'Thiết kế CSDL'
WHERE b.ten_sach = 'Database Application Development and Design'
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten = 'Bảo mật CSDL'
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten = 'PTIT'
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 5.19, 'A4', NULL
FROM dau_sach b
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CSDL-2006-01', 'Kệ G1', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Cơ sở dữ liệu' AND b.nam_xuat_ban = 2006
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CSDL-2006-01');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'REF-DATE-1977-01', 'Kệ G2', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'An Introduction to Database Systems'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'REF-DATE-1977-01');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'REF-ULLMAN-1980-01', 'Kệ G2', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Principles of Database Systems'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'REF-ULLMAN-1980-01');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'REF-MANNINO-2001-01', 'Kệ G3', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Database Application Development and Design'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'REF-MANNINO-2001-01');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'REF-DBCONCEPTS-2002-01', 'Kệ G3', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Database System Concepts'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'REF-DBCONCEPTS-2002-01');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'REF-AHO-1974-01', 'Kệ H1', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'The Design and Analysis of Computer Algorithms'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'REF-AHO-1974-01');
