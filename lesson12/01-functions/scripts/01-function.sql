USE friends;
GO

--House cleaning
DROP FUNCTION IF EXISTS dbo.udf_FullName;
DROP FUNCTION IF EXISTS dbo.udf_FullNameEmail;
GO

--CREATE a function, once created use ALTER to change
CREATE FUNCTION dbo.udf_FullName(@fn NVARCHAR(200), @ln NVARCHAR(200))
RETURNS NVARCHAR(400) AS
BEGIN
    RETURN CONCAT_WS(' ', @fn, @ln)
END;
GO

--CREATE another function, , once created use ALTER to change
CREATE FUNCTION dbo.udf_FullNameEmail(@fn NVARCHAR(200), @ln NVARCHAR(200), @email NVARCHAR(200))
RETURNS NVARCHAR(400) AS
BEGIN
    --I can call a function inside anoter function, i.e., nested calls
    DECLARE @sRet NVARCHAR(600) = dbo.udf_FullName(@fn, @ln);
    IF (@email IS NOT NULL)
        --Only one statment does not require BEGIN..END
        SET @sRet = CONCAT_WS(' ', @fn, @ln, 'can be reached at', @email);
    
    --Must be last statement
    RETURN @sRet
END;
GO

SELECT FriendId, dbo.udf_FullNameEmail(FirstName, LastName, Email) [Contact] from dbo.Friend;

--House cleaning
DROP FUNCTION IF EXISTS dbo.udf_FullName;
DROP FUNCTION IF EXISTS dbo.udf_FullNameEmail;
GO