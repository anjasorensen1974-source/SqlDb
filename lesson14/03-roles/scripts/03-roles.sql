USE [friends];
GO

--House cleaning
-- remove roles
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gstUsrRole' AND type = 'R')
BEGIN
    ALTER ROLE gstUsrRole DROP MEMBER HermioneUser;
    ALTER ROLE gstUsrRole DROP MEMBER AlbusUser;
    ALTER ROLE gstUsrRole DROP MEMBER GandalfUser;
END
DROP ROLE IF EXISTS gstUsrRole;
DROP USER IF EXISTS HermioneUser;
DROP USER IF EXISTS AlbusUser;
DROP USER IF EXISTS GandalfUser;

--Create some users
CREATE USER HermioneUser WITHOUT LOGIN;
CREATE USER AlbusUser WITHOUT LOGIN;
CREATE USER GandalfUser WITHOUT LOGIN;

--Create a role for common users
CREATE ROLE gstUsrRole;

--SELECT only rights, nothing can be damaged
GRANT SELECT ON dbo.Friend to gstUsrRole;
GRANT SELECT ON dbo.Pet to gstUsrRole;
GRANT SELECT ON dbo.Address to gstUsrRole;
GRANT SELECT ON dbo.Quote to gstUsrRole;

ALTER ROLE gstUsrRole ADD MEMBER HermioneUser;
ALTER ROLE gstUsrRole ADD MEMBER AlbusUser;
--ALTER ROLE gstUsrRole DROP MEMBER AlbusUser;
ALTER ROLE gstUsrRole ADD MEMBER GandalfUser;

--Impersonate the users
EXECUTE AS USER = 'AlbusUser';  -- try all different, AlbusUser, GandalfUser, HermioneUser

--This works
SELECT TOP 5 * FROM dbo.Friend;
SELECT * FROM dbo.Friend WHERE LastName IN ('Doe')  

--But not this
BEGIN TRY
    UPDATE dbo.Friend
    SET FirstName = 'Ann'
    WHERE LastName IN ('Doe')
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

--end the impersonation session
REVERT;

--House cleaning
-- remove roles
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'gstUsrRole' AND type = 'R')
BEGIN
    ALTER ROLE gstUsrRole DROP MEMBER HermioneUser;
    ALTER ROLE gstUsrRole DROP MEMBER AlbusUser;
    ALTER ROLE gstUsrRole DROP MEMBER GandalfUser;
END
DROP ROLE IF EXISTS gstUsrRole;
DROP USER IF EXISTS HermioneUser;
DROP USER IF EXISTS AlbusUser;
DROP USER IF EXISTS GandalfUser;

SELECT * FROM sys.database_principals WHERE type = 'R'