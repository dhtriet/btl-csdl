USE resource_center;

-- Them cac giao trinh PTIT co trong thu muc tai lieu hoc tap.
INSERT INTO publishers (name, address)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM publishers
    WHERE name = 'Học viện Công nghệ Bưu chính Viễn thông'
);

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Từ Minh Phương', 'Việt Nam', 'Tác giả giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông.'
WHERE NOT EXISTS (
    SELECT 1 FROM authors WHERE full_name = 'Từ Minh Phương'
);

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Đỗ Thị Diệu', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.'
WHERE NOT EXISTS (
    SELECT 1 FROM authors WHERE full_name = 'Đỗ Thị Diệu'
);

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Đào Mạnh Ninh', 'Việt Nam', 'Đồng chủ biên Bài giảng Lịch sử Đảng Cộng sản Việt Nam của PTIT.'
WHERE NOT EXISTS (
    SELECT 1 FROM authors WHERE full_name = 'Đào Mạnh Ninh'
);

INSERT INTO keywords (name)
SELECT 'Hệ điều hành'
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = 'Hệ điều hành'
);

INSERT INTO keywords (name)
SELECT 'Lịch sử Đảng'
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = 'Lịch sử Đảng'
);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT
    'Giáo trình Hệ điều hành',
    2015,
    'Tiếng Việt',
    'Giáo trình trình bày các khái niệm và nguyên lý hoạt động của hệ điều hành, quản lý tiến trình, bộ nhớ, hệ thống tệp và vào ra.',
    185,
    NULL,
    'Giáo trình Hệ điều hành của Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2015.',
    p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (
      SELECT 1 FROM books
      WHERE title = 'Giáo trình Hệ điều hành' AND publication_year = 2015
  );

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT
    'Bài giảng Lịch sử Đảng Cộng sản Việt Nam',
    2021,
    'Tiếng Việt',
    'Bài giảng dành cho sinh viên đại học, trình bày quá trình ra đời, lãnh đạo đấu tranh giành chính quyền, kháng chiến và công cuộc đổi mới.',
    169,
    NULL,
    'Bài giảng của Khoa Cơ bản 1, Học viện Công nghệ Bưu chính Viễn thông, Hà Nội 2021.',
    p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (
      SELECT 1 FROM books
      WHERE title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND publication_year = 2021
  );

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id
FROM books b
JOIN authors a ON a.full_name = 'Từ Minh Phương'
WHERE b.title = 'Giáo trình Hệ điều hành'
  AND b.publication_year = 2015
  AND NOT EXISTS (
      SELECT 1 FROM book_authors ba
      WHERE ba.book_id = b.id AND ba.author_id = a.id
  );

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id
FROM books b
JOIN authors a ON a.full_name = 'Đỗ Thị Diệu'
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam'
  AND b.publication_year = 2021
  AND NOT EXISTS (
      SELECT 1 FROM book_authors ba
      WHERE ba.book_id = b.id AND ba.author_id = a.id
  );

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id
FROM books b
JOIN authors a ON a.full_name = 'Đào Mạnh Ninh'
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam'
  AND b.publication_year = 2021
  AND NOT EXISTS (
      SELECT 1 FROM book_authors ba
      WHERE ba.book_id = b.id AND ba.author_id = a.id
  );

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id
FROM books b
JOIN genres g ON g.name = 'Giáo trình'
WHERE (
        (b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015)
        OR (b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021)
      )
  AND NOT EXISTS (
      SELECT 1 FROM book_genres bg
      WHERE bg.book_id = b.id AND bg.genre_id = g.id
  );

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id
FROM books b
JOIN keywords k ON k.name = 'Hệ điều hành'
WHERE b.title = 'Giáo trình Hệ điều hành'
  AND b.publication_year = 2015
  AND NOT EXISTS (
      SELECT 1 FROM book_keywords bk
      WHERE bk.book_id = b.id AND bk.keyword_id = k.id
  );

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id
FROM books b
JOIN keywords k ON k.name = 'Lịch sử Đảng'
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam'
  AND b.publication_year = 2021
  AND NOT EXISTS (
      SELECT 1 FROM book_keywords bk
      WHERE bk.book_id = b.id AND bk.keyword_id = k.id
  );

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id
FROM books b
JOIN keywords k ON k.name = 'PTIT'
WHERE (
        (b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015)
        OR (b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021)
      )
  AND NOT EXISTS (
      SELECT 1 FROM book_keywords bk
      WHERE bk.book_id = b.id AND bk.keyword_id = k.id
  );

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-HDH-2015-01', 'Kệ I1', 'good', 'available'
FROM books b
WHERE b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-HDH-2015-01');

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-LSD-2021-01', 'Kệ I2', 'good', 'available'
FROM books b
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021
  AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-LSD-2021-01');

-- Phien ban dien tu tu file PDF giao trinh PTIT.
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 4.28, 'A4', '/ebooks/ptit-he-dieu-hanh-2015.pdf'
FROM books b
WHERE b.title = 'Giáo trình Hệ điều hành' AND b.publication_year = 2015
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 2.70, 'A4', '/ebooks/ptit-lich-su-dang-2021.pdf'
FROM books b
WHERE b.title = 'Bài giảng Lịch sử Đảng Cộng sản Việt Nam' AND b.publication_year = 2021
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
