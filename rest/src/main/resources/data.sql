-- Clear existing data to ensure a clean start.
TRUNCATE TABLE user_postgres RESTART IDENTITY CASCADE;
TRUNCATE TABLE book RESTART IDENTITY CASCADE;
TRUNCATE TABLE review RESTART IDENTITY CASCADE;

-- Insert Users (Sellers)
INSERT INTO user_postgres (login, password, email, number, country, city) VALUES
('janek_bookworm', '$2a$10$i/5d9FOP/28rUd1aDmNC0.uq8qJ8a/pXENzDPLsXZbpSwynpi8.KG', 'jan.kowalski@example.com', '501102203', 'Poland', 'Warsaw'),
('zofia_reads', '$2a$10$i/5d9FOP/28rUd1aDmNC0.uq8qJ8a/pXENzDPLsXZbpSwynpi8.KG', 'zofia.nowak@example.com', '602304405', 'Poland', 'Krakow'),
('piotr_seller', '$2a$10$i/5d9FOP/28rUd1aDmNC0.uq8qJ8a/pXENzDPLsXZbpSwynpi8.KG', 'piotr.wisniewski@example.com', '703506607', 'Poland', 'Lodz');

-- Insert Book Offers
INSERT INTO book (title, author, book_condition, price, image_url, seller_id) VALUES
('Mechanika techniczna', 'Władysław Siuta', 'Visibly Used', 70.00, 'https://images.pexels.com/photos/2228569/pexels-photo-2228569.jpeg', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Symfonia C++ Standard', 'Jerzy Grębosz', 'Excellent', 100.00, 'https://images.pexels.com/photos/2004161/pexels-photo-2004161.jpeg', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Linux Biblia', 'Christopher Negus', 'Visibly Used', 120.00, 'https://images.pexels.com/photos/433308/pexels-photo-433308.jpeg', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Biologia na czasie 2', 'Marek Guzik, Władysław Zamachowski', 'Very Good', 49.00, 'https://images.pexels.com/photos/265087/pexels-photo-265087.jpeg', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Wiedźmin - Ostatnie życzenie', 'Andrzej Sapkowski', 'Like New', 35.50, 'https://images.pexels.com/photos/3747468/pexels-photo-3747468.jpeg', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Clean Code', 'Robert C. Martin', 'Good', 85.00, 'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg', (SELECT id from user_postgres WHERE login = 'piotr_seller')),
('Pan Tadeusz', 'Adam Mickiewicz', 'Acceptable', 15.00, 'https://images.pexels.com/photos/694740/pexels-photo-694740.jpeg', (SELECT id from user_postgres WHERE login = 'piotr_seller'));

-- Insert Reviews for Books
INSERT INTO review (rating, comment, reviewer_name, book_id) VALUES
(5, 'Excellent book, a must-read for any C++ enthusiast!', 'User123', (SELECT id from book WHERE title = 'Symfonia C++ Standard')),
(4, 'Very detailed and comprehensive, but can be a bit dense.', 'CodeMaster', (SELECT id from book WHERE title = 'Symfonia C++ Standard')),
(5, 'A classic for a reason. Sapkowski is a master of fantasy.', 'FantasyFan', (SELECT id from book WHERE title = 'Wiedźmin - Ostatnie życzenie')),
(3, 'Good, but not as groundbreaking as some say.', 'PragmaticDev', (SELECT id from book WHERE title = 'Clean Code'));
