-- ============================================================
-- Exercise 1: Impersonation with EXECUTE AS USER
-- ============================================================

USE master;
GO

-- House cleaning
DROP USER IF EXISTS SamUser;

-- Create a user with no login
CREATE USER SamUser WITHOUT LOGIN;

-- Check current identity before impersonation
SELECT USER             AS UserName,
       SYSTEM_USER      AS SystemUserName,
       ORIGINAL_LOGIN() AS OriginalLoginName;

-- Start impersonation
EXECUTE AS USER = 'SamUser';
------------------------------------------------
-- From here on, I am SamUser

-- Identity query: USER is SamUser, but ORIGINAL_LOGIN() still shows the admin login
SELECT USER             AS UserName,
       SYSTEM_USER      AS SystemUserName,
       ORIGINAL_LOGIN() AS OriginalLoginName;

-- SamUser has no rights to switch databases
BEGIN TRY
    USE friends;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- End impersonation
REVERT;
------------------------------------------------
-- Back to admin

-- Confirm identity is restored
SELECT USER             AS UserName,
       SYSTEM_USER      AS SystemUserName,
       ORIGINAL_LOGIN() AS OriginalLoginName;

-- House cleaning
DROP USER IF EXISTS SamUser;
GO


-- ============================================================
-- Exercise 2: Granting and Querying Database Permissions
-- ============================================================

USE friends;
GO

-- House cleaning
DROP USER IF EXISTS MeriadocUser;

-- Create user without login
CREATE USER MeriadocUser WITHOUT LOGIN;

-- Grant SELECT on specific tables only
GRANT SELECT ON dbo.Friend  TO MeriadocUser;
GRANT SELECT ON dbo.Address TO MeriadocUser;

-- Start impersonation
EXECUTE AS USER = 'MeriadocUser';
------------------------------------------------
-- From here on, I am MeriadocUser

-- Should succeed
SELECT TOP 5 * FROM dbo.Friend;
SELECT TOP 5 * FROM dbo.Address;

-- INSERT is not granted – should fail
BEGIN TRY
    INSERT INTO dbo.Friend (FirstName, LastName, Email, Birthday, AddressId)
    VALUES ('Meriadoc', 'Brandybuck', NULL, NULL, NULL);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- dbo.Pet was not granted – should fail
BEGIN TRY
    SELECT TOP 1 * FROM dbo.Pet;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- End impersonation
REVERT;
------------------------------------------------
-- Back to admin

-- Query sys.database_permissions to see what MeriadocUser was granted
SELECT class_desc                                                                  AS PermissionType,
       OBJECT_SCHEMA_NAME(major_id) + '.' + OBJECT_NAME(major_id)                AS ObjectName,
       permission_name,
       state_desc,
       USER_NAME(grantee_principal_id)                                            AS Grantee
FROM   sys.database_permissions
WHERE  USER_NAME(grantee_principal_id) = 'MeriadocUser'
ORDER BY ObjectName;

-- House cleaning
DROP USER IF EXISTS MeriadocUser;
GO


-- ============================================================
-- Exercise 3: Schema-Scoped Securables via a View
-- ============================================================

USE friends;
GO

-- House cleaning
DROP USER IF EXISTS GollumUser;
DROP VIEW IF EXISTS dbo.vw_FriendStats;
GO

-- Create summary view (GO required before CREATE VIEW)
CREATE VIEW dbo.vw_FriendStats
AS
SELECT (SELECT COUNT(*) FROM dbo.Friend)  AS NrOfFriends,
       (SELECT COUNT(*) FROM dbo.Pet)     AS NrOfPets,
       (SELECT COUNT(*) FROM dbo.Address) AS NrOfAddresses,
       (SELECT COUNT(*) FROM dbo.Quote)   AS NrOfQuotes;
GO

-- Create user without login
CREATE USER GollumUser WITHOUT LOGIN;

-- Grant SELECT on the VIEW only – not on the underlying tables
GRANT SELECT ON dbo.vw_FriendStats TO GollumUser;

-- Start impersonation
EXECUTE AS USER = 'GollumUser';
------------------------------------------------
-- From here on, I am GollumUser

-- Should succeed – ownership chaining allows read-through the view
SELECT * FROM dbo.vw_FriendStats;

-- Direct table access is not granted – should fail
BEGIN TRY
    SELECT TOP 1 * FROM dbo.Friend;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

BEGIN TRY
    SELECT TOP 1 * FROM dbo.Pet;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- End impersonation
REVERT;
------------------------------------------------
-- Back to admin

-- House cleaning
DROP USER IF EXISTS GollumUser;
DROP VIEW IF EXISTS dbo.vw_FriendStats;
GO
