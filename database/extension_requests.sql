CREATE TABLE IF NOT EXISTS extension_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    loan_detail_id INT UNSIGNED NOT NULL,
    old_due_date DATE NOT NULL,
    requested_due_date DATE NOT NULL,
    reason VARCHAR(500) NOT NULL DEFAULT '',
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    librarian_id INT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    review_note VARCHAR(500) NULL,
    extension_id INT UNSIGNED NULL UNIQUE,
    pending_loan_id INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN status='pending' THEN loan_detail_id ELSE NULL END) STORED,
    UNIQUE KEY uq_extension_pending (pending_loan_id),
    CONSTRAINT fk_extension_request_loan FOREIGN KEY (loan_detail_id) REFERENCES loan_details(id),
    CONSTRAINT fk_extension_request_staff FOREIGN KEY (librarian_id) REFERENCES librarians(id),
    CONSTRAINT fk_extension_request_result FOREIGN KEY (extension_id) REFERENCES extensions(id),
    CONSTRAINT chk_extension_request_dates CHECK (requested_due_date > old_due_date),
    CONSTRAINT chk_extension_request_review CHECK (
        (status='pending' AND librarian_id IS NULL AND reviewed_at IS NULL AND extension_id IS NULL)
        OR (status='approved' AND librarian_id IS NOT NULL AND reviewed_at IS NOT NULL AND extension_id IS NOT NULL)
        OR (status='rejected' AND librarian_id IS NOT NULL AND reviewed_at IS NOT NULL AND extension_id IS NULL)
    )
) ENGINE=InnoDB;
