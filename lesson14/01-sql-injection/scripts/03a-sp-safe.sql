USE friends;
GO

-- ------------------------------------------------------------------
-- Reminder: the VULNERABLE approach (do NOT do this)
-- ------------------------------------------------------------------

--SQL Injection example ''='' is Always True
DECLARE @UserFirstName NVARCHAR(50); -- could user name
DECLARE @UserLastName NVARCHAR(50); -- could be user password

--Intention
SET @UserFirstName = 'Severus';
SET @UserLastName = 'Gamgee';
SELECT * FROM dbo.Friend WHERE FirstName = 'Severus' AND LastName = 'Gamgee'; 
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserFirstName + ''' AND LastName = ''' + @UserLastName + ''';');

--Attack
SET @UserFirstName = ''' or ''''=''';
SET @UserLastName = ''' or ''''=''';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserFirstName + ''' AND LastName = ''' + @UserLastName + ''';');

--Reason:
SELECT * FROM dbo.Friend WHERE FirstName ='' or ''='' AND LastName ='' or ''='';
GO



-- ------------------------------------------------------------------
-- The SAFE alternative: stored procedure with a parameter
-- ------------------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.usp_FindFriendByName;
GO

CREATE OR ALTER PROCEDURE dbo.usp_FindFriendByName
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50) AS

    SET NOCOUNT ON;

    -- The parameter is passed as typed data, not concatenated into SQL text.
    -- Quotes, keywords, and operators inside @FirstName are treated as literal
    -- characters — they can never change the structure of the query.
    SELECT FriendId, FirstName, LastName, Email
    FROM dbo.Friend
    WHERE FirstName = @FirstName AND LastName = @LastName;
GO

DECLARE @UserFirstName NVARCHAR(50); -- could user name
DECLARE @UserLastName NVARCHAR(50); -- could be user password

--Intention
SET @UserFirstName = 'Severus';
SET @UserLastName = 'Gamgee';

-- Test the stored procedure with the same inputs as before
EXEC dbo.usp_FindFriendByName @UserFirstName, @UserLastName; -- works
EXEC dbo.usp_FindFriendByName 'Severus', 'Gamgee'; -- works


--Attack
SET @UserFirstName = ''' or ''''=''';
SET @UserLastName = ''' or ''''=''';

EXEC dbo.usp_FindFriendByName @UserFirstName, @UserLastName; -- safe, returns no results

--EXEC dbo.usp_FindFriendByName ''' or ''''=''', ''' or ''''=''''; 
-- not even close to working, just treats the input as literal strings


