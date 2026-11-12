USE resource_center;

-- Dau sach minh hoa cho tim kiem theo mot phan nhan de, vi du: "cấu trúc".
INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'Nhà xuất bản Đại học Quốc gia Hà Nội', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM nha_xuat_ban WHERE ten = 'Nhà xuất bản Đại học Quốc gia Hà Nội'
);

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Nguyễn Đức Nghĩa', 'Việt Nam', 'Tác giả tài liệu về cấu trúc dữ liệu và giải thuật.'
WHERE NOT EXISTS (
    SELECT 1 FROM tac_gia WHERE ho_ten = 'Nguyễn Đức Nghĩa'
);

INSERT INTO tu_khoa (ten)
SELECT 'Cấu trúc dữ liệu'
WHERE NOT EXISTS (
    SELECT 1 FROM tu_khoa WHERE ten = 'Cấu trúc dữ liệu'
);

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT
    'Cấu trúc dữ liệu và giải thuật',
    2015,
    'Tiếng Việt',
    'Tài liệu nhập môn về cấu trúc dữ liệu, thuật toán và kỹ thuật giải quyết bài toán lập trình.',
    NULL,
    NULL,
    'Đầu sách minh họa cho chức năng tìm kiếm theo một phần tên sách.',
    p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Nhà xuất bản Đại học Quốc gia Hà Nội'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach
      WHERE ten_sach = 'Cấu trúc dữ liệu và giải thuật'
  );

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma
FROM dau_sach b
JOIN tac_gia a ON a.ho_ten = 'Nguyễn Đức Nghĩa'
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tac_gia ba
      WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma
  );

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma
FROM dau_sach b
JOIN the_loai g ON g.ten = 'Thuật toán'
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_the_loai bg
      WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma
  );

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma
FROM dau_sach b
JOIN the_loai g ON g.ten = 'Giáo trình'
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_the_loai bg
      WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma
  );

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma
FROM dau_sach b
JOIN tu_khoa k ON k.ten = 'Cấu trúc dữ liệu'
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM dau_sach_tu_khoa bk
      WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma
  );

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'DSA-VN-2015-01', 'Kệ H2', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM ban_sach WHERE ma_vach = 'DSA-VN-2015-01'
  );
