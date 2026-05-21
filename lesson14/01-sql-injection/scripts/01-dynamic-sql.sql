USE friends;
GO

-- Dynamic SQL
-- A very common BUT BAD idea from SQLServer Security Perspective
-- https://learn.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices?view=sql-server-ver16#sql-injection-risks
-- It is very common SQL sloppy code using Dynamic SQL
-- Imagine you have a search box and you want to search for a friend by name

--good when placed in a stored procedure with parameter validation.
DECLARE @UserInput NVARCHAR(50) = 'Padma';
SELECT * FROM dbo.Friend WHERE FirstName = @UserInput;

--bad when simply generate a query string and execute it without any validation of the input
EXEC ('SELECT * FROM dbo.Friend WHERE FirstName = ''' + @UserInput + '''');



