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

flac AS 
(
SELECT year, COUNT(*) 
FROM albums
WHERE format = 'FLAC'
GROUP BY year
),

dsf AS
(
SELECT year, COUNT(*)
FROM albums
WHERE format = 'DSF'
GROUP BY year
),

all_years AS (
  SELECT generate_series((SELECT MIN(year) FROM albums), (SELECT MAX(year) FROM albums)) AS year
)

SELECT make_date(a.year, 1,1) AS year, 
COALESCE(dsf.count, 0) AS dsf,
COALESCE(flac.count, 0) AS flac,
COALESCE(dsf.count, 0) + COALESCE(flac.count, 0) AS all

FROM all_years as a 
LEFT JOIN dsf ON a.year=dsf.year
LEFT JOIN flac ON a.year=flac.year

ORDER BY year;

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



