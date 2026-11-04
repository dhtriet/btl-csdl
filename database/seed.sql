USE resource_center;

INSERT INTO accounts (username, password, full_name, email, role) VALUES
('user1', '$2y$12$w0sxfJK37FF0v3GsbG2iEO0t5c687mbzDPX7LOQsvUYWXfQEkUoV.', 'Nguyễn Minh Quân', 'quan.admin@example.test', 'admin'),
('user2', '$2y$12$ezHbKMz.FQ5Lv4N53Yg6zedFrTKa/O6cueDrFKuMLmX.8QDvP7P5i', 'Trần Thu Hà', 'ha.librarian@example.test', 'librarian'),
('user3', '$2y$12$ottkBQLKbra4HZ3eBiszK.ajqd4NTvE/Eq2RNrZtb4//lezQudtp2', 'Lê Minh Anh', 'anh.student@example.test', 'student'),
('user4', '$2y$12$CZV9lwVE/gealpSHW3Zpd.NvcCscWox3ZMvYgxf1HwJkpeTt5XjNe', 'Phạm Gia Bảo', 'bao.student@example.test', 'student');

INSERT INTO students (account_id, student_code, faculty, class_name)
SELECT id, 'SV001', 'An toàn thông tin', 'D22CQCN01' FROM accounts WHERE username = 'user3';
INSERT INTO students (account_id, student_code, faculty, class_name)
SELECT id, 'SV002', 'Kỹ thuật điện tử', 'D22CQDT02' FROM accounts WHERE username = 'user4';

INSERT INTO librarians (account_id, librarian_code)
SELECT id, 'TT001' FROM accounts WHERE username = 'user2';

INSERT INTO publishers (name, address, email, phone) VALUES
('Nhà xuất bản Trẻ', 'TP. Hồ Chí Minh', 'contact@tre.example.test', '028-111-2200'),
('Nhà xuất bản Giáo dục', 'Hà Nội', 'contact@gd.example.test', '024-222-3300'),
('OReilly Media', 'Sebastopol, California', 'hello@oreilly.example.test', '001-555-4400');

INSERT INTO authors (full_name, date_of_birth, nationality, biography) VALUES
('Nguyễn Nhật Ánh', '1955-05-07', 'Việt Nam', 'Tác giả văn học thiếu nhi nổi tiếng.'),
('Robert C. Martin', '1952-12-05', 'Hoa Kỳ', 'Tác giả sách về kỹ thuật phần mềm.'),
('Martin Kleppmann', '1982-01-01', 'Anh', 'Tác giả và nhà nghiên cứu hệ thống dữ liệu.'),
('Thomas H. Cormen', '1951-06-22', 'Hoa Kỳ', 'Đồng tác giả của Introduction to Algorithms.');

INSERT INTO genres (name, description) VALUES
('Văn học', 'Tác phẩm văn học và truyện dài'),
('Lập trình', 'Sách về lập trình và phát triển phần mềm'),
('Cơ sở dữ liệu', 'Hệ thống, mô hình và xử lý dữ liệu'),
('Thuật toán', 'Thuật toán và cấu trúc dữ liệu');

INSERT INTO keywords (name) VALUES
('SQL'), ('PHP'), ('Clean Code'), ('Distributed Systems'), ('Algorithms');

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id) VALUES
('Tôi thấy hoa vàng trên cỏ xanh', 2010, 'Tiếng Việt', 'Một câu chuyện trong sáng về tuổi thơ.', 378, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=500&q=80', 'Sách văn học Việt Nam.', 1),
('Clean Code', 2008, 'English', 'A handbook of agile software craftsmanship.', 464, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=500&q=80', 'Nguyên tắc viết mã nguồn dễ đọc và bảo trì.', 3),
('Designing Data-Intensive Applications', 2017, 'English', 'The big ideas behind reliable, scalable, and maintainable systems.', 616, 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=500&q=80', 'Nền tảng cho hệ thống dữ liệu hiện đại.', 3),
('Introduction to Algorithms', 2022, 'English', 'A comprehensive introduction to modern algorithms.', 1312, 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=500&q=80', 'Giáo trình thuật toán kinh điển.', 2),
('PHP and MySQL Web Development', 2019, 'English', 'Build dynamic web applications with PHP and MySQL.', 720, 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=500&q=80', 'Thực hành xây dựng ứng dụng web.', 3),
('Tư duy hệ thống', 2021, 'Tiếng Việt', 'Cách nhìn vấn đề qua mối quan hệ và quy luật.', 256, 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=500&q=80', 'Sách nhập môn về tư duy hệ thống.', 1);

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 2), (6, 1);

INSERT INTO book_genres (book_id, genre_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 2), (5, 3), (6, 1);

INSERT INTO book_keywords (book_id, keyword_id) VALUES
(2, 3), (3, 1), (3, 4), (4, 5), (5, 2), (5, 1), (6, 3);

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path) VALUES
(2, 'PDF', 8.40, '1200x1800', '/ebooks/clean-code.pdf'),
(3, 'EPUB', 12.60, 'Responsive', '/ebooks/data-intensive.epub'),
(5, 'PDF', 9.20, '1200x1800', '/ebooks/php-mysql.pdf');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status) VALUES
(1, 'BK-001-A', 'Ke A1', 'good', 'available'),
(1, 'BK-001-B', 'Ke A1', 'good', 'borrowed'),
(2, 'BK-002-A', 'Ke B2', 'good', 'available'),
(2, 'BK-002-B', 'Ke B2', 'worn', 'available'),
(3, 'BK-003-A', 'Ke B3', 'good', 'available'),
(4, 'BK-004-A', 'Ke C1', 'good', 'available'),
(5, 'BK-005-A', 'Ke C2', 'good', 'available'),
(6, 'BK-006-A', 'Ke A2', 'good', 'available');

INSERT INTO loan_receipts (student_id, librarian_id, registered_at, note, status)
SELECT s.id, l.id, DATE_SUB(NOW(), INTERVAL 16 DAY), 'Phieu co sach dang qua han', 'open'
FROM students s, librarians l WHERE s.student_code = 'SV001' AND l.librarian_code = 'TT001';
INSERT INTO loan_receipts (student_id, librarian_id, registered_at, note, status)
SELECT s.id, l.id, DATE_SUB(NOW(), INTERVAL 30 DAY), 'Phieu da tra', 'completed'
FROM students s, librarians l WHERE s.student_code = 'SV002' AND l.librarian_code = 'TT001';

INSERT INTO loan_details (receipt_id, copy_id, borrow_date, due_date, return_date, extension_count, status, condition_on_return, return_status, late_days)
SELECT r.id, c.id, DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), NULL, 1, 'overdue', NULL, NULL, 0
FROM loan_receipts r, book_copies c WHERE r.note = 'Phieu co sach dang qua han' AND c.barcode = 'BK-001-B';
INSERT INTO loan_details (receipt_id, copy_id, borrow_date, due_date, return_date, extension_count, status, condition_on_return, return_status, late_days)
SELECT r.id, c.id, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 17 DAY), 0, 'returned', 'good', 'on_time', 0
FROM loan_receipts r, book_copies c WHERE r.note = 'Phieu da tra' AND c.barcode = 'BK-002-A';

INSERT INTO extensions (loan_detail_id, librarian_id, old_due_date, new_due_date, extension_date)
SELECT d.id, l.id, DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY)
FROM loan_details d, librarians l, loan_receipts r
WHERE d.receipt_id = r.id AND r.note = 'Phieu co sach dang qua han' AND l.librarian_code = 'TT001';

INSERT INTO book_loan_requests (student_id, note)
SELECT s.id, 'Muon sach phuc vu do an mon hoc'
FROM students s
WHERE s.student_code = 'SV002';
INSERT INTO book_loan_request_items (request_id, book_id, quantity, requested_due_date)
SELECT r.id, b.id, 1, DATE_ADD(CURDATE(), INTERVAL 14 DAY)
FROM book_loan_requests r, books b
WHERE r.note = 'Muon sach phuc vu do an mon hoc' AND b.title = 'Clean Code';

INSERT INTO rooms (name, room_type, location, capacity, included_equipment, operating_hours, status) VALUES
('Phòng học A101', 'classroom', 'Tầng 1 - Khu A', 40, 'Máy chiếu, Bảng tương tác', '00:00 - 24:00', 'available'),
('Phòng họp B204', 'meeting_room', 'Tầng 2 - Khu B', 12, 'Màn hình, Camera họp', '00:00 - 24:00', 'available'),
('Phòng dữ liệu C302', 'classroom', 'Tầng 3 - Khu C', 30, 'Máy tính, Máy chiếu', '00:00 - 24:00', 'available'),
('Phòng học A102', 'classroom', 'Tầng 1 - Khu A', 25, 'Máy chiếu', '00:00 - 24:00', 'maintenance');

INSERT INTO room_requests (student_id, room_id, use_date, start_time, end_time, purpose, status)
SELECT s.id, r.id, CURDATE(), '09:00', '11:00', 'Học nhóm môn Cơ sở dữ liệu', 'pending'
FROM students s, rooms r WHERE s.student_code = 'SV001' AND r.name = 'Phòng học A101';
INSERT INTO room_requests (student_id, room_id, use_date, start_time, end_time, purpose, status)
SELECT s.id, r.id, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '13:00', '15:00', 'Thảo luận đồ án', 'approved'
FROM students s, rooms r WHERE s.student_code = 'SV002' AND r.name = 'Phòng họp B204';

INSERT INTO equipment (name, equipment_type, manufacturer, description, usage_guide, total_quantity, available_quantity, storage_location, serial_number, status) VALUES
('Máy chiếu Epson EB-X06', 'Thiết bị trình chiếu', 'Epson', 'Máy chiếu phòng học.', 'Kết nối HDMI và tắt nguồn sau khi sử dụng.', 4, 3, 'Kho thiết bị 01', 'EP-EBX06-01', 'available'),
('Bộ kit Arduino Uno', 'Bộ thí nghiệm điện tử', 'Arduino', 'Bộ mạch lập trình cơ bản.', 'Sử dụng nguồn 5V và kiểm tra dây nối.', 10, 8, 'Kho thí nghiệm 02', 'ARD-UNO-01', 'available'),
('Máy đo đa năng', 'Thiết bị đo', 'Fluke', 'Thiết bị đo điện đa năng.', 'Đọc hướng dẫn trước khi kết nối mạch.', 3, 0, 'Kho thí nghiệm 02', 'FLK-117-01', 'borrowed'),
('Microphone không dây', 'Thiết bị âm thanh', 'Shure', 'Bộ micro phục vụ phòng họp.', 'Sạc đầy đủ trước khi sử dụng.', 6, 6, 'Kho thiết bị 01', 'SH-58-01', 'available');

INSERT INTO equipment_loans (student_id, librarian_id, registered_at, note, status)
SELECT s.id, l.id, DATE_SUB(NOW(), INTERVAL 10 DAY), 'Muon bo kit thi nghiem', 'borrowed'
FROM students s, librarians l WHERE s.student_code = 'SV001' AND l.librarian_code = 'TT001';
INSERT INTO equipment_loan_details (loan_id, equipment_id, quantity, borrow_date, due_date, condition_on_borrow, status)
SELECT el.id, e.id, 2, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Tot', 'overdue'
FROM equipment_loans el, equipment e WHERE el.note = 'Muon bo kit thi nghiem' AND e.name = 'Bo kit Arduino Uno';

INSERT INTO equipment_loan_requests (student_id, note)
SELECT s.id, 'Muon thiet bi cho buoi thuyet trinh'
FROM students s
WHERE s.student_code = 'SV002';
INSERT INTO equipment_loan_request_items (request_id, equipment_id, quantity, requested_due_date)
SELECT r.id, e.id, 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY)
FROM equipment_loan_requests r, equipment e
WHERE r.note = 'Muon thiet bi cho buoi thuyet trinh' AND e.name = 'Microphone khong day';

-- Thiet bi va dung cu phuc vu sinh vien, giang vien.
INSERT INTO equipment (
    name, equipment_type, manufacturer, description, usage_guide,
    total_quantity, available_quantity, storage_location, serial_number, status
) VALUES
('Laptop học tập Dell Latitude 5440', 'Thiết bị máy tính', 'Dell', 'Laptop dùng cho bài giảng, thực hành lập trình và làm đồ án.', 'Đăng nhập bằng tài khoản được cấp, sạc pin sau khi sử dụng và bàn giao đúng nơi quy định.', 8, 8, 'Kho thiết bị 01', 'DL-5440-01', 'available'),
('Bộ kit mạng Cisco thực hành', 'Thiết bị mạng', 'Cisco', 'Bộ thiết bị mô phỏng mạng gồm router, switch và phụ kiện kết nối.', 'Tắt nguồn trước khi thay đổi dây nối, kiểm tra sơ đồ mạng trước khi cấu hình.', 6, 6, 'Kho thí nghiệm 01', 'CISCO-LAB-01', 'available'),
('Bộ cảm biến IoT ESP32', 'Bộ thí nghiệm IoT', 'Espressif', 'Bộ mạch ESP32 và cảm biến dùng cho bài thực hành Internet of Things.', 'Cấp nguồn đúng điện áp, kiểm tra sơ đồ chân trước khi kết nối cảm biến.', 8, 8, 'Kho thí nghiệm 02', 'ESP32-IOT-01', 'available'),
('Bảng vẽ điện tử Wacom', 'Dụng cụ giảng dạy', 'Wacom', 'Bảng vẽ điện tử hỗ trợ giảng viên trình bày và minh họa trực tuyến.', 'Kết nối USB trước khi mở phần mềm, cất bút vào hộp sau khi sử dụng.', 4, 4, 'Kho thiết bị 01', 'WACOM-01', 'available'),
('Bộ breadboard và linh kiện điện tử', 'Dụng cụ điện tử', 'PTIT Lab', 'Bộ breadboard, dây nối, điện trở, LED và linh kiện phục vụ thực hành mạch điện.', 'Ngắt nguồn trước khi thay đổi mạch, phân loại linh kiện và trả đủ sau khi dùng.', 12, 12, 'Kho thí nghiệm 02', 'ELEC-KIT-01', 'available');

-- Giao trinh PTIT va cac tai lieu tham khao co trong giao trinh Co so du lieu.
INSERT INTO publishers (name, address) VALUES
('Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'),
('Addison-Wesley', 'Reading, Massachusetts'),
('Prentice Hall', 'Englewood Cliffs, New Jersey'),
('McGraw-Hill/Irwin', 'New York');

INSERT INTO authors (full_name, nationality, biography) VALUES
('Phạm Thế Quế', 'Việt Nam', 'Tác giả biên soạn giáo trình Cơ sở dữ liệu của Học viện Công nghệ Bưu chính Viễn thông.'),
('C. J. Date', 'Anh', NULL),
('Alfred V. Aho', 'Hoa Kỳ', NULL),
('John E. Hopcroft', 'Hoa Kỳ', NULL),
('Jeffrey D. Ullman', 'Hoa Kỳ', NULL),
('Michael V. Mannino', 'Hoa Kỳ', NULL),
('Abraham Silberschatz', 'Hoa Kỳ', NULL),
('Henry F. Korth', 'Hoa Kỳ', NULL),
('S. Sudarshan', 'Ấn Độ', NULL);

INSERT INTO genres (name, description) VALUES
('Giáo trình', 'Tài liệu học tập và giáo trình đại học');

INSERT INTO keywords (name) VALUES
('CSDL quan hệ'), ('Chuẩn hóa'), ('Thiết kế CSDL'), ('Bảo mật CSDL'), ('PTIT');

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id) VALUES
('Cơ sở dữ liệu', 2006, 'Tiếng Việt', 'Giáo trình giới thiệu hệ cơ sở dữ liệu, mô hình dữ liệu, CSDL quan hệ, chuẩn hóa, SQL, tối ưu hóa truy vấn và an toàn dữ liệu.', 166, NULL, 'Giáo trình dùng cho sinh viên hệ đào tạo đại học từ xa, lưu hành nội bộ; mã số 492CDL351.', 4),
('An Introduction to Database Systems', 1977, 'English', 'Tài liệu tham khảo về các khái niệm và hệ thống cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [2] trong giáo trình Cơ sở dữ liệu PTIT.', 5),
('Principles of Database Systems', 1980, 'English', 'Tài liệu tham khảo về nguyên lý hệ cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [9] trong giáo trình Cơ sở dữ liệu PTIT.', 6),
('Database Application Development and Design', 2001, 'English', 'Tài liệu tham khảo về phát triển và thiết kế ứng dụng cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [10] trong giáo trình Cơ sở dữ liệu PTIT.', 7),
('Database System Concepts', 2002, 'English', 'Tài liệu tham khảo về khái niệm, thiết kế và vận hành hệ cơ sở dữ liệu.', NULL, NULL, 'Tài liệu tham khảo [11] trong giáo trình Cơ sở dữ liệu PTIT.', 7),
('The Design and Analysis of Computer Algorithms', 1974, 'English', 'Tài liệu tham khảo về thiết kế và phân tích thuật toán.', NULL, NULL, 'Tài liệu tham khảo [4] trong giáo trình Cơ sở dữ liệu PTIT.', 5);

INSERT INTO book_authors (book_id, author_id) VALUES
(7, 5), (8, 6), (9, 9), (10, 10), (11, 11), (11, 12), (11, 13), (12, 7), (12, 8), (12, 9);

INSERT INTO book_genres (book_id, genre_id) VALUES
(7, 3), (7, 5), (8, 3), (9, 3), (10, 3), (11, 3), (12, 4);

INSERT INTO book_keywords (book_id, keyword_id) VALUES
(7, 1), (7, 6), (7, 7), (7, 9), (7, 10), (8, 6), (9, 6), (10, 8), (11, 1), (11, 6), (12, 5);

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path) VALUES
(7, 'PDF', 5.19, 'A4', '/ebooks/csdl-giao-trinh.pdf');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status) VALUES
(7, 'PTIT-CSDL-2006-01', 'Kệ G1', 'good', 'available'),
(8, 'REF-DATE-1977-01', 'Kệ G2', 'good', 'available'),
(9, 'REF-ULLMAN-1980-01', 'Kệ G2', 'good', 'available'),
(10, 'REF-MANNINO-2001-01', 'Kệ G3', 'good', 'available'),
(11, 'REF-DBCONCEPTS-2002-01', 'Kệ G3', 'good', 'available'),
(12, 'REF-AHO-1974-01', 'Kệ H1', 'good', 'available');

-- Dau sach minh hoa cho tim kiem theo mot phan nhan de: "cấu trúc".
INSERT INTO publishers (name, address) VALUES
('Nhà xuất bản Đại học Quốc gia Hà Nội', 'Hà Nội');

INSERT INTO authors (full_name, nationality, biography) VALUES
('Nguyễn Đức Nghĩa', 'Việt Nam', 'Tác giả tài liệu về cấu trúc dữ liệu và giải thuật.');

INSERT INTO keywords (name) VALUES
('Cấu trúc dữ liệu');

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT
    'Cấu trúc dữ liệu và giải thuật',
    2015,
    'Tiếng Việt',
    'Tài liệu nhập môn về cấu trúc dữ liệu, thuật toán và kỹ thuật giải quyết bài toán lập trình.',
    NULL,
    NULL,
    'Đầu sách minh họa cho chức năng tìm kiếm theo một phần tên sách.',
    p.id
FROM publishers p
WHERE p.name = 'Nhà xuất bản Đại học Quốc gia Hà Nội';

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id
FROM books b
JOIN authors a ON a.full_name = 'Nguyễn Đức Nghĩa'
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật';

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id
FROM books b
JOIN genres g ON g.name IN ('Thuật toán', 'Giáo trình')
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật';

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id
FROM books b
JOIN keywords k ON k.name = 'Cấu trúc dữ liệu'
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật';

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'DSA-VN-2015-01', 'Kệ H2', 'good', 'available'
FROM books b
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật';

-- Them giao trinh PTIT ve he dieu hanh va lich su Dang.
INSERT INTO authors (full_name, nationality, biography) VALUES
('Từ Minh Phương', 'Việt Nam', 'Tác giả giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông.'),
('Đỗ Thị Diệu', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.'),
('Đào Mạnh Ninh', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.');

INSERT INTO keywords (name) VALUES
('Hệ điều hành'), ('Lịch sử Đảng');

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'Giáo trình Hệ điều hành', 2015, 'Tiếng Việt',
       'Giáo trình trình bày các khái niệm và nguyên lý hoạt động của hệ điều hành, quản lý tiến trình, bộ nhớ, hệ thống tệp và vào ra.',
       185, NULL,
       'Giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2015.', p.id
FROM publishers p WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông';

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam', 2021, 'Tiếng Việt',
       'Bài giảng dành cho sinh viên đại học, trình bày quá trình ra đời, lãnh đạo đấu tranh giành chính quyền, kháng chiến và công cuộc đổi mới.',
       169, NULL,
       'Bài giảng của Khoa Cơ bản 1, Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2021.', p.id
FROM publishers p WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông';

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Từ Minh Phương'
WHERE b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015;
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name IN ('Đỗ Thị Diệu', 'Đào Mạnh Ninh')
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021;

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name = 'Giáo trình'
WHERE (b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015)
   OR (b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('Hệ điều hành', 'PTIT')
WHERE b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015;
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('Lịch sử Đảng', 'PTIT')
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021;

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-HDH-2015-01', 'Kệ I1', 'good', 'available'
FROM books b WHERE b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015;
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-LSD-2021-01', 'Kệ I2', 'good', 'available'
FROM books b WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021;

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 4.28, 'A4', '/ebooks/ptit-he-dieu-hanh-2015.pdf'
FROM books b WHERE b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015;
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 2.70, 'A4', '/ebooks/ptit-lich-su-dang-2021.pdf'
FROM books b WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021;
-- Them 10 giao trinh PTIT tu thu muc Desktop, kem ban sach dien tu PDF.
INSERT INTO publishers (name, address)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM publishers
    WHERE name = 'Học viện Công nghệ Bưu chính Viễn thông'
);

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Ao Thu Hoài', 'Việt Nam', 'Giảng viên, biên soạn tài liệu về thương mại điện tử và marketing trực tuyến.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Ao Thu Hoài');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trần Thị Thập', 'Việt Nam', 'Biên tập tài liệu Xây dựng Website thương mại điện tử của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trần Thị Thập');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Nguyễn Hoàng Anh', 'Việt Nam', 'Biên tập tài liệu Xây dựng Website thương mại điện tử của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Nguyễn Hoàng Anh');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Hoàng Xuân Dậu', 'Việt Nam', 'Tác giả các giáo trình về an toàn thông tin và bảo mật hệ thống.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Hoàng Xuân Dậu');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trịnh Thị Vân Anh', 'Việt Nam', 'Tác giả giáo trình Kỹ thuật đồ họa của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trịnh Thị Vân Anh');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trần Thị Hoà', 'Việt Nam', 'Tác giả giáo trình Kinh tế vi mô của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trần Thị Hoà');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Phạm Hoàng Duy', 'Việt Nam', 'Tác giả giáo trình An toàn hệ điều hành của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Phạm Hoàng Duy');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trần Đình Quế', 'Việt Nam', 'Đồng tác giả giáo trình Nhập môn Công nghệ phần mềm của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trần Đình Quế');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Nguyễn Mạnh Hùng', 'Việt Nam', 'Đồng tác giả giáo trình Nhập môn Công nghệ phần mềm của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Nguyễn Mạnh Hùng');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Đỗ Xuân Chợ', 'Việt Nam', 'Tác giả bài giảng Các kỹ thuật giấu tin của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Đỗ Xuân Chợ');

INSERT INTO genres (name, description)
SELECT 'Thương mại điện tử', 'Xây dựng và vận hành website thương mại điện tử'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Thương mại điện tử');
INSERT INTO genres (name, description)
SELECT 'Marketing', 'Marketing và marketing trực tuyến'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Marketing');
INSERT INTO genres (name, description)
SELECT 'An toàn thông tin', 'Bảo vệ dữ liệu, hệ thống và ứng dụng'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'An toàn thông tin');
INSERT INTO genres (name, description)
SELECT 'Đồ họa máy tính', 'Kỹ thuật và ứng dụng đồ họa máy tính'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Đồ họa máy tính');
INSERT INTO genres (name, description)
SELECT 'Kinh tế', 'Các môn học kinh tế cơ bản'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Kinh tế');
INSERT INTO genres (name, description)
SELECT 'Hệ điều hành', 'Nguyên lý và an toàn hệ điều hành'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Hệ điều hành');
INSERT INTO genres (name, description)
SELECT 'Công nghệ phần mềm', 'Phân tích, thiết kế và phát triển phần mềm'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Công nghệ phần mềm');
INSERT INTO genres (name, description)
SELECT 'Giấu tin', 'Kỹ thuật giấu tin và thủy vân số'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Giấu tin');

INSERT INTO keywords (name)
SELECT 'PTIT' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'PTIT');
INSERT INTO keywords (name)
SELECT 'Thương mại điện tử' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Thương mại điện tử');
INSERT INTO keywords (name)
SELECT 'Marketing trực tuyến' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Marketing trực tuyến');
INSERT INTO keywords (name)
SELECT 'An toàn thông tin' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'An toàn thông tin');
INSERT INTO keywords (name)
SELECT 'Bảo mật hệ thống' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Bảo mật hệ thống');
INSERT INTO keywords (name)
SELECT 'Ứng dụng web' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Ứng dụng web');
INSERT INTO keywords (name)
SELECT 'Cơ sở dữ liệu' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Cơ sở dữ liệu');
INSERT INTO keywords (name)
SELECT 'Hệ điều hành' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Hệ điều hành');
INSERT INTO keywords (name)
SELECT 'Công nghệ phần mềm' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Công nghệ phần mềm');
INSERT INTO keywords (name)
SELECT 'Đồ họa máy tính' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Đồ họa máy tính');
INSERT INTO keywords (name)
SELECT 'Kinh tế vi mô' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Kinh tế vi mô');
INSERT INTO keywords (name)
SELECT 'Giấu tin' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Giấu tin');

INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Bài giảng Xây dựng Website thương mại điện tử', 2018, 'Tiếng Việt',
       'Tài liệu trình bày các kiến thức và kỹ thuật xây dựng website thương mại điện tử.',
       141, 'Bài giảng PTIT, biên soạn bởi Th.S. Ao Thu Hoài, hiệu đính năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Bài giảng Xây dựng Website thương mại điện tử' AND publication_year = 2018);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'E-marketing (Marketing trực tuyến)', 2013, 'Tiếng Việt',
       'Tài liệu nhập môn về marketing trực tuyến và các hoạt động marketing trên môi trường số.',
       353, 'Giáo trình PTIT, tác giả TS. Ao Thu Hoài, năm 2013.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'E-marketing (Marketing trực tuyến)' AND publication_year = 2013);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Giáo trình Cơ sở an toàn thông tin', 2018, 'Tiếng Việt',
       'Giáo trình giới thiệu các khái niệm nền tảng, nguy cơ và biện pháp bảo đảm an toàn thông tin.',
       143, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Giáo trình Cơ sở an toàn thông tin' AND publication_year = 2018);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Giáo trình Kỹ thuật đồ họa', 2018, 'Tiếng Việt',
       'Giáo trình trình bày các nguyên lý và kỹ thuật cơ bản của đồ họa máy tính.',
       222, 'Giáo trình PTIT, tác giả Trịnh Thị Vân Anh, năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Giáo trình Kỹ thuật đồ họa' AND publication_year = 2018);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Kinh tế vi mô 1', 2013, 'Tiếng Việt',
       'Tài liệu trình bày các khái niệm và nguyên lý cơ bản của kinh tế vi mô.',
       180, 'Giáo trình PTIT, tác giả TS. Trần Thị Hoà, năm 2013.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Kinh tế vi mô 1' AND publication_year = 2013);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'An toàn hệ điều hành', 2017, 'Tiếng Việt',
       'Tài liệu trình bày các vấn đề bảo vệ hệ điều hành, tài nguyên hệ thống và dữ liệu người dùng.',
       100, 'Giáo trình PTIT, tác giả Phạm Hoàng Duy, năm 2017.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An toàn hệ điều hành' AND publication_year = 2017);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Nhập môn Công nghệ phần mềm', 2016, 'Tiếng Việt',
       'Giáo trình nhập môn về quy trình, phương pháp và kỹ thuật phát triển phần mềm.',
       229, 'Giáo trình PTIT, đồng tác giả Trần Đình Quế và Nguyễn Mạnh Hùng, năm 2016.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Nhập môn Công nghệ phần mềm' AND publication_year = 2016);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'An toàn và bảo mật hệ thống thông tin', 2017, 'Tiếng Việt',
       'Tài liệu trình bày các nguyên tắc, mô hình và biện pháp bảo đảm an toàn, bảo mật hệ thống thông tin.',
       152, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2017.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An toàn và bảo mật hệ thống thông tin' AND publication_year = 2017);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'An toàn ứng dụng web và cơ sở dữ liệu', 2017, 'Tiếng Việt',
       'Tài liệu giới thiệu các nguy cơ và biện pháp bảo vệ ứng dụng web và cơ sở dữ liệu.',
       160, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2017.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND publication_year = 2017);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Bài giảng Các kỹ thuật giấu tin', 2018, 'Tiếng Việt',
       'Bài giảng giới thiệu các kỹ thuật giấu tin và những ứng dụng cơ bản trong môi trường số.',
       136, 'Bài giảng PTIT, tác giả Đỗ Xuân Chợ, tháng 12 năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Bài giảng Các kỹ thuật giấu tin' AND publication_year = 2018);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name IN ('Ao Thu Hoài', 'Trần Thị Thập', 'Nguyễn Hoàng Anh')
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Ao Thu Hoài'
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Hoàng Xuân Dậu'
WHERE b.title IN ('Giáo trình Cơ sở an toàn thông tin', 'An toàn và bảo mật hệ thống thông tin', 'An toàn ứng dụng web và cơ sở dữ liệu')
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Trịnh Thị Vân Anh'
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Trần Thị Hoà'
WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Phạm Hoàng Duy'
WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name IN ('Trần Đình Quế', 'Nguyễn Mạnh Hùng')
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Đỗ Xuân Chợ'
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Thương mại điện tử')
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Marketing')
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'An toàn thông tin')
WHERE b.title IN ('Giáo trình Cơ sở an toàn thông tin', 'An toàn và bảo mật hệ thống thông tin', 'An toàn ứng dụng web và cơ sở dữ liệu')
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Đồ họa máy tính')
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Kinh tế')
WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Hệ điều hành')
WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Công nghệ phần mềm')
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Giấu tin')
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Thương mại điện tử', 'Ứng dụng web')
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Marketing trực tuyến')
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'An toàn thông tin')
WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Đồ họa máy tính')
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Kinh tế vi mô')
WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Hệ điều hành')
WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Công nghệ phần mềm')
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Bảo mật hệ thống')
WHERE b.title = 'An toàn và bảo mật hệ thống thông tin' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'An toàn thông tin', 'Ứng dụng web', 'Cơ sở dữ liệu')
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Giấu tin')
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 10.85, 'A4', '/ebooks/ptit-website-thuong-mai-dien-tu-2018.pdf'
FROM books b WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 10.02, 'A4', '/ebooks/ptit-e-marketing-2013.pdf'
FROM books b WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 7.65, 'A4', '/ebooks/ptit-co-so-an-toan-thong-tin-2018.pdf'
FROM books b WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 5.44, 'A4', '/ebooks/ptit-ky-thuat-do-hoa-2018.pdf'
FROM books b WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 3.81, 'A4', '/ebooks/ptit-kinh-te-vi-mo-1-2013.pdf'
FROM books b WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 4.83, 'A4', '/ebooks/ptit-an-toan-he-dieu-hanh-2017.pdf'
FROM books b WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 9.06, 'A4', '/ebooks/ptit-nhap-mon-cong-nghe-phan-mem-2016.pdf'
FROM books b WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 6.85, 'A4', '/ebooks/ptit-an-toan-bao-mat-he-thong-thong-tin-2017.pdf'
FROM books b WHERE b.title = 'An toàn và bảo mật hệ thống thông tin' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 7.05, 'A4', '/ebooks/ptit-an-toan-ung-dung-web-co-so-du-lieu-2017.pdf'
FROM books b WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 3.60, 'A4', '/ebooks/ptit-cac-ky-thuat-giau-tin-2018.pdf'
FROM books b WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-WEB-2018-01', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-WEB-2018-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-01', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATTT-2018-01', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATTT-2018-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-DH-2018-01', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-DH-2018-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-KTVM-2013-01', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'Kinh tế vi mô 1' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-KTVM-2013-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATHDH-2017-01', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'An toàn hệ điều hành' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATHDH-2017-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-01', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-BMHTTT-2017-01', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'An toàn và bảo mật hệ thống thông tin' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-BMHTTT-2017-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATWEB-2017-01', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATWEB-2017-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-GIAUTIN-2018-01', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-GIAUTIN-2018-01');
-- Tao so luong ban sao khac nhau cho 10 giao trinh PTIT.
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-WEB-2018-02', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-WEB-2018-02');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-WEB-2018-03', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-WEB-2018-03');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-WEB-2018-04', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-WEB-2018-04');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-02', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-02');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-03', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-03');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-04', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-04');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-05', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-05');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-06', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-06');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATTT-2018-02', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATTT-2018-02');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-DH-2018-02', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-DH-2018-02');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-DH-2018-03', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-DH-2018-03');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-DH-2018-04', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-DH-2018-04');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-KTVM-2013-02', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'Kinh tế vi mô 1'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-KTVM-2013-02');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATHDH-2017-02', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATHDH-2017-02');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATHDH-2017-03', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATHDH-2017-03');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATHDH-2017-04', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATHDH-2017-04');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-02', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-02');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-03', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-03');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-04', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-04');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-05', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-05');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-06', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-06');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-BMHTTT-2017-02', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'An toàn và bảo mật hệ thống thông tin'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-BMHTTT-2017-02');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATWEB-2017-02', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATWEB-2017-02');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATWEB-2017-03', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATWEB-2017-03');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATWEB-2017-04', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATWEB-2017-04');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-GIAUTIN-2018-02', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-GIAUTIN-2018-02');





