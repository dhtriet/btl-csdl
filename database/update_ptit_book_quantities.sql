USE resource_center;

-- Tao so luong ban sao khac nhau cho 10 giao trinh PTIT.
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-02', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-03', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-WEB-2018-04', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Xây dựng Website thương mại điện tử'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-WEB-2018-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-02', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-03', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-04', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-04');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-05', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-05');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-EMARKETING-2013-06', 'Kệ J1', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'E-marketing (Marketing trực tuyến)'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-EMARKETING-2013-06');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATTT-2018-02', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Cơ sở an toàn thông tin'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATTT-2018-02');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-02', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-03', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-DH-2018-04', 'Kệ J2', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Giáo trình Kỹ thuật đồ họa'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-DH-2018-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-KTVM-2013-02', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Kinh tế vi mô 1'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-KTVM-2013-02');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-02', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-03', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATHDH-2017-04', 'Kệ J3', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn hệ điều hành'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATHDH-2017-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-02', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-03', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-04', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-04');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-05', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-05');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-CNPM-2016-06', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Nhập môn Công nghệ phần mềm'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-CNPM-2016-06');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-BMHTTT-2017-02', 'Kệ J4', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn và bảo mật hệ thống thông tin'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-BMHTTT-2017-02');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-02', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-02');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-03', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-03');
INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-ATWEB-2017-04', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'An toàn ứng dụng web và cơ sở dữ liệu'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-ATWEB-2017-04');

INSERT INTO ban_sach (ma_dau_sach, ma_vach, vi_tri_luu_tru, tinh_trang, trang_thai)
SELECT b.ma, 'PTIT-GIAUTIN-2018-02', 'Kệ J5', 'good', 'available' FROM dau_sach b
WHERE b.ten_sach = 'Bài giảng Các kỹ thuật giấu tin'
  AND NOT EXISTS (SELECT 1 FROM ban_sach WHERE ma_vach = 'PTIT-GIAUTIN-2018-02');
