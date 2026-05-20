-- ============================================================
-- Exercise 1: Stored Procedure – Input Parameters and Return Code
-- ============================================================

USE music;
GO

DROP PROCEDURE IF EXISTS dbo.usp_GetAlbumsByGenre;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetAlbumsByGenre
    @Genre         NVARCHAR(50),
    @MinCopiesSold BIGINT AS

    SET NOCOUNT ON;

    SELECT mg.Name  AS GroupName,
           al.Name  AS AlbumName,
           al.ReleaseYear,
           al.CopiesSold
    FROM dbo.Album      AS al
    INNER JOIN dbo.MusicGroup AS mg ON al.MusicGroupId = mg.MusicGroupId
    WHERE mg.Genre = @Genre
      AND al.CopiesSold >= @MinCopiesSold
    ORDER BY al.CopiesSold DESC;

    RETURN 0;
GO

DECLARE @ret INT;
EXEC @ret = dbo.usp_GetAlbumsByGenre 'Rock', 1000000;

IF @ret = 0
    PRINT 'Procedure executed successfully';
ELSE
    PRINT 'Error executing stored procedure';

DROP PROCEDURE IF EXISTS dbo.usp_GetAlbumsByGenre;
GO

-- ============================================================
-- Exercise 2: Stored Procedure – Default Parameters and OUTPUT Parameter
-- ============================================================

USE friends;
GO

DROP PROCEDURE IF EXISTS dbo.usp_GetPetsByMood;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetPetsByMood
    @AnimalMood  NVARCHAR(20) = NULL,
    @AnimalKind  NVARCHAR(20) = NULL,
    @PetCount    INT OUTPUT AS

    SET NOCOUNT ON;

    SELECT f.FirstName,
           f.LastName,
           p.Name        AS PetName,
           p.AnimalKind,
           p.AnimalMood
    FROM dbo.Friend AS f
    INNER JOIN dbo.Pet AS p ON p.OwnerId = f.FriendId
    WHERE (@AnimalMood IS NULL OR p.AnimalMood = @AnimalMood)
      AND (@AnimalKind IS NULL OR p.AnimalKind = @AnimalKind);

    SET @PetCount = @@ROWCOUNT;

    RETURN 0;
GO

DECLARE @count INT, @ret INT;

-- All pets (no filters)
EXEC @ret = dbo.usp_GetPetsByMood NULL, NULL, @count OUTPUT;
PRINT 'All pets: ' + CAST(@count AS VARCHAR);

-- Happy pets only (named parameter style)
EXEC dbo.usp_GetPetsByMood @AnimalMood = 'Happy', @PetCount = @count OUTPUT;
PRINT 'Happy pets: ' + CAST(@count AS VARCHAR);

-- Fish only (named parameter style)
EXEC dbo.usp_GetPetsByMood @AnimalKind = 'Fish', @PetCount = @count OUTPUT;
PRINT 'Fish: ' + CAST(@count AS VARCHAR);

-- Happy fish only
EXEC dbo.usp_GetPetsByMood @AnimalMood = 'Happy', @AnimalKind = 'Fish', @PetCount = @count OUTPUT;
PRINT 'Happy fish: ' + CAST(@count AS VARCHAR);

DROP PROCEDURE IF EXISTS dbo.usp_GetPetsByMood;
GO

-- ============================================================
-- Exercise 3: Stored Procedure with CTE – Capture Result into Temp Table / Table Variable
-- ============================================================

USE sakila;
GO

DROP PROCEDURE IF EXISTS dbo.usp_TopRentedFilms;
GO

CREATE OR ALTER PROCEDURE dbo.usp_TopRentedFilms
    @rating NVARCHAR(10),
    @top_n  INT AS

    SET NOCOUNT ON;

    ;WITH film_rentals AS
        (SELECT f.film_id,
                f.title,
                f.rating,
                COUNT(r.rental_id) AS rental_count
         FROM film f
         INNER JOIN inventory i ON i.film_id      = f.film_id
         INNER JOIN rental    r ON r.inventory_id = i.inventory_id
         WHERE f.rating = @rating
         GROUP BY f.film_id, f.title, f.rating)

    SELECT TOP (@top_n)
           title,
           rating,
           rental_count
    FROM film_rentals
    ORDER BY rental_count DESC;
GO

-- Capture into a temp table
CREATE TABLE #topFilms (title NVARCHAR(255), rating NVARCHAR(10), rental_count INT);

INSERT INTO #topFilms
    EXEC dbo.usp_TopRentedFilms 'PG', 10;

SELECT * FROM #topFilms;

-- Capture into a table variable
DECLARE @topFilms TABLE (title NVARCHAR(255), rating NVARCHAR(10), rental_count INT);

INSERT INTO @topFilms
    EXEC dbo.usp_TopRentedFilms 'PG-13', 5;

SELECT * FROM @topFilms;

DROP TABLE IF EXISTS #topFilms;
DROP PROCEDURE IF EXISTS dbo.usp_TopRentedFilms;
GO

-- ============================================================
-- Exercise 4: Stored Procedure with WHILE Loop and Temp Table
-- ============================================================

USE music;
GO

DROP PROCEDURE IF EXISTS dbo.usp_AlbumsByDecade;
GO

CREATE OR ALTER PROCEDURE dbo.usp_AlbumsByDecade AS

    SET NOCOUNT ON;

    CREATE TABLE #decades (
        Decade          NVARCHAR(10),
        AlbumCount      INT,
        TotalCopiesSold BIGINT
    );

    DECLARE @decade INT = 1950;

    WHILE @decade <= 2020
    BEGIN
        INSERT INTO #decades (Decade, AlbumCount, TotalCopiesSold)
        SELECT CAST(@decade AS NVARCHAR(4)) + 's',
               COUNT(AlbumId),
               ISNULL(SUM(CopiesSold), 0)
        FROM dbo.Album
        WHERE ReleaseYear BETWEEN @decade AND @decade + 9;

        SET @decade = @decade + 10;
    END;

    SELECT * FROM #decades WHERE AlbumCount > 0;
GO

EXEC dbo.usp_AlbumsByDecade;

DROP PROCEDURE IF EXISTS dbo.usp_AlbumsByDecade;
GO
