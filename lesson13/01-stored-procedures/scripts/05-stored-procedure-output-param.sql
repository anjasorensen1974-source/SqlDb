USE friends;
GO

--Create a stored procedure that gets all the friends in a specific city
--Using parameters with default vaues
CREATE OR ALTER PROCEDURE dbo.usp_GetFriends 
    @Country NVARCHAR(200),
    @City NVARCHAR(200),

    --Use an output variable to return number of rows in the dataset
    @Count INT OUTPUT AS

    SELECT f.*, a.City, a.Country FROM dbo.Friend f 
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
    WHERE a.Country = @Country AND a.City = @City

    --@@ROWCOUNT always number of rows affected in last statement
    SET @Count = @@ROWCOUNT; 

    --alternative way to get the count, but less efficient as it has to run the query twice
    --SELECT @Count = COUNT(*) FROM dbo.Friend f 
    --INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
    --WHERE a.Country = @Country AND a.City = @City
GO

--Executing
DECLARE @NrFriends INT
EXEC dbo.usp_GetFriends 'Sweden', 'Stockholm', @NrFriends OUTPUT;

PRINT @NrFriends;

--House cleaning only for the example
DROP PROCEDURE IF EXISTS dbo.usp_GetFriends;