USE sakila;
GO

--CREATE a function, once created use ALTER to change
CREATE OR ALTER FUNCTION dbo.udf_FullName(@fn NVARCHAR(200), @ln NVARCHAR(200))
RETURNS NVARCHAR(400) AS
BEGIN
    RETURN CONCAT_WS(' ', @fn, @ln)
END;
GO

--CREATE a stored procedure
CREATE OR ALTER PROC dbo.usp_Actors AS
    
    SET NOCOUNT ON;
    
    SELECT a.actor_id, f.title, dbo.udf_FullName(a.first_name, a.last_name) [actor]
    FROM dbo.actor a
    INNER JOIN dbo.film_actor fa ON a.actor_id = fa.actor_id
    INNER JOIN dbo.film f ON f.film_id = fa.film_id
    ORDER BY 2
    
GO

--Execute the stored procedure
EXEC dbo.usp_Actors;



-- List all stored procedures in the database
SELECT SCHEMA_NAME(schema_id) +'.' + name AS ProcedureName
FROM   sys.procedures;

--House cleaning only for the example
DROP FUNCTION IF EXISTS dbo.udf_FullName;
DROP PROCEDURE IF EXISTS dbo.usp_Actors;
GO
