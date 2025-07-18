-- Netflix Content Analysis Project
Drop table if exists netflix;
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(135),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(80),
	description VARCHAR(250)
);
SELECT * FROM netflix;

SELECT COUNT(*) AS total_content
FROM netflix;

SELECT DISTINCT type AS type_of_content
FROM netflix;

SELECT COUNT(type) AS movie_content_count
FROM netflix
WHERE type='Movie';

--BUSINESS Problems.

--Q1. COUNT the number of Movies and TV Shows.
SELECT type,COUNT(*) AS movie_content_count
FROM netflix
GROUP BY type;

--Q2. Find the most common ratings for movies and tv shows.
SELECT 
	type,
	rating
FROM
(SELECT 
	type,
	rating,
	COUNT(*),
	DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(*) desc) AS ranking
FROM netflix
GROUP BY 1,2
) AS t1
WHERE 
	ranking =1;

--Q3.List all the movies released in a specific year.eg(2020) also give the total count.
-- List of all movies released in 2020
SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

-- Count of movies released in 2020
SELECT COUNT(*) AS total_movies_2020
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

--Q4.Find the top 5 countries with the most content on netflix.
SELECT  
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as new_country,
	COUNT(show_id) AS most_content
FROM netflix
GROUP BY new_country
ORDER BY most_content DESC LIMIT 5;

--Q5.Identify the longest movie.
SELECT *
FROM netflix
WHERE type='Movie' AND duration=(SELECT MAX(duration) FROM netflix);
				
--Q6.Find the content added in last 5 years.
SELECT *
FROM netflix
WHERE TO_DATE(date_added,'MONTH DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--Q7.Find all the movies/tv shows by director 'Rajiv Chilaka'.
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--Q8.List all TV shows with more than 5 seasons.
SELECT *
FROM netflix	   
WHERE type = 'TV Show'
			AND 
			  SPLIT_PART(duration,' ',1)::int > 5 ;

--Q9.Count the number of content items in each genre.
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in ,',')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in ,','));

--Q10.Find each year and the average numbers of content
-- release by India on netflix. Return top 5 year with 
-- highest avg content release.
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(show_id) AS total_count,
    ROUND(COUNT(show_id) * 100.0 / (SELECT COUNT(show_id) FROM netflix WHERE country='India'),2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'));


--Q11.List all the movies that are documentries.
SELECT * FROM netflix
WHERE type='Movie' AND listed_in LIKE '%Documentaries%';

--Q12.Find all the content without a director.
SELECT * FROM netflix
WHERE 
	director IS NULL;

--Q13.Find how many movies actor 'Salman Khan' appeared in last 12 years.
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND casts ILIKE '%Salman Khan%'
 AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 12;
 
--Method 2:
SELECT *
FROM netflix,
 UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
WHERE type = 'Movie'
  AND TRIM(actor) = 'Salman Khan'
  AND TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '12 years'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 12;

--Q14.Find the top 10 actors who have appeared in the highest
--number of movies produced in India.
SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS actors,
COUNT(type) as total_content
FROM netflix
WHERE type='Movie' AND country ILIKE '%India%'
GROUP BY 1
ORDER BY total_content DESC LIMIT 10;

--Q15.Categorize the content based on the presence of the 
--keywords 'kill' and 'violence' in the description field
--Label content containing these keywords as 'Bad' and all
--other contents as 'Good'.Count how many items fall in each category.
SELECT COUNT(*) total_content,
		CASE
		WHEN description  ILIKE '%kill%'
		OR 
		description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END category
FROM netflix
GROUP BY category;

--Method 2:
WITH new_table AS
(
SELECT *,
		CASE
		WHEN description  ILIKE '%kill%'
		OR 
		description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;
	
