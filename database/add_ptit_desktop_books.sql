USE resource_center;

-- Them 10 giao trinh PTIT tu thu muc Desktop, kem ban sach dien tu PDF.
INSERT INTO nha_xuat_ban (ten, dia_chi)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM nha_xuat_ban
    WHERE ten = 'Học viện Công nghệ Bưu chính Viễn thông'
);

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Ao Thu Hoài', 'Việt Nam', 'Giảng viên, biên soạn tài liệu về thương mại điện tử và marketing trực tuyến.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Ao Thu Hoài');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Trần Thị Thập', 'Việt Nam', 'Biên tập tài liệu Xây dựng Website thương mại điện tử của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Trần Thị Thập');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Nguyễn Hoàng Anh', 'Việt Nam', 'Biên tập tài liệu Xây dựng Website thương mại điện tử của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Nguyễn Hoàng Anh');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Hoàng Xuân Dậu', 'Việt Nam', 'Tác giả các giáo trình về an toàn thông tin và bảo mật hệ thống.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Hoàng Xuân Dậu');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Trịnh Thị Vân Anh', 'Việt Nam', 'Tác giả giáo trình Kỹ thuật đồ họa của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Trịnh Thị Vân Anh');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Trần Thị Hoà', 'Việt Nam', 'Tác giả giáo trình Kinh tế vi mô của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Trần Thị Hoà');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Phạm Hoàng Duy', 'Việt Nam', 'Tác giả giáo trình An toàn hệ điều hành của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Phạm Hoàng Duy');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Trần Đình Quế', 'Việt Nam', 'Đồng tác giả giáo trình Nhập môn Công nghệ phần mềm của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Trần Đình Quế');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Nguyễn Mạnh Hùng', 'Việt Nam', 'Đồng tác giả giáo trình Nhập môn Công nghệ phần mềm của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Nguyễn Mạnh Hùng');
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su)
SELECT 'Đỗ Xuân Chợ', 'Việt Nam', 'Tác giả bài giảng Các kỹ thuật giấu tin của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM tac_gia WHERE ho_ten = 'Đỗ Xuân Chợ');

INSERT INTO the_loai (ten, mo_ta)
SELECT 'Thương mại điện tử', 'Xây dựng và vận hành website thương mại điện tử'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Thương mại điện tử');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'Marketing', 'Marketing và marketing trực tuyến'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Marketing');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'An toàn thông tin', 'Bảo vệ dữ liệu, hệ thống và ứng dụng'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'An toàn thông tin');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'Đồ họa máy tính', 'Kỹ thuật và ứng dụng đồ họa máy tính'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Đồ họa máy tính');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'Kinh tế', 'Các môn học kinh tế cơ bản'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Kinh tế');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'Hệ điều hành', 'Nguyên lý và an toàn hệ điều hành'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Hệ điều hành');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'Công nghệ phần mềm', 'Phân tích, thiết kế và phát triển phần mềm'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Công nghệ phần mềm');
INSERT INTO the_loai (ten, mo_ta)
SELECT 'Giấu tin', 'Kỹ thuật giấu tin và thủy vân số'
WHERE NOT EXISTS (SELECT 1 FROM the_loai WHERE ten = 'Giấu tin');

INSERT INTO tu_khoa (ten)
SELECT 'PTIT' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'PTIT');
INSERT INTO tu_khoa (ten)
SELECT 'Thương mại điện tử' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Thương mại điện tử');
INSERT INTO tu_khoa (ten)
SELECT 'Marketing trực tuyến' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Marketing trực tuyến');
INSERT INTO tu_khoa (ten)
SELECT 'An toàn thông tin' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'An toàn thông tin');
INSERT INTO tu_khoa (ten)
SELECT 'Bảo mật hệ thống' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Bảo mật hệ thống');
INSERT INTO tu_khoa (ten)
SELECT 'Ứng dụng web' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Ứng dụng web');
INSERT INTO tu_khoa (ten)
SELECT 'Cơ sở dữ liệu' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Cơ sở dữ liệu');
INSERT INTO tu_khoa (ten)
SELECT 'Hệ điều hành' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Hệ điều hành');
INSERT INTO tu_khoa (ten)
SELECT 'Công nghệ phần mềm' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Công nghệ phần mềm');
INSERT INTO tu_khoa (ten)
SELECT 'Đồ họa máy tính' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Đồ họa máy tính');
INSERT INTO tu_khoa (ten)
SELECT 'Kinh tế vi mô' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Kinh tế vi mô');
INSERT INTO tu_khoa (ten)
SELECT 'Giấu tin' WHERE NOT EXISTS (SELECT 1 FROM tu_khoa WHERE ten = 'Giấu tin');

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'Bài giảng Xây dựng Website thương mại điện tử', 2018, 'Tiếng Việt',
       'Tài liệu trình bày các kiến thức và kỹ thuật xây dựng website thương mại điện tử.',
       141, 'Bài giảng PTIT, biên soạn bởi Th.S. Ao Thu Hoài, hiệu đính năm 2018.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử' AND nam_xuat_ban = 2018);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'E-marketing (Marketing trực tuyến)', 2013, 'Tiếng Việt',
       'Tài liệu nhập môn về marketing trực tuyến và các hoạt động marketing trên môi trường số.',
       353, 'Giáo trình PTIT, tác giả TS. Ao Thu Hoài, năm 2013.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'E-marketing (Marketing trực tuyến)' AND nam_xuat_ban = 2013);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'Giáo trình Cơ sở an toàn thông tin', 2018, 'Tiếng Việt',
       'Giáo trình giới thiệu các khái niệm nền tảng, nguy cơ và biện pháp bảo đảm an toàn thông tin.',
       143, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2018.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Giáo trình Cơ sở an toàn thông tin' AND nam_xuat_ban = 2018);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'Giáo trình Kỹ thuật đồ họa', 2018, 'Tiếng Việt',
       'Giáo trình trình bày các nguyên lý và kỹ thuật cơ bản của đồ họa máy tính.',
       222, 'Giáo trình PTIT, tác giả Trịnh Thị Vân Anh, năm 2018.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Giáo trình Kỹ thuật đồ họa' AND nam_xuat_ban = 2018);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'Kinh tế vi mô 1', 2013, 'Tiếng Việt',
       'Tài liệu trình bày các khái niệm và nguyên lý cơ bản của kinh tế vi mô.',
       180, 'Giáo trình PTIT, tác giả TS. Trần Thị Hoà, năm 2013.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Kinh tế vi mô 1' AND nam_xuat_ban = 2013);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'An toàn hệ điều hành', 2017, 'Tiếng Việt',
       'Tài liệu trình bày các vấn đề bảo vệ hệ điều hành, tài nguyên hệ thống và dữ liệu người dùng.',
       100, 'Giáo trình PTIT, tác giả Phạm Hoàng Duy, năm 2017.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'An toàn hệ điều hành' AND nam_xuat_ban = 2017);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'Nhập môn Công nghệ phần mềm', 2016, 'Tiếng Việt',
       'Giáo trình nhập môn về quy trình, phương pháp và kỹ thuật phát triển phần mềm.',
       229, 'Giáo trình PTIT, đồng tác giả Trần Đình Quế và Nguyễn Mạnh Hùng, năm 2016.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Nhập môn Công nghệ phần mềm' AND nam_xuat_ban = 2016);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'An toàn và bảo mật hệ thống thông tin', 2017, 'Tiếng Việt',
       'Tài liệu trình bày các nguyên tắc, mô hình và biện pháp bảo đảm an toàn, bảo mật hệ thống thông tin.',
       152, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2017.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'An toàn và bảo mật hệ thống thông tin' AND nam_xuat_ban = 2017);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'An toàn ứng dụng web và cơ sở dữ liệu', 2017, 'Tiếng Việt',
       'Tài liệu giới thiệu các nguy cơ và biện pháp bảo vệ ứng dụng web và cơ sở dữ liệu.',
       160, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2017.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu' AND nam_xuat_ban = 2017);
INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, mo_ta, ma_nha_xuat_ban)
SELECT 'Bài giảng Các kỹ thuật giấu tin', 2018, 'Tiếng Việt',
       'Bài giảng giới thiệu các kỹ thuật giấu tin và những ứng dụng cơ bản trong môi trường số.',
       136, 'Bài giảng PTIT, tác giả Đỗ Xuân Chợ, tháng 12 năm 2018.', p.ma
FROM nha_xuat_ban p
WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM dau_sach WHERE ten_sach = 'Bài giảng Các kỹ thuật giấu tin' AND nam_xuat_ban = 2018);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten IN ('Ao Thu Hoài', 'Trần Thị Thập', 'Nguyễn Hoàng Anh')
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Ao Thu Hoài'
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Hoàng Xuân Dậu'
WHERE b.ten_sach IN ('Giáo trình Cơ sở an toàn thông tin', 'An toàn và bảo mật hệ thống thông tin', 'An toàn ứng dụng web và cơ sở dữ liệu')
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Trịnh Thị Vân Anh'
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Trần Thị Hoà'
WHERE b.ten_sach = 'Kinh tế vi mô 1' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Phạm Hoàng Duy'
WHERE b.ten_sach = 'An toàn hệ điều hành' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten IN ('Trần Đình Quế', 'Nguyễn Mạnh Hùng')
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm' AND b.nam_xuat_ban = 2016
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Đỗ Xuân Chợ'
WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tac_gia ba WHERE ba.ma_dau_sach = b.ma AND ba.ma_tac_gia = a.ma);

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Thương mại điện tử')
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Marketing')
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'An toàn thông tin')
WHERE b.ten_sach IN ('Giáo trình Cơ sở an toàn thông tin', 'An toàn và bảo mật hệ thống thông tin', 'An toàn ứng dụng web và cơ sở dữ liệu')
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Đồ họa máy tính')
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Kinh tế')
WHERE b.ten_sach = 'Kinh tế vi mô 1' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Hệ điều hành')
WHERE b.ten_sach = 'An toàn hệ điều hành' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Công nghệ phần mềm')
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm' AND b.nam_xuat_ban = 2016
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);
INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten IN ('Giáo trình', 'Giấu tin')
WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_the_loai bg WHERE bg.ma_dau_sach = b.ma AND bg.ma_the_loai = g.ma);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Thương mại điện tử', 'Ứng dụng web')
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Marketing trực tuyến')
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'An toàn thông tin')
WHERE b.ten_sach = 'Giáo trình Cơ sở an toàn thông tin' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Đồ họa máy tính')
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Kinh tế vi mô')
WHERE b.ten_sach = 'Kinh tế vi mô 1' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Hệ điều hành')
WHERE b.ten_sach = 'An toàn hệ điều hành' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Công nghệ phần mềm')
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm' AND b.nam_xuat_ban = 2016
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Bảo mật hệ thống')
WHERE b.ten_sach = 'An toàn và bảo mật hệ thống thông tin' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'An toàn thông tin', 'Ứng dụng web', 'Cơ sở dữ liệu')
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('PTIT', 'Giấu tin')
WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM dau_sach_tu_khoa bk WHERE bk.ma_dau_sach = b.ma AND bk.ma_tu_khoa = k.ma);

INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 10.85, 'A4', '/ebooks/ptit-website-thuong-mai-dien-tu-2018.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 10.02, 'A4', '/ebooks/ptit-e-marketing-2013.pdf'
FROM dau_sach b WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 7.65, 'A4', '/ebooks/ptit-co-so-an-toan-thong-tin-2018.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Giáo trình Cơ sở an toàn thông tin' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 5.44, 'A4', '/ebooks/ptit-ky-thuat-do-hoa-2018.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 3.81, 'A4', '/ebooks/ptit-kinh-te-vi-mo-1-2013.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Kinh tế vi mô 1' AND b.nam_xuat_ban = 2013
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 4.83, 'A4', '/ebooks/ptit-an-toan-he-dieu-hanh-2017.pdf'
FROM dau_sach b WHERE b.ten_sach = 'An toàn hệ điều hành' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 9.06, 'A4', '/ebooks/ptit-nhap-mon-cong-nghe-phan-mem-2016.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm' AND b.nam_xuat_ban = 2016
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 6.85, 'A4', '/ebooks/ptit-an-toan-bao-mat-he-thong-thong-tin-2017.pdf'
FROM dau_sach b WHERE b.ten_sach = 'An toàn và bảo mật hệ thống thông tin' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 7.05, 'A4', '/ebooks/ptit-an-toan-ung-dung-web-co-so-du-lieu-2017.pdf'
FROM dau_sach b WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu' AND b.nam_xuat_ban = 2017
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 3.60, 'A4', '/ebooks/ptit-cac-ky-thuat-giau-tin-2018.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin' AND b.nam_xuat_ban = 2018
  AND NOT EXISTS (SELECT 1 FROM sach_dien_tu e WHERE e.ma_dau_sach = b.ma);

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-01', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-01', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATTT-2018-01', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Cơ sở an toàn thông tin' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATTT-2018-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-01', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-KTVM-2013-01', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Kinh tế vi mô 1' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-KTVM-2013-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-01', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-01', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-BMHTTT-2017-01', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn và bảo mật hệ thống thông tin' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-BMHTTT-2017-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-01', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-01');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-GIAUTIN-2018-01', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin' AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-GIAUTIN-2018-01');
