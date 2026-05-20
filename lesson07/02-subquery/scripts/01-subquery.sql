USE sakila;
GO

--As query by itself
(SELECT country_id FROM country WHERE country = 'India');

--As subquery
SELECT city_id, city 
FROM dbo.city
WHERE country_id <> (SELECT TOP 1 country_id FROM country WHERE country = 'India');

--As query by itself
(SELECT  MAX (amount) FROM dbo.payment);

--As subquery
SELECT film_id
FROM dbo.film
WHERE replacement_cost < (SELECT  MAX (amount) FROM dbo.payment);
