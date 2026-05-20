USE friends;
GO

-- ------------------------------------------------------------------
-- the VULNERABLE approach (do NOT do this)
-- ------------------------------------------------------------------

--SQL Injection example ''='' is Always True
DECLARE @UserFirstName NVARCHAR(50); -- could user name
DECLARE @UserLastName NVARCHAR(50); -- could be user password

--Intention
SET @UserFirstName = 'Severus';
SET @UserLastName = 'Gamgee';
SELECT * FROM dbo.Friend WHERE FirstName = 'Severus' AND LastName = 'Gamgee'; 
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserFirstName + ''' AND LastName = ''' + @UserLastName + ''';');

--Attack
SET @UserFirstName = ''' or ''''=''';
SET @UserLastName = ''' or ''''=''';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserFirstName + ''' AND LastName = ''' + @UserLastName + ''';');

--Reason:
SELECT * FROM dbo.Friend WHERE FirstName ='' or ''='' AND LastName ='' or ''='';
GO
