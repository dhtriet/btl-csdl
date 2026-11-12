USE resource_center;

INSERT INTO tai_khoan (ten_dang_nhap, mat_khau, ho_ten, thu_dien_tu, vai_tro) VALUES
('user1', '$2y$12$w0sxfJK37FF0v3GsbG2iEO0t5c687mbzDPX7LOQsvUYWXfQEkUoV.', 'Nguyễn Minh Quân', 'quan.admin@example.test', 'admin'),
('user2', '$2y$12$ezHbKMz.FQ5Lv4N53Yg6zedFrTKa/O6cueDrFKuMLmX.8QDvP7P5i', 'Trần Thu Hà', 'ha.librarian@example.test', 'librarian'),
('user3', '$2y$12$ottkBQLKbra4HZ3eBiszK.ajqd4NTvE/Eq2RNrZtb4//lezQudtp2', 'Lê Minh Anh', 'anh.student@example.test', 'student'),
('user4', '$2y$12$CZV9lwVE/gealpSHW3Zpd.NvcCscWox3ZMvYgxf1HwJkpeTt5XjNe', 'Phạm Gia Bảo', 'bao.student@example.test', 'student');

INSERT INTO sinh_vien (ma_tai_khoan, ma_sinh_vien, khoa, lop)
SELECT ma, 'SV001', 'An toàn thông tin', 'D22CQCN01' FROM tai_khoan WHERE ten_dang_nhap = 'user3';
INSERT INTO sinh_vien (ma_tai_khoan, ma_sinh_vien, khoa, lop)
SELECT ma, 'SV002', 'Kỹ thuật điện tử', 'D22CQDT02' FROM tai_khoan WHERE ten_dang_nhap = 'user4';

INSERT INTO thu_thu (ma_tai_khoan, ma_thu_thu)
SELECT ma, 'TT001' FROM tai_khoan WHERE ten_dang_nhap = 'user2';

INSERT INTO nha_xuat_ban (ten, dia_chi, thu_dien_tu, so_dien_thoai) VALUES
('Nhà xuất bản Trẻ', 'TP. Hồ Chí Minh', 'contact@tre.example.test', '028-111-2200'),
('Nhà xuất bản Giáo dục', 'Hà Nội', 'contact@gd.example.test', '024-222-3300'),
('OReilly Media', 'Sebastopol, California', 'hello@oreilly.example.test', '001-555-4400');

INSERT INTO tac_gia (ho_ten, ngay_sinh, quoc_tich, tieu_su) VALUES
('Nguyễn Nhật Ánh', '1955-05-07', 'Việt Nam', 'Tác giả văn học thiếu nhi nổi tiếng.'),
('Robert C. Martin', '1952-12-05', 'Hoa Kỳ', 'Tác giả sách về kỹ thuật phần mềm.'),
('Martin Kleppmann', '1982-01-01', 'Anh', 'Tác giả và nhà nghiên cứu hệ thống dữ liệu.'),
('Thomas H. Cormen', '1951-06-22', 'Hoa Kỳ', 'Đồng tác giả của Introduction to Algorithms.');

INSERT INTO the_loai (ten, mo_ta) VALUES
('Văn học', 'Tác phẩm văn học và truyện dài'),
('Lập trình', 'Sách về lập trình và phát triển phần mềm'),
('Cơ sở dữ liệu', 'Hệ thống, mô hình và xử lý dữ liệu'),
('Thuật toán', 'Thuật toán và cấu trúc dữ liệu');

INSERT INTO tu_khoa (ten) VALUES
('SQL'), ('PHP'), ('Clean Code'), ('Distributed Systems'), ('Algorithms');

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban) VALUES
('Tôi thấy hoa vàng trên cỏ xanh', 2010, 'Tiếng Việt', 'Một câu chuyện trong sáng về tuổi thơ.', 378, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=500&q=80', 'Sách văn học Việt Nam.', 1),
('Clean Code', 2008, 'English', 'A handbook of agile software craftsmanship.', 464, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=500&q=80', 'Nguyên tắc viết mã nguồn dễ đọc và bảo trì.', 3),
('Designing Data-Intensive Applications', 2017, 'English', 'The big ideas behind reliable, scalable, and maintainable systems.', 616, 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=500&q=80', 'Nền tảng cho hệ thống dữ liệu hiện đại.', 3),
('Introduction to Algorithms', 2022, 'English', 'A comprehensive introduction to modern algorithms.', 1312, 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=500&q=80', 'Giáo trình thuật toán kinh điển.', 2),
('PHP and MySQL Web Development', 2019, 'English', 'Build dynamic web applications with PHP and MySQL.', 720, 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80', 'Thực hành xây dựng ứng dụng web.', 3),
('Tư duy hệ thống', 2021, 'Tiếng Việt', 'Cách nhìn vấn đề qua mối quan hệ và quy luật.', 256, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=500&q=80', 'Sách nhập môn về tư duy hệ thống.', 1);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 2), (6, 1);

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 2), (5, 3), (6, 1);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa) VALUES
(2, 3), (3, 1), (3, 4), (4, 5), (5, 2), (5, 1), (6, 3);

INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep) VALUES
(2, 'PDF', 8.40, '1200x1800', '/ebooks/clean-code.pdf'),
(3, 'EPUB', 12.60, 'Responsive', '/ebooks/data-intensive.epub'),
(5, 'PDF', 9.20, '1200x1800', '/ebooks/php-mysql.pdf');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai) VALUES
(1, 'BK-001-A', 'Ke A1', 'good', 'available'),
(1, 'BK-001-B', 'Ke A1', 'good', 'borrowed'),
(2, 'BK-002-A', 'Ke B2', 'good', 'available'),
(2, 'BK-002-B', 'Ke B2', 'worn', 'available'),
(3, 'BK-003-A', 'Ke B3', 'good', 'available'),
(4, 'BK-004-A', 'Ke C1', 'good', 'available'),
(5, 'BK-005-A', 'Ke C2', 'good', 'available'),
(6, 'BK-006-A', 'Ke A2', 'good', 'available');

INSERT INTO phieu_muon_sach (ma_ho_so_sinh_vien, ma_ho_so_thu_thu, thoi_diem_dang_ky, ghi_chu, trang_thai)
SELECT s.ma, l.ma, DATE_SUB(NOW(), INTERVAL 16 DAY), 'Phieu co sach dang qua han', 'open'
FROM sinh_vien s, thu_thu l WHERE s.ma_sinh_vien = 'SV001' AND l.ma_thu_thu = 'TT001';
INSERT INTO phieu_muon_sach (ma_ho_so_sinh_vien, ma_ho_so_thu_thu, thoi_diem_dang_ky, ghi_chu, trang_thai)
SELECT s.ma, l.ma, DATE_SUB(NOW(), INTERVAL 30 DAY), 'Phieu da tra', 'completed'
FROM sinh_vien s, thu_thu l WHERE s.ma_sinh_vien = 'SV002' AND l.ma_thu_thu = 'TT001';

INSERT INTO chi_tiet_muon_sach (ma_phieu_muon_sach, ma_ban_sach, ngay_muon, han_tra, ngay_tra, so_lan_gia_han, trang_thai, tinh_trang_khi_tra, ket_qua_tra, so_ngay_tre)
SELECT r.ma, c.ma, DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), NULL, 1, 'overdue', NULL, NULL, 0
FROM phieu_muon_sach r, ban_sach c WHERE r.ghi_chu = 'Phieu co sach dang qua han' AND c.ma_vach = 'BK-001-B';
INSERT INTO chi_tiet_muon_sach (ma_phieu_muon_sach, ma_ban_sach, ngay_muon, han_tra, ngay_tra, so_lan_gia_han, trang_thai, tinh_trang_khi_tra, ket_qua_tra, so_ngay_tre)
SELECT r.ma, c.ma, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 17 DAY), 0, 'returned', 'good', 'on_time', 0
FROM phieu_muon_sach r, ban_sach c WHERE r.ghi_chu = 'Phieu da tra' AND c.ma_vach = 'BK-002-A';

INSERT INTO gia_han_sach (ma_chi_tiet_muon_sach, ma_ho_so_thu_thu, han_tra_cu, han_tra_moi, ngay_gia_han)
SELECT d.ma, l.ma, DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY)
FROM chi_tiet_muon_sach d, thu_thu l, phieu_muon_sach r
WHERE d.ma_phieu_muon_sach = r.ma AND r.ghi_chu = 'Phieu co sach dang qua han' AND l.ma_thu_thu = 'TT001';

INSERT INTO yeu_cau_muon_sach (ma_ho_so_sinh_vien, ghi_chu)
SELECT s.ma, 'Muon sach phuc vu do an mon hoc'
FROM sinh_vien s
WHERE s.ma_sinh_vien = 'SV002';
INSERT INTO chi_tiet_yeu_cau_muon_sach (ma_yeu_cau, ma_dau_sach, so_luong, han_tra_de_nghi)
SELECT r.ma, b.ma, 1, DATE_ADD(CURDATE(), INTERVAL 14 DAY)
FROM yeu_cau_muon_sach r, dau_sach b
WHERE r.ghi_chu = 'Muon sach phuc vu do an mon hoc' AND b.ten_sach = 'Clean Code';

INSERT INTO phong (ten, loai_phong, vi_tri, suc_chua, thiet_bi_di_kem, gio_hoat_dong, trang_thai) VALUES
('Phòng học A101', 'classroom', 'Tầng 1 - Khu A', 40, 'Máy chiếu, Bảng tương tác', '00:00 - 24:00', 'available'),
('Phòng họp B204', 'meeting_room', 'Tầng 2 - Khu B', 12, 'Màn hình, Camera họp', '00:00 - 24:00', 'available'),
('Phòng dữ liệu C302', 'classroom', 'Tầng 3 - Khu C', 30, 'Máy tính, Máy chiếu', '00:00 - 24:00', 'available'),
('Phòng học A102', 'classroom', 'Tầng 1 - Khu A', 25, 'Máy chiếu', '00:00 - 24:00', 'maintenance');

INSERT INTO yeu_cau_dat_phong (ma_ho_so_sinh_vien, ma_phong, ngay_su_dung, gio_bat_dau, gio_ket_thuc, muc_dich, trang_thai)
SELECT s.ma, r.ma, CURDATE(), '09:00', '11:00', 'Học nhóm môn Cơ sở dữ liệu', 'pending'
FROM sinh_vien s, phong r WHERE s.ma_sinh_vien = 'SV001' AND r.ten = 'Phòng học A101';
INSERT INTO yeu_cau_dat_phong (ma_ho_so_sinh_vien, ma_phong, ngay_su_dung, gio_bat_dau, gio_ket_thuc, muc_dich, trang_thai)
SELECT s.ma, r.ma, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '13:00', '15:00', 'Thảo luận đồ án', 'approved'
FROM sinh_vien s, phong r WHERE s.ma_sinh_vien = 'SV002' AND r.ten = 'Phòng họp B204';

INSERT INTO thiet_bi (ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung, tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai) VALUES
('Máy chiếu Epson EB-X06', 'Thiết bị trình chiếu', 'Epson', 'Máy chiếu phòng học.', 'Kết nối HDMI và tắt nguồn sau khi sử dụng.', 4, 3, 'Kho thiết bị 01', 'EP-EBX06-01', 'available'),
('Bộ kit Arduino Uno', 'Bộ thí nghiệm điện tử', 'Arduino', 'Bộ mạch lập trình cơ bản.', 'Sử dụng nguồn 5V và kiểm tra dây nối.', 10, 8, 'Kho thí nghiệm 02', 'ARD-UNO-01', 'available'),
('Máy đo đa năng', 'Thiết bị đo', 'Fluke', 'Thiết bị đo điện đa năng.', 'Đọc hướng dẫn trước khi kết nối mạch.', 3, 0, 'Kho thí nghiệm 02', 'FLK-117-01', 'borrowed'),
('Microphone không dây', 'Thiết bị âm thanh', 'Shure', 'Bộ micro phục vụ phòng họp.', 'Sạc đầy đủ trước khi sử dụng.', 6, 6, 'Kho thiết bị 01', 'SH-58-01', 'available');

INSERT INTO phieu_muon_thiet_bi (ma_ho_so_sinh_vien, ma_ho_so_thu_thu, thoi_diem_dang_ky, ghi_chu, trang_thai)
SELECT s.ma, l.ma, DATE_SUB(NOW(), INTERVAL 10 DAY), 'Muon bo kit thi nghiem', 'borrowed'
FROM sinh_vien s, thu_thu l WHERE s.ma_sinh_vien = 'SV001' AND l.ma_thu_thu = 'TT001';
INSERT INTO chi_tiet_muon_thiet_bi (ma_phieu_muon_thiet_bi, ma_thiet_bi, so_luong, ngay_muon, han_tra, tinh_trang_khi_muon, trang_thai)
SELECT el.ma, e.ma, 2, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Tot', 'overdue'
FROM phieu_muon_thiet_bi el, thiet_bi e WHERE el.ghi_chu = 'Muon bo kit thi nghiem' AND e.ten = 'Bo kit Arduino Uno';

INSERT INTO yeu_cau_muon_thiet_bi (ma_ho_so_sinh_vien, ghi_chu)
SELECT s.ma, 'Muon thiet bi cho buoi thuyet trinh'
FROM sinh_vien s
WHERE s.ma_sinh_vien = 'SV002';
INSERT INTO chi_tiet_yeu_cau_muon_thiet_bi (ma_yeu_cau, ma_thiet_bi, so_luong, han_tra_de_nghi)
SELECT r.ma, e.ma, 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY)
FROM yeu_cau_muon_thiet_bi r, thiet_bi e
WHERE r.ghi_chu = 'Muon thiet bi cho buoi thuyet trinh' AND e.ten = 'Microphone khong day';

-- Thiet bi va dung cu phuc vu sinh vien, giang vien.
INSERT INTO thiet_bi (
    ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung,
    tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai
) VALUES
('Laptop học tập Dell Latitude 5440', 'Thiết bị máy tính', 'Dell', 'Laptop dùng cho bài giảng, thực hành lập trình và làm đồ án.', 'Đăng nhập bằng tài khoản được cấp, sạc pin sau khi sử dụng và bàn giao đúng nơi quy định.', 8, 8, 'Kho thiết bị 01', 'DL-5440-01', 'available'),
('Bộ kit mạng Cisco thực hành', 'Thiết bị mạng', 'Cisco', 'Bộ thiết bị mô phỏng mạng gồm router, switch và phụ kiện kết nối.', 'Tắt nguồn trước khi thay đổi dây nối, kiểm tra sơ đồ mạng trước khi cấu hình.', 6, 6, 'Kho thí nghiệm 01', 'CISCO-LAB-01', 'available'),
('Bộ cảm biến IoT ESP32', 'Bộ thí nghiệm IoT', 'Espressif', 'Bộ mạch ESP32 và cảm biến dùng cho bài thực hành Internet of Things.', 'Cấp nguồn đúng điện áp, kiểm tra sơ đồ chân trước khi kết nối cảm biến.', 8, 8, 'Kho thí nghiệm 02', 'ESP32-IOT-01', 'available'),
('Bảng vẽ điện tử Wacom', 'Dụng cụ giảng dạy', 'Wacom', 'Bảng vẽ điện tử hỗ trợ giảng viên trình bày và minh họa trực tuyến.', 'Kết nối USB trước khi mở phần mềm, cất bút vào hộp sau khi sử dụng.', 4, 4, 'Kho thiết bị 01', 'WACOM-01', 'available'),
('Bộ breadboard và linh kiện điện tử', 'Dụng cụ điện tử', 'PTIT Lab', 'Bộ breadboard, dây nối, điện trở, LED và linh kiện phục vụ thực hành mạch điện.', 'Ngắt nguồn trước khi thay đổi mạch, phân loại linh kiện và trả đủ sau khi dùng.', 12, 12, 'Kho thí nghiệm 02', 'ELEC-KIT-01', 'available');

-- Giao trinh PTIT va cac tai lieu tham khao co trong giao trinh Co so du lieu.
INSERT INTO nha_xuat_ban (ten, dia_chi) VALUES
('Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'),
('Addison-Wesley', 'Reading, Massachusetts'),
('Prentice Hall', 'Englewood Cliffs, New Jersey'),
('McGraw-Hill/Irwin', 'New York');

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su) VALUES
('Phạm Thế Quế', 'Việt Nam', 'Tác giả biên soạn giáo trình Cơ sở dữ liệu của Học viện Công nghệ Bưu chính Viễn thông.'),
('C. J. Date', 'Anh', NULL),
('Alfred V. Aho', 'Hoa Kỳ', NULL),
('John E. Hopcroft', 'Hoa Kỳ', NULL),
('Jeffrey D. Ullman', 'Hoa Kỳ', NULL),
('Michael V. Mannino', 'Hoa Kỳ', NULL),
('Abraham Silberschatz', 'Hoa Kỳ', NULL),
('Henry F. Korth', 'Hoa Kỳ', NULL),
('S. Sudarshan', 'Ấn Độ', NULL);

INSERT INTO the_loai (ten, mo_ta) VALUES
('Giáo trình', 'Tài liệu học tập và giáo trình đại học');

INSERT INTO tu_khoa (ten) VALUES
('CSDL quan hệ'), ('Chuẩn hóa'), ('Thiết kế CSDL'), ('Bảo mật CSDL'), ('PTIT');

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban) VALUES
('Cơ sở dữ liệu', 2006, 'Tiếng Việt', 'Giáo trình giới thiệu hệ cơ sở dữ liệu, mô hình dữ liệu, CSDL quan hệ, chuẩn hóa, SQL, tối ưu hóa truy vấn và an toàn dữ liệu.', 166, NULL, 'Giáo trình dùng cho sinh viên hệ đào tạo đại học từ xa, lưu hành nội bộ; mã số 492CDL351.', 4),
('An Introduction to Database Systems', 1977, 'English', 'Tài liệu tham khảo về các khái niệm và hệ thống cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [2] trong giáo trình Cơ sở dữ liệu PTIT.', 5),
('Principles of Database Systems', 1980, 'English', 'Tài liệu tham khảo về nguyên lý hệ cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [9] trong giáo trình Cơ sở dữ liệu PTIT.', 6),
('Database Application Development and Design', 2001, 'English', 'Tài liệu tham khảo về phát triển và thiết kế ứng dụng cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [10] trong giáo trình Cơ sở dữ liệu PTIT.', 7),
('Database System Concepts', 2002, 'English', 'Tài liệu tham khảo về khái niệm, thiết kế và vận hành hệ cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [11] trong giáo trình Cơ sở dữ liệu PTIT.', 7),
('The Design and Analysis of Computer Algorithms', 1974, 'English', 'Tài liệu tham khảo về thiết kế và phân tích thuật toán.', NULL, NULL, 'Tài liệu tham khảo [4] trong giáo trình Cơ sở dữ liệu PTIT.', 5);

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia) VALUES
(7, 5), (8, 6), (9, 9), (10, 10), (11, 11), (11, 12), (11, 13), (12, 7), (12, 8), (12, 9);

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai) VALUES
(7, 3), (7, 5), (8, 3), (9, 3), (10, 3), (11, 3), (12, 4);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa) VALUES
(7, 1), (7, 6), (7, 7), (7, 9), (7, 10), (8, 6), (9, 6), (10, 8), (11, 1), (11, 6), (12, 5);

INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep) VALUES
(7, 'PDF', 5.19, 'A4', '/ebooks/csdl-giao-trinh.pdf');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai) VALUES
(7, 'PTIT-CSDL-2006-01', 'Kệ G1', 'good', 'available'),
(8, 'REF-DATE-1977-01', 'Kệ G2', 'good', 'available'),
(9, 'REF-ULLMAN-1980-01', 'Kệ G2', 'good', 'available'),
(10, 'REF-MANNINO-2001-01', 'Kệ G3', 'good', 'available'),
(11, 'REF-DBCONCEPTS-2002-01', 'Kệ G3', 'good', 'available'),
(12, 'REF-AHO-1974-01', 'Kệ H1', 'good', 'available');

-- Dau sach minh hoa cho tim kiem theo mot phan nhan de: "cấu trúc".
INSERT INTO nha_xuat_ban (ten, dia_chi) VALUES
('Nhà xuất bản Đại học Quốc gia Hà Nội', 'Hà Nội');

INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su) VALUES
('Nguyễn Đức Nghĩa', 'Việt Nam', 'Tác giả tài liệu về cấu trúc dữ liệu và giải thuật.');

INSERT INTO tu_khoa (ten) VALUES
('Cấu trúc dữ liệu');

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
WHERE p.ten = 'Nhà xuất bản Đại học Quốc gia Hà Nội';

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma
FROM dau_sach b
JOIN tac_gia a ON a.ho_ten = 'Nguyễn Đức Nghĩa'
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật';

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma
FROM dau_sach b
JOIN the_loai g ON g.ten IN ('Thuật toán', 'Giáo trình')
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật';

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma
FROM dau_sach b
JOIN tu_khoa k ON k.ten = 'Cấu trúc dữ liệu'
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật';

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'DSA-VN-2015-01', 'Kệ H2', 'good', 'available'
FROM dau_sach b
WHERE b.ten_sach = 'Cấu trúc dữ liệu và giải thuật';

-- Them giao trinh PTIT ve he dieu hanh va lich su Dang.
INSERT INTO tac_gia (ho_ten, quoc_tich, tieu_su) VALUES
('Từ Minh Phương', 'Việt Nam', 'Tác giả giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông.'),
('Đỗ Thị Diệu', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.'),
('Đào Mạnh Ninh', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.');

INSERT INTO tu_khoa (ten) VALUES
('Hệ điều hành'), ('Lịch sử Đảng');

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'Giáo trình Hệ điều hành', 2015, 'Tiếng Việt',
       'Giáo trình trình bày các khái niệm và nguyên lý hoạt động của hệ điều hành, quản lý tiến trình, bộ nhớ, hệ thống tệp và vào ra.',
       185, NULL,
       'Giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2015.', p.ma
FROM nha_xuat_ban p WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông';

INSERT INTO dau_sach (ten_sach, nam_xuat_ban, ngon_ngu, tom_tat, so_trang, anh_bia, mo_ta, ma_nha_xuat_ban)
SELECT 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam', 2021, 'Tiếng Việt',
       'Bài giảng dành cho sinh viên đại học, trình bày quá trình ra đời, lãnh đạo đấu tranh giành chính quyền, kháng chiến và công cuộc đổi mới.',
       169, NULL,
       'Bài giảng của Khoa Cơ bản 1, Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2021.', p.ma
FROM nha_xuat_ban p WHERE p.ten = 'Học viện Công nghệ Bưu chính Viễn thông';

INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten = 'Từ Minh Phương'
WHERE b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015;
INSERT INTO dau_sach_tac_gia (ma_dau_sach, ma_tac_gia)
SELECT b.ma, a.ma FROM dau_sach b JOIN tac_gia a ON a.ho_ten IN ('Đỗ Thị Diệu', 'Đào Mạnh Ninh')
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021;

INSERT INTO dau_sach_the_loai (ma_dau_sach, ma_the_loai)
SELECT b.ma, g.ma FROM dau_sach b JOIN the_loai g ON g.ten = 'Giáo trình'
WHERE (b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015)
   OR (b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021);

INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('Hệ điều hành', 'PTIT')
WHERE b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015;
INSERT INTO dau_sach_tu_khoa (ma_dau_sach, ma_tu_khoa)
SELECT b.ma, k.ma FROM dau_sach b JOIN tu_khoa k ON k.ten IN ('Lịch sử Đảng', 'PTIT')
WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021;

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-HDH-2015-01', 'Kệ I1', 'good', 'available'
FROM dau_sach b WHERE b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015;
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-LSD-2021-01', 'Kệ I2', 'good', 'available'
FROM dau_sach b WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021;

INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 4.28, 'A4', '/ebooks/ptit-he-dieu-hanh-2015.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Giáo trình Hệ điều hành' AND b.nam_xuat_ban = 2015;
INSERT INTO sach_dien_tu (ma_dau_sach, dinh_dang_tep, dung_luong_mb, do_phan_giai, duong_dan_tep)
SELECT b.ma, 'PDF', 2.70, 'A4', '/ebooks/ptit-lich-su-dang-2021.pdf'
FROM dau_sach b WHERE b.ten_sach = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.nam_xuat_ban = 2021;
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
-- Tao so luong ban sao khac nhau cho 10 giao trinh PTIT.
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-02', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-03', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-04', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-02', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-03', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-04', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-04');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-05', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-05');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-06', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-06');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATTT-2018-02', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Cơ sở an toàn thông tin'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATTT-2018-02');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-02', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-03', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-04', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-KTVM-2013-02', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Kinh tế vi mô 1'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-KTVM-2013-02');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-02', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-03', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-04', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-02', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-03', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-04', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-04');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-05', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-05');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-06', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-06');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-BMHTTT-2017-02', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn và bảo mật hệ thống thông tin'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-BMHTTT-2017-02');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-02', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-03', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-04', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-GIAUTIN-2018-02', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-GIAUTIN-2018-02');





