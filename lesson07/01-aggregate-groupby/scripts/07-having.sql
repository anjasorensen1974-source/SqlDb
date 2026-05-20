USE sakila;
GO

SELECT YEAR(rental_date) AS YEAR, DATEPART(week, rental_date) AS WEEK, COUNT(*) AS NrRentals
FROM dbo.rental
GROUP BY YEAR(rental_date), DATEPART(week, rental_date)
HAVING COUNT(*) < 500
ORDER BY 1, 2 ASC


SELECT YEAR(rental_date) AS YEAR, DATEPART(week, rental_date) AS WEEK, 
    COUNT(*) AS NrRentals, 
    SUM (p.amount) AS RentalAmount
FROM dbo.rental r INNER JOIN dbo.payment p ON r.rental_id = p.rental_id
WHERE YEAR(rental_date) = 2005
GROUP BY YEAR(rental_date), DATEPART(week, rental_date)
HAVING SUM (p.amount) > 4000
ORDER BY 3 DESC;
