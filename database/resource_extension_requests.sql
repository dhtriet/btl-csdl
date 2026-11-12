CREATE TABLE IF NOT EXISTS resource_extension_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    equipment_detail_id INT UNSIGNED NULL,
    room_request_id INT UNSIGNED NULL,
    old_deadline DATETIME NOT NULL,
    requested_deadline DATETIME NOT NULL,
    reason VARCHAR(500) NOT NULL DEFAULT '',
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    librarian_id INT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    review_note VARCHAR(500) NULL,
    pending_equipment_id INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN status='pending' THEN equipment_detail_id ELSE NULL END) STORED,
    pending_room_id INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN status='pending' THEN room_request_id ELSE NULL END) STORED,
    UNIQUE KEY uq_resource_extension_equipment (pending_equipment_id),
    UNIQUE KEY uq_resource_extension_room (pending_room_id),
    CONSTRAINT fk_resource_extension_equipment FOREIGN KEY (equipment_detail_id) REFERENCES equipment_loan_details(id),
    CONSTRAINT fk_resource_extension_room FOREIGN KEY (room_request_id) REFERENCES room_requests(id),
    CONSTRAINT fk_resource_extension_staff FOREIGN KEY (librarian_id) REFERENCES librarians(id),
    CONSTRAINT chk_resource_extension_target CHECK ((equipment_detail_id IS NOT NULL) + (room_request_id IS NOT NULL) = 1),
    CONSTRAINT chk_resource_extension_deadline CHECK (requested_deadline > old_deadline),
    CONSTRAINT chk_resource_extension_review CHECK (
        (status='pending' AND librarian_id IS NULL AND reviewed_at IS NULL)
        OR (status IN ('approved','rejected') AND librarian_id IS NOT NULL AND reviewed_at IS NOT NULL)
    )
) ENGINE=InnoDB;
