# Ảnh danh mục tài nguyên

Bộ lọc ngôn ngữ hiển thị **Tiếng Anh**, giữ giá trị `English` để khớp dữ liệu trong CSDL.

Ảnh phòng học và thiết bị là ảnh minh họa, có nhãn trên giao diện; không đại diện cho ảnh chụp thực tế của phòng hay cấu hình thiết bị trong trường. Mỗi tài nguyên đang hiển thị có ảnh riêng. Các bìa sách có sẵn do người dùng cung cấp được giữ nguyên.

## Bổ sung ngày 11/11/2026

- *An Introduction to Database Systems*: bìa ấn bản 1977, [Open Library OL4907372M](https://openlibrary.org/books/OL4907372M).
- *Principles of Database Systems*: ảnh ấn bản 1980, [Open Library OL4416137M](https://openlibrary.org/books/OL4416137M).
- *E-marketing*: trích nguyên trang bìa đầu tiên từ PDF 2013 có trong dự án.
- Phòng dữ liệu: [Tuấn Nguyễn Văn — phòng máy tính](https://www.pexels.com/photo/computer-classroom-with-focused-students-35571660/).
- Phòng 102 A3: [Pavel Danilyuk — lớp học ghế đỏ](https://www.pexels.com/photo/desks-and-chairs-in-a-classroom-8423439/).
- Phòng 402 A2: [Mikhail Nilov — lớp học và giá sách](https://www.pexels.com/photo/an-empty-classroom-6981007/).
- Phòng 401 A2: [Katerina Holmes — bàn học và bảng trắng](https://www.pexels.com/photo/school-bench-with-stationery-in-classroom-5905445/).
- Phòng 304 A3: [Giảng đường ghế xanh](https://www.pexels.com/photo/modern-empty-lecture-hall-with-blue-seats-36834057/).
- Phòng 701 A2: [Không gian hội thảo](https://www.pexels.com/photo/empty-conference-room-16859956/).
- Phòng 501 A2: [Phòng họp có cửa sổ](https://www.pexels.com/photo/empty-conference-room-8102300/).
- Breadboard: [Electronic Parts and Wires](https://www.pexels.com/photo/electronic-parts-and-wires-11447064/).

Các ảnh Pexels được tải về, giữ nguyên nội dung, dùng theo [Pexels License](https://www.pexels.com/license/).

ESP32: **Edwiyanto**, [ESP32 Dev Board.jpg](https://commons.wikimedia.org/wiki/File:ESP32_Dev_Board.jpg), [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Sử dụng nguyên thumbnail 500px từ Wikimedia; không sửa nội dung ảnh. Giấy phép này áp dụng cho ảnh ESP32, không áp đặt giấy phép cho mã nguồn ứng dụng.

## Áp dụng vào database hiện có

Danh sách đường dẫn, nguồn ảnh, mã tài nguyên và ảnh cũ được lưu trong `unique-resource-images.json`. Chạy với kết nối `NEXUS_DB_*` của môi trường cần cập nhật:

```sh
php scripts/apply-unique-resource-images.php --check
php scripts/apply-unique-resource-images.php --apply
```

Script sao lưu database trước khi ghi, kiểm tra đúng mã và tên tài nguyên, chỉ thay ảnh mẫu cũ hoặc ảnh còn trống. Chạy lại không ghi đè ảnh quản trị viên đã thay. Bản khởi tạo mới tiếp tục dùng `scripts/import-resource-images.php` với manifest tổng `resource-image-import.json` đã cập nhật.
