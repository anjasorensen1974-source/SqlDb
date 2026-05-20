USE friends;
GO

--House cleaning
DROP FUNCTION IF EXISTS dbo.udf_DaysToBirthday;
GO

--Create a scalar function that returns the number of days until the next birthday, given a date of birth
CREATE OR ALTER FUNCTION dbo.udf_DaysToBirthday (@Birthday DATETIME )
RETURNS INT AS
BEGIN

RETURN DATEDIFF(DAY, GETDATE(), DATEADD(YEAR,DATEDIFF(YEAR, @Birthday, GETDATE()), @Birthday));
END
GO


-- Test: days to next birthday for each friend
SELECT
    FirstName,
    LastName,
    Birthday,
    dbo.udf_DaysToBirthday(Birthday) AS DaysToNextBirthday
FROM dbo.Friend
ORDER BY DaysToNextBirthday;


--House cleaning
DROP FUNCTION IF EXISTS dbo.udf_DaysToBirthday;
GO