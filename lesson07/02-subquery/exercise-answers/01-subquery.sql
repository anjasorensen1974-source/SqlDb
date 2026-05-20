USE music;
GO

-- Exercise 1: Scalar subquery

-- Query 1: Album(s) with the highest copies sold
SELECT Name, CopiesSold
FROM dbo.Album
WHERE CopiesSold = (SELECT MAX(CopiesSold) FROM dbo.Album);

-- Query 2: All albums except the best-selling one
SELECT Name, CopiesSold
FROM dbo.Album
WHERE CopiesSold < (SELECT MAX(CopiesSold) FROM dbo.Album)
ORDER BY CopiesSold DESC;

-- Exercise 2: IN subquery — albums by Rock or Blues groups

-- Inner query on its own (verify first)
-- SELECT MusicGroupId FROM dbo.MusicGroup WHERE Genre IN ('Rock', 'Blues');

SELECT Name, ReleaseYear
FROM dbo.Album
WHERE MusicGroupId IN (SELECT MusicGroupId FROM dbo.MusicGroup WHERE Genre IN ('Rock', 'Blues'))
ORDER BY ReleaseYear ASC;

-- Exercise 3: IN / NOT IN with NULL awareness

-- Query 1: Albums released in a year when at least one artist was born
SELECT Name, ReleaseYear
FROM dbo.Album
WHERE ReleaseYear IN (SELECT DISTINCT YEAR(BirthDay) FROM dbo.Artist);

-- Query 2: Albums NOT released in a birth year — subquery includes NULLs (likely returns no rows)
SELECT Name, ReleaseYear
FROM dbo.Album
WHERE ReleaseYear NOT IN (SELECT DISTINCT YEAR(BirthDay) FROM dbo.Artist);

-- Query 3: Same as Query 2 but NULL birth years excluded — returns correct result
SELECT Name, ReleaseYear
FROM dbo.Album
WHERE ReleaseYear NOT IN (
    SELECT DISTINCT YEAR(BirthDay) FROM dbo.Artist
    WHERE BirthDay IS NOT NULL);

-- Exercise 4: Nested subquery — music groups in the genre with the highest total copies sold

-- Step 1: Total copies sold per genre
SELECT mg.Genre, SUM(a.CopiesSold) AS TotalCopies
FROM dbo.Album a INNER JOIN dbo.MusicGroup mg ON a.MusicGroupId = mg.MusicGroupId
GROUP BY mg.Genre;

-- Step 2: Top genre only
SELECT TOP 1 mg.Genre, SUM(a.CopiesSold) AS TotalCopies
FROM dbo.Album a INNER JOIN dbo.MusicGroup mg ON a.MusicGroupId = mg.MusicGroupId
GROUP BY mg.Genre
ORDER BY 2 DESC;

-- Final query: music groups belonging to the top genre
SELECT Name, EstablishedYear
FROM dbo.MusicGroup
WHERE Genre = (
    SELECT tg.Genre FROM (
        SELECT TOP 1 mg.Genre, SUM(a.CopiesSold) AS TotalCopies
        FROM dbo.Album a
            INNER JOIN dbo.MusicGroup mg ON a.MusicGroupId = mg.MusicGroupId
        GROUP BY mg.Genre
        ORDER BY 2 DESC
    ) tg
)
ORDER BY EstablishedYear ASC;

-- Exercise 5: Nested subquery — friends in the city with the most friends
USE friends;
GO

-- Step 1: Count friends per city
SELECT a.City, COUNT(f.FriendId) AS FriendCount
FROM dbo.Friend f
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
GROUP BY a.City;

-- Step 2: Top 1 city only
SELECT TOP 1 a.City, COUNT(f.FriendId) AS FriendCount
FROM dbo.Friend f
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
GROUP BY a.City
ORDER BY 2 DESC;

-- Step 3: Isolate City as a derived table
SELECT cfc.City FROM (
    SELECT TOP 1 a.City, COUNT(f.FriendId) AS FriendCount
    FROM dbo.Friend f
        INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
    GROUP BY a.City
    ORDER BY 2 DESC
) cfc;

-- Step 4: Test the outer query
SELECT f.FirstName, f.LastName, a.City
FROM dbo.Friend f
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
WHERE a.City = 'Stockholm';

-- Final query: friends living in the city with the most friends
SELECT f.FirstName, f.LastName, a.City
FROM dbo.Friend f
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
WHERE a.City = (
    SELECT cfc.City FROM (
        SELECT TOP 1 a2.City, COUNT(f2.FriendId) AS FriendCount
        FROM dbo.Friend f2
            INNER JOIN dbo.Address a2 ON f2.AddressId = a2.AddressId
        GROUP BY a2.City
        ORDER BY 2 DESC
    ) cfc
);

-- Exercise 6: Nested subquery — pets of the most common AnimalKind

-- Step 1: Count pets per AnimalKind
SELECT AnimalKind, COUNT(*) AS PetCount
FROM dbo.Pet
GROUP BY AnimalKind;

-- Step 2: Top 1 AnimalKind only
SELECT TOP 1 AnimalKind, COUNT(*) AS PetCount
FROM dbo.Pet
GROUP BY AnimalKind
ORDER BY 2 DESC;

-- Step 3: Isolate AnimalKind as a derived table
SELECT pak.AnimalKind FROM (
    SELECT TOP 1 AnimalKind, COUNT(*) AS PetCount
    FROM dbo.Pet
    GROUP BY AnimalKind
    ORDER BY 2 DESC
) pak;

-- Step 4: Test the outer query
SELECT p.Name AS PetName, p.AnimalKind, CONCAT_WS(' ', f.FirstName, f.LastName) AS OwnerName
FROM dbo.Pet p
    INNER JOIN dbo.Friend f ON p.OwnerId = f.FriendId
WHERE p.AnimalKind = 'Dog'
ORDER BY OwnerName;

-- Final query: all pets of the most common AnimalKind with their owner's full name
SELECT p.Name AS PetName, p.AnimalKind, CONCAT_WS(' ', f.FirstName, f.LastName) AS OwnerName
FROM dbo.Pet p
    INNER JOIN dbo.Friend f ON p.OwnerId = f.FriendId
WHERE p.AnimalKind = (
    SELECT pak.AnimalKind FROM (
        SELECT TOP 1 AnimalKind, COUNT(*) AS PetCount
        FROM dbo.Pet
        GROUP BY AnimalKind
        ORDER BY 2 DESC
    ) pak
)
ORDER BY OwnerName;
