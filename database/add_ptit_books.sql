USE resource_center;

-- Danh muc giao trinh PTIT va tai lieu tham khao duoc liet ke trong giao trinh Co so du lieu.
INSERT INTO publishers (name, address)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (SELECT 1 FROM publishers WHERE name = 'Học viện Công nghệ Bưu chính Viễn thông');

INSERT INTO publishers (name, address)
SELECT 'Addison-Wesley', 'Reading, Massachusetts'
WHERE NOT EXISTS (SELECT 1 FROM publishers WHERE name = 'Addison-Wesley');

INSERT INTO publishers (name, address)
SELECT 'Prentice Hall', 'Englewood Cliffs, New Jersey'
WHERE NOT EXISTS (SELECT 1 FROM publishers WHERE name = 'Prentice Hall');

INSERT INTO publishers (name, address)
SELECT 'McGraw-Hill/Irwin', 'New York'
WHERE NOT EXISTS (SELECT 1 FROM publishers WHERE name = 'McGraw-Hill/Irwin');

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Phạm Thế Quế', 'Việt Nam', 'Tác giả biên soạn giáo trình Cơ sở dữ liệu của Học viện Công nghệ Bưu chính Viễn thông.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Phạm Thế Quế');

INSERT INTO authors (full_name, nationality)
SELECT 'C. J. Date', 'Anh'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'C. J. Date');

INSERT INTO authors (full_name, nationality)
SELECT 'Alfred V. Aho', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Alfred V. Aho');

INSERT INTO authors (full_name, nationality)
SELECT 'John E. Hopcroft', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'John E. Hopcroft');

INSERT INTO authors (full_name, nationality)
SELECT 'Jeffrey D. Ullman', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Jeffrey D. Ullman');

INSERT INTO authors (full_name, nationality)
SELECT 'Michael V. Mannino', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Michael V. Mannino');

INSERT INTO authors (full_name, nationality)
SELECT 'Abraham Silberschatz', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Abraham Silberschatz');

INSERT INTO authors (full_name, nationality)
SELECT 'Henry F. Korth', 'Hoa Kỳ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Henry F. Korth');

INSERT INTO authors (full_name, nationality)
SELECT 'S. Sudarshan', 'Ấn Độ'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'S. Sudarshan');

INSERT INTO genres (name, description)
SELECT 'Giáo trình', 'Tài liệu học tập và giáo trình đại học'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Giáo trình');

INSERT INTO keywords (name)
SELECT 'CSDL quan hệ'
WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'CSDL quan hệ');

INSERT INTO keywords (name)
SELECT 'Chuẩn hóa'
WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Chuẩn hóa');

INSERT INTO keywords (name)
SELECT 'Thiết kế CSDL'
WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Thiết kế CSDL');

INSERT INTO keywords (name)
SELECT 'Bảo mật CSDL'
WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Bảo mật CSDL');

INSERT INTO keywords (name)
SELECT 'PTIT'
WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'PTIT');

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'Cơ sở dữ liệu', 2006, 'Tiếng Việt',
       'Giáo trình giới thiệu hệ cơ sở dữ liệu, mô hình dữ liệu, CSDL quan hệ, chuẩn hóa, SQL, tối ưu hóa truy vấn và an toàn dữ liệu.',
       166, NULL,
       'Giáo trình dùng cho sinh viên hệ đào tạo đại học từ xa, lưu hành nội bộ; mã số 492CDL351.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Cơ sở dữ liệu' AND publication_year = 2006);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'An Introduction to Database Systems', 1977, 'English',
       'Tài liệu tham khảo về các khái niệm và hệ thống cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [2] trong giáo trình Cơ sở dữ liệu PTIT.', p.id
FROM publishers p
WHERE p.name = 'Addison-Wesley'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An Introduction to Database Systems' AND publication_year = 1977);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'Principles of Database Systems', 1980, 'English',
       'Tài liệu tham khảo về nguyên lý hệ cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [9] trong giáo trình Cơ sở dữ liệu PTIT.', p.id
FROM publishers p
WHERE p.name = 'Prentice Hall'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Principles of Database Systems' AND publication_year = 1980);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'Database Application Development and Design', 2001, 'English',
       'Tài liệu tham khảo về phát triển và thiết kế ứng dụng cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [10] trong giáo trình Cơ sở dữ liệu PTIT.', p.id
FROM publishers p
WHERE p.name = 'McGraw-Hill/Irwin'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Database Application Development and Design' AND publication_year = 2001);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'Database System Concepts', 2002, 'English',
       'Tài liệu tham khảo về khái niệm, thiết kế và vận hành hệ cơ sở dữ liệu.',
       NULL, NULL, 'Tài liệu tham khảo [11] trong giáo trình Cơ sở dữ liệu PTIT.', p.id
FROM publishers p
WHERE p.name = 'McGraw-Hill/Irwin'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Database System Concepts' AND publication_year = 2002);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT 'The Design and Analysis of Computer Algorithms', 1974, 'English',
       'Tài liệu tham khảo về thiết kế và phân tích thuật toán.',
       NULL, NULL, 'Tài liệu tham khảo [4] trong giáo trình Cơ sở dữ liệu PTIT.', p.id
FROM publishers p
WHERE p.name = 'Addison-Wesley'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'The Design and Analysis of Computer Algorithms' AND publication_year = 1974);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Phạm Thế Quế'
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'C. J. Date'
WHERE b.title = 'An Introduction to Database Systems' AND b.publication_year = 1977
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Jeffrey D. Ullman'
WHERE b.title = 'Principles of Database Systems' AND b.publication_year = 1980
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Michael V. Mannino'
WHERE b.title = 'Database Application Development and Design' AND b.publication_year = 2001
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Abraham Silberschatz'
WHERE b.title = 'Database System Concepts' AND b.publication_year = 2002
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Henry F. Korth'
WHERE b.title = 'Database System Concepts' AND b.publication_year = 2002
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'S. Sudarshan'
WHERE b.title = 'Database System Concepts' AND b.publication_year = 2002
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Alfred V. Aho'
WHERE b.title = 'The Design and Analysis of Computer Algorithms' AND b.publication_year = 1974
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'John E. Hopcroft'
WHERE b.title = 'The Design and Analysis of Computer Algorithms' AND b.publication_year = 1974
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Jeffrey D. Ullman'
WHERE b.title = 'The Design and Analysis of Computer Algorithms' AND b.publication_year = 1974
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name = 'Cơ sở dữ liệu'
WHERE b.title IN ('Cơ sở dữ liệu', 'An Introduction to Database Systems', 'Principles of Database Systems', 'Database Application Development and Design', 'Database System Concepts')
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name = 'Giáo trình'
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name = 'Thuật toán'
WHERE b.title = 'The Design and Analysis of Computer Algorithms'
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name = 'CSDL quan hệ'
WHERE b.title IN ('Cơ sở dữ liệu', 'An Introduction to Database Systems', 'Principles of Database Systems', 'Database System Concepts')
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name = 'SQL'
WHERE b.title IN ('Cơ sở dữ liệu', 'Database System Concepts')
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name = 'Chuẩn hóa'
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name = 'Thiết kế CSDL'
WHERE b.title = 'Database Application Development and Design'
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name = 'Bảo mật CSDL'
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name = 'PTIT'
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 5.19, 'A4', NULL
FROM books b
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CSDL-2006-01', 'Kệ G1', 'good', 'available'
FROM books b
WHERE b.title = 'Cơ sở dữ liệu' AND b.publication_year = 2006
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CSDL-2006-01');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'REF-DATE-1977-01', 'Kệ G2', 'good', 'available'
FROM books b
WHERE b.title = 'An Introduction to Database Systems'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'REF-DATE-1977-01');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'REF-ULLMAN-1980-01', 'Kệ G2', 'good', 'available'
FROM books b
WHERE b.title = 'Principles of Database Systems'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'REF-ULLMAN-1980-01');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'REF-MANNINO-2001-01', 'Kệ G3', 'good', 'available'
FROM books b
WHERE b.title = 'Database Application Development and Design'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'REF-MANNINO-2001-01');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'REF-DBCONCEPTS-2002-01', 'Kệ G3', 'good', 'available'
FROM books b
WHERE b.title = 'Database System Concepts'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'REF-DBCONCEPTS-2002-01');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'REF-AHO-1974-01', 'Kệ H1', 'good', 'available'
FROM books b
WHERE b.title = 'The Design and Analysis of Computer Algorithms'
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'REF-AHO-1974-01');
