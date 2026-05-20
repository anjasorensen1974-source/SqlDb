USE friends;
GO

-- ------------------------------------------------------------------
-- Reminder: the VULNERABLE approach (do NOT do this)
-- ------------------------------------------------------------------

--SQL Injection use ; to run several SQL statements
--Lets create a temp table as we dont want to destroy a real table
DROP TABLE IF EXISTS #tmpPet
SELECT * INTO #tmpPet FROM dbo.Pet; 

DECLARE @UserInput NVARCHAR(50);

--Intention
SET @UserInput = 'Diana';
SELECT * FROM dbo.Friend WHERE FirstName = @UserInput;
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');

--Attack
SET @UserInput = 'Whatever''; DROP TABLE #tmpPet --';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');
SELECT * FROM #tmpPet; --does not exist any more

--Reason:
SELECT * FROM dbo.Friend WHERE FirstName = @UserInput; DROP TABLE #tmpPet;
GO


-- ------------------------------------------------------------------
-- The SAFE alternative: stored procedure with a parameter
-- ------------------------------------------------------------------

-- Recreate the temp table so we can prove the attack no longer works
DROP TABLE IF EXISTS #tmpPet;
SELECT * INTO #tmpPet FROM dbo.Pet;

DROP PROCEDURE IF EXISTS dbo.usp_FindFriendByName;
GO

CREATE OR ALTER PROCEDURE dbo.usp_FindFriendByName
    @FirstName NVARCHAR(50) AS

    SET NOCOUNT ON;

    -- The parameter is passed as typed data, not concatenated into SQL text.
    -- Semicolons, DROP, and other SQL keywords inside @FirstName are treated as
    -- literal characters — they can never be executed as separate statements.
    SELECT FriendId, FirstName, LastName, Email
    FROM dbo.Friend
    WHERE FirstName = @FirstName;
GO

-- Intention
EXEC dbo.usp_FindFriendByName 'Diana'; -- works as expected

-- Attack attempt: the semicolon and DROP TABLE are just part of the string value
EXEC dbo.usp_FindFriendByName 'Whatever''; DROP TABLE #tmpPet --'; --safe, no error, no table dropped

-- #tmpPet still exists — the attack had no effect
SELECT * FROM #tmpPet;

-- House cleaning
DROP TABLE IF EXISTS #tmpPet;
DROP PROCEDURE IF EXISTS dbo.usp_FindFriendByName;
GO

