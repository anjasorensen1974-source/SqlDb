USE [friends];
GO

--House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gstUsrRole' AND type = 'R')
BEGIN
    ALTER ROLE gstUsrRole DROP MEMBER GandalfUser;
END
DROP ROLE IF EXISTS gstUsrRole;
DROP USER IF EXISTS GandalfUser;
DELETE FROM dbo.Friend WHERE LastName IN ('Doe')  

--Create some users
CREATE USER GandalfUser WITHOUT LOGIN;

--Create a role for common users
CREATE ROLE gstUsrRole;

--SELECT, EXECUTE only rights on the SCHEMA, 
GRANT SELECT, EXECUTE ON SCHEMA::dbo to gstUsrRole;

ALTER ROLE gstUsrRole ADD MEMBER GandalfUser;

--Impersonate the users
EXECUTE AS USER = 'GandalfUser'; 

--This works
SELECT TOP 5 * FROM dbo.Friend;

--NOW this will work as the stored procedure is within dbo SCHEMA 
--Permissions include EXECUTE
BEGIN TRY

    DECLARE @NewFriendId UNIQUEIDENTIFIER;
    EXEC dbo.usp_InsertFriend
        @FirstName        = 'Mary',
        @LastName         = 'Doe',
        @Email            = 'mary.doe@example.com',
        @BirthDay         = '1988-11-05',
        @InsertedFriendId = @NewFriendId OUTPUT;

END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

--Now, added
SELECT * FROM dbo.Friend WHERE LastName IN ('Doe')  

--end the impersonation session 
REVERT;

--House cleaning
-- remove roles
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gstUsrRole' AND type = 'R')
BEGIN
    ALTER ROLE gstUsrRole DROP MEMBER GandalfUser;
END
DROP ROLE IF EXISTS gstUsrRole;
DROP USER IF EXISTS GandalfUser;
DROP PROCEDURE IF EXISTS dbo.usp_InsertFriend;
