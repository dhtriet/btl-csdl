# Sinh viên yêu cầu gia hạn, thủ thư xét duyệt

- Sinh viên mở **Đang mượn & lịch sử**, chọn **Gia hạn** ở khoản mượn sách chưa trả, chọn hạn đề nghị và có thể ghi lý do.
- Gửi yêu cầu tạo bản ghi `extension_requests` ở trạng thái `pending`. Hạn trả và số lần gia hạn chưa thay đổi. Sinh viên xem được yêu cầu của chính mình.
- Thủ thư mở **Mượn & trả → Yêu cầu gia hạn sách → Xem yêu cầu**, duyệt theo ngày sinh viên đề nghị hoặc từ chối kèm lý do. Thủ thư không tự nhập một ngày gia hạn khác, không tự tạo yêu cầu thay sinh viên.
- Duyệt tạo bản ghi `extensions`, liên kết qua `extension_requests.extension_id`, cập nhật hạn trả và tăng số lần trong cùng transaction. Từ chối chỉ cập nhật kết quả xét duyệt.
- Admin xem được danh sách, không gửi hoặc duyệt thay hai vai trò trên.

Mỗi khoản mượn chỉ có một yêu cầu chờ duyệt (UNIQUE trên khóa sinh từ trạng thái pending). Khóa dòng khoản mượn và yêu cầu ngăn duyệt hai lần. Hệ thống kiểm tra lại khi xét duyệt: sách chưa trả, hạn cũ chưa thay đổi, ngày đề nghị chưa qua và số lần gia hạn đã duyệt còn dưới 3. Hạn đề nghị phải sau hạn hiện tại, từ hôm nay trở đi. Sách quá hạn vẫn có thể gửi yêu cầu; quyền chấp thuận thuộc thủ thư. Thiết bị chưa có nghiệp vụ gia hạn trong phạm vi này.

Yêu cầu chờ duyệt của sách vừa trả vẫn được giữ để truy vết, không thể duyệt; thủ thư từ chối với lý do “Sách đã trả”. Các lần gia hạn trực tiếp cũ trong `extensions` được giữ nguyên như dữ liệu lịch sử, không tạo giả yêu cầu sinh viên cho các bản ghi đó.

## Nâng cấp

Với database cũ, cấu hình `NEXUS_DB_*`, chạy `php scripts/migrate-extension-requests.php --check`, rồi `--apply`. Runner sao lưu toàn bộ database trước DDL, có thể chạy lại. Không chạy schema/seed ghi đè database cũ. Schema khởi tạo mới đã có bảng này (tổng 26 bảng).

API cũ `POST /api/loan-details/{id}/extend` trả 403. API mới dùng CSRF và kiểm tra vai trò/quyền sở hữu:

| API | Quyền |
|---|---|
| GET `/api/extension-requests` | Sinh viên xem của mình; thủ thư/admin xem toàn bộ |
| POST `/api/extension-requests` | Sinh viên, `loan_detail_id`, `new_due_date`, `reason` |
| POST `/api/extension-requests/{id}/review` | Thủ thư, `status` approved/rejected, `review_note` |

Kiểm thử HTTP trong `tests/extension-requests.py` chỉ chạy với database riêng có tên `resource_center_test_<chữ số>`, không chạy trên database người dùng/hosting.
