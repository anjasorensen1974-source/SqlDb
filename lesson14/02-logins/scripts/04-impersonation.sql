USE master;
GO
--House cleaning
DROP USER IF EXISTS FrodoUser;
--Create a User with no rights, not bothering to create a login
CREATE USER FrodoUser WITHOUT LOGIN;
--Up to this point I am system Admin (logged in a sa)
SELECT USER AS UserName, SYSTEM_USER AS SystemUserName,
       ORIGINAL_LOGIN() AS OriginalLoginName;
--Starting the impersonation session as FrodoUser
EXECUTE AS USER = 'FrodoUser';
------------------------------------------------
--From here on, I am FrodoUser
SELECT USER AS UserName, SYSTEM_USER AS SystemUserName,
       ORIGINAL_LOGIN() AS OriginalLoginName;
--I cannot switch to any database, it will cause en error, I don't have permissions to do that
BEGIN TRY
    USE friends;    
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
--Ending the impersonation session
REVERT;
-------------------------------------------------
--From here on, I am system Admin again (logged in as sa)
SELECT USER AS UserName, SYSTEM_USER AS SystemUserName,
       ORIGINAL_LOGIN() AS OriginalLoginName;
--House cleaning
DROP USER IF EXISTS FrodoUser;