USE sakila;
GO

--view can use all clauses in a SELECT, just as a table of CTE
SELECT [store country], [store city], COUNT ([cus id]) AS [nr customers]
FROM dbo.vw_customer_store
GROUP BY [store country], [store city]
ORDER BY 1


--view can be inner joined to tables as well 
SELECT [store country], [store city], 
        COUNT ([cus id]) AS [nr customers], 
        SUM (p.amount) AS [total sales]
FROM dbo.vw_customer_store AS vw_cs
INNER JOIN dbo.payment p ON vw_cs.[cus id] = p.customer_id
GROUP BY [store country], [store city]
ORDER BY 1

--simple verification of rather complex views creations
SELECT SUM (amount) FROM dbo.payment;
