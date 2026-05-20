USE music;
GO

-- ============================================================
-- Exercise 1: Scalar Function – Formatted Initials
-- ============================================================

DROP FUNCTION IF EXISTS dbo.udf_ArtistInitials;
GO

CREATE FUNCTION dbo.udf_ArtistInitials
    (@FirstName NVARCHAR(200), @LastName NVARCHAR(200))
RETURNS NVARCHAR(200) AS
BEGIN
    RETURN CONCAT(LEFT(@FirstName, 1), '. ', @LastName);
END;
GO

SELECT dbo.udf_ArtistInitials(FirstName, LastName) AS ShortName,
       BirthDay
FROM dbo.Artist
ORDER BY LastName;

DROP FUNCTION IF EXISTS dbo.udf_ArtistInitials;
GO

-- ============================================================
-- Exercise 2: Scalar Function – Group Era (Conditional Logic)
-- ============================================================

DROP FUNCTION IF EXISTS dbo.udf_GroupEra;
GO

CREATE OR ALTER FUNCTION dbo.udf_GroupEra(@EstablishedYear INT)
RETURNS NVARCHAR(20) AS
BEGIN
    DECLARE @Era NVARCHAR(20);

    IF @EstablishedYear < 1980
        SET @Era = 'Classic';
    ELSE IF @EstablishedYear < 2000
        SET @Era = 'Golden Age';
    ELSE
        SET @Era = 'Modern';

    RETURN @Era;
END;
GO

SELECT Name,
       Genre,
       EstablishedYear,
       dbo.udf_GroupEra(EstablishedYear) AS Era
FROM dbo.MusicGroup
ORDER BY EstablishedYear;

DROP FUNCTION IF EXISTS dbo.udf_GroupEra;
GO

-- ============================================================
-- Exercise 3: Table-Valued Function – Friends by Country
-- ============================================================

USE friends;
GO

DROP FUNCTION IF EXISTS dbo.udf_FriendsByCountry;
GO

CREATE OR ALTER FUNCTION dbo.udf_FriendsByCountry(@Country NVARCHAR(100))
RETURNS TABLE AS
RETURN
    SELECT f.FriendId, f.FirstName, f.LastName, f.Email, a.City
    FROM dbo.Friend  AS f
    INNER JOIN dbo.Address AS a ON f.AddressId = a.AddressId
    WHERE a.Country = @Country;
GO

-- Part 1: call the TVF directly
SELECT FirstName, LastName, Email, City
FROM dbo.udf_FriendsByCountry('Sweden');

-- Part 2: use the TVF as a subquery to find pets owned by friends from 'Sweden'
SELECT p.Name     AS PetName,
       p.AnimalKind
FROM dbo.Pet AS p
WHERE p.OwnerId IN (SELECT FriendId FROM dbo.udf_FriendsByCountry('Sweden'));

DROP FUNCTION IF EXISTS dbo.udf_FriendsByCountry;
GO

-- ============================================================
-- Exercise 4: Table-Valued Functions – UNION of Two TVFs
-- ============================================================

DROP FUNCTION IF EXISTS dbo.udf_HappyPetOwners;
DROP FUNCTION IF EXISTS dbo.udf_MultiplePetOwners;
GO

CREATE OR ALTER FUNCTION dbo.udf_HappyPetOwners()
RETURNS TABLE AS
RETURN
    SELECT f.FirstName, f.LastName, a.Country
    FROM dbo.Friend  AS f
    INNER JOIN dbo.Pet     AS p ON p.OwnerId   = f.FriendId
    INNER JOIN dbo.Address AS a ON f.AddressId = a.AddressId
    WHERE p.AnimalMood = 'Happy';
GO

CREATE OR ALTER FUNCTION dbo.udf_MultiplePetOwners()
RETURNS TABLE AS
RETURN
    SELECT f.FirstName, f.LastName, a.Country
    FROM dbo.Friend  AS f
    INNER JOIN dbo.Pet     AS p ON p.OwnerId   = f.FriendId
    INNER JOIN dbo.Address AS a ON f.AddressId = a.AddressId
    GROUP BY f.FriendId, f.FirstName, f.LastName, a.Country
    HAVING COUNT(p.PetId) > 1;
GO

-- UNION both TVFs to list friends who meet either condition
SELECT DISTINCT FirstName, LastName, Country
FROM (
    SELECT FirstName, LastName, Country FROM dbo.udf_HappyPetOwners()
    UNION
    SELECT FirstName, LastName, Country FROM dbo.udf_MultiplePetOwners()
) AS combined
ORDER BY LastName;

DROP FUNCTION IF EXISTS dbo.udf_HappyPetOwners;
DROP FUNCTION IF EXISTS dbo.udf_MultiplePetOwners;
GO
