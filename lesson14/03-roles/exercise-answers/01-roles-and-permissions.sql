-- ============================================================
-- Exercise 1: Exploring Database Principals
-- ============================================================

USE [friends];
GO

-- List all SQL users in the database
SELECT * FROM sys.database_principals WHERE type_desc = 'SQL_USER';

-- Current server-level and database-level principal names
SELECT SUSER_SNAME() AS ServerPrincipalName,
       USER_NAME()   AS DatabasePrincipalName;

-- List all database roles
SELECT * FROM sys.database_principals WHERE type = 'R';

-- Show all roles and their members
SELECT  DP1.name                        AS DatabaseRoleName,
        ISNULL(DP2.name, 'No members')  AS DatabaseUserName
FROM    sys.database_role_members AS DRM
    RIGHT OUTER JOIN sys.database_principals AS DP1
        ON DRM.role_principal_id   = DP1.principal_id
    LEFT  OUTER JOIN sys.database_principals AS DP2
        ON DRM.member_principal_id = DP2.principal_id
WHERE   DP1.type = 'R'
ORDER BY DP1.name;
GO


-- ============================================================
-- Exercise 2: Creating a Custom Role and Assigning Members
-- ============================================================

USE [friends];
GO

-- House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'readersRole' AND type = 'R')
BEGIN
    ALTER ROLE readersRole DROP MEMBER SiriusUser;
    ALTER ROLE readersRole DROP MEMBER LupinUser;
    ALTER ROLE readersRole DROP MEMBER TonksUser;
END
DROP ROLE IF EXISTS readersRole;
DROP USER IF EXISTS SiriusUser;
DROP USER IF EXISTS LupinUser;
DROP USER IF EXISTS TonksUser;

-- Create three users without logins
CREATE USER SiriusUser WITHOUT LOGIN;
CREATE USER LupinUser  WITHOUT LOGIN;
CREATE USER TonksUser  WITHOUT LOGIN;

-- Create a custom role
CREATE ROLE readersRole;

-- Grant SELECT on all four tables to the role
GRANT SELECT ON dbo.Friend  TO readersRole;
GRANT SELECT ON dbo.Pet     TO readersRole;
GRANT SELECT ON dbo.Address TO readersRole;
GRANT SELECT ON dbo.Quote   TO readersRole;

-- Add all three users as members
ALTER ROLE readersRole ADD MEMBER SiriusUser;
ALTER ROLE readersRole ADD MEMBER LupinUser;
ALTER ROLE readersRole ADD MEMBER TonksUser;

-- Impersonate LupinUser and verify permissions
EXECUTE AS USER = 'LupinUser';
------------------------------------------------

-- Should succeed – SELECT inherited from readersRole
SELECT TOP 5 * FROM dbo.Friend;

-- Should fail – UPDATE not granted
BEGIN TRY
    UPDATE dbo.Friend
    SET FirstName = 'Remus'
    WHERE LastName = 'Doe';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

REVERT;
------------------------------------------------

-- Verify role membership
SELECT  DP1.name                        AS DatabaseRoleName,
        ISNULL(DP2.name, 'No members')  AS DatabaseUserName
FROM    sys.database_role_members AS DRM
    RIGHT OUTER JOIN sys.database_principals AS DP1
        ON DRM.role_principal_id   = DP1.principal_id
    LEFT  OUTER JOIN sys.database_principals AS DP2
        ON DRM.member_principal_id = DP2.principal_id
WHERE   DP1.type = 'R'
  AND   DP1.name = 'readersRole'
ORDER BY DP2.name;

-- House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'readersRole' AND type = 'R')
BEGIN
    ALTER ROLE readersRole DROP MEMBER SiriusUser;
    ALTER ROLE readersRole DROP MEMBER LupinUser;
    ALTER ROLE readersRole DROP MEMBER TonksUser;
END
DROP ROLE IF EXISTS readersRole;
DROP USER IF EXISTS SiriusUser;
DROP USER IF EXISTS LupinUser;
DROP USER IF EXISTS TonksUser;
GO


-- ============================================================
-- Exercise 3: Using Built-in Database Roles
-- ============================================================

USE master;
GO

-- House cleaning (server level)
IF SUSER_ID(N'Aragorn') IS NOT NULL
    DROP LOGIN Aragorn;

USE [friends];
GO

-- House cleaning (database level)
DROP USER IF EXISTS AragornUser;

USE master;
GO

-- Create the login
CREATE LOGIN Aragorn WITH PASSWORD     = N'pa$$W0rd!',
                          DEFAULT_DATABASE  = friends,
                          CHECK_EXPIRATION  = OFF,
                          CHECK_POLICY      = OFF;

USE [friends];
GO

-- Create the database user mapped to the login
CREATE USER AragornUser FROM LOGIN Aragorn;

-- Add to the built-in db_datareader role
ALTER ROLE db_datareader ADD MEMBER AragornUser;

-- Verify membership
SELECT  DP1.name                        AS DatabaseRoleName,
        ISNULL(DP2.name, 'No members')  AS DatabaseUserName
FROM    sys.database_role_members AS DRM
    RIGHT OUTER JOIN sys.database_principals AS DP1
        ON DRM.role_principal_id   = DP1.principal_id
    LEFT  OUTER JOIN sys.database_principals AS DP2
        ON DRM.member_principal_id = DP2.principal_id
WHERE   DP1.type = 'R'
  AND   DP1.name = 'db_datareader';

-- Impersonate AragornUser and verify
EXECUTE AS USER = 'AragornUser';
------------------------------------------------

-- Should succeed – db_datareader grants SELECT on all tables
SELECT TOP 3 * FROM dbo.Friend;

-- Should fail – db_datareader does not grant INSERT
BEGIN TRY
    INSERT INTO dbo.Friend (FirstName, LastName, Email, Birthday, AddressId)
    VALUES ('Aragorn', 'Elessar', NULL, NULL, NULL);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

REVERT;
------------------------------------------------

-- House cleaning
DROP USER IF EXISTS AragornUser;

USE master;
GO

IF SUSER_ID(N'Aragorn') IS NOT NULL
    DROP LOGIN Aragorn;
GO


-- ============================================================
-- Exercise 4: Verifying Role Membership and Table Permissions
-- ============================================================

USE [friends];
GO

-- House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'checkRole' AND type = 'R')
    ALTER ROLE checkRole DROP MEMBER RemusUser;
DROP ROLE IF EXISTS checkRole;
DROP USER IF EXISTS RemusUser;

-- Create user and role
CREATE USER RemusUser WITHOUT LOGIN;
CREATE ROLE checkRole;

-- Grant SELECT and INSERT on two tables only
GRANT SELECT, INSERT ON dbo.Friend TO checkRole;
GRANT SELECT, INSERT ON dbo.Pet    TO checkRole;

-- Add user to role
ALTER ROLE checkRole ADD MEMBER RemusUser;

-- Impersonate RemusUser
EXECUTE AS USER = 'RemusUser';
------------------------------------------------

-- Check role membership with IS_MEMBER()
IF (SELECT IS_MEMBER('checkRole')) = 1
    SELECT 'Member of checkRole'     AS MembershipStatus;
ELSE
    SELECT 'NOT member of checkRole' AS MembershipStatus;

-- Permission matrix for all visible tables
SELECT  TABLE_SCHEMA + '.' + TABLE_NAME                                                    AS tableName,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'SELECT')            AS AllowSelect,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'INSERT')            AS AllowInsert,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'DELETE')            AS AllowDelete,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'UPDATE')            AS AllowUpdate
FROM    INFORMATION_SCHEMA.TABLES;

REVERT;
------------------------------------------------

-- House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'checkRole' AND type = 'R')
    ALTER ROLE checkRole DROP MEMBER RemusUser;
DROP ROLE IF EXISTS checkRole;
DROP USER IF EXISTS RemusUser;
GO


-- ============================================================
-- Exercise 5: Schema-Level Permissions
-- ============================================================

USE [friends];
GO

-- House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'kingsRole' AND type = 'R')
    ALTER ROLE kingsRole DROP MEMBER TheodenUser;
DROP ROLE IF EXISTS kingsRole;
DROP USER IF EXISTS TheodenUser;

DROP VIEW IF EXISTS usr.vwFriend;
DROP VIEW IF EXISTS usr.vwPet;
DROP VIEW IF EXISTS usr.vwAddress;

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'usr')
    DROP SCHEMA usr;
GO

-- Create a new schema
CREATE SCHEMA usr;
GO

-- Create restricted views inside the usr schema
CREATE VIEW usr.vwFriend AS
SELECT FirstName, LastName FROM dbo.Friend;
GO

CREATE VIEW usr.vwPet AS
SELECT Name, Kind FROM dbo.Pet;
GO

CREATE VIEW usr.vwAddress AS
SELECT Street, City FROM dbo.Address;
GO

-- Create the role
CREATE ROLE kingsRole;

-- Deny direct access to the base tables
DENY SELECT ON dbo.Friend  TO kingsRole;
DENY SELECT ON dbo.Pet     TO kingsRole;
DENY SELECT ON dbo.Address TO kingsRole;

-- Grant SELECT and EXECUTE on the entire usr schema
GRANT SELECT, EXECUTE ON SCHEMA::usr TO kingsRole;

-- Create user and add to role
CREATE USER TheodenUser WITHOUT LOGIN;
ALTER ROLE kingsRole ADD MEMBER TheodenUser;

-- Impersonate TheodenUser
EXECUTE AS USER = 'TheodenUser';
------------------------------------------------

-- Should succeed – SELECT on schema usr is granted
SELECT * FROM usr.vwFriend;
SELECT * FROM usr.vwPet;

-- Should fail – DENY on dbo.Friend overrides any inherited grant
BEGIN TRY
    SELECT TOP 1 * FROM dbo.Friend;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

REVERT;
------------------------------------------------

-- House cleaning
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'kingsRole' AND type = 'R')
    ALTER ROLE kingsRole DROP MEMBER TheodenUser;
DROP ROLE IF EXISTS kingsRole;
DROP USER IF EXISTS TheodenUser;
DROP VIEW IF EXISTS usr.vwFriend;
DROP VIEW IF EXISTS usr.vwPet;
DROP VIEW IF EXISTS usr.vwAddress;

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'usr')
    DROP SCHEMA usr;
GO


-- ============================================================
-- Exercise 6: Exploring Schema Objects
-- ============================================================

USE [friends];
GO

-- Count of objects per schema per type
SELECT  SCHEMA_NAME(schema_id) AS schema_name,
        type_desc,
        COUNT(*)               AS object_count
FROM    sys.objects
WHERE   type_desc IN (
            'SQL_STORED_PROCEDURE',
            'CLR_STORED_PROCEDURE',
            'SQL_SCALAR_FUNCTION',
            'CLR_SCALAR_FUNCTION',
            'CLR_TABLE_VALUED_FUNCTION',
            'SYNONYM',
            'SQL_INLINE_TABLE_VALUED_FUNCTION',
            'SQL_TABLE_VALUED_FUNCTION',
            'USER_TABLE',
            'VIEW')
GROUP BY SCHEMA_NAME(schema_id), type_desc
ORDER BY schema_name;
GO
