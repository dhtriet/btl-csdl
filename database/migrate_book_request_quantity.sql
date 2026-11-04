USE resource_center;

ALTER TABLE book_loan_request_items
    ADD COLUMN quantity INT UNSIGNED NOT NULL DEFAULT 1 AFTER book_id;
