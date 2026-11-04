CREATE DATABASE IF NOT EXISTS resource_center
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE resource_center;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS equipment_loan_request_items;
DROP TABLE IF EXISTS equipment_loan_requests;
DROP TABLE IF EXISTS book_loan_request_items;
DROP TABLE IF EXISTS book_loan_requests;
DROP TABLE IF EXISTS equipment_loan_details;
DROP TABLE IF EXISTS equipment_loans;
DROP TABLE IF EXISTS room_requests;
DROP TABLE IF EXISTS extensions;
DROP TABLE IF EXISTS loan_details;
DROP TABLE IF EXISTS loan_receipts;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS ebooks;
DROP TABLE IF EXISTS book_keywords;
DROP TABLE IF EXISTS book_genres;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS keywords;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS librarians;
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    date_of_birth DATE NULL,
    email VARCHAR(120) NULL,
    phone VARCHAR(30) NULL,
    address VARCHAR(255) NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role ENUM('student', 'librarian', 'admin') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE students (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL UNIQUE,
    student_code VARCHAR(30) NOT NULL UNIQUE,
    faculty VARCHAR(120) NOT NULL,
    class_name VARCHAR(80) NOT NULL,
    CONSTRAINT fk_students_account FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE librarians (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id INT UNSIGNED NOT NULL UNIQUE,
    librarian_code VARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT fk_librarians_account FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB;

CREATE TABLE publishers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(160) NOT NULL,
    address VARCHAR(255) NULL,
    email VARCHAR(120) NULL,
    phone VARCHAR(30) NULL
) ENGINE=InnoDB;

CREATE TABLE authors (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(160) NOT NULL,
    date_of_birth DATE NULL,
    nationality VARCHAR(80) NULL,
    biography TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE genres (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE keywords (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE books (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    is_visible TINYINT(1) NOT NULL DEFAULT 1,
    deleted_at DATETIME NULL,
    title VARCHAR(240) NOT NULL,
    publication_year YEAR NULL,
    language VARCHAR(60) NOT NULL,
    summary TEXT NULL,
    pages INT UNSIGNED NULL,
    cover_image VARCHAR(255) NULL,
    description TEXT NULL,
    publisher_id INT UNSIGNED NOT NULL,
    CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id) REFERENCES publishers(id),
    INDEX idx_books_title (title),
    INDEX idx_books_language (language),
    INDEX idx_books_year (publication_year)
) ENGINE=InnoDB;

CREATE TABLE book_authors (
    book_id INT UNSIGNED NOT NULL,
    author_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE book_genres (
    book_id INT UNSIGNED NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (book_id, genre_id),
    CONSTRAINT fk_book_genres_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT fk_book_genres_genre FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE book_keywords (
    book_id INT UNSIGNED NOT NULL,
    keyword_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (book_id, keyword_id),
    CONSTRAINT fk_book_keywords_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT fk_book_keywords_keyword FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ebooks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id INT UNSIGNED NOT NULL UNIQUE,
    file_format VARCHAR(20) NOT NULL,
    file_size_mb DECIMAL(8, 2) NULL,
    resolution VARCHAR(40) NULL,
    file_path VARCHAR(255) NULL,
    CONSTRAINT fk_ebooks_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE book_copies (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    is_visible TINYINT(1) NOT NULL DEFAULT 1,
    deleted_at DATETIME NULL,
    book_id INT UNSIGNED NOT NULL,
    barcode VARCHAR(40) NOT NULL UNIQUE,
    storage_location VARCHAR(120) NOT NULL,
    condition_status ENUM('good', 'worn', 'damaged', 'lost') NOT NULL DEFAULT 'good',
    status ENUM('available', 'borrowed', 'damaged', 'lost') NOT NULL DEFAULT 'available',
    CONSTRAINT fk_book_copies_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    INDEX idx_book_copies_status (status)
) ENGINE=InnoDB;

CREATE TABLE book_loan_requests (
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

CREATE TABLE book_loan_request_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id INT UNSIGNED NOT NULL,
    book_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    requested_due_date DATE NOT NULL,
    CONSTRAINT fk_book_loan_request_items_request FOREIGN KEY (request_id) REFERENCES book_loan_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_book_loan_request_items_book FOREIGN KEY (book_id) REFERENCES books(id),
    UNIQUE KEY uq_book_loan_request_item (request_id, book_id)
) ENGINE=InnoDB;

CREATE TABLE loan_receipts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    librarian_id INT UNSIGNED NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255) NULL,
    status ENUM('open', 'completed') NOT NULL DEFAULT 'open',
    CONSTRAINT fk_loan_receipts_student FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_loan_receipts_librarian FOREIGN KEY (librarian_id) REFERENCES librarians(id),
    INDEX idx_loan_receipts_student (student_id)
) ENGINE=InnoDB;

CREATE TABLE loan_details (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    receipt_id INT UNSIGNED NOT NULL,
    copy_id INT UNSIGNED NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    return_status ENUM('on_time', 'late') NULL,
    late_days SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    extension_count TINYINT UNSIGNED NOT NULL DEFAULT 0,
    status ENUM('borrowed', 'returned', 'overdue') NOT NULL DEFAULT 'borrowed',
    condition_on_return ENUM('good', 'worn', 'damaged', 'lost') NULL,
    CONSTRAINT fk_loan_details_receipt FOREIGN KEY (receipt_id) REFERENCES loan_receipts(id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_details_copy FOREIGN KEY (copy_id) REFERENCES book_copies(id),
    INDEX idx_loan_details_due (due_date, status),
    INDEX idx_loan_details_return (return_date)
) ENGINE=InnoDB;

CREATE TABLE extensions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    loan_detail_id INT UNSIGNED NOT NULL,
    librarian_id INT UNSIGNED NOT NULL,
    old_due_date DATE NOT NULL,
    new_due_date DATE NOT NULL,
    extension_date DATE NOT NULL,
    CONSTRAINT fk_extensions_detail FOREIGN KEY (loan_detail_id) REFERENCES loan_details(id) ON DELETE CASCADE,
    CONSTRAINT fk_extensions_librarian FOREIGN KEY (librarian_id) REFERENCES librarians(id)
) ENGINE=InnoDB;

CREATE TABLE rooms (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    is_visible TINYINT(1) NOT NULL DEFAULT 1,
    deleted_at DATETIME NULL,
    image_path VARCHAR(255) NULL,
    image_is_illustration TINYINT(1) NOT NULL DEFAULT 0,
    name VARCHAR(100) NOT NULL,
    room_type ENUM('classroom', 'meeting_room') NOT NULL,
    location VARCHAR(160) NOT NULL,
    capacity INT UNSIGNED NOT NULL,
    included_equipment VARCHAR(255) NULL,
    operating_hours VARCHAR(120) NULL,
    status ENUM('available', 'maintenance', 'inactive') NOT NULL DEFAULT 'available',
    INDEX idx_rooms_type_capacity (room_type, capacity)
) ENGINE=InnoDB;

CREATE TABLE room_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    room_id INT UNSIGNED NOT NULL,
    librarian_id INT UNSIGNED NULL,
    use_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME NULL,
    review_note VARCHAR(255) NULL,
    CONSTRAINT fk_room_requests_student FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_room_requests_room FOREIGN KEY (room_id) REFERENCES rooms(id),
    CONSTRAINT fk_room_requests_librarian FOREIGN KEY (librarian_id) REFERENCES librarians(id),
    INDEX idx_room_requests_schedule (room_id, use_date, start_time, end_time, status)
) ENGINE=InnoDB;

CREATE TABLE equipment (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    is_visible TINYINT(1) NOT NULL DEFAULT 1,
    deleted_at DATETIME NULL,
    image_path VARCHAR(255) NULL,
    image_is_illustration TINYINT(1) NOT NULL DEFAULT 0,
    name VARCHAR(160) NOT NULL,
    equipment_type VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(120) NULL,
    description TEXT NULL,
    usage_guide TEXT NULL,
    total_quantity INT UNSIGNED NOT NULL DEFAULT 1,
    available_quantity INT UNSIGNED NOT NULL DEFAULT 1,
    storage_location VARCHAR(160) NULL,
    serial_number VARCHAR(120) NULL,
    status ENUM('available', 'borrowed', 'maintenance', 'damaged') NOT NULL DEFAULT 'available',
    INDEX idx_equipment_type_status (equipment_type, status)
) ENGINE=InnoDB;

CREATE TABLE equipment_loan_requests (
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

CREATE TABLE equipment_loan_request_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id INT UNSIGNED NOT NULL,
    equipment_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    requested_due_date DATE NOT NULL,
    CONSTRAINT fk_equipment_loan_request_items_request FOREIGN KEY (request_id) REFERENCES equipment_loan_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_loan_request_items_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id),
    UNIQUE KEY uq_equipment_loan_request_item (request_id, equipment_id)
) ENGINE=InnoDB;

CREATE TABLE equipment_loans (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    librarian_id INT UNSIGNED NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255) NULL,
    status ENUM('borrowed', 'returned', 'overdue') NOT NULL DEFAULT 'borrowed',
    CONSTRAINT fk_equipment_loans_student FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_equipment_loans_librarian FOREIGN KEY (librarian_id) REFERENCES librarians(id)
) ENGINE=InnoDB;

CREATE TABLE equipment_loan_details (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    loan_id INT UNSIGNED NOT NULL,
    equipment_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    return_status ENUM('on_time', 'late') NULL,
    late_days SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    condition_on_borrow VARCHAR(120) NULL,
    condition_on_return VARCHAR(120) NULL,
    status ENUM('borrowed', 'returned', 'overdue') NOT NULL DEFAULT 'borrowed',
    CONSTRAINT fk_equipment_loan_details_loan FOREIGN KEY (loan_id) REFERENCES equipment_loans(id) ON DELETE CASCADE,
    CONSTRAINT fk_equipment_loan_details_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id),
    INDEX idx_equipment_loan_details_due (due_date, status)
) ENGINE=InnoDB;

-- Row invariants and one active loan per physical copy.
ALTER TABLE `books` ADD CONSTRAINT `chk_books_pages` CHECK (pages IS NULL OR pages > 0);
ALTER TABLE `ebooks` ADD CONSTRAINT `chk_ebooks_size` CHECK (file_size_mb IS NULL OR file_size_mb > 0);
ALTER TABLE `book_loan_request_items` ADD CONSTRAINT `chk_book_request_quantity` CHECK (quantity > 0);
ALTER TABLE `equipment_loan_request_items` ADD CONSTRAINT `chk_equipment_request_quantity` CHECK (quantity > 0);
ALTER TABLE `equipment` ADD CONSTRAINT `chk_equipment_quantities` CHECK (total_quantity > 0 AND available_quantity >= 0 AND available_quantity <= total_quantity);
ALTER TABLE `rooms` ADD CONSTRAINT `chk_rooms_capacity` CHECK (capacity > 0);
ALTER TABLE `room_requests` ADD CONSTRAINT `chk_room_request_time` CHECK (use_date >= '1000-01-01' AND start_time >= '00:00:00' AND start_time < end_time AND end_time <= '24:00:00');
ALTER TABLE `extensions` ADD CONSTRAINT `chk_extensions_dates` CHECK (old_due_date >= '1000-01-01' AND new_due_date > old_due_date AND extension_date >= '1000-01-01');
ALTER TABLE `loan_details` ADD CONSTRAINT `chk_loan_dates` CHECK (borrow_date >= '1000-01-01' AND due_date >= borrow_date AND (return_date IS NULL OR return_date >= borrow_date));
ALTER TABLE `loan_details` ADD CONSTRAINT `chk_loan_extensions` CHECK (extension_count <= 3);
ALTER TABLE `loan_details` ADD CONSTRAINT `chk_loan_return_state` CHECK ((return_date IS NULL AND status IN ('borrowed','overdue') AND return_status IS NULL AND late_days=0 AND condition_on_return IS NULL) OR (return_date IS NOT NULL AND status='returned' AND return_status IS NOT NULL AND condition_on_return IS NOT NULL AND CHAR_LENGTH(TRIM(condition_on_return))>0));
ALTER TABLE `loan_details` ADD CONSTRAINT `chk_loan_return_result` CHECK (return_date IS NULL OR (late_days=GREATEST(DATEDIFF(return_date,due_date),0) AND return_status=IF(return_date>due_date,'late','on_time')));
ALTER TABLE `equipment_loan_details` ADD CONSTRAINT `chk_equipment_loan_quantity` CHECK (quantity > 0);
ALTER TABLE `equipment_loan_details` ADD CONSTRAINT `chk_equipment_loan_dates` CHECK (borrow_date >= '1000-01-01' AND due_date >= borrow_date AND (return_date IS NULL OR return_date >= borrow_date));
ALTER TABLE `equipment_loan_details` ADD CONSTRAINT `chk_equipment_return_state` CHECK ((return_date IS NULL AND status IN ('borrowed','overdue') AND return_status IS NULL AND late_days=0 AND condition_on_return IS NULL) OR (return_date IS NOT NULL AND status='returned' AND return_status IS NOT NULL AND condition_on_return IS NOT NULL AND CHAR_LENGTH(TRIM(condition_on_return))>0));
ALTER TABLE `equipment_loan_details` ADD CONSTRAINT `chk_equipment_return_result` CHECK (return_date IS NULL OR (late_days=GREATEST(DATEDIFF(return_date,due_date),0) AND return_status=IF(return_date>due_date,'late','on_time')));
ALTER TABLE loan_details ADD COLUMN active_copy_id INT UNSIGNED GENERATED ALWAYS AS (CASE WHEN return_date IS NULL THEN copy_id ELSE NULL END) VIRTUAL, ADD UNIQUE KEY uq_loan_details_active_copy(active_copy_id);

SET FOREIGN_KEY_CHECKS = 1;
