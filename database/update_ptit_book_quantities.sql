USE resource_center;

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
