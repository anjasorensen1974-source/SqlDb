USE master;
GO

--Assign Server permissions
CREATE SERVER ROLE ServerViewOnly;

GRANT CONNECT ANY DATABASE to ServerViewOnly; -- connect to any database
GRANT VIEW ANY DATABASE to ServerViewOnly; --see any database
GRANT SELECT ALL USER SECURABLES to ServerViewOnly; -- only select

--Frodo will now have permissions to see the databases and do SELECT on any database table but not modify any data or see the logins or server role information
ALTER SERVER ROLE ServerViewOnly ADD MEMBER Frodo;

--Now, log in as Frodo in a separate VS Code Window (Duplicate Workspace) and run the below script to verify you can see the databases but not the logins
--Connection string is:
--Data Source=localhost,14333;User ID=Frodo;Password=pa$$Word1;Pooling=False;Connect Timeout=30;Encrypt=True;Trust Server Certificate=True;Authentication=SqlPassword;Application Name=vscode-mssql;Application Intent=ReadWrite;Command Timeout=30


-- Notice that Frodo can see the databases and do SELECT on any database table
-- Try modifying any table data
-- Frodo doesn't have permissions to modify any database


--close the duplicate workspace where you are logged in as Frodo and run the below script in the admin workspace 
--to clean up the login and server role we just created for the demo

-- House cleaning
-- Remove Frodo from the role only if they are a member, then drop the role and login
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'ServerViewOnly' AND type = 'R')
BEGIN
    -- Remove Frodo from the role only if they are a member
    IF EXISTS (
        SELECT 1 FROM sys.server_role_members rm
            INNER JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id
            INNER JOIN sys.server_principals r ON rm.role_principal_id   = r.principal_id
        WHERE m.name = N'Frodo' AND r.name = N'ServerViewOnly')
        ALTER SERVER ROLE ServerViewOnly DROP MEMBER Frodo;

    DROP SERVER ROLE ServerViewOnly;
END
-- Drop the login if it exists
IF SUSER_ID (N'Frodo') IS NOT NULL
    DROP LOGIN Frodo;