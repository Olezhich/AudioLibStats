DROP TABLE IF EXISTS albums;

CREATE TABLE albums (
    id SERIAL PRIMARY KEY,
    format TEXT NOT NULL,
    category TEXT NOT NULL,
    year INT NOT NULL,
    size FLOAT NOT NULL
);

DROP VIEW IF EXISTS album_count;

CREATE OR REPLACE VIEW album_count AS

WITH 

flac_albums AS 
(
SELECT year, COUNT(*) 
FROM albums
WHERE format = 'FLAC' AND category = '1_Studio_Albums'
GROUP BY year
),

dsf_albums AS
(
SELECT year, COUNT(*)
FROM albums
WHERE format = 'DSF' AND category = '1_Studio_Albums'
GROUP BY year
),

all_years AS (
  SELECT generate_series((SELECT MIN(year) FROM albums), (SELECT MAX(year) FROM albums)) AS year
),

wo_gamma AS
(
SELECT make_date(a.year, 1,1) AS year, 
COALESCE(flac_albums.count, 0) AS FLAC,
COALESCE(dsf_albums.count, 0) AS DSF,
COALESCE(dsf_albums.count, 0) + COALESCE(flac_albums.count, 0)  AS all_

FROM all_years as a 
LEFT JOIN dsf_albums ON a.year=dsf_albums.year
LEFT JOIN flac_albums ON a.year=flac_albums.year

ORDER BY year
)

DROP VIEW IF EXISTS by_size_gb;

CREATE VIEW by_size_gb AS

SELECT format, (SUM(size)/1024/1024/1024)::NUMERIC(6,1) as size_gb
FROM albums
GROUP BY format;

DROP VIEW IF EXISTS by_album_count;

CREATE VIEW by_album_count AS

SELECT format, (SUM(size)/1024/1024/1024)::NUMERIC(6,1) as size_gb
FROM albums
GROUP BY format;



