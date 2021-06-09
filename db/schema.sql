CREATE DATABASE l_bry;

\c l_bry

CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    email TEXT,
    password_digest TEXT,
    first_name TEXT,
    last_name TEXT
);

CREATE TABLE books(
    id SERIAL PRIMARY KEY,
    title TEXT,
    author TEXT,
    cover_image TEXT,
    rating DECIMAL,
    genre TEXT,
    bio TEXT,
    google_id TEXT
);

CREATE TABLE books_users(
    id SERIAL PRIMARY KEY,
    book_id TEXT,
    user_id INTEGER,
    book_status TEXT
);

-- Book Status either : want, current or read 


INSERT INTO books (title, author, rating, genre, bio) VALUES (
    'Malibu Rising',
    'Taylor Jenkins Reid',
    4,
    'Fiction',
    'Malibu Rising is a story about one unforgettable night in the life of a family: the night they each have to choose what they will keep from the people who made them . . . and what they will leave behind.'
);

ALTER TABLE books
ADD book_cover_image TEXT;


ALTER TABLE books
ADD google_id INTEGER;

UPDATE books SET book_cover_image = 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1614630096l/53404196._SY475_.jpg' WHERE id = 1;

INSERT INTO books_users (book_id, user_id, book_status) VALUES ( #{google_id}, #{session[:user_id]}, 'want')

UPDATE books_users SET book_status = 'current' WHERE user_id = 1 AND book_id = 'rolgBAAAQBAJ';

SELECT * FROM books_users WHERE user_id = 12 AND book_id = '#MNaczQEACAAJ';