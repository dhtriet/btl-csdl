USE resource_center;

-- Remove the per-account activity flag without failing if it is already absent.
SET @drop_account_status = (
    SELECT IF(
        COUNT(*) > 0,
        'ALTER TABLE accounts DROP COLUMN status',
        'SELECT 1'
    )
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'accounts'
      AND column_name = 'status'
);
PREPARE account_status_statement FROM @drop_account_status;
EXECUTE account_status_statement;
DEALLOCATE PREPARE account_status_statement;

CREATE TABLE IF NOT EXISTS book_loan_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    librarian_id INT UNSIGNED NULL,
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255) NULL,
    status ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    reviewed_at DATETIME NULL,
    review_note VARCHAR(255) NULL,
    CONSTRAINT fk_book_loan_requests_student FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_book_loan_requests_librarian FOREIGN KEY (librarian_id) REFERENCES librarians(id),
    INDEX idx_book_loan_requests_student_status (student_id, status),
    INDEX idx_book_loan_requests_status (status, requested_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS book_loan_request_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id INT UNSIGNED NOT NULL,
    book_id INT UNSIGNED NOT NULL,
    requested_due_date DATE NOT NULL,
    CONSTRAINT fk_book_loan_request_items_request FOREIGN KEY (request_id) REFERENCES book_loan_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_book_loan_request_items_book FOREIGN KEY (book_id) REFERENCES books(id),
    UNIQUE KEY uq_book_loan_request_item (request_id, book_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipment_loan_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    librarian_id INT UNSIGNED NULL,
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255) NULL,
    status ENUM('pending', 'approved', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
    reviewed_at DATETIME NULL,
    review_note VARCHAR(255) NULL,
    CONSTRAINT fk_equipment_loan_requests_student FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_equipment_loan_requests_librarian FOREIGN KEY (librarian_id) REFERENCES librarians(id),
    INDEX idx_equipment_loan_requests_student_status (student_id, status),
    INDEX idx_equipment_loan_requests_status (status, requested_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipment_loan_request_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id INT UNSIGNED NOT NULL,
    equipment_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    requested_due_date DATE NOT NULL,
    CONSTRAINT fk_equipment_loan_request_items_request FOREIGN KEY (request_id) REFERENCES equipment_loan_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_loan_request_items_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id),
    UNIQUE KEY uq_equipment_loan_request_item (request_id, equipment_id)
) ENGINE=InnoDB;
