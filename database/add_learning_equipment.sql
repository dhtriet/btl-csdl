USE resource_center;

-- Bo sung thiet bi va dung cu phuc vu hoc tap, thuc hanh va giang day.
INSERT INTO thiet_bi (
    ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung,
    tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai
)
SELECT
    'Laptop học tập Dell Latitude 5440',
    'Thiết bị máy tính',
    'Dell',
    'Laptop dùng cho bài giảng, thực hành lập trình và làm đồ án.',
    'Đăng nhập bằng tài khoản được cấp, sạc pin sau khi sử dụng và bàn giao đúng nơi quy định.',
    8, 8, 'Kho thiết bị 01', 'DL-5440-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM thiet_bi WHERE ten = 'Laptop học tập Dell Latitude 5440'
);

INSERT INTO thiet_bi (
    ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung,
    tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai
)
SELECT
    'Bộ kit mạng Cisco thực hành',
    'Thiết bị mạng',
    'Cisco',
    'Bộ thiết bị mô phỏng mạng gồm router, switch và phụ kiện kết nối.',
    'Tắt nguồn trước khi thay đổi dây nối, kiểm tra sơ đồ mạng trước khi cấu hình.',
    6, 6, 'Kho thí nghiệm 01', 'CISCO-LAB-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM thiet_bi WHERE ten = 'Bộ kit mạng Cisco thực hành'
);

INSERT INTO thiet_bi (
    ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung,
    tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai
)
SELECT
    'Bộ cảm biến IoT ESP32',
    'Bộ thí nghiệm IoT',
    'Espressif',
    'Bộ mạch ESP32 và cảm biến dùng cho bài thực hành Internet of Things.',
    'Cấp nguồn đúng điện áp, kiểm tra sơ đồ chân trước khi kết nối cảm biến.',
    8, 8, 'Kho thí nghiệm 02', 'ESP32-IOT-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM thiet_bi WHERE ten = 'Bộ cảm biến IoT ESP32'
);

INSERT INTO thiet_bi (
    ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung,
    tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai
)
SELECT
    'Bảng vẽ điện tử Wacom',
    'Dụng cụ giảng dạy',
    'Wacom',
    'Bảng vẽ điện tử hỗ trợ giảng viên trình bày và minh họa trực tuyến.',
    'Kết nối USB trước khi mở phần mềm, cất bút vào hộp sau khi sử dụng.',
    4, 4, 'Kho thiết bị 01', 'WACOM-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM thiet_bi WHERE ten = 'Bảng vẽ điện tử Wacom'
);

INSERT INTO thiet_bi (
    ten, loai_thiet_bi, hang_san_xuat, mo_ta, huong_dan_su_dung,
    tong_so_luong, so_luong_san_sang, vi_tri_luu_tru, so_se_ri, trang_thai
)
SELECT
    'Bộ breadboard và linh kiện điện tử',
    'Dụng cụ điện tử',
    'PTIT Lab',
    'Bộ breadboard, dây nối, điện trở, LED và linh kiện phục vụ thực hành mạch điện.',
    'Ngắt nguồn trước khi thay đổi mạch, phân loại linh kiện và trả đủ sau khi dùng.',
    12, 12, 'Kho thí nghiệm 02', 'ELEC-KIT-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM thiet_bi WHERE ten = 'Bộ breadboard và linh kiện điện tử'
);
