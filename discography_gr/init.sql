DROP TABLE IF EXISTS albums;

CREATE TABLE albums (
    id SERIAL PRIMARY KEY,
    format TEXT NOT NULL,
    year INT NOT NULL,
    size FLOAT NOT NULL
);
