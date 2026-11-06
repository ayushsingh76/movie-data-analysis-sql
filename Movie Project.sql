-- create database name movie 
create database movie;
use movie;

-- -- create table 
CREATE TABLE movies_raw (
    row_num INT,
    id BIGINT,
    original_language VARCHAR(10),
    original_title TEXT,
    popularity DECIMAL(12,3),
    release_date DATE,
    vote_average DECIMAL(4,2),
    vote_count INT,
    genre TEXT,
    overview TEXT,
    revenue BIGINT,
    runtime INT,
    tagline TEXT
    )
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
 
 -- import data 
LOAD DATA LOCAL INFILE 'C:/Users/ayush singh/Downloads/ABHI  movie.csv'
INTO TABLE movies_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from movies_raw;

-- Enable and Check LOCAL INFILE in MySQL
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- create database movies_import like movies_raw for correct the date values
CREATE TABLE movies_import LIKE movies_raw;
-- alter release_date into str
ALTER TABLE movies_raw
MODIFY release_date VARCHAR(20);

-- here we re import data in movies_import 
LOAD DATA LOCAL INFILE 'C:/Users/ayush singh/Downloads/ABHI  movie.csv'
INTO TABLE movies_import
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
-- count the actual data in dataset 
SELECT COUNT(*)
FROM movies_import;
--  convert date ftom str to date 
SELECT
    original_title,
    release_date,
    STR_TO_DATE(release_date, '%d-%m-%Y') AS correct_date
FROM movies_import
LIMIT 10;

select * from movies_import;

-- describe data 
describe movies_import;

-- check missing values
select count(*) as total_count,
sum(row_num is null ) as missing_row,
sum(id is null ) as missing_id,
sum(original_language is null ) as missing_language,
sum(original_title is null ) as missing_title,
sum(popularity is null ) as missing_popularity,
sum(vote_average is null) as missing_vote,
 sum(vote_count is null) as missing_vote_count,
 sum(genre is null) as missing_genre,
 sum(overview is null) as missing_overview,
 sum(revenue is null) as missing_revenue,
 sum(runtime  is null) as missing_runtime,
 sum(tagline is null) as missing_tagline
 from movies_import;

-- (check duplicate)
select id,count(*) as duplicate_values
from movies_import 
group by id
having count(*) > 1;

-- (extarct duplicate)
-- 14 duplicates in this dataset 
select * from movies_import
where id in (select id from 
movies_import
group by id 
having count(*) > 1)
order by id;

-- check how many id are 0 
select count(*) from movies_import 
where id = 0;

-- -- count missing title
select count(*) from movies_import
where original_title is null 
or trim(original_title) = " "; 


-- delete duplicate 
delete from movies_import
where id = 0 
and(original_language is null or trim(original_language)='')
and(original_title is null or trim(original_title) = '')
and popularity = 0 
and vote_average = 0 
and vote_count = 0 
and (genre is null or trim(genre) = '')
and (overview is null or trim(overview) ='')
and revenue = 0 
and runtime = 0 
and (tagline is null or trim(tagline) ='');

delete from  movies_import
where id =  0
or original_title = 'Disney Tinkerbell Animated Short';

-- fill vote_average
select id,vote_average from movies_import;


-- mean  is 6.298750
select avg(vote_average) as mean_rateing 
from movies_import 
where vote_average is not null ;

-- median is 6.500000
with ranked as (
select vote_average ,
row_number() over(order by vote_average) as rn ,
count(*) over() as total_rows
from movies_import 
where vote_average is not null )
select avg(vote_average) as median_rateing
from ranked
where rn in(
floor((total_rows + 1) /2),
floor((total_rows + 2)/2)
);

-- The percentage difference between the mean (6.298750) and median (6.500000) of vote_average is approximately 3.19%.
-- 

select count(*) from movies_import;

select * from movies_import;


-- SECTION 1: BASIC SELECT & FILTERING (1-20)
-- 1. Select all columns from movies_raw
select * from movies_import;

-- 2. Select movie title and revenue
select original_title , revenue from movies_import;

-- -- 3. Select unique original_language
select  distinct( original_language) from movies_raw;

-- 5. Select movies with an alias
select original_title  as movie , runtime as watch_time from movies_raw;

-- -- 6. Select movie titles and constant string
select original_title , 'Movie' as type from movies_raw;

-- 7. Select movies where duration is greater than 100
select * from movies_raw 
where runtime > 100;

-- 8. Select movies where gross is less than 10M
select * from movies_raw
where revenue < 100000000;

-- 9. Select movies released after 2000
select * from movies_import
where release_date >= '2000-01-01';

-- -- 10. Select movies from Japan
select original_title from movies_raw
where original_language = 'ja';

-- 11. English movies with gross > 50M
select original_title , revenue from movies_raw
where original_language = 'en' and revenue > 50000000;

-- -- 12. Movies from USA or Japan
select original_title , revenue from movies_raw
where original_language in ('en' , 'ja');

-- 13. Movies not from USA
select * from movies_raw
where original_language != 'en';

-- 14. Movies with duration between 90 and 120
select * from movies_raw
where runtime between 90 and 120 ;

-- -- 15. Movies with duration NOT between 90 and 120
select * from movies_raw
where runtime != 90 and 120 ;

-- -- 16. Movies in specific languages using IN
select original_title from movies_raw
where original_language  in ('en');

-- 17  Movies NOT in specific languages using IN
select original_title from movies_raw
where original_language not in ('en');

-- 18. Movies starting with 'The'
select original_title from movies_raw
where  original_title like 'The%'; 

-- -- 19. Movies ending with 'y'
select original_title from movies_raw
where  original_title like '%y'; 

-- -- 20. Movies containing 'King'
select original_title from movies_raw
where  original_title like '%King%'; 

-- SECTION 2: SORTING & LIMITING (21-30)

-- 21. Order by title ASC
select * from movies_raw
order by original_title asc;

--  22. Order by gross DESC
select * from movies_import
order by revenue desc;

-- -- 23. Order by country, then title
select * from movies_import
order by original_title , original_language;

 -- 24. Get top 3 grossing movies
select * from movies_raw
order by revenue desc
limit 3;

-- -- 25. Get bottom 3 grossing movies
select * from movies_raw
order by revenue asc
limit 3;

-- -- 26. Get highest rated movie
select * from movies_raw
order by popularity desc
limit 5;

-- 27. Get second highest grossing movie (OFFSET)
-- OFFSET is use for skip the result from starting 
select * from movies_raw
order by revenue desc
limit 1 offset 1;

-- 28. Get 3rd to 5th longest movies
select * from movies_raw
order by runtime desc 
limit 3 offset 2;

-- -- 29. Order movies by length of title
select original_title from movies_import
order by length(original_title) ;

-- 30. Get randomly ordered movies
select original_title from movies_raw
order by rand();

-- SECTION 3: STRING & NUMBER FUNCTIONS (31-50)

-- 31. Uppercase titles
select upper(original_title) from movies_raw;

-- -- 32. Lowercase titles
select lower(original_title) from movies_raw;

-- -- 33. Title length
select length(original_title) from movies_raw;

-- -- 34. Concatenate title and country
select concat( original_title ,'(', original_language,')') from movies_raw;

-- - 35. Substring first 5 characters
select substring(original_title ,1,5) from movies_raw;

-- 36. Extract year from string 
select left(release_date , 4) from movies_raw_backup;

-- -- 37. Right 3 chars of title
select right (original_title ,3) from movies_raw;

-- 38. Replace 'The' with 'A'
select replace(original_title,'The','A') from movies_raw;

-- -- 39. Trim spaces 
select trim(' ' from original_title) from movies_raw;

-- -- 40. Find position of 'a' in title
select instr(original_title , 'a') from movies_raw;

-- -- 41. Gross in millions
select  revenue / 10000000 from movies_raw;

-- -- 42. Round gross to nearest million
select  round(revenue / 10000000) from movies_raw;

 -- 43. Ceiling of imdb
select ceil(popularity) from movies_raw;

-- -- 44. Floor of imdb
select floor(popularity) from movies_raw;

-- - 45. Absolute value 
select abs(popularity) from movies_raw;

-- -- 46. Modulo of duration by 60 (hours and mins)
select runtime % 60 as remaining_movie from movies_raw;

-- - 47. Power 
select power(popularity , 2) from movies_raw;

-- -- 48. Square root of gross
select SQRT(revenue) from movies_raw;

-- -- 49. Truncate imdb to 1 decimal
select truncate(popularity ,1) from movies_raw;

-- -- 50. Sign of gross (1 for pos)
-- sign is use to check number is -ve.-ve,0
select sign(popularity) from movies_raw;

-- SECTION 4: DATE FUNCTIONS & CASE STATEMENTS (51-60)
-- 51. Extract Year when date in varchar
select year(STR_TO_DATE(release_date, '%Y-%m-%d')) as release_year
from  movies_import;

-- -- 52. Extract Month
select month(str_to_date(release_date,'%Y-%m-%d')) as release_month
from movies_import;

-- 53. Extract Day
select day(str_to_date(release_date,'%Y-%m-%d')) as release_day 
from movies_import;

-- -- 54. Format Date
select date_format(str_to_date(release_date,'%Y-%m-%d'),'%M %D, %Y') as format_date
from movies_import;

-- 55. Add 10 days to release date
select date_add(str_to_date(release_date,'%Y-%m-%d'),interval 10 day ) from 
movies_import;

-- 56. Subtract 1 month
select date_sub(str_to_date(release_date,'%Y-%m-%d'),interval 1 month ) from 
movies_import;

-- 57. Difference between release date and now
select datediff(current_date(),(str_to_date(release_date,'%Y-%m-%d'))) from movies_import;

-- 58. Get current date alongside title
select original_title , current_date() from movies_import;

-- 59. Gross Categories (CASE WHEN)
select original_title , 
case when revenue > 165000000 then 'Superhit' 
else 'Floap' end  from movies_import;

-- -- 60. Rating Categories (CASE WHEN)
select original_title ,
case when vote_average >= 7 then 'Excellent' else 'Good' 
end from movies_import;

-- SECTION 5: AGGREGATION & GROUP BY (61-75)
 -- 61. Total movies
 select count(*)from movies_import;
 
 -- -- 62. Total gross
 select sum(revenue) from movies_import;
 
 -- -- 63. Average gross
 select avg(revenue) from movies_import;
 
 --  64. Min duration
 select min(runtime) from movies_import;
 
 -- -- 65. Max duration
 select max(runtime) from movies_import;
 
 --  -- 66. Movies per country
 select original_language , count(*) from movies_raw
 group by  original_language;
 
 -- - 67. Movies per language
 select original_language , count(*) from movies_raw
 group by  original_language;
 
 -- -- 68. Total gross per country
 select original_language , sum(revenue) as total_revenue 
 from movies_raw
 group by  original_language;
 
 -- -- 69. Avg duration per language
  select original_language , avg(runtime) as avg_runtime
 from movies_raw
 group by  original_language;
 
 -- -- 70. Countries with > 1 movie
 select * from movies_raw
 where original_language > 1;
 
 -- -- 71. Countries with avg gross > 10M
 select * from movies_raw
 where revenue > 100000000;
 
 -- 72. Max gross per release year
 select year(STR_TO_DATE(release_date, '%Y-%m-%d')) ,sum(revenue) 
 from movies_import 
 group by year(STR_TO_DATE(release_date, '%Y-%m-%d'));
 
 -- -- 73. Min imdb 
 select min(vote_average) from movies_import;
 
 -- -- 74. Avg imdb
 select avg(vote_average) from movies_import;
 
 -- -- 75. Count non-null imdb
  select count(vote_average)
  from movies_import;
  
  -- SECTION 6: JOINS & SUBQUERIES (76-95)
-- - 86. Movie with highest gross (Subquery)
select * from movies_import
where revenue = (select max(revenue) from 
movies_import);
-- 87. Movies with above average gross
select * from movies_import
where revenue > (select avg(revenue) from 
movies_import);

-- -- 88. Movies from countries with > 1 movie
select * from movies_import 
where original_language in (select original_language
from movies_import
group by original_language
having count(*) > 1);

-- 89. Movies with rating > 8
select * from movies_import
where id in (select id
from movies_import
where vote_average > 8);

-- -- 90. Movies not in info table
select * from movies_import
where id not in (select id
from movies_import);

-- -- 91. Correlated subquery (above avg for their country)
select * from movies_import m
where revenue >(select avg(revenue) from 
movies_import
where  original_language = m.original_language);

-- -- 92. EXISTS clausese;
select * from movies_import m
where exists (select 1 from movies_import i 
where i.id = m.id and i.vote_average < 5);

-- 93. NOT EXISTS
select * from movies_import m
where not exists (select 0 from movies_import i 
where i.id = m.id and i.vote_average < 5);

-- - 94. Subquery in SELECT
select id , original_title, (
select avg(vote_average) from movies_import) as overall_avg
from movies_import;

-- -- 95. Subquery in FROM
select original_language ,a from (
select original_language , avg(revenue)
as a 
from movies_import 
group by original_language) as l;

--  -- -- SECTION 7: ADVANCED - WINDOW FUNCTIONS & CTE (96-105)
-- 96. ROW_NUMBER
select original_title,
row_number() over(
order by vote_average desc) as rateing 
from movies_import;

-- -- . RANK
select original_title,
rank() over(
order by revenue desc) as rateing 
from movies_import;

-- 98. DENSE_RANK
select original_title,
dense_rank() over( order by popularity) as rank_1
from movies_import;

-- -- -- 99. Partitioned ROW_NUMBER
select original_title, original_language,
row_number () over(partition by original_language 
order by revenue) as rank_2
from movies_import;

-- -- 100. LEAD (Next movie's gross)
select id, original_title, revenue,
lead(revenue) over(order by revenue asc) as next_revenue
from movies_import;
 -- 101 lag
 select id , original_title, revenue,
 lag( revenue) over(order by revenue asc) as pre_revenue
 from movies_import;

-- -- 102. Running Total
select id , original_title, revenue,
sum(revenue) over (order by popularity asc)
from movies_import;

-- -- 103. NTILE (Quartiles)
select original_title,
ntile(4) over(order by revenue asc)
from movies_import;

-- -- 104. Simple CTE
with c as(
select * from movies_import 
where vote_count > 1700 )
select * from c;

-- 105. CTE with Window
with ranked as (
select original_title ,
row_number() over(order by popularity desc) as rnk
from movies_import)
select * from ranked
where rnk = 1;

-- 1. RANK() and DENSE_RANK() by IMDb score
select m.original_title, i.popularity,
rank() over(order by i.popularity desc ) as pop,
dense_rank() over(order by i.popularity desc) as popp
from movies_import m
join 


-- -- 2. ROW_NUMBER() Partitioned by Country
select original_title,
row_number() over(partition by original_language
order by popularity desc)
from movies_import;

-- -- 3. LAG() to compare chronological releases (finding gross difference from previous release)
select original_title,
lag(release_date) over(order by revenue desc) as pre_movie_pro,
revenue - lag(release_date) over(order by revenue desc) diff_re
from movies_import;

-- 4. Running Total (Cumulative Sum) of gross revenue over time
select original_title,
sum(revenue) over(order by release_date desc) 
from movies_import;

-- 5. NTILE() for grouping into 4 Quartiles based on gross
SELECT original_title,
ntile(4) over(order by revenue  desc) 
from movies_import;

select * from movies_import;


