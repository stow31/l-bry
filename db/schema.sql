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
    bio TEXT
);

CREATE TABLE books_users(
    id SERIAL PRIMARY KEY,
    book_id INTEGER,
    user_id INTEGER,
    book_status TEXT
);


INSERT INTO books (title, author, rating, genre, bio) VALUES (
    'Malibu Rising',
    'Taylor Jenkins Reid',
    4,
    'Fiction',
    'Malibu Rising is a story about one unforgettable night in the life of a family: the night they each have to choose what they will keep from the people who made them . . . and what they will leave behind.'
);

ALTER TABLE books
ADD book_cover_image TEXT;

UPDATE books SET book_cover_image = 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1614630096l/53404196._SY475_.jpg' WHERE id = 1;