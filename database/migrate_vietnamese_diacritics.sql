USE resource_center;

-- Chuẩn hóa dữ liệu mẫu tiếng Việt để hiển thị đúng dấu trên giao diện.
UPDATE tai_khoan SET ho_ten = CASE ten_dang_nhap
    WHEN 'admin' THEN 'Nguyễn Minh Quân'
    WHEN 'librarian' THEN 'Trần Thu Hà'
    WHEN 'student' THEN 'Lê Minh Anh'
    WHEN 'student2' THEN 'Phạm Gia Bảo'
    ELSE ho_ten END;
UPDATE tai_khoan SET ten_dang_nhap = 'thuthu' WHERE vai_tro = 'librarian' AND ten_dang_nhap = 'librarian';

UPDATE sinh_vien SET khoa = CASE ma_sinh_vien
    WHEN 'SV001' THEN 'An toàn thông tin'
    WHEN 'SV002' THEN 'Kỹ thuật điện tử'
    ELSE khoa END;

UPDATE nha_xuat_ban SET ten = 'Nhà xuất bản Trẻ', dia_chi = 'TP. Hồ Chí Minh' WHERE ma = 1;
UPDATE nha_xuat_ban SET ten = 'Nhà xuất bản Giáo dục', dia_chi = 'Hà Nội' WHERE ma = 2;

UPDATE tac_gia SET ho_ten = 'Nguyễn Nhật Ánh', quoc_tich = 'Việt Nam', tieu_su = 'Tác giả văn học thiếu nhi nổi tiếng.' WHERE ma = 1;
UPDATE tac_gia SET quoc_tich = 'Hoa Kỳ', tieu_su = 'Tác giả sách về kỹ thuật phần mềm.' WHERE ma = 2;
UPDATE tac_gia SET tieu_su = 'Tác giả và nhà nghiên cứu hệ thống dữ liệu.' WHERE ma = 3;
UPDATE tac_gia SET quoc_tich = 'Hoa Kỳ', tieu_su = 'Đồng tác giả của Introduction to Algorithms.' WHERE ma = 4;

UPDATE the_loai SET ten = 'Văn học', mo_ta = 'Tác phẩm văn học và truyện dài' WHERE ma = 1;
UPDATE the_loai SET ten = 'Lập trình', mo_ta = 'Sách về lập trình và phát triển phần mềm' WHERE ma = 2;
UPDATE the_loai SET ten = 'Cơ sở dữ liệu', mo_ta = 'Hệ thống, mô hình và xử lý dữ liệu' WHERE ma = 3;
UPDATE the_loai SET ten = 'Thuật toán', mo_ta = 'Thuật toán và cấu trúc dữ liệu' WHERE ma = 4;

UPDATE dau_sach SET ten_sach = 'Tôi thấy hoa vàng trên cỏ xanh', ngon_ngu = 'Tiếng Việt', tom_tat = 'Một câu chuyện trong sáng về tuổi thơ.', mo_ta = 'Sách văn học Việt Nam.' WHERE ma = 1;
UPDATE dau_sach SET mo_ta = 'Nguyên tắc viết mã nguồn dễ đọc và bảo trì.' WHERE ma = 2;
UPDATE dau_sach SET mo_ta = 'Nền tảng cho hệ thống dữ liệu hiện đại.' WHERE ma = 3;
UPDATE dau_sach SET mo_ta = 'Giáo trình thuật toán kinh điển.' WHERE ma = 4;
UPDATE dau_sach SET mo_ta = 'Thực hành xây dựng ứng dụng web.' WHERE ma = 5;
UPDATE dau_sach SET ten_sach = 'Tư duy hệ thống', ngon_ngu = 'Tiếng Việt', tom_tat = 'Cách nhìn vấn đề qua mối quan hệ và quy luật.', mo_ta = 'Sách nhập môn về tư duy hệ thống.' WHERE ma = 6;
UPDATE dau_sach SET ngon_ngu = 'Tiếng Việt' WHERE ma IN (7, 13);

UPDATE phong SET ten = 'Phòng học A101', vi_tri = 'Tầng 1 - Khu A', thiet_bi_di_kem = 'Máy chiếu, Bảng tương tác' WHERE ma = 1;
UPDATE phong SET ten = 'Phòng họp B204', vi_tri = 'Tầng 2 - Khu B', thiet_bi_di_kem = 'Màn hình, Camera họp' WHERE ma = 2;
UPDATE phong SET ten = 'Phòng dữ liệu C302', vi_tri = 'Tầng 3 - Khu C', thiet_bi_di_kem = 'Máy tính, Máy chiếu' WHERE ma = 3;
UPDATE phong SET ten = 'Phòng học A102', vi_tri = 'Tầng 1 - Khu A', thiet_bi_di_kem = 'Máy chiếu' WHERE ma = 4;
UPDATE phong SET gio_hoat_dong = '00:00 - 24:00' WHERE ma IN (1, 2, 3, 4);

UPDATE thiet_bi SET ten = 'Máy chiếu Epson EB-X06', loai_thiet_bi = 'Thiết bị trình chiếu', mo_ta = 'Máy chiếu phòng học.', huong_dan_su_dung = 'Kết nối HDMI và tắt nguồn sau khi sử dụng.' WHERE ma = 1;
UPDATE thiet_bi SET ten = 'Bộ kit Arduino Uno', loai_thiet_bi = 'Bộ thí nghiệm điện tử', mo_ta = 'Bộ mạch lập trình cơ bản.', huong_dan_su_dung = 'Sử dụng nguồn 5V và kiểm tra dây nối.' WHERE ma = 2;
UPDATE thiet_bi SET ten = 'Máy đo đa năng', loai_thiet_bi = 'Thiết bị đo', mo_ta = 'Thiết bị đo điện đa năng.', huong_dan_su_dung = 'Đọc hướng dẫn trước khi kết nối mạch.' WHERE ma = 3;
UPDATE thiet_bi SET ten = 'Microphone không dây', loai_thiet_bi = 'Thiết bị âm thanh', mo_ta = 'Bộ micro phục vụ phòng họp.', huong_dan_su_dung = 'Sạc đầy đủ trước khi sử dụng.' WHERE ma = 4;
UPDATE thiet_bi SET vi_tri_luu_tru = 'Kho thiết bị 01' WHERE vi_tri_luu_tru = 'Kho thiet bi 01';
UPDATE thiet_bi SET vi_tri_luu_tru = 'Kho thí nghiệm 02' WHERE vi_tri_luu_tru = 'Kho thi nghiem 02';
