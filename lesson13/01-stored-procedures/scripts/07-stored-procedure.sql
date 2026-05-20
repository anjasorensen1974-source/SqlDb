USE friends;
GO

--Now using the stored prodocedure and userdefined functions in previous example
--Notice the compact code when using the stored procedures and functions 
DECLARE @NrFriends INT,
        @ret_code INT;  

--Executing with various default parameters
EXEC @ret_code = dbo.usp_GetFriends NULL, NULL, @NrFriends OUTPUT;
PRINT dbo.udf_ExecutionSuccess(@ret_code, @NrFriends);

EXEC dbo.usp_GetFriends 'Sweden', NULL, @NrFriends OUTPUT;
PRINT dbo.udf_ExecutionSuccess(@ret_code, @NrFriends);

EXEC dbo.usp_GetFriends NULL, 'Stockholm', @NrFriends OUTPUT;
PRINT dbo.udf_ExecutionSuccess(@ret_code, @NrFriends);

EXEC dbo.usp_GetFriends 'Sweden', 'Stockholm', @NrFriends OUTPUT;
PRINT dbo.udf_ExecutionSuccess(@ret_code, @NrFriends);

--House cleaning
DROP PROCEDURE IF EXISTS dbo.usp_GetFriends;
DROP FUNCTION IF EXISTS dbo.udf_ExecutionSuccess;