# SQL trong ứng dụng

Lượt refactor 2026-11-04 tập trung vào truy vấn danh mục, quản lý tài nguyên, thống kê và kiểm tra mượn trả. Không thay schema hay dữ liệu tài nguyên đang dùng.

## Vị trí

- `app/queries/books.php`: danh mục sách, thống kê lượt mượn, nguồn trợ lý, tồn kho bộ học liệu và ánh xạ tác giả/thể loại/từ khóa.
- `app/queries/resources.php`: bộ đếm dashboard, danh sách quản trị có phân trang và kiểm tra giao dịch đang mở.
- `app/resources.php`: xác thực dữ liệu và điều phối ghi tài nguyên trong transaction.
- `public/index.php`: nhận tham số HTTP, phân quyền và điều phối nghiệp vụ. Các truy vấn khóa hàng để duyệt/trả vẫn nằm cạnh transaction sở hữu chúng.
- `database/queries.sql`: 12 ví dụ SQL chạy trực tiếp; biến phiên chỉ dùng cho ví dụ. PHP luôn truyền dữ liệu qua PDO parameters.

## Quy ước

1. Viết rõ SELECT/FROM/JOIN/WHERE/ORDER BY; mỗi điều kiện dài nằm trên một dòng. Không xây thêm query builder cho các câu SQL có cấu trúc cố định.
2. Giá trị đến từ người dùng phải dùng placeholders. LIMIT/OFFSET được bind bằng PDO::PARAM_INT. Tên bảng/cột động chỉ lấy từ whitelist nội bộ (`managed_table`, `book_relations`). Không dùng khóa của request để dựng identifier.
3. Tổng hợp từng quan hệ về một dòng cho mỗi đầu sách trước khi JOIN. Không JOIN đồng thời tác giả/thể loại/từ khóa/bản sách rồi COUNT lượt mượn: các quan hệ nhiều-nhiều có thể nhân số dòng. Lượt mượn tính theo dòng loan_details, kể cả nhiều lần mượn cùng một bản sách.
4. Danh mục công khai lọc is_visible = 1 và deleted_at IS NULL. Kho khả dụng còn lọc status = available. Lịch sử giữ tài nguyên đã ẩn/xóa để không mất thông tin mượn trả.
5. Danh sách quản trị dùng chung FROM/WHERE cho COUNT và lấy trang. SELECT r.* chỉ dùng ở tài nguyên quản trị đa loại; chi tiết quản trị cần toàn bộ bản ghi để tạo version chống ghi đè. Các bản chiếu danh mục/chuyên biệt liệt kê rõ cột.
6. Kiểm tra tồn tại dùng SELECT 1 ... LIMIT 1; COUNT dành cho số liệu cần đếm. Truy vấn được lặp với nhiều ID phải prepare một lần rồi execute lại.
7. Giữ FOR UPDATE và thứ tự khóa trong transaction duyệt mượn/đặt phòng. Hàm truy vấn không tự mở hoặc commit transaction thay cho nghiệp vụ gọi nó.
8. Thứ tự metadata quản trị vẫn theo ID để không đổi version hash; chi tiết sinh viên vẫn theo tên. Giữ nguyên tên/kiểu trường API.

## Thay đổi hành vi có chủ đích

Sửa thống kê sách bị nhân lượt mượn khi có nhiều tác giả. Ví dụ 3 lượt mượn + 2 tác giả phải là 3 lượt, thay vì 6. Truy vấn danh mục cũng tách các tổng hợp, tránh tạo tích các quan hệ rồi phải khử trùng lặp toàn bộ kết quả.

Dashboard lấy sáu số đếm trong một câu SQL. Bỏ kiểm tra yêu cầu phòng trùng hoàn toàn vì truy vấn kiểm tra giao nhau trước đó đã bao phủ trường hợp này. Quy tắc xung đột và thông báo xuất hiện trước đây được giữ nguyên.

## Xác minh

`php tests/sql-queries.php` yêu cầu NEXUS_DB_NAME có dạng resource_center_test_<digits>. Bài kiểm tra tạo fixture trong transaction rồi rollback, kiểm tra nhiều tác giả/thể loại/từ khóa, nhiều lượt mượn cùng bản sách, bản ẩn/xóa, tìm kiếm có chuỗi SQL, số trang vượt giới hạn, thứ tự metadata/version, các bộ đếm và chạy cả 12 SQL ví dụ trên DB cô lập.

Các bộ `tests/regression.cjs`, `tests/resource-visibility.cjs` và 22 bài Python về trợ lý/bộ học liệu cũng đã đạt sau refactor. Regression kiểm tra duyệt đồng thời, mượn trả, phân quyền, CRUD, ảnh và ba vai trò. Không chạy kiểm tra ghi dữ liệu trên DB đang dùng.

Sao lưu mã nguồn trước refactor: `E:/Dell Gaming/resource-center-backups/sql-cleanup-20261104-155959/`.
