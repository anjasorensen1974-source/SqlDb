USE [friends];
GO

--see all users
SELECT * FROM sys.database_principals WHERE type_desc = 'SQL_USER'

--current database scoped principals
SELECT SUSER_SNAME() AS server_principal_name,
       USER_NAME() AS database_principal_name;

--List all the roles in the database
SELECT * FROM sys.database_principals WHERE type = 'R'

--Show all roles and their members
SELECT DP1.name AS DatabaseRoleName,  ISNULL (DP2.name, 'No members') AS DatabaseUserName   
FROM sys.database_role_members AS DRM  
    RIGHT OUTER JOIN sys.database_principals AS DP1 ON DRM.role_principal_id = DP1.principal_id  
    LEFT OUTER JOIN sys.database_principals AS DP2 ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R'
ORDER BY DP1.name;