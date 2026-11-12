USE resource_center;

-- Them cac giao trinh PTIT co trong thu muc tai lieu hoc tap.
INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM nha_xuat_ban
    WHERE ten = 'Học viện Công nghệ Bưu chính Viễn thông'
);

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Từ Minh Phương', 'Việt Nam', 'Tác giả giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông.'
WHERE NOT EXISTS (
    SELECT 1 FROM tac_gia WHERE ho_ten = 'Từ Minh Phương'
);

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Đỗ Thị Diệu', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.'
WHERE NOT EXISTS (
    SELECT 1 FROM tac_gia WHERE ho_ten = 'Đỗ Thị Diệu'
);

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Đào Mạnh Ninh', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.'
WHERE NOT EXISTS (
    SELECT 1 FROM tac_gia WHERE ho_ten = 'Đào Mạnh Ninh'
);

INSERT INTO tu_khoa (ten)
SELECT 'Hệ điều hành'
WHERE NOT EXISTS (
    SELECT 1 FROM tu_khoa WHERE ten = 'Hệ điều hành'
);

INSERT INTO tu_khoa (ten)
SELECT 'Lịch sử Đảng'
WHERE NOT EXISTS (
    SELECT 1 FROM tu_khoa WHERE ten = 'Lịch sử Đảng'
);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT
    'Giáo trình Hệ điều hành',
    2015,
    'Tiếng Việt',
    'Giáo trình trình bày các khái niệm và nguyên lý hoạt động của hệ điều hành, quản lý tiến trình, bộ nhớ, hệ thống tệp và vào ra.',
    185,
    NULL,
    'Giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2015.',
    p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach
      WHERE ten_sach = 'Giáo trình Hệ điều hành' AND nam_xuat_ban = 2015
  );

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT
    'Bài giảng Lịch sử Đảng Cộng sản Việt Nam',
    2021,
    'Tiếng Việt',
    'Bài giảng dành cho sinh viên đại học, trình bày quá trình ra đời, lãnh đạo đấu tranh giành chính quyền, kháng chiến và công cuộc đổi mới.',
    169,
    NULL,
    'Bài giảng của Khoa Cơ bản 1, Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2021.',
    p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach
      WHERE ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND nam_xuat_ban = 2021
  );

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma
FROM dau_sach b
JOIN tac_gia a ON a.ho_ten = 'Từ Minh Phương'
WHERE b.ten_sach = 'Giáo trình Hệ điều hành'
  AND b.nam_xuat_ban = 2015
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tac_gia ba
      WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma
  );

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma
FROM dau_sach b
JOIN tac_gia a ON a.ho_ten = 'Đỗ Thị Diệu'
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam'
  AND b.nam_xuat_ban = 2021
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tac_gia ba
      WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma
  );

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma
FROM dau_sach b
JOIN tac_gia a ON a.ho_ten = 'Đào Mạnh Ninh'
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam'
  AND b.nam_xuat_ban = 2021
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tac_gia ba
      WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma
  );

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma
FROM dau_sach b
JOIN the_loai g ON g.ten = 'Giáo trình'
WHERE (
        (b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015)
        OR (b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021)
      )
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_the_loai bg
      WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma
  );

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma
FROM dau_sach b
JOIN tu_khoa k ON k.ten = 'Hệ điều hành'
WHERE b.ten_sach = 'Giáo trình Hệ điều hành'
  AND b.nam_xuat_ban = 2015
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tu_khoa bk
      WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma
  );

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma
FROM dau_sach b
JOIN tu_khoa k ON k.ten = 'Lịch sử Đảng'
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam'
  AND b.nam_xuat_ban = 2021
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tu_khoa bk
      WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma
  );

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma
FROM dau_sach b
JOIN tu_khoa k ON k.ten = 'PTIT'
WHERE (
        (b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015)
        OR (b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021)
      )
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tu_khoa bk
      WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma
  );

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-HDH-2015-01', 'Kệ I1', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-HDH-2015-01');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-LSD-2021-01', 'Kệ I2', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-LSD-2021-01');

-- Phien ban dien tu tu file PDF giao trinh PTIT.
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 4.28, 'A4', '/ebooks/ptit-he-dieu-hanh-2015.pdf'
FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);

INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 2.70, 'A4', '/ebooks/ptit-lich-su-dang-2021.pdf'
FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
