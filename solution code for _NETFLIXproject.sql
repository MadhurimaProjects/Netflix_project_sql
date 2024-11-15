--Netflix Project

CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	show_type VARCHAR(10),
	title	VARCHAR(120),
	director VARCHAR(210),
	casts 	VARCHAR(800),
	country  VARCHAR(140),
	date_added	VARCHAR(20),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(85),
	description VARCHAR(260)
);

SELECT * FROM netflix;

SELECT 
	COUNT(*) as total_content
FROM netflix;

SELECT 
  DISTINCT show_type
FROM netflix;

--15 Business Problems

--1. Count the number of Movies vs Tv shows
SELECT 
  show_type,
  COUNT(*) as total_content
FROM netflix
GROUP BY show_type;

--2.Find the most common rating for movies and TV shows
SELECT
	show_type,
	rating
FROM
(SELECT 
  show_type,
  rating,
  COUNT(*),
  RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC ) AS ranking
FROM netflix
GROUP BY 1,2
--ORDER BY 1, 3 DESC
) as t1
WHERE 
ranking =1
;


--3.List all movies released in a specific year(eg 2020,..)

SELECT * FROM netflix;

SELECT *
FROM netflix
WHERE show_type='Movie' AND release_year=2020;

--4.Find the top 5 countires with the most content on Netflix

SELECT * FROM netflix;
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(*) AS total_count
FROM netflix
GROUP BY new_country
ORDER BY 2 DESC
LIMIT 5;


--5. Select the longest movie

SELECT * FROM netflix;

SELECT *
FROM
(SELECT DISTINCT title as movie,
	split_part(duration,' ',1)::numeric AS duration
FROM netflix
WHERE show_type= 'Movie') as t2
WHERE duration = 
  (SELECT MAX(split_part(duration, ' ', 1)::numeric) 
   FROM netflix);

--6. Find content added in last 5 years
SELECT * FROM netflix;

SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE-INTERVAL '5 years'


--7. Find all the movies or TV shows where Junko Takeuchi is casted
SELECT * FROM netflix;

SELECT * FROM netflix
WHERE casts ILIKE '%Junko Takeuchi%';


--8.List all the Tv shows which has more than 5 seasons
SELECT * FROM netflix;

SELECT *
FROM netflix
WHERE show_type='TV Show' AND split_part(duration,' ',1)::numeric >=5;

--9.Count the number of contents items in each genre
SELECT * FROM netflix;

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1;

--10.Find each year and the average number of content released by Japan on netflix
--return top 5 year with highest average content release

SELECT * FROM netflix;

SELECT 
	EXTRACT(year FROM TO_DATE(date_added,'Month DD ,YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%Japan%')::numeric*100 ,2)as avg_no_of_content
FROM netflix
WHERE country ILIKE '%Japan%' 
GROUP BY 1
ORDER BY 1 DESC;

--11. List all the movies that are documentaries
SELECT * FROM netflix;

SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

--12.Find all TV shows and movies without a director
SELECT * FROM netflix;

SELECT *
FROM netflix
WHERE director IS NULL;

--13.Find how many movies actor "Shah Rukh Khan" appeared in last 10 days
SELECT * FROM netflix;

SELECT * 
FROM netflix
WHERE casts ILIKE '%Shah Rukh Khan%'
AND release_year>EXTRACT(YEAR FROM CURRENT_DATE)-10;

--14.Find the top 10 actors who have appeared in the highest number of movies from United States.
SELECT * FROM netflix;

SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) as Actors,
	COUNT(*) as total_movies_acted_in
FROM netflix
WHERE country ILIKE '%India%' 
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
--Label containing these keywords as 'bad' and all other as 'good'. Count how many times each item fall into each category

SELECT * FROM netflix;

WITH rating_table
as
(
SELECT 
*,
	CASE 
	WHEN
		 description ILIKE '%kill%' OR
		 description ILIKE '%violence%' THEN 'Bad content'
		 ELSE 'Good content'
	END category
FROM netflix
)
SELECT 
	category,	
	COUNT(*)  as total
FROM rating_table
GROUP BY 1;
