# Bản web online

## Render: PDF và chỉ mục trợ lý

Render chạy Docker từ GitHub. Các PDF riêng được phục hồi lúc khởi động bằng
`scripts/restore-ebooks.py`, với hai biến môi trường bí mật:
`NEXUS_EBOOK_BUNDLE_URL` và `NEXUS_EBOOK_BUNDLE_TOKEN`.
Nguồn hiện tại nằm trên Alwaysdata, yêu cầu Bearer token; archive và token nằm
ngoài document root. Không thêm PDF hoặc token vào GitHub.

`scripts/docker-start.sh` tải PDF trước khi mở Apache, sau đó lập chỉ mục ở nền.
Trạng thái `pending` nghĩa là PDF đã có nhưng chỉ mục chưa hoàn tất. Khi container
Free được tạo lại, quá trình này chạy lại. Nguồn archive hiện chứa 13 PDF; khi
thêm sách mới cần cập nhật archive nguồn. Lịch sử chat trên filesystem Render
chưa có lưu trữ bền vững.

URL: https://csdl.alwaysdata.net/

Ứng dụng chạy trên gói Alwaysdata Free của tài khoản hosting `csdl`, với PHP 8.4,
Python 3 và MariaDB 11.8. Đây là địa chỉ con do hosting cấp; không cần giữ máy cá
nhân bật để website hoạt động.

## Triển khai

- Source ở `/home/csdl/nexus`; document root phải là `/home/csdl/nexus/public/`.
- `public/.htaccess` chuyển các URL API tới `index.php`; file tĩnh được phục vụ trực tiếp.
- Database riêng: `csdl_nexus`. Khởi tạo từ schema/seed demo, không đưa database local lên.
- PDF ở `storage/ebooks`, ngoài document root, chỉ đọc qua endpoint kiểm tra đăng nhập.
- Ảnh bìa và ảnh minh họa được giữ từ source và áp dụng theo manifest.
- HTTP tự chuyển HTTPS. Cookie phiên dùng Secure, HttpOnly và SameSite=Lax.

## Thông tin riêng

Mật khẩu kết nối không nằm trong Git. Trên hosting, `app/config.php` đọc cấu hình
riêng trong `storage/database.json`; file này chỉ chủ tài khoản đọc được.

Tài khoản online dùng mật khẩu riêng thay cho mật khẩu demo công khai. Thông tin
truy cập lưu cục bộ tại `.deploy/website-logins.json`, bị Git bỏ qua. Database và
tài khoản local giữ nguyên.

SSH dùng khóa triển khai riêng trên máy đã được chủ tài khoản cho phép. Chỉ public
key được thêm vào Alwaysdata; private key không tải lên hosting hoặc GitHub.

## Trợ lý học tập

Python và thư viện đọc PDF đã được cài trên hosting. Chưa sao chép khóa API AI từ
máy local lên; AI vẫn ở trạng thái chưa cấu hình. Chủ tài khoản có thể thêm cấu
hình riêng `storage/ai-config.json` trên hosting để bật, dùng `python3` thay cho
đường dẫn Python Windows. Không commit file này vào Git.

## Kiểm tra sau triển khai

Đã xác minh HTTPS, chuyển hướng HTTP, đăng nhập ba vai trò, dashboard, danh mục,
phòng, thiết bị và trạng thái trợ lý qua API. Kiểm tra trình duyệt xác nhận giao
diện online và đăng nhập hoạt động. Tệp cấu hình riêng và dữ liệu chạy không được
đưa vào repository.
