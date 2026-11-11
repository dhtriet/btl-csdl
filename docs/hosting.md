# Triển khai Nexus trên Render

Web chính: [btl-csdl-onqi.onrender.com](https://btl-csdl-onqi.onrender.com/). Render lấy mã nguồn từ nhánh `main` của [dhtriet/btl-csdl](https://github.com/dhtriet/btl-csdl), build Docker PHP 8.2/Apache, document root `/var/www/html/public`.

## Cấu hình server

Các biến kết nối MySQL/MariaDB: `NEXUS_DB_HOST`, `NEXUS_DB_PORT`, `NEXUS_DB_NAME`, `NEXUS_DB_USER`, `NEXUS_DB_PASS`. Khóa trợ lý do server giữ trong `GROQ_API_KEY`; không đưa khóa vào frontend, Markdown hoặc ảnh minh họa. `app/config.php` trong Git chỉ đọc biến môi trường.

CSDL được cung cấp riêng trên Alwaysdata. Quá trình triển khai Render không nạp seed hoặc ghi đè bằng database localhost.

## Nâng cấp nghiệp vụ mượn trả

1. Sao lưu CSDL hosting và chuẩn bị các tệp của phiên bản mới.
2. Chạy `php scripts/migrate-circulation.php --check` với cấu hình database hosting, sau đó `--apply` khi triển khai phiên bản này. Runner tạo snapshot riêng trước DDL và có thể chạy lại an toàn. Tệp `database/schema.sql` dành cho khởi tạo mới và có DROP TABLE; không chạy nó lên database đang có dữ liệu.
3. Xác minh đủ bảng/cột/ràng buộc. Số dư chưa rõ nguyên nhân được đưa vào nhóm không khả dụng chờ kiểm kê; liên kết phiếu cũ chỉ khôi phục khi có bằng chứng duy nhất.
4. Push mã nguồn lên GitHub, triển khai commit đó trên Render và kiểm tra phiên bản Live.
5. Kiểm tra đăng nhập ba vai trò, danh mục, hồ sơ admin, đối soát, truy vết và trạng thái PDF/trợ lý. Kiểm thử có ghi dữ liệu phải dùng CSDL test riêng.

Schema mới có 26 bảng. [Từ điển](database-schema.md) và [ERD](database-erd.mmd) được sinh từ cùng metadata bằng `php scripts/document-schema.php`. [Tài liệu chuẩn hóa](normalization.md) ghi rõ các thuộc tính suy diễn và phi chuẩn hóa được kiểm soát.

## PDF và chỉ mục trợ lý

PDF riêng được phục hồi lúc container khởi động bằng `scripts/restore-ebooks.py`, với hai biến bí mật `NEXUS_EBOOK_BUNDLE_URL` và `NEXUS_EBOOK_BUNDLE_TOKEN`. Nguồn archive nằm trên Alwaysdata, xác thực bằng Bearer token, ngoài document root. Không thêm PDF hay token vào GitHub.

`scripts/docker-start.sh` tải PDF trước khi mở Apache rồi khôi phục/lập chỉ mục ở nền. Archive chứa 13 PDF cùng chỉ mục đã chuẩn bị; khi thêm sách cần cập nhật archive nguồn và ánh xạ chỉ mục. Lịch sử chat và upload phát sinh trên filesystem Render cần lưu trữ bền vững để giữ qua lần tạo lại container.

`.dockerignore` loại các cấu hình riêng, cache, phiên và PDF khỏi Docker build cục bộ. Git chứa mã nguồn, dữ liệu demo SQL và các ảnh tài nguyên được chọn; ảnh README nằm trong `docs/images`.

## Kiểm thử

`tests/circulation.py` kiểm tra API và tranh chấp thiết bị cuối qua hai server độc lập. `tests/schema-circulation.php` kiểm tra khởi tạo, migration chạy lại và FK/UNIQUE/CHECK. `tests/circulation-ui.cjs` kiểm tra thứ tự phản hồi bất đồng bộ. Xem [hướng dẫn](../tests/README.md).
