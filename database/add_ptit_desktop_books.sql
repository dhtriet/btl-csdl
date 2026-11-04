USE resource_center;

-- Them 10 giao trinh PTIT tu thu muc Desktop, kem ban sach dien tu PDF.
INSERT INTO publishers (name, address)
SELECT 'Học viện Công nghệ Bưu chính Viễn thông', 'Hà Nội'
WHERE NOT EXISTS (
    SELECT 1 FROM publishers
    WHERE name = 'Học viện Công nghệ Bưu chính Viễn thông'
);

INSERT INTO authors (full_name, nationality, biography)
SELECT 'Ao Thu Hoài', 'Việt Nam', 'Giảng viên, biên soạn tài liệu về thương mại điện tử và marketing trực tuyến.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Ao Thu Hoài');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trần Thị Thập', 'Việt Nam', 'Biên tập tài liệu Xây dựng Website thương mại điện tử của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trần Thị Thập');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Nguyễn Hoàng Anh', 'Việt Nam', 'Biên tập tài liệu Xây dựng Website thương mại điện tử của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Nguyễn Hoàng Anh');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Hoàng Xuân Dậu', 'Việt Nam', 'Tác giả các giáo trình về an toàn thông tin và bảo mật hệ thống.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Hoàng Xuân Dậu');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trịnh Thị Vân Anh', 'Việt Nam', 'Tác giả giáo trình Kỹ thuật đồ họa của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trịnh Thị Vân Anh');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trần Thị Hoà', 'Việt Nam', 'Tác giả giáo trình Kinh tế vi mô của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trần Thị Hoà');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Phạm Hoàng Duy', 'Việt Nam', 'Tác giả giáo trình An toàn hệ điều hành của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Phạm Hoàng Duy');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Trần Đình Quế', 'Việt Nam', 'Đồng tác giả giáo trình Nhập môn Công nghệ phần mềm của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Trần Đình Quế');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Nguyễn Mạnh Hùng', 'Việt Nam', 'Đồng tác giả giáo trình Nhập môn Công nghệ phần mềm của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Nguyễn Mạnh Hùng');
INSERT INTO authors (full_name, nationality, biography)
SELECT 'Đỗ Xuân Chợ', 'Việt Nam', 'Tác giả bài giảng Các kỹ thuật giấu tin của PTIT.'
WHERE NOT EXISTS (SELECT 1 FROM authors WHERE full_name = 'Đỗ Xuân Chợ');

INSERT INTO genres (name, description)
SELECT 'Thương mại điện tử', 'Xây dựng và vận hành website thương mại điện tử'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Thương mại điện tử');
INSERT INTO genres (name, description)
SELECT 'Marketing', 'Marketing và marketing trực tuyến'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Marketing');
INSERT INTO genres (name, description)
SELECT 'An toàn thông tin', 'Bảo vệ dữ liệu, hệ thống và ứng dụng'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'An toàn thông tin');
INSERT INTO genres (name, description)
SELECT 'Đồ họa máy tính', 'Kỹ thuật và ứng dụng đồ họa máy tính'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Đồ họa máy tính');
INSERT INTO genres (name, description)
SELECT 'Kinh tế', 'Các môn học kinh tế cơ bản'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Kinh tế');
INSERT INTO genres (name, description)
SELECT 'Hệ điều hành', 'Nguyên lý và an toàn hệ điều hành'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Hệ điều hành');
INSERT INTO genres (name, description)
SELECT 'Công nghệ phần mềm', 'Phân tích, thiết kế và phát triển phần mềm'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Công nghệ phần mềm');
INSERT INTO genres (name, description)
SELECT 'Giấu tin', 'Kỹ thuật giấu tin và thủy vân số'
WHERE NOT EXISTS (SELECT 1 FROM genres WHERE name = 'Giấu tin');

INSERT INTO keywords (name)
SELECT 'PTIT' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'PTIT');
INSERT INTO keywords (name)
SELECT 'Thương mại điện tử' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Thương mại điện tử');
INSERT INTO keywords (name)
SELECT 'Marketing trực tuyến' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Marketing trực tuyến');
INSERT INTO keywords (name)
SELECT 'An toàn thông tin' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'An toàn thông tin');
INSERT INTO keywords (name)
SELECT 'Bảo mật hệ thống' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Bảo mật hệ thống');
INSERT INTO keywords (name)
SELECT 'Ứng dụng web' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Ứng dụng web');
INSERT INTO keywords (name)
SELECT 'Cơ sở dữ liệu' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Cơ sở dữ liệu');
INSERT INTO keywords (name)
SELECT 'Hệ điều hành' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Hệ điều hành');
INSERT INTO keywords (name)
SELECT 'Công nghệ phần mềm' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Công nghệ phần mềm');
INSERT INTO keywords (name)
SELECT 'Đồ họa máy tính' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Đồ họa máy tính');
INSERT INTO keywords (name)
SELECT 'Kinh tế vi mô' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Kinh tế vi mô');
INSERT INTO keywords (name)
SELECT 'Giấu tin' WHERE NOT EXISTS (SELECT 1 FROM keywords WHERE name = 'Giấu tin');

INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Bài giảng Xây dựng Website thương mại điện tử', 2018, 'Tiếng Việt',
       'Tài liệu trình bày các kiến thức và kỹ thuật xây dựng website thương mại điện tử.',
       141, 'Bài giảng PTIT, biên soạn bởi Th.S. Ao Thu Hoài, hiệu đính năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Bài giảng Xây dựng Website thương mại điện tử' AND publication_year = 2018);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'E-marketing (Marketing trực tuyến)', 2013, 'Tiếng Việt',
       'Tài liệu nhập môn về marketing trực tuyến và các hoạt động marketing trên môi trường số.',
       353, 'Giáo trình PTIT, tác giả TS. Ao Thu Hoài, năm 2013.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'E-marketing (Marketing trực tuyến)' AND publication_year = 2013);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Giáo trình Cơ sở an toàn thông tin', 2018, 'Tiếng Việt',
       'Giáo trình giới thiệu các khái niệm nền tảng, nguy cơ và biện pháp bảo đảm an toàn thông tin.',
       143, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Giáo trình Cơ sở an toàn thông tin' AND publication_year = 2018);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Giáo trình Kỹ thuật đồ họa', 2018, 'Tiếng Việt',
       'Giáo trình trình bày các nguyên lý và kỹ thuật cơ bản của đồ họa máy tính.',
       222, 'Giáo trình PTIT, tác giả Trịnh Thị Vân Anh, năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Giáo trình Kỹ thuật đồ họa' AND publication_year = 2018);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Kinh tế vi mô 1', 2013, 'Tiếng Việt',
       'Tài liệu trình bày các khái niệm và nguyên lý cơ bản của kinh tế vi mô.',
       180, 'Giáo trình PTIT, tác giả TS. Trần Thị Hoà, năm 2013.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Kinh tế vi mô 1' AND publication_year = 2013);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'An toàn hệ điều hành', 2017, 'Tiếng Việt',
       'Tài liệu trình bày các vấn đề bảo vệ hệ điều hành, tài nguyên hệ thống và dữ liệu người dùng.',
       100, 'Giáo trình PTIT, tác giả Phạm Hoàng Duy, năm 2017.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An toàn hệ điều hành' AND publication_year = 2017);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Nhập môn Công nghệ phần mềm', 2016, 'Tiếng Việt',
       'Giáo trình nhập môn về quy trình, phương pháp và kỹ thuật phát triển phần mềm.',
       229, 'Giáo trình PTIT, đồng tác giả Trần Đình Quế và Nguyễn Mạnh Hùng, năm 2016.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Nhập môn Công nghệ phần mềm' AND publication_year = 2016);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'An toàn và bảo mật hệ thống thông tin', 2017, 'Tiếng Việt',
       'Tài liệu trình bày các nguyên tắc, mô hình và biện pháp bảo đảm an toàn, bảo mật hệ thống thông tin.',
       152, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2017.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An toàn và bảo mật hệ thống thông tin' AND publication_year = 2017);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'An toàn ứng dụng web và cơ sở dữ liệu', 2017, 'Tiếng Việt',
       'Tài liệu giới thiệu các nguy cơ và biện pháp bảo vệ ứng dụng web và cơ sở dữ liệu.',
       160, 'Giáo trình PTIT, tác giả Hoàng Xuân Dậu, năm 2017.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND publication_year = 2017);
INSERT INTO books (title, publication_year, language, summary, pages, description, publisher_id)
SELECT 'Bài giảng Các kỹ thuật giấu tin', 2018, 'Tiếng Việt',
       'Bài giảng giới thiệu các kỹ thuật giấu tin và những ứng dụng cơ bản trong môi trường số.',
       136, 'Bài giảng PTIT, tác giả Đỗ Xuân Chợ, tháng 12 năm 2018.', p.id
FROM publishers p
WHERE p.name = 'Học viện Công nghệ Bưu chính Viễn thông'
  AND NOT EXISTS (SELECT 1 FROM books WHERE title = 'Bài giảng Các kỹ thuật giấu tin' AND publication_year = 2018);

INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name IN ('Ao Thu Hoài', 'Trần Thị Thập', 'Nguyễn Hoàng Anh')
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Ao Thu Hoài'
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Hoàng Xuân Dậu'
WHERE b.title IN ('Giáo trình Cơ sở an toàn thông tin', 'An toàn và bảo mật hệ thống thông tin', 'An toàn ứng dụng web và cơ sở dữ liệu')
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Trịnh Thị Vân Anh'
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Trần Thị Hoà'
WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Phạm Hoàng Duy'
WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name IN ('Trần Đình Quế', 'Nguyễn Mạnh Hùng')
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);
INSERT INTO book_authors (book_id, author_id)
SELECT b.id, a.id FROM books b JOIN authors a ON a.full_name = 'Đỗ Xuân Chợ'
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_authors ba WHERE ba.book_id = b.id AND ba.author_id = a.id);

INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Thương mại điện tử')
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Marketing')
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'An toàn thông tin')
WHERE b.title IN ('Giáo trình Cơ sở an toàn thông tin', 'An toàn và bảo mật hệ thống thông tin', 'An toàn ứng dụng web và cơ sở dữ liệu')
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Đồ họa máy tính')
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Kinh tế')
WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Hệ điều hành')
WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Công nghệ phần mềm')
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);
INSERT INTO book_genres (book_id, genre_id)
SELECT b.id, g.id FROM books b JOIN genres g ON g.name IN ('Giáo trình', 'Giấu tin')
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_genres bg WHERE bg.book_id = b.id AND bg.genre_id = g.id);

INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Thương mại điện tử', 'Ứng dụng web')
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Marketing trực tuyến')
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'An toàn thông tin')
WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Đồ họa máy tính')
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Kinh tế vi mô')
WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Hệ điều hành')
WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Công nghệ phần mềm')
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Bảo mật hệ thống')
WHERE b.title = 'An toàn và bảo mật hệ thống thông tin' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'An toàn thông tin', 'Ứng dụng web', 'Cơ sở dữ liệu')
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);
INSERT INTO book_keywords (book_id, keyword_id)
SELECT b.id, k.id FROM books b JOIN keywords k ON k.name IN ('PTIT', 'Giấu tin')
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM book_keywords bk WHERE bk.book_id = b.id AND bk.keyword_id = k.id);

INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 10.85, 'A4', '/ebooks/ptit-website-thuong-mai-dien-tu-2018.pdf'
FROM books b WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 10.02, 'A4', '/ebooks/ptit-e-marketing-2013.pdf'
FROM books b WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 7.65, 'A4', '/ebooks/ptit-co-so-an-toan-thong-tin-2018.pdf'
FROM books b WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 5.44, 'A4', '/ebooks/ptit-ky-thuat-do-hoa-2018.pdf'
FROM books b WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 3.81, 'A4', '/ebooks/ptit-kinh-te-vi-mo-1-2013.pdf'
FROM books b WHERE b.title = 'Kinh tế vi mô 1' AND b.publication_year = 2013
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 4.83, 'A4', '/ebooks/ptit-an-toan-he-dieu-hanh-2017.pdf'
FROM books b WHERE b.title = 'An toàn hệ điều hành' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 9.06, 'A4', '/ebooks/ptit-nhap-mon-cong-nghe-phan-mem-2016.pdf'
FROM books b WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND b.publication_year = 2016
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 6.85, 'A4', '/ebooks/ptit-an-toan-bao-mat-he-thong-thong-tin-2017.pdf'
FROM books b WHERE b.title = 'An toàn và bảo mật hệ thống thông tin' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 7.05, 'A4', '/ebooks/ptit-an-toan-ung-dung-web-co-so-du-lieu-2017.pdf'
FROM books b WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND b.publication_year = 2017
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);
INSERT INTO ebooks (book_id, file_format, file_size_mb, resolution, file_path)
SELECT b.id, 'PDF', 3.60, 'A4', '/ebooks/ptit-cac-ky-thuat-giau-tin-2018.pdf'
FROM books b WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND b.publication_year = 2018
  AND NOT EXISTS (SELECT 1 FROM ebooks e WHERE e.book_id = b.id);

INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-WEB-2018-01', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Xây dựng Website thương mại điện tử' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-WEB-2018-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-EMARKETING-2013-01', 'Kệ J1', 'good', 'available' FROM books b
WHERE b.title = 'E-marketing (Marketing trực tuyến)' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-EMARKETING-2013-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATTT-2018-01', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Cơ sở an toàn thông tin' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATTT-2018-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-DH-2018-01', 'Kệ J2', 'good', 'available' FROM books b
WHERE b.title = 'Giáo trình Kỹ thuật đồ họa' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-DH-2018-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-KTVM-2013-01', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'Kinh tế vi mô 1' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-KTVM-2013-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATHDH-2017-01', 'Kệ J3', 'good', 'available' FROM books b
WHERE b.title = 'An toàn hệ điều hành' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATHDH-2017-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-CNPM-2016-01', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'Nhập môn Công nghệ phần mềm' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-CNPM-2016-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-BMHTTT-2017-01', 'Kệ J4', 'good', 'available' FROM books b
WHERE b.title = 'An toàn và bảo mật hệ thống thông tin' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-BMHTTT-2017-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-ATWEB-2017-01', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'An toàn ứng dụng web và cơ sở dữ liệu' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-ATWEB-2017-01');
INSERT INTO book_copies (book_id, barcode, storage_location, condition_status, status)
SELECT b.id, 'PTIT-GIAUTIN-2018-01', 'Kệ J5', 'good', 'available' FROM books b
WHERE b.title = 'Bài giảng Các kỹ thuật giấu tin' AND NOT EXISTS (SELECT 1 FROM book_copies WHERE barcode = 'PTIT-GIAUTIN-2018-01');
