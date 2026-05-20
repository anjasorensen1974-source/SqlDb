USE friends;
GO

-- ============================================================
-- Stored Procedure with Parameters: The Safe Alternative to Dynamic SQL
--
-- Dynamic SQL builds a query string at runtime and passes it directly
-- to EXEC(). Any user-supplied value is concatenated into the SQL text,
-- which gives an attacker the ability to break out of the string literal
-- and inject arbitrary SQL commands.
--
-- A stored procedure with typed parameters solves this completely.
-- SQL Server treats each parameter value as data, never as executable code,
-- so quotes and keywords in the input are harmless.
-- ============================================================

-- ------------------------------------------------------------------
-- Reminder: the VULNERABLE approach (do NOT do this)
-- ------------------------------------------------------------------

DECLARE @UserInput NVARCHAR(50);

-- Normal use looks fine ...
SET @UserInput = 'Diana';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');

-- ... but an attacker can inject SQL that returns the whole table:
SET @UserInput = 'Whatever'' OR 1=1 --';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');

-- ------------------------------------------------------------------
-- The SAFE alternative: stored procedure with a parameter
-- ------------------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.usp_FindFriendByName;
GO

CREATE OR ALTER PROCEDURE dbo.usp_FindFriendByName
    @FirstName NVARCHAR(50) AS

    SET NOCOUNT ON;

    -- The parameter is passed as typed data, not concatenated into SQL text.
    -- Quotes, keywords, and operators inside @FirstName are treated as literal
    -- characters — they can never change the structure of the query.
    SELECT FriendId, FirstName, LastName, Email
    FROM dbo.Friend
    WHERE FirstName = @FirstName;
GO

-- ------------------------------------------------------------------
-- Execute: normal input works as expected
-- ------------------------------------------------------------------

EXEC dbo.usp_FindFriendByName 'Diana';
EXEC dbo.usp_FindFriendByName 'Padma';

-- ------------------------------------------------------------------
-- Execute: injection attempt — the attack string is treated as a
-- plain string literal, so no rows are returned instead of all rows.
-- ------------------------------------------------------------------

EXEC dbo.usp_FindFriendByName 'Whatever'' OR 1=1 --';

-- ------------------------------------------------------------------
-- House cleaning
-- ------------------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.usp_FindFriendByName;
GO
