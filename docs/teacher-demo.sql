-- Read-only demo queries. Select the intended database in Workbench first.
SET @request_id = 9;
SET @student_code = 'SV001';
SET @barcode = 'PTIT-GIAUTIN-2018-01';

-- 1. Real constraints installed in this database.
SELECT TABLE_NAME,CONSTRAINT_NAME,CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA=DATABASE()
ORDER BY TABLE_NAME,CONSTRAINT_TYPE,CONSTRAINT_NAME;

-- 2. Current inventory buckets and independent consistency calculation.
SELECT e.id,e.name,e.total_quantity,e.available_quantity,
       COALESCE(active.quantity,0) AS on_loan_quantity,e.unavailable_quantity,
       e.total_quantity-e.available_quantity-e.unavailable_quantity-COALESCE(active.quantity,0) AS difference,
       e.inventory_verified_at
FROM equipment e
LEFT JOIN (
    SELECT equipment_id,SUM(quantity) AS quantity
    FROM equipment_loan_details WHERE return_date IS NULL GROUP BY equipment_id
) active ON active.equipment_id=e.id
WHERE e.deleted_at IS NULL ORDER BY e.name;

-- 3. Explicit request -> receipt -> physical copy -> reader path.
SELECT r.id AS request_id,r.source,r.status AS request_status,
       lr.id AS receipt_id,s.student_code,a.full_name,
       b.title,c.barcode,d.borrow_date,d.due_date,d.return_date
FROM book_loan_requests r
JOIN students s ON s.id=r.student_id
JOIN accounts a ON a.id=s.account_id
LEFT JOIN loan_receipts lr ON lr.request_id=r.id
LEFT JOIN loan_details d ON d.receipt_id=lr.id
LEFT JOIN book_copies c ON c.id=d.copy_id
LEFT JOIN books b ON b.id=c.book_id
WHERE r.id=@request_id ORDER BY d.id;

-- 4. Current holder of a physical copy; no row means nobody currently holds it.
SELECT c.barcode,b.title,s.student_code,a.full_name,lr.id AS receipt_id,d.due_date
FROM book_copies c
JOIN books b ON b.id=c.book_id
JOIN loan_details d ON d.copy_id=c.id AND d.return_date IS NULL
JOIN loan_receipts lr ON lr.id=d.receipt_id
JOIN students s ON s.id=lr.student_id
JOIN accounts a ON a.id=s.account_id
WHERE c.barcode=@barcode;

-- 5. Complete reader identity, without authentication secrets.
SELECT s.student_code,a.username,a.full_name,a.date_of_birth,a.email,a.phone,a.address,s.faculty,s.class_name
FROM students s JOIN accounts a ON a.id=s.account_id
WHERE s.student_code=@student_code;

-- 6. Inventory audit: actual actor/reason and the recorded stock before/after.
SELECT h.id,e.name,a.full_name AS actor_name,h.event_type,h.created_at,
       h.old_total,h.old_available,h.old_unavailable,
       h.new_total,h.new_available,h.new_unavailable,h.on_loan_quantity,h.reason
FROM equipment_inventory_adjustments h
JOIN equipment e ON e.id=h.equipment_id
LEFT JOIN accounts a ON a.id=h.actor_account_id
ORDER BY h.id DESC;
