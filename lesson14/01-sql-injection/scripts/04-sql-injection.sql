USE friends;
GO

-- ------------------------------------------------------------------
-- the VULNERABLE approach (do NOT do this)
-- ------------------------------------------------------------------

--SQL Injection use ; to run several SQL statements
--Lets create a temp table as we dont want to destroy a real table
DROP TABLE IF EXISTS #tmpPet
SELECT * INTO #tmpPet FROM dbo.Pet; 

DECLARE @UserInput NVARCHAR(50);

--Intention
SET @UserInput = 'Diana';
SELECT * FROM dbo.Friend WHERE FirstName = @UserInput;
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');

--Attack
SET @UserInput = 'Whatever''; DROP TABLE #tmpPet --';
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');
SELECT * FROM #tmpPet; --does not exist any more

--Reason:
SELECT * FROM dbo.Friend WHERE FirstName = @UserInput; DROP TABLE #tmpPet;
GO

--

