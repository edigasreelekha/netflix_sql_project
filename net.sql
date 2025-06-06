create database net;
use net;

CREATE TABLE IF NOT EXISTS netflix (
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(50),
    title VARCHAR(255),
    director VARCHAR(255),
     casts   VARCHAR(1050),
    country VARCHAR(255),
    date_added VARCHAR(50), -- Store as VARCHAR and convert during import
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
     description  VARCHAR(550)
);
-- 1. Count the Number of Movies vs TV Shows 
SELECT 
    type,
    COUNT(*) as type_count
FROM netflix
GROUP BY 1;

-- 2  Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rnk
    FROM RatingCounts
)

-- 3 List All Movies Released in a Specific Year (e.g., 2020) 
select * 
from netflix
where release_year = 2020; 

-- 4. Find the Top 5 Countries with the Most Content on Netflix
 SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the Longest Movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1) DESC;

-- 6. Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years' ;

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM (
	SELECT *,
			UNNEST(STRING_TO_ARRAY(director,',')) as director_name
            from netflix 
		) as t 
        where director_name = 'Rajiv Chilaka';
        
-- 8 List All TV Shows with More Than 5 Seasons
select * 
from netflix
where type = 'TV Show'
	and split_part(duration, ' ', 1) :: int >5;
    
-- 9. Count the Number of Content Items in Each Genre
SELECT  
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

-- 10.Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find All Content Without a Director
SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13 Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE cast LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
