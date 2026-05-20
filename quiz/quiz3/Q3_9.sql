USE sakila;
GO


SELECT co.country, YEAR(rental_date) AS [Year], DATEPART(month, rental_date) AS [Month], 
    COUNT(*) AS NrRentals, 
    SUM (p.amount) AS RentalAmount

FROM dbo.rental r 
INNER JOIN dbo.payment p ON r.rental_id = p.rental_id
INNER JOIN dbo.staff s ON r.staff_id = s.staff_id
INNER JOIN dbo.store st ON s.store_id = st.store_id
INNER JOIN dbo.address a ON st.address_id = a.address_id
INNER JOIN dbo.city c ON a.city_id = c.city_id
INNER JOIN dbo.country co ON c.country_id = co.country_id


GROUP BY co.country, YEAR(rental_date), DATEPART(month, rental_date) WITH ROLLUP
ORDER BY 1,2,3;
    