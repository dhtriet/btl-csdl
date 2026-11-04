USE resource_center;

-- Dau sach minh hoa cho tim kiem theo mot phan nhan de, vi du: "cấu trúc".
INSERT INTO publishers (name, address)
SELECT 'Nhà xuất bản Đại học Quốc gia Hà Nội', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM publishers WHERE name = 'Nhà xuất bản Đại học Quốc gia Hà Nội'
);

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Nguyễn Đức Nghĩa', 'Việt Nam', 'Tác giả tài liệu về cấu trúc dữ liệu và giải thuật.'
WHERE NOT EXISTS (
    SELECT 1 FROM authors WHERE full_name = 'Nguyễn Đức Nghĩa'
);

INSERT INTO keywords (name)
SELECT 'Cấu trúc dữ liệu'
WHERE NOT EXISTS (
    SELECT 1 FROM keywords WHERE name = 'Cấu trúc dữ liệu'
);

INSERT INTO books (title, publication_year, language, summary, pages, cover_image, description, publisher_id)
SELECT
    'Cấu trúc dữ liệu và giải thuật',
    2015,
    'Tiếng Việt',
    'Tài liệu nhập môn về cấu trúc dữ liệu, thuật toán và kỹ thuật giải quyết bài toán lập trình.',
    NULL,
    NULL,
    'Đầu sách minh họa cho chức năng tìm kiếm theo một phần tên sách.',
    p.id
FROM publishers p
WHERE p.name = 'Nhà xuất bản Đại học Quốc gia Hà Nội'
  AND NOT EXISTS (
      SELECT 1 FROM books
      WHERE title = 'Cấu trúc dữ liệu và giải thuật'
  );

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id
FROM books b
JOIN authors a ON a.full_name = 'Nguyễn Đức Nghĩa'
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM book_authors ba
      WHERE ba.book_id = b.id AND ba.author_id = a.id
  );

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id
FROM books b
JOIN genres g ON g.name = 'Thuật toán'
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM book_genres bg
      WHERE bg.book_id = b.id AND bg.genre_id = g.id
  );

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id
FROM books b
JOIN genres g ON g.name = 'Giáo trình'
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM book_genres bg
      WHERE bg.book_id = b.id AND bg.genre_id = g.id
  );

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id
FROM books b
JOIN keywords k ON k.name = 'Cấu trúc dữ liệu'
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM book_keywords bk
      WHERE bk.book_id = b.id AND bk.keyword_id = k.id
  );

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'DSA-VN-2015-01', 'Kệ H2', 'good', 'available'
FROM books b
WHERE b.title = 'Cấu trúc dữ liệu và giải thuật'
  AND NOT EXISTS (
      SELECT 1 FROM book_copies WHERE barcode = 'DSA-VN-2015-01'
  );
