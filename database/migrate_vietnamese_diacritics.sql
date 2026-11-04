USE resource_center;

-- Chuẩn hóa dữ liệu mẫu tiếng Việt để hiển thị đúng dấu trên giao diện.
UPDATE accounts SET full_name = CASE username
    WHEN 'admin' THEN 'Nguyễn Minh Quân'
    WHEN 'librarian' THEN 'Trần Thu Hà'
    WHEN 'student' THEN 'Lê Minh Anh'
    WHEN 'student2' THEN 'Phạm Gia Bảo'
    ELSE full_name END;
UPDATE accounts SET username = 'thuthu' WHERE role = 'librarian' AND username = 'librarian';

UPDATE students SET faculty = CASE student_code
    WHEN 'SV001' THEN 'An toàn thông tin'
    WHEN 'SV002' THEN 'Kỹ thuật điện tử'
    ELSE faculty END;

UPDATE publishers SET name = 'Nhà xuất bản Trẻ', address = 'TP. Hồ Chí Minh' WHERE id = 1;
UPDATE publishers SET name = 'Nhà xuất bản Giáo dục', address = 'Hà Nội' WHERE id = 2;

UPDATE authors SET full_name = 'Nguyễn Nhật Ánh', nationality = 'Việt Nam', biography = 'Tác giả văn học thiếu nhi nổi tiếng.' WHERE id = 1;
UPDATE authors SET nationality = 'Hoa Kỳ', biography = 'Tác giả sách về kỹ thuật phần mềm.' WHERE id = 2;
UPDATE authors SET biography = 'Tác giả và nhà nghiên cứu hệ thống dữ liệu.' WHERE id = 3;
UPDATE authors SET nationality = 'Hoa Kỳ', biography = 'Đồng tác giả của Introduction to Algorithms.' WHERE id = 4;

UPDATE genres SET name = 'Văn học', description = 'Tác phẩm văn học và truyện dài' WHERE id = 1;
UPDATE genres SET name = 'Lập trình', description = 'Sách về lập trình và phát triển phần mềm' WHERE id = 2;
UPDATE genres SET name = 'Cơ sở dữ liệu', description = 'Hệ thống, mô hình và xử lý dữ liệu' WHERE id = 3;
UPDATE genres SET name = 'Thuật toán', description = 'Thuật toán và cấu trúc dữ liệu' WHERE id = 4;

UPDATE books SET title = 'Tôi thấy hoa vàng trên cỏ xanh', language = 'Tiếng Việt', summary = 'Một câu chuyện trong sáng về tuổi thơ.', description = 'Sách văn học Việt Nam.' WHERE id = 1;
UPDATE books SET description = 'Nguyên tắc viết mã nguồn dễ đọc và bảo trì.' WHERE id = 2;
UPDATE books SET description = 'Nền tảng cho hệ thống dữ liệu hiện đại.' WHERE id = 3;
UPDATE books SET description = 'Giáo trình thuật toán kinh điển.' WHERE id = 4;
UPDATE books SET description = 'Thực hành xây dựng ứng dụng web.' WHERE id = 5;
UPDATE books SET title = 'Tư duy hệ thống', language = 'Tiếng Việt', summary = 'Cách nhìn vấn đề qua mối quan hệ và quy luật.', description = 'Sách nhập môn về tư duy hệ thống.' WHERE id = 6;
UPDATE books SET language = 'Tiếng Việt' WHERE id IN (7, 13);

UPDATE rooms SET name = 'Phòng học A101', location = 'Tầng 1 - Khu A', included_equipment = 'Máy chiếu, Bảng tương tác' WHERE id = 1;
UPDATE rooms SET name = 'Phòng họp B204', location = 'Tầng 2 - Khu B', included_equipment = 'Màn hình, Camera họp' WHERE id = 2;
UPDATE rooms SET name = 'Phòng dữ liệu C302', location = 'Tầng 3 - Khu C', included_equipment = 'Máy tính, Máy chiếu' WHERE id = 3;
UPDATE rooms SET name = 'Phòng học A102', location = 'Tầng 1 - Khu A', included_equipment = 'Máy chiếu' WHERE id = 4;
UPDATE rooms SET operating_hours = '00:00 - 24:00' WHERE id IN (1, 2, 3, 4);

UPDATE equipment SET name = 'Máy chiếu Epson EB-X06', equipment_type = 'Thiết bị trình chiếu', description = 'Máy chiếu phòng học.', usage_guide = 'Kết nối HDMI và tắt nguồn sau khi sử dụng.' WHERE id = 1;
UPDATE equipment SET name = 'Bộ kit Arduino Uno', equipment_type = 'Bộ thí nghiệm điện tử', description = 'Bộ mạch lập trình cơ bản.', usage_guide = 'Sử dụng nguồn 5V và kiểm tra dây nối.' WHERE id = 2;
UPDATE equipment SET name = 'Máy đo đa năng', equipment_type = 'Thiết bị đo', description = 'Thiết bị đo điện đa năng.', usage_guide = 'Đọc hướng dẫn trước khi kết nối mạch.' WHERE id = 3;
UPDATE equipment SET name = 'Microphone không dây', equipment_type = 'Thiết bị âm thanh', description = 'Bộ micro phục vụ phòng họp.', usage_guide = 'Sạc đầy đủ trước khi sử dụng.' WHERE id = 4;
UPDATE equipment SET storage_location = 'Kho thiết bị 01' WHERE storage_location = 'Kho thiet bi 01';
UPDATE equipment SET storage_location = 'Kho thí nghiệm 02' WHERE storage_location = 'Kho thi nghiem 02';
