# Sinh viên yêu cầu gia hạn, thủ thư xét duyệt

- Sinh viên mở **Đang mượn & lịch sử**, chọn **Gia hạn** ở khoản mượn sách chưa trả, chọn hạn đề nghị và có thể ghi lý do.
- Gửi yêu cầu tạo bản ghi `extension_requests` ở trạng thái `pending`. Hạn trả và số lần gia hạn chưa thay đổi. Sinh viên xem được yêu cầu của chính mình.
- Thủ thư mở **Mượn & trả → Yêu cầu gia hạn tài nguyên → Xem yêu cầu**, duyệt theo ngày sinh viên đề nghị hoặc từ chối kèm lý do. Thủ thư không tự nhập một ngày gia hạn khác, không tự tạo yêu cầu thay sinh viên.
- Duyệt tạo bản ghi `extensions`, liên kết qua `extension_requests.extension_id`, cập nhật hạn trả và tăng số lần trong cùng transaction. Từ chối chỉ cập nhật kết quả xét duyệt.
- Admin xem được danh sách, không gửi hoặc duyệt thay hai vai trò trên.

Mỗi khoản mượn chỉ có một yêu cầu chờ duyệt (UNIQUE trên khóa sinh từ trạng thái pending). Khóa dòng khoản mượn và yêu cầu ngăn duyệt hai lần. Hệ thống kiểm tra lại khi xét duyệt: sách chưa trả, hạn cũ chưa thay đổi, ngày đề nghị chưa qua và số lần gia hạn đã duyệt còn dưới 3. Hạn đề nghị phải sau hạn hiện tại, từ hôm nay trở đi. Sách quá hạn vẫn có thể gửi yêu cầu; quyền chấp thuận thuộc thủ thư. Thiết bị và không gian cũng có luồng gửi yêu cầu → thủ thư xét duyệt, mô tả dưới đây.

Yêu cầu chờ duyệt của sách vừa trả vẫn được giữ để truy vết, không thể duyệt; thủ thư từ chối với lý do “Sách đã trả”. Các lần gia hạn trực tiếp cũ trong `extensions` được giữ nguyên như dữ liệu lịch sử, không tạo giả yêu cầu sinh viên cho các bản ghi đó.

## Nâng cấp

Với database cũ, cấu hình `NEXUS_DB_*`, chạy `php scripts/migrate-extension-requests.php --check`, rồi `--apply`. Runner sao lưu toàn bộ database trước DDL, có thể chạy lại. Không chạy schema/seed ghi đè database cũ. Schema khởi tạo mới đã có bảng này (tổng 27 bảng).

API cũ `POST /api/loan-details/{id}/extend` trả 403. API mới dùng CSRF và kiểm tra vai trò/quyền sở hữu:

| API | Quyền |
|---|---|
| GET `/api/extension-requests` | Sinh viên xem của mình; thủ thư/admin xem toàn bộ |
| POST `/api/extension-requests` | Sinh viên, `loan_detail_id`, `new_due_date`, `reason` |
| POST `/api/extension-requests/{id}/review` | Thủ thư, `status` approved/rejected, `review_note` |

Kiểm thử HTTP trong `tests/extension-requests.py` chỉ chạy với database riêng có tên `resource_center_test_<chữ số>`, không chạy trên database người dùng/hosting.


## Gia hạn thiết bị và không gian

- Thiết bị: sinh viên chọn **Gia hạn** ở khoản thiết bị trong **Đang mượn & lịch sử**, chọn ngày trả mới. Chỉ cập nhật `equipment_loan_details.due_date` khi được duyệt; số lượng tồn và số lượng đang mượn giữ nguyên.
- Không gian: vào **Không gian → Lịch phòng của bạn · Gia hạn** hoặc **Đang mượn & lịch sử → Không gian đang sử dụng**. Chọn giờ kết thúc mới trong cùng ngày, tối đa 24:00. Lịch phải đã duyệt và chưa hết giờ/kết thúc.
- Thủ thư xét cả ba loại trong **Mượn & trả → Yêu cầu gia hạn tài nguyên**. Từ chối cần ghi lý do; admin chỉ xem. Mỗi khoản có tối đa một yêu cầu chờ và ba lần được duyệt.
- Bảng `resource_extension_requests` lưu một trong hai FK `equipment_detail_id` / `room_request_id` (CHECK đúng một FK), hạn cũ/mới, lý do và người/thời điểm xử lý. UNIQUE khóa sinh bảo vệ một yêu cầu pending cho từng khoản. Với phòng kết thúc 24:00, DATETIME lưu 00:00 ngày kế tiếp, lịch gốc giữ TIME 24:00.
- Hệ thống khóa khoản mượn/lịch trước khi xử lý. Phòng còn phải khóa tài nguyên và kiểm tra trùng lịch đã duyệt ở cả lúc gửi lẫn lúc duyệt. Thiết bị đã trả, lịch đã kết thúc, hạn bị thay đổi đều không thể được duyệt; thủ thư vẫn có thể từ chối yêu cầu để giữ truy vết.
- Nâng cấp database cũ: `php scripts/migrate-resource-extensions.php --apply` (sao lưu trước DDL, chạy lại an toàn). Không import schema/seed vào dữ liệu đang dùng.

| API | Quyền / nội dung |
|---|---|
| GET `/api/resource-extension-requests` | Sinh viên xem riêng; thủ thư/admin xem toàn bộ |
| POST `/api/resource-extension-requests` | Sinh viên: `resource_type` equipment/room, `target_id`, `new_due_date` hoặc `new_end_time`, `reason` |
| POST `/api/resource-extension-requests/{id}/review` | Thủ thư: `status` approved/rejected, `review_note` |

GET `/api/extension-requests` trả danh sách tổng hợp; yêu cầu sách giữ API duyệt cũ, thiết bị/phòng dùng API riêng để không nhầm ID. Kiểm thử mới: `tests/resource-extensions.py` (database riêng).
