USE resource_center;

-- Bo sung thiet bi va dung cu phuc vu hoc tap, thuc hanh va giang day.
INSERT INTO equipment (
    name, equipment_type, manufacturer, description, usage_guide,
    total_quantity, available_quantity, storage_location, serial_number, status
)
SELECT
    'Laptop học tập Dell Latitude 5440',
    'Thiết bị máy tính',
    'Dell',
    'Laptop dùng cho bài giảng, thực hành lập trình và làm đồ án.',
    'Đăng nhập bằng tài khoản được cấp, sạc pin sau khi sử dụng và bàn giao đúng nơi quy định.',
    8, 8, 'Kho thiết bị 01', 'DL-5440-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM equipment WHERE name = 'Laptop học tập Dell Latitude 5440'
);

INSERT INTO equipment (
    name, equipment_type, manufacturer, description, usage_guide,
    total_quantity, available_quantity, storage_location, serial_number, status
)
SELECT
    'Bộ kit mạng Cisco thực hành',
    'Thiết bị mạng',
    'Cisco',
    'Bộ thiết bị mô phỏng mạng gồm router, switch và phụ kiện kết nối.',
    'Tắt nguồn trước khi thay đổi dây nối, kiểm tra sơ đồ mạng trước khi cấu hình.',
    6, 6, 'Kho thí nghiệm 01', 'CISCO-LAB-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM equipment WHERE name = 'Bộ kit mạng Cisco thực hành'
);

INSERT INTO equipment (
    name, equipment_type, manufacturer, description, usage_guide,
    total_quantity, available_quantity, storage_location, serial_number, status
)
SELECT
    'Bộ cảm biến IoT ESP32',
    'Bộ thí nghiệm IoT',
    'Espressif',
    'Bộ mạch ESP32 và cảm biến dùng cho bài thực hành Internet of Things.',
    'Cấp nguồn đúng điện áp, kiểm tra sơ đồ chân trước khi kết nối cảm biến.',
    8, 8, 'Kho thí nghiệm 02', 'ESP32-IOT-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM equipment WHERE name = 'Bộ cảm biến IoT ESP32'
);

INSERT INTO equipment (
    name, equipment_type, manufacturer, description, usage_guide,
    total_quantity, available_quantity, storage_location, serial_number, status
)
SELECT
    'Bảng vẽ điện tử Wacom',
    'Dụng cụ giảng dạy',
    'Wacom',
    'Bảng vẽ điện tử hỗ trợ giảng viên trình bày và minh họa trực tuyến.',
    'Kết nối USB trước khi mở phần mềm, cất bút vào hộp sau khi sử dụng.',
    4, 4, 'Kho thiết bị 01', 'WACOM-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM equipment WHERE name = 'Bảng vẽ điện tử Wacom'
);

INSERT INTO equipment (
    name, equipment_type, manufacturer, description, usage_guide,
    total_quantity, available_quantity, storage_location, serial_number, status
)
SELECT
    'Bộ breadboard và linh kiện điện tử',
    'Dụng cụ điện tử',
    'PTIT Lab',
    'Bộ breadboard, dây nối, điện trở, LED và linh kiện phục vụ thực hành mạch điện.',
    'Ngắt nguồn trước khi thay đổi mạch, phân loại linh kiện và trả đủ sau khi dùng.',
    12, 12, 'Kho thí nghiệm 02', 'ELEC-KIT-01', 'available'
WHERE NOT EXISTS (
    SELECT 1 FROM equipment WHERE name = 'Bộ breadboard và linh kiện điện tử'
);
