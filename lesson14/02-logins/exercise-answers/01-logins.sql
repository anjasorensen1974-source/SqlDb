-- ============================================================
-- Exercise 1: Create a SQL Server Login
-- ============================================================

USE master;
GO

-- House cleaning
IF SUSER_ID(N'Bilbo') IS NOT NULL
    DROP LOGIN Bilbo;

-- Create the login
CREATE LOGIN Bilbo WITH PASSWORD     = N'pa$$W0rd!',
                        DEFAULT_DATABASE  = tempdb,
                        DEFAULT_LANGUAGE  = us_english,
                        CHECK_EXPIRATION  = OFF,
                        CHECK_POLICY      = OFF;

-- Verify
SELECT name,
       type_desc,
       default_database_name,
       is_policy_checked
FROM sys.sql_logins
WHERE name = 'Bilbo';

-- House cleaning
IF SUSER_ID(N'Bilbo') IS NOT NULL
    DROP LOGIN Bilbo;
GO

-- ============================================================
-- Exercise 2: Create a Server Role and Grant Server-Level Permissions
-- ============================================================

USE master;
GO

-- House cleaning
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'ReadAnyDB' AND type = 'R')
BEGIN
    IF EXISTS (
        SELECT 1 FROM sys.server_role_members rm
            INNER JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id
            INNER JOIN sys.server_principals r ON rm.role_principal_id   = r.principal_id
        WHERE m.name = N'Pippin' AND r.name = N'ReadAnyDB')
        ALTER SERVER ROLE ReadAnyDB DROP MEMBER Pippin;

    DROP SERVER ROLE ReadAnyDB;
END
IF SUSER_ID(N'Pippin') IS NOT NULL
    DROP LOGIN Pippin;

-- Create the login
CREATE LOGIN Pippin WITH PASSWORD     = N'pa$$W0rd!',
                         DEFAULT_DATABASE  = tempdb,
                         CHECK_EXPIRATION  = OFF,
                         CHECK_POLICY      = OFF;

-- Create the server role
CREATE SERVER ROLE ReadAnyDB;

-- Grant server-level permissions to the role
GRANT CONNECT ANY DATABASE       TO ReadAnyDB;
GRANT VIEW ANY DATABASE          TO ReadAnyDB;
GRANT SELECT ALL USER SECURABLES TO ReadAnyDB;

-- Add Pippin as a member of the role
ALTER SERVER ROLE ReadAnyDB ADD MEMBER Pippin;

-- Verify membership
SELECT m.name AS member_name,
       r.name AS role_name
FROM sys.server_role_members rm
    INNER JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id
    INNER JOIN sys.server_principals r ON rm.role_principal_id   = r.principal_id
WHERE r.name = N'ReadAnyDB';

-- House cleaning
ALTER SERVER ROLE ReadAnyDB DROP MEMBER Pippin;
DROP SERVER ROLE ReadAnyDB;
IF SUSER_ID(N'Pippin') IS NOT NULL
    DROP LOGIN Pippin;
GO

-- ============================================================
-- Exercise 3: Create a Database User and Grant Database Permissions
-- ============================================================

USE master;
GO

-- House cleaning (server level)
IF SUSER_ID(N'Merry') IS NOT NULL
    DROP LOGIN Merry;

USE music;
GO

-- House cleaning (database level)
DROP USER IF EXISTS MerryUser;

USE master;
GO

-- Create the login
CREATE LOGIN Merry WITH PASSWORD     = N'pa$$W0rd!',
                        DEFAULT_DATABASE  = tempdb,
                        CHECK_EXPIRATION  = OFF,
                        CHECK_POLICY      = OFF;

USE music;
GO

-- Create the database user mapped to the login
CREATE USER MerryUser FROM LOGIN Merry;

-- Grant connect permission
GRANT CONNECT TO MerryUser;

-- Grant SELECT on specific tables
GRANT SELECT ON dbo.Artist TO MerryUser;
GRANT SELECT ON dbo.Album  TO MerryUser;

-- Verify
SELECT name,
       type_desc,
       default_schema_name
FROM sys.database_principals
WHERE type_desc = 'SQL_USER'
  AND name = 'MerryUser';

-- House cleaning
DROP USER IF EXISTS MerryUser;

USE master;
GO

IF SUSER_ID(N'Merry') IS NOT NULL
    DROP LOGIN Merry;
GO
