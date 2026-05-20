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
IF (SELECT IS_MEMBER('gstUsrRole')) = 1
       SELECT 'Member of the gstUsrRole';
ELSE
       SELECT 'NOT Member of the gstUsrRole';

--Show all roles and their members
SELECT DP1.name AS DatabaseRoleName,  ISNULL (DP2.name, 'No members') AS DatabaseUserName   
FROM sys.database_role_members AS DRM  
    RIGHT OUTER JOIN sys.database_principals AS DP1 ON DRM.role_principal_id = DP1.principal_id  
    LEFT OUTER JOIN sys.database_principals AS DP2 ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R'
ORDER BY DP1.name;  

--note, this query only returns rows for tables where the user has SOME rights
SELECT  TABLE_SCHEMA + '.' + TABLE_NAME AS tableName,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'SELECT') AS AllowSelect,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'INSERT') AS AllowInsert,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'DELETE') AS AllowDelete,
        HAS_PERMS_BY_NAME(TABLE_SCHEMA + '.' + TABLE_NAME, 'OBJECT', 'UPDATE') AS AllowUpdate
FROM    INFORMATION_SCHEMA.TABLES;

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