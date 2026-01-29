-- Clear existing data to ensure a clean start.
TRUNCATE TABLE user_postgres RESTART IDENTITY CASCADE;
TRUNCATE TABLE book RESTART IDENTITY CASCADE;
TRUNCATE TABLE review RESTART IDENTITY CASCADE;

-- Insert Users (Sellers)
INSERT INTO user_postgres (login, password, email, number, country, city) VALUES
('janek_bookworm', '$2a$10$i/5d9FOP/28rUd1aDmNC0.uq8qJ8a/pXENzDPLsXZbpSwynpi8.KG', 'jan.kowalski@example.com', '501102203', 'Poland', 'Warsaw'),
('zofia_reads', '$2a$10$i/5d9FOP/28rUd1aDmNC0.uq8qJ8a/pXENzDPLsXZbpSwynpi8.KG', 'zofia.nowak@example.com', '602304405', 'Poland', 'Krakow'),
('piotr_seller', '$2a$10$i/5d9FOP/28rUd1aDmNC0.uq8qJ8a/pXENzDPLsXZbpSwynpi8.KG', 'piotr.wisniewski@example.com', '703506607', 'Poland', 'Lodz');

-- Insert Book Offers (Empty image_url triggers dynamic fetch in the app)
INSERT INTO book (title, author, book_condition, price, image_url, seller_id) VALUES
('Mechanika techniczna', 'Władysław Siuta', 'Visibly Used', 70.00, '', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Symfonia C++ Standard', 'Jerzy Grębosz', 'Excellent', 100.00, '', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Linux Biblia', 'Christopher Negus', 'Visibly Used', 120.00, '', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Biologia na czasie 2', 'Marek Guzik, Władysław Zamachowski', 'Very Good', 49.00, '', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Wiedźmin - Ostatnie życzenie', 'Andrzej Sapkowski', 'Like New', 35.50, '', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Clean Code', 'Robert C. Martin', 'Good', 85.00, '', (SELECT id from user_postgres WHERE login = 'piotr_seller')),
('Pan Tadeusz', 'Adam Mickiewicz', 'Acceptable', 15.00, '', (SELECT id from user_postgres WHERE login = 'piotr_seller')),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Very Good', 45.00, '', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('1984', 'George Orwell', 'Like New', 40.00, '', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Harry Potter i Kamień Filozoficzny', 'J.K. Rowling', 'Good', 55.00, '', (SELECT id from user_postgres WHERE login = 'piotr_seller')),
('The Lord of the Rings', 'J.R.R. Tolkien', 'Excellent', 150.00, '', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Thinking, Fast and Slow', 'Daniel Kahneman', 'Visibly Used', 60.00, '', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('Effective Java', 'Joshua Bloch', 'Like New', 180.00, '', (SELECT id from user_postgres WHERE login = 'piotr_seller')),
('The Pragmatic Programmer', 'Andrew Hunt, David Thomas', 'Excellent', 140.00, '', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Zbrodnia i kara', 'Fiodor Dostojewski', 'Acceptable', 25.00, '', (SELECT id from user_postgres WHERE login = 'zofia_reads')),
('The Alchemist', 'Paulo Coelho', 'Good', 30.00, '', (SELECT id from user_postgres WHERE login = 'piotr_seller')),
('Maly Ksiaze', 'Antoine de Saint-Exupéry', 'Like New', 20.00, '', (SELECT id from user_postgres WHERE login = 'janek_bookworm')),
('Design Patterns', 'Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides', 'Good', 200.00, '', (SELECT id from user_postgres WHERE login = 'piotr_seller'));

-- Insert Reviews for Books
INSERT INTO review (rating, comment, reviewer_name, book_id) VALUES
(5, 'Excellent book, a must-read for any C++ enthusiast!', 'User123', (SELECT id from book WHERE title = 'Symfonia C++ Standard')),
(4, 'Very detailed and comprehensive, but can be a bit dense.', 'CodeMaster', (SELECT id from book WHERE title = 'Symfonia C++ Standard')),
(5, 'A classic for a reason. Sapkowski is a master of fantasy.', 'FantasyFan', (SELECT id from book WHERE title = 'Wiedźmin - Ostatnie życzenie')),
(3, 'Good, but not as groundbreaking as some say.', 'PragmaticDev', (SELECT id from book WHERE title = 'Clean Code')),
(5, 'Terrifyingly relevant even today.', 'Reader99', (SELECT id from book WHERE title = '1984')),
(5, 'The foundation of modern Java programming.', 'JavaGuru', (SELECT id from book WHERE title = 'Effective Java')),
(4, 'A bit philosophical but very insightful.', 'Thinker', (SELECT id from book WHERE title = 'Thinking, Fast and Slow')),
(5, 'Magic! Loved it as a child and still do.', 'PotterHead', (SELECT id from book WHERE title = 'Harry Potter i Kamień Filozoficzny')),
(4, 'Deeply psychological and moving.', 'LiteratureLover', (SELECT id from book WHERE title = 'Zbrodnia i kara'));
