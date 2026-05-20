USE friends;
GO

--House cleaning
DROP FUNCTION IF EXISTS dbo.udf_MostPets;
DROP FUNCTION IF EXISTS dbo.udf_LeastFriends;
GO

--Create a table-valued function that returns the country with the most pets of a given kind, 
--and the number of those pets
CREATE OR ALTER FUNCTION dbo.udf_MostPets(@AnimalKind As NVARCHAR(20))
RETURNS TABLE AS
RETURN 

    SELECT Top 1 a.Country, COUNT(p.PetId) [Nr of Pets] FROM dbo.Friend f
    INNER JOIN dbo.Pet p ON f.FriendId = p.OwnerId
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
    WHERE AnimalKind = @AnimalKind
    GROUP BY a.Country
    ORDER BY 2 DESC
GO

--Create a table-valued function that returns the country with the least friends, and the number of friends
CREATE OR ALTER FUNCTION dbo.udf_LeastFriends()
RETURNS TABLE AS
RETURN 
    SELECT TOP 1 a.Country, COUNT(f.FriendId) [Nr of Friends] FROM dbo.Friend f
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
    GROUP BY a.Country
    ORDER BY 2 ASC 
GO

--test it
SELECT * FROM dbo.udf_MostPets('Cat');
SELECT * FROM dbo.udf_LeastFriends();

--Now it is easy to use as a subquery, For example
--List all cities in the countries where I have least friends or most pets 
SELECT DISTINCT Country, City FROM dbo.Address
WHERE Country IN (
    SELECT Country from dbo.udf_MostPets('Cat')
    UNION
    SELECT Country from dbo.udf_LeastFriends());


--House cleaning
DROP FUNCTION IF EXISTS dbo.udf_MostPets;
DROP FUNCTION IF EXISTS dbo.udf_LeastFriends;
GO