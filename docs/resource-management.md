# Hiển thị, xóa và hình ảnh tài nguyên

Phạm vi giao diện: web desktop, Open Campus. Không thiết kế lại điện thoại.

## Quy tắc sử dụng

- **Đầu sách** lưu thông tin chung: tên, tác giả, nhà xuất bản, ảnh bìa. **Bản sách** là từng cuốn vật lý có mã vạch, vị trí và tình trạng riêng. Một đầu sách có thể có nhiều bản sách; các bản dùng chung ảnh bìa.
- Mỗi đầu sách, bản sách, phòng và thiết bị có `is_visible`: 1 là Hiện, 0 là Đã ẩn. Tách khỏi tình trạng hoạt động (đang mượn, hư hỏng, bảo trì...).
- Sinh viên chỉ khám phá tài nguyên hiện. Ẩn đầu sách cũng chặn các bản thuộc đầu sách đó. Bản sách ẩn không được tính vào số lượng sẵn sàng và không được cấp phát khi duyệt.
- Bộ lọc và nút Ẩn/Hiện nằm trong Quản lý tài nguyên. Thủ thư và quản trị viên được sửa/ẩn/hiện. Chỉ quản trị viên được xóa.
- Xóa là xóa khỏi danh mục (`deleted_at`), giữ nguyên các khóa liên kết và lịch sử mượn trả. Tài nguyên còn khoản mượn, yêu cầu chờ xử lý hoặc lịch phòng đang hiệu lực sẽ bị chặn xóa. Có thể dùng Đã ẩn trong thời gian xử lý.
- Lịch sử và khoản đang mượn của chính sinh viên vẫn có thể xem và trả sau khi ẩn. Đường đọc sách trực tiếp, yêu cầu mới, duyệt và nguồn trợ lý đều kiểm tra hiển thị ở máy chủ. Bộ học liệu cũ có sách bị ẩn được yêu cầu tạo lại.

## Hình ảnh

Đã nhập 16 ảnh bìa từ thư mục Desktop do người dùng chỉ định, đối chiếu tên sách chính xác sau chuẩn hóa dấu. Không thay ảnh tự chọn đã tồn tại. Bản gốc được giữ nguyên. 9 phòng và 9 thiết bị có ảnh minh họa theo loại tài nguyên. Ảnh minh họa không khẳng định là ảnh thực tế hoặc đúng mẫu thiết bị tại trường.

Trong biểu mẫu quản trị có chọn ảnh, xem trước, gỡ ảnh và nhãn Ảnh minh họa. Thay ảnh tự động bỏ chọn nhãn để dùng ảnh thật; có thể chọn lại khi tải ảnh minh họa khác. JPG, PNG, WebP, tối đa 2 MB / 8000 px. Máy chủ kiểm tra nội dung ảnh, không nhận SVG. Đường dẫn tải lên dùng tên ngẫu nhiên; không xóa file cũ để tránh làm mất nguồn ảnh được tham chiếu.

Nguồn, tác giả, giấy phép và ánh xạ từng tài nguyên nằm trong `resource-image-import.json`; nguồn cũng được nhúng trong metadata của 25 file ảnh. Ảnh minh họa lấy từ Unsplash/Pexels theo giấy phép tương ứng ghi trong manifest.

## Cài đặt / khôi phục

Cơ sở dữ liệu cũ: chạy `php scripts/migrate-resource-visibility.php --check`, sau đó `--apply`. Migration tự sao lưu đầy đủ DB và mã nguồn app/public/database trước khi thêm cột. Các dòng cũ mặc định Hiện. Schema mới đã chứa các cột.

Bản sao lưu trước thay đổi trên máy phát triển: `E:/Dell Gaming/resource-center-backups/visibility-20261104-083435-8f9c1f/database.sql`; mã nguồn cũ ở thư mục `source` cùng cấp. Khi khôi phục phải chọn rõ database đích trước khi nhập SQL; không nhập nhầm vào DB đang dùng.

`prepare-resource-images.py` và `prepare-equipment-images.py` chuẩn bị asset; `php scripts/import-resource-images.php` kiểm tra ảnh rồi gắn vào DB theo manifest, giữ ảnh tùy chỉnh hiện có. Không chạy lại các script chuẩn bị nếu không cần tái nhập nguồn.

## Kiểm tra

- `tests/regression.cjs`: phân quyền/CSRF, CRUD, phiên bản, ảnh tải lên, duyệt đồng thời, mượn trả, ba vai trò desktop.
- `tests/resource-visibility.cjs`: ẩn bốn loại tài nguyên, số bản có thể mượn, đường đọc trực tiếp, chặn duyệt ẩn, quyền xóa, xóa giữ lịch sử, chặn xóa đang mượn, phiên bản cũ, ảnh thêm/gỡ và thao tác trình duyệt.
- Chỉ chạy các bài kiểm tra ghi dữ liệu với `NEXUS_DB_NAME=resource_center_test_<digits>`. `tests/clone-visibility.php <tên DB test mới>` tạo bản sao cô lập, từ chối tên không phải test hoặc DB đã tồn tại.
- `scripts/resource-gallery-check.cjs` kiểm tra ảnh, tràn ngang và lỗi JavaScript trên web đang chạy, chụp các trang ở 1024/1440/1920 px; không ghi dữ liệu tài nguyên. Bằng chứng: `.impeccable/review/resources/`.
