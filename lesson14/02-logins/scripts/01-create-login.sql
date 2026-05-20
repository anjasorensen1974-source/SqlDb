USE master;
GO
--House cleaning
--remove the login if it already exists
IF SUSER_ID (N'Frodo') IS NOT NULL
    DROP LOGIN Frodo;


--Create the login
CREATE LOGIN Frodo WITH PASSWORD=N'pa$$Word1', 
    DEFAULT_DATABASE=tempdb, DEFAULT_LANGUAGE=us_english, 
    CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;

--See all logins (need admin rights)
SELECT * FROM sys.sql_logins;

--Now, log in as Frodo in a separate VS Code Window (Duplicate Workspace) and run the below script to verify you can see the databases but not the logins
--Connection string is:
--Data Source=localhost,14333;User ID=Frodo;Password=pa$$Word1;Pooling=False;Connect Timeout=30;Encrypt=True;Trust Server Certificate=True;Authentication=SqlPassword;Application Name=vscode-mssql;Application Intent=ReadWrite;Command Timeout=30


-- Notice that Frodo can see the databases but not content
-- Frodo doesn't have permissions to do anything with the databases, we will fix that in the next script
