-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

USE mavenmovies;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA -
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM customer;
SELECT * FROM film;

-- You need to provide customer firstname, lastname and email id to the marketing team --

SELECT first_name,last_name,email
FROM customer;

-- How many movies are with rental rate of $0.99? --

SELECT *
FROM film
WHERE rental_rate = 0.99;

-- We want to see rental rate and how many movies are in each rental category --

SELECT rental_rate,count(*) AS total_num_of_movies
FROM film
group by rental_rate;

-- Which rating has the most films? --

SELECT RATING,COUNT(*) AS RATING_CATEGORY_COUNT
FROM FILM
GROUP BY RATING
ORDER BY RATING_CATEGORY_COUNT DESC;

-- Which rating is most prevalant in each store? --

SELECT INV.store_id,F.rating,COUNT(*) AS TOTAL_FILMS
FROM inventory AS INV LEFT JOIN
	film AS F
ON INV.film_id = F.film_id
GROUP BY INV.store_id,F.rating
ORDER BY TOTAL_FILMS DESC;

-- List of films by Film Name, Category, Language --

SELECT F.TITLE, LANG.NAME AS LANGUAGE_NAME,C.NAME AS CATEGORY_NAME
FROM FILM AS F LEFT JOIN LANGUAGE AS LANG
ON F.LANGUAGE_ID = LANG.LANGUAGE_ID
LEFT JOIN film_category AS FC
ON F.FILM_ID = FC.FILM_ID
LEFT JOIN CATEGORY AS C
ON FC.CATEGORY_ID = C.CATEGORY_ID;

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

SELECT TITLE,SPECIAL_FEATURES
FROM FILM
WHERE SPECIAL_FEATURES LIKE '%Behind the Scenes%';

-- unique movie ratings and number of movies

SELECT RATING,COUNT(FILM_ID) AS NUMBER_OF_FILMS
FROM FILM
GROUP BY RATING;

-- Could you please pull a count of titles sliced by rental duration?

SELECT RENTAL_DURATION,COUNT(FILM_ID) AS NUMBER_OF_FILMS
FROM FILM
GROUP BY RENTAL_DURATION;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT RATING,
	COUNT(FILM_ID)  AS COUNT_OF_FILMS,
    MIN(LENGTH) AS SHORTEST_FILM,
    MAX(LENGTH) AS LONGEST_FILM,
    AVG(LENGTH) AS AVERAGE_FILM_LENGTH,
    AVG(RENTAL_DURATION) AS AVERAGE_RENTAL_DURATION
FROM FILM
GROUP BY RATING
ORDER BY AVERAGE_FILM_LENGTH;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?

SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUM_OF_FILMS,
    MIN(RENTAL_RATE) AS CLIP_RENTAL,
    MAX(RENTAL_RATE) AS EXP_RENTAL,
    AVG(RENTAL_RATE) AS AVG_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;

-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTAL
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTAL < 15;
	
-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- CATEGORIZE MOVIES AS PER LENGTH

SELECT TITLE,LENGTH,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;

-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;

-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”

SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,
	CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'store 1 active'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'store 1 inactive'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'store 2 active'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'store 2 inactive'
        ELSE 'ERROR'
	END AS STORE_AND_STATUS
FROM CUSTOMER;

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

SELECT DISTINCT INVENTORY.INVENTORY_ID,
				INVENTORY.STORE_ID,
                FILM.TITLE,
                FILM.DESCRIPTION 
FROM FILM INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID;

-- Actor first_name, last_name and number of movies

SELECT ACTOR.ACTOR_ID,ACTOR.FIRST_NAME,ACTOR.LAST_NAME,COUNT(FILM_ACTOR.FILM_ID) AS NUMBER_OF_FILMS
FROM ACTOR LEFT JOIN FILM_ACTOR ON ACTOR.ACTOR_ID= FILM_ACTOR.ACTOR_ID
GROUP BY ACTOR.ACTOR_ID
ORDER BY NUMBER_OF_FILMS DESC;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT FILM.TITLE, COUNT(FILM_ACTOR.ACTOR_ID) AS NUMBER_OF_ACTORS
FROM FILM LEFT JOIN FILM_ACTOR ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY FILM.TITLE
ORDER BY NUMBER_OF_ACTORS DESC;

-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
SELECT ACTOR.FIRST_NAME,ACTOR.LAST_NAME,FILM.TITLE
FROM ACTOR INNER JOIN FILM_ACTOR ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
INNER JOIN FILM ON FILM_ACTOR.FILM_ID = FILM.FILM_ID
ORDER BY ACTOR.LAST_NAME, ACTOR.FIRST_NAME;

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

SELECT * FROM STAFF;
SELECT * FROM ADVISOR;
(SELECT FIRST_NAME,LAST_NAME,'ADVISORS' AS DESIGNATION
FROM ADVISOR
UNION
SELECT FIRST_NAME,LAST_NAME,'STAFF MEMBER' AS DESIGNATION
FROM STAFF);









