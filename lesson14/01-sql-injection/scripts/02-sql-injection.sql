USE friends;
GO

-- ------------------------------------------------------------------
-- Reminder: the VULNERABLE approach (do NOT do this)
-- ------------------------------------------------------------------

--SQL Injection example 1=1 is true
DECLARE @UserInput NVARCHAR(50);

--Intention
SET @UserInput = 'Diana';
SELECT * FROM dbo.Friend WHERE FirstName = @UserInput;
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');

--Attack
SET @UserInput = 'Whatever'' OR 1=1 --';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''    ');

--Reason:
SELECT * FROM dbo.Friend WHERE FirstName = 'Whatever' OR 1=1;
GO
