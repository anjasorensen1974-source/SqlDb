USE sakila;
GO

SELECT customer_id, COUNT(*) AS NrRentals
FROM dbo.rental
GROUP BY customer_id
ORDER BY 2 DESC;


SELECT r.customer_id, COUNT(*) AS NrRentals, SUM (p.amount) AS RentalAmount
FROM dbo.rental r INNER JOIN dbo.payment p ON r.rental_id = p.rental_id
GROUP BY r.customer_id
ORDER BY RentalAmount DESC;
