# Phân tích nghiệp vụ, chuẩn hóa và mô hình thống nhất

## 1. Bối cảnh và phạm vi

Nexus quản lý tài nguyên học tập tại **một trung tâm**: sách vật lý, PDF, phòng và thiết bị. Sinh viên tìm tài nguyên, gửi yêu cầu và xem lịch sử của mình. Thủ thư duyệt yêu cầu, lập phiếu trực tiếp tại quầy, nhận trả và xét yêu cầu gia hạn do sinh viên gửi. Quản trị viên xem đầy đủ hồ sơ tài khoản và quản lý tài nguyên.

Phạm vi hiện tại không có nghiệp vụ lương, nhiều chi nhánh, phạt tiền hoặc hàng đợi giữ chỗ đầu sách. Đặt phòng là giữ một phòng trong khung giờ; yêu cầu mượn sách là đề nghị cấp các bản vật lý, chưa giữ chỗ trong hàng đợi. Mỗi tài khoản có một điện thoại và một địa chỉ liên hệ; nếu thay đổi yêu cầu thành nhiều địa chỉ/số điện thoại, cần thêm các quan hệ liên hệ tương ứng.

## 2. Nguồn mô hình dùng trong báo cáo và slide

1. `database/schema.sql`: khởi tạo mới, 26 bảng nghiệp vụ.
2. `scripts/migrate-circulation.php`: nâng cấp dữ liệu cũ, sao lưu trước DDL, khởi tạo số lượng không khả dụng và nối phiếu cũ khi có bằng chứng duy nhất.
3. [database-schema.md](database-schema.md): từ điển tất cả thuộc tính, khóa và CHECK của CSDL đang chạy.
4. [database-erd.mmd](database-erd.mmd): ERD Mermaid sinh từ cùng metadata với từ điển. Nhập tệp này vào công cụ Mermaid để xuất hình cho báo cáo và slide.

Chạy `php scripts/document-schema.php` sau khi áp dụng migration để sinh lại hai tài liệu. Tệp `cautruc.sql` ở thư mục gốc là bản xuất tại một thời điểm trước nâng cấp; không dùng nó làm mô hình hiện hành hoặc nhập đè khi trình bày phiên bản mới. Không sửa ERD và slide độc lập với schema.

## 3. Kịch bản nghiệp vụ và dữ liệu chính

| Kịch bản | Dữ liệu cần lưu | Quy tắc |
|---|---|---|
| Sinh viên gửi yêu cầu sách | Người yêu cầu, đầu sách, số lượng, hạn trả từng dòng | Chưa có phiếu mượn trước khi duyệt; kiểm tra lại tồn khi duyệt |
| Thủ thư cấp sách | Yêu cầu, sinh viên, thủ thư, phiếu và từng bản sách | Một bản sách chỉ có tối đa một lượt mượn chưa trả |
| Cho mượn tại quầy | Cùng dữ liệu yêu cầu và phiếu, nguồn `counter` | Tạo yêu cầu, duyệt, tạo phiếu, cập nhật kho trong một transaction; lỗi thì rollback toàn bộ |
| Trả và gia hạn | Chi tiết lượt mượn, ngày trả, tình trạng; lịch sử đổi hạn | Trả theo chi tiết phiếu để xác định đúng người/bản sách; không nhận trả hai lần |
| Mượn thiết bị | Phiếu, thiết bị, số lượng, hạn trả | Khóa dòng thiết bị khi cấp phát; không cấp quá số sẵn sàng |
| Kiểm kê | Các số trước/sau, số đang mượn tại thời điểm ghi, người ghi, lý do | Tổng = sẵn sàng + đang mượn + không khả dụng; không sửa/xóa lịch sử kiểm kê từ web |
| Đặt phòng | Sinh viên, phòng, ngày, giờ bắt đầu/kết thúc | Giờ bắt đầu trước giờ kết thúc; giao dịch duyệt kiểm tra trùng lịch |
| Xem hồ sơ | Tài khoản, sinh viên/thủ thư và lịch sử liên quan | Admin được xem người khác; sinh viên chỉ xem lịch sử của mình |

## 4. Phân rã trước và sau chuẩn hóa

Ví dụ **giả định để minh họa quá trình thiết kế**, không phải tên một bảng đã từng tồn tại trong hệ thống:

`MUON_UNF(MaPhieu, NgayLap, MaSV, TenSV, EmailSV, MaThuThu, TenThuThu, {MaDauSach, TenSach, NXB, {TacGia}, {MaBan, TinhTrang, HanTra, NgayTra}})`.

### 1NF

Bỏ nhóm lặp danh sách đầu sách, tác giả và bản sách khỏi một ô; xác định từng dòng bằng khóa. Không lưu nhiều mã bản sách hoặc nhiều tác giả trong cùng một thuộc tính. Chuỗi tên tác giả hiển thị trên web là kết quả tổng hợp truy vấn, không phải cấu trúc lưu trữ quan hệ tác giả.

### 2NF

Trong quan hệ giả định có khóa ghép `(MaPhieu, MaBan)`, thông tin phiếu chỉ phụ thuộc `MaPhieu`, thông tin cuốn sách chỉ phụ thuộc `MaBan`. Tách thành `loan_receipts`, `loan_details`, `book_copies`. Với quan hệ nhiều tác giả, dùng khóa ghép `(book_id, author_id)` trong `book_authors`; không đưa tên tác giả vào bảng nối.

### 3NF

Loại các phụ thuộc bắc cầu: thông tin sinh viên đi qua `student_id`, thông tin tài khoản đi qua `account_id`, nhà xuất bản đi qua `publisher_id`. Dùng `accounts`, `students`, `librarians`, `publishers`, `books`, `authors` và các bảng nối. Một phiếu không sao chép họ tên/email sinh viên hoặc tên nhà xuất bản để tránh cập nhật nhiều nơi.

### Phụ thuộc hàm và khóa cần giải thích

| Quan hệ / nhóm | Khóa ứng viên và phụ thuộc hàm chính |
|---|---|
| `accounts` | `id →` thông tin tài khoản; `username →` cùng thông tin vì username UNIQUE |
| `students`, `librarians` | `id`, `account_id`, mã sinh viên/thủ thư là các khóa ứng viên trong từng bảng |
| `books` | `id → title, publisher_id, language, ...`; tên sách không được giả định duy nhất |
| `book_copies` | `id → book_id, barcode, vị trí, trạng thái`; `barcode →` toàn bộ thông tin bản sách |
| `book_authors`, `book_genres`, `book_keywords` | Khóa ghép hai FK; không có thuộc tính mô tả phụ thuộc riêng từng nửa khóa |
| `book_loan_request_items`, `equipment_loan_request_items` | `id` và `(request_id, resource_id)` là khóa ứng viên; khóa ghép quyết định số lượng và hạn trả |
| `loan_receipts`, `equipment_loans` | `id →` thông tin phiếu; mỗi `request_id` khác NULL chỉ được nối một phiếu |
| `loan_details`, `equipment_loan_details` | `id →` thông tin từng lượt cấp phát; mã bản sách không duy nhất qua toàn bộ lịch sử |
| `room_requests` | `id →` lịch đặt; bộ phòng/ngày/giờ không được tự động coi là khóa khi có yêu cầu bị từ chối/hủy |
| `extensions` | `id → loan_detail_id, librarian_id, old_due_date, new_due_date, extension_date` |

### BCNF và các ngoại lệ triển khai

Đối với các quan hệ danh mục/bảng nối chỉ có các phụ thuộc hàm đã nêu, các định thức là khóa ứng viên nên có thể lập luận BCNF theo giả thiết nghiệp vụ đó. **Không tuyên bố toàn bộ CSDL vật lý đạt BCNF một cách tuyệt đối**:

- `return_status`, `late_days` được suy ra từ ngày trả/hạn trả; `extension_count` là số đếm lưu sẵn. Đây là phi chuẩn hóa có kiểm soát; CHECK đảm bảo kết quả trả/ngày trễ khớp ngày, transaction cập nhật gia hạn cùng lịch sử.
- `equipment.available_quantity` và `unavailable_quantity` là số dư lưu sẵn. Số đang mượn tính từ chi tiết chưa trả, transaction nghiệp vụ kiểm tra phương trình cân bằng. CHECK trong một dòng không thể tự chứng minh tổng trên nhiều bảng.
- `active_copy_id` và `pending_loan_id` là cột kỹ thuật GENERATED cho ràng buộc duy nhất có điều kiện; không phải thuộc tính nghiệp vụ độc lập.
- `rooms.included_equipment` là văn bản mô tả tiện ích, không dùng để hạch toán thiết bị. Nếu quản lý số lượng thiết bị cấp cho từng phòng, cần thiết kế quan hệ `room_equipment` và nghiệp vụ điều chuyển tương ứng.

Khi cô yêu cầu mô hình 3NF/BCNF thuần túy, trình bày mô hình logic bỏ các số suy diễn và dùng truy vấn/view tính chúng; chỉ rõ ánh xạ từ mô hình logic sang các cột triển khai nêu trên. Số 26 bảng là số bảng vật lý hiện hành, không phải một bằng chứng đạt dạng chuẩn.

## 5. Đầu sách, bản sách và thực thể yếu

`books` là đầu sách: tên, nội dung chung, tác giả, nhà xuất bản, ảnh bìa. `book_copies` là mỗi cuốn vật lý: mã vạch riêng, vị trí, tình trạng riêng. Một đầu sách có nhiều bản; phiếu cấp phát tham chiếu `copy_id`, còn yêu cầu tham chiếu `book_id` và số lượng mong muốn.

Hệ thống dùng surrogate key `id` cho các bản sách, dòng phiếu và dòng yêu cầu. Trong mô hình ER triển khai, `book_copies` có khóa nhận diện riêng và barcode UNIQUE nên không nên gọi nó là thực thể yếu chỉ vì có FK đến `books`. Các thực thể kết hợp dùng khóa ghép được trình bày như quan hệ kết hợp. Nếu chọn mô hình ER khái niệm có thực thể yếu, phải nêu khóa bộ phận và quan hệ định danh, rồi giải thích cách ánh xạ sang bảng vật lý.

## 6. Toàn vẹn và tính nhất quán

| Quy tắc | Nơi bảo vệ |
|---|---|
| Tài khoản, mã sinh viên, mã vạch không trùng | UNIQUE trong MySQL |
| Liên kết phiếu, sinh viên, sách, yêu cầu hợp lệ | FK; liên kết yêu cầu–phiếu có UNIQUE |
| Số lượng dương, hạn trả hợp lệ, kết quả trả khớp ngày | CHECK trong schema và kiểm tra API |
| Một bản chỉ có một lượt mượn chưa trả | GENERATED `active_copy_id` + UNIQUE |
| Không vượt tồn, không trùng phòng khi duyệt | Transaction + khóa dòng `FOR UPDATE` + kiểm tra tại thời điểm duyệt |
| Tổng các nhóm thiết bị khớp | Kiểm tra aggregate trong transaction mượn trả/cập nhật thiết bị; CHECK chặn sẵn sàng + không khả dụng vượt tổng |
| Đúng người / vai trò / CSRF | Kiểm tra phía server; không phụ thuộc nút ẩn trên giao diện |

Khóa ngoại yêu cầu–phiếu không tự kiểm chứng tất cả thuộc tính lặp như sinh viên, thủ thư và trạng thái đã duyệt. Luồng cấp phát chỉ lấy các mã này từ yêu cầu đang khóa, không nhận chúng từ client để ghi phiếu.

## 7. Di chuyển dữ liệu cũ

Migration sao lưu toàn bộ CSDL trước DDL. Phần thiếu giữa tổng, sẵn sàng và đang mượn được giữ trong số không khả dụng; không tự gán nguyên nhân hỏng hoặc thất lạc.

Liên kết phiếu cũ chỉ được khôi phục từ ghi chú do hệ thống tạo nếu tìm đúng một phiếu, cùng sinh viên, cùng thủ thư, yêu cầu đã duyệt và chưa được liên kết. Trường hợp không đủ bằng chứng giữ NULL và báo cần rà soát. Phiếu mới luôn lưu FK rõ ràng. Không giả lập một yêu cầu lịch sử để lấp dữ liệu.

## 8. Kịch bản demo trước cô

1. Mở admin → Quản trị → Xem chi tiết một sinh viên: thông tin liên hệ, khoa/lớp, lịch sử sách/thiết bị, lịch phòng. Mở thủ thư để xem các phiếu đã lập/duyệt và lịch sử gia hạn.
2. Đăng nhập thủ thư → Mượn & trả → Lập phiếu mượn tại quầy. Chọn sinh viên, hai đầu sách, mỗi dòng có số lượng/hạn trả. Lập phiếu và truy vết để xem mã bản vật lý đã giao.
3. Sinh viên gửi yêu cầu trực tuyến → thủ thư duyệt → truy vết mã yêu cầu. Giải thích nguồn online/counter và FK `request_id`.
4. Nhận trả một bản, mở lại chi tiết phiếu để thấy người mượn, mã vạch, ngày trả và trạng thái từng bản. Trả hết thì phiếu hoàn tất.
6. Trên CSDL test, thử số lượng 0, vượt tồn, trả hai lần, hai lượt tranh bản cuối, sửa bằng phiên bản cũ; giải thích lỗi/rollback và ràng buộc gây chặn.
7. Mở metadata MySQL, từ điển dữ liệu và ERD cùng phiên bản. Giải thích các bước chuẩn hóa bằng một phiếu ví dụ và nêu rõ các cột suy diễn triển khai.

Kiểm thử có ghi dữ liệu chỉ chạy trong `resource_center_test_<digits>`; xem `tests/README.md`.
