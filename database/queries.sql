USE resource_center;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Read-only examples. In PHP, bind these values with PDO placeholders.
SET @book_search = '%PHP%';
SET @use_date = CURDATE();
SET @start_time = '09:00:00';
SET @end_time = '11:00:00';

-- Public discovery filters visible/non-deleted resources.
-- Loan/request history deliberately keeps hidden and deleted resource references.

-- 1. Tim kiem va loc sach theo nhieu dieu kien.
SELECT b.id, b.title, b.language, b.publication_year,
       p.name AS publisher,
       (
           SELECT GROUP_CONCAT(DISTINCT a.full_name ORDER BY a.full_name SEPARATOR ', ')
           FROM book_authors ba
           JOIN authors a ON a.id = ba.author_id
           WHERE ba.book_id = b.id
       ) AS authors,
       (
           SELECT GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ')
           FROM book_genres bg
           JOIN genres g ON g.id = bg.genre_id
           WHERE bg.book_id = b.id
       ) AS genres
FROM books b
JOIN publishers p ON p.id = b.publisher_id
WHERE b.title LIKE @book_search
  AND b.is_visible = 1
  AND b.deleted_at IS NULL
ORDER BY b.id DESC;

-- 2. Liet ke sach da tra, ke ca sach tra tre.
SELECT b.title, s.student_code, ld.borrow_date, ld.due_date, ld.return_date,
       CASE WHEN ld.return_status = 'late' THEN 'Tra tre'
            WHEN ld.return_status = 'on_time' THEN 'Tra dung han'
            WHEN ld.return_date > ld.due_date THEN 'Tra tre' ELSE 'Tra dung han' END AS return_status,
       CASE WHEN ld.return_status = 'late' THEN ld.late_days
            ELSE GREATEST(DATEDIFF(ld.return_date, ld.due_date), 0) END AS late_days
FROM loan_details ld
JOIN loan_receipts lr ON lr.id = ld.receipt_id
JOIN students s ON s.id = lr.student_id
JOIN book_copies c ON c.id = ld.copy_id
JOIN books b ON b.id = c.book_id
WHERE ld.return_date IS NOT NULL;

-- 3. Sach dang qua han, moi dong la mot cuon trong chi tiet phieu.
SELECT b.title, s.student_code, ld.due_date,
       DATEDIFF(CURDATE(), ld.due_date) AS overdue_days
FROM loan_details ld
JOIN loan_receipts lr ON lr.id = ld.receipt_id
JOIN students s ON s.id = lr.student_id
JOIN book_copies c ON c.id = ld.copy_id
JOIN books b ON b.id = c.book_id
WHERE ld.return_date IS NULL AND ld.due_date < CURDATE()
ORDER BY overdue_days DESC;

-- 4. Phong trong trong khoang thoi gian.
SELECT r.id, r.name, r.room_type, r.location, r.capacity,
       r.included_equipment, r.operating_hours
FROM rooms r
WHERE r.status = 'available'
  AND r.is_visible = 1
  AND r.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM room_requests rr
      WHERE rr.room_id = r.id
        AND rr.use_date = @use_date
        AND rr.status IN ('pending', 'approved')
        AND rr.start_time < @end_time
        AND rr.end_time > @start_time
  );

-- 5. Sach duoc muon nhieu nhat.
SELECT b.title, COUNT(ld.id) AS borrow_count
FROM books b
JOIN book_copies c ON c.book_id = b.id
JOIN loan_details ld ON ld.copy_id = c.id
WHERE b.is_visible = 1
  AND b.deleted_at IS NULL
GROUP BY b.id, b.title
ORDER BY borrow_count DESC;

-- 6. Sinh vien co sach hoac thiet bi qua han.
SELECT s.student_code, a.full_name,
       COALESCE(book_counts.book_overdue, 0) AS overdue_books,
       COALESCE(equipment_counts.equipment_overdue, 0) AS overdue_equipment
FROM students s
JOIN accounts a ON a.id = s.account_id
LEFT JOIN (
    SELECT lr.student_id, COUNT(*) AS book_overdue
    FROM loan_receipts lr JOIN loan_details ld ON ld.receipt_id = lr.id
    WHERE ld.return_date IS NULL AND ld.due_date < CURDATE()
    GROUP BY lr.student_id
) book_counts ON book_counts.student_id = s.id
LEFT JOIN (
    SELECT el.student_id, COUNT(*) AS equipment_overdue
    FROM equipment_loans el JOIN equipment_loan_details eld ON eld.loan_id = el.id
    WHERE eld.return_date IS NULL AND eld.due_date < CURDATE()
    GROUP BY el.student_id
) equipment_counts ON equipment_counts.student_id = s.id
WHERE book_counts.book_overdue IS NOT NULL OR equipment_counts.equipment_overdue IS NOT NULL;

-- 7. Danh sach yeu cau muon sach dang cho thu thu duyet.
SELECT r.id AS request_id, s.student_code, a.full_name,
       GROUP_CONCAT(CONCAT(b.title, ' - han ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y')) ORDER BY i.id SEPARATOR '; ') AS requested_books,
       r.requested_at, r.note
FROM book_loan_requests r
JOIN students s ON s.id = r.student_id
JOIN accounts a ON a.id = s.account_id
JOIN book_loan_request_items i ON i.request_id = r.id
JOIN books b ON b.id = i.book_id
WHERE r.status = 'pending'
GROUP BY r.id, s.student_code, a.full_name, r.requested_at, r.note
ORDER BY r.requested_at;

-- 8. Danh sach yeu cau muon thiet bi dang cho thu thu duyet.
SELECT r.id AS request_id, s.student_code, a.full_name,
       GROUP_CONCAT(CONCAT(e.name, ' x', i.quantity, ' - han ', DATE_FORMAT(i.requested_due_date, '%d/%m/%Y')) ORDER BY i.id SEPARATOR '; ') AS requested_equipment,
       r.requested_at, r.note
FROM equipment_loan_requests r
JOIN students s ON s.id = r.student_id
JOIN accounts a ON a.id = s.account_id
JOIN equipment_loan_request_items i ON i.request_id = r.id
JOIN equipment e ON e.id = i.equipment_id
WHERE r.status = 'pending'
GROUP BY r.id, s.student_code, a.full_name, r.requested_at, r.note
ORDER BY r.requested_at;

-- 9. Danh sach yeu cau dat phong dang cho thu thu duyet.
SELECT rr.id AS request_id, s.student_code, a.full_name, r.name AS room_name,
       rr.use_date, rr.start_time, rr.end_time, rr.purpose, rr.created_at
FROM room_requests rr
JOIN students s ON s.id = rr.student_id
JOIN accounts a ON a.id = s.account_id
JOIN rooms r ON r.id = rr.room_id
WHERE rr.status = 'pending'
ORDER BY rr.use_date, rr.start_time;

-- 10. Lich su cac yeu cau da duoc thu thu xu ly.
SELECT 'Muon sach' AS request_type, r.id AS request_id, s.student_code,
       a.full_name AS student_name, r.status, r.reviewed_at,
       la.full_name AS librarian_name, r.review_note,
       GROUP_CONCAT(b.title SEPARATOR '; ') AS resources
FROM book_loan_requests r
JOIN students s ON s.id = r.student_id
JOIN accounts a ON a.id = s.account_id
LEFT JOIN librarians l ON l.id = r.librarian_id
LEFT JOIN accounts la ON la.id = l.account_id
JOIN book_loan_request_items i ON i.request_id = r.id
JOIN books b ON b.id = i.book_id
WHERE r.status IN ('approved', 'rejected')
GROUP BY r.id, s.student_code, a.full_name, r.status, r.reviewed_at, la.full_name, r.review_note
ORDER BY r.reviewed_at DESC;

-- 11. Tai nguyen dang muon de thu thu ghi nhan ngay tra.
SELECT 'Sach' AS resource_type, ld.id AS detail_id, b.title AS resource_name,
       s.student_code, a.full_name AS student_name, ld.due_date,
       CASE WHEN ld.due_date < CURDATE() THEN 'Qua han' ELSE 'Dang muon' END AS loan_status
FROM loan_details ld
JOIN loan_receipts lr ON lr.id = ld.receipt_id
JOIN students s ON s.id = lr.student_id
JOIN accounts a ON a.id = s.account_id
JOIN book_copies c ON c.id = ld.copy_id
JOIN books b ON b.id = c.book_id
WHERE ld.return_date IS NULL
UNION ALL
SELECT 'Thiet bi', eld.id, e.name, s.student_code, a.full_name, eld.due_date,
       CASE WHEN eld.due_date < CURDATE() THEN 'Qua han' ELSE 'Dang muon' END
FROM equipment_loan_details eld
JOIN equipment_loans el ON el.id = eld.loan_id
JOIN equipment e ON e.id = eld.equipment_id
JOIN students s ON s.id = el.student_id
JOIN accounts a ON a.id = s.account_id
WHERE eld.return_date IS NULL;

-- 12. Danh sach da tra va ket qua dung han hay tre han.
SELECT 'Sach' AS resource_type, b.title AS resource_name, s.student_code,
       ld.due_date, ld.return_date,
       CASE WHEN ld.return_status = 'late' THEN 'Tra tre'
            WHEN ld.return_status = 'on_time' THEN 'Tra dung han'
            WHEN ld.return_date > ld.due_date THEN 'Tra tre' ELSE 'Tra dung han' END AS return_status,
       CASE WHEN ld.return_status = 'late' THEN ld.late_days
            ELSE GREATEST(DATEDIFF(ld.return_date, ld.due_date), 0) END AS late_days
FROM loan_details ld
JOIN loan_receipts lr ON lr.id = ld.receipt_id
JOIN students s ON s.id = lr.student_id
JOIN book_copies c ON c.id = ld.copy_id
JOIN books b ON b.id = c.book_id
WHERE ld.return_date IS NOT NULL
UNION ALL
SELECT 'Thiet bi', e.name, s.student_code, eld.due_date, eld.return_date,
       CASE WHEN eld.return_status = 'late' THEN 'Tra tre'
            WHEN eld.return_status = 'on_time' THEN 'Tra dung han'
            WHEN eld.return_date > eld.due_date THEN 'Tra tre' ELSE 'Tra dung han' END,
       CASE WHEN eld.return_status = 'late' THEN eld.late_days
            ELSE GREATEST(DATEDIFF(eld.return_date, eld.due_date), 0) END
FROM equipment_loan_details eld
JOIN equipment_loans el ON el.id = eld.loan_id
JOIN equipment e ON e.id = eld.equipment_id
JOIN students s ON s.id = el.student_id
WHERE eld.return_date IS NOT NULL
ORDER BY return_date DESC;
