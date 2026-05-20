USE friends;
GO

--Create a stored procedure that inserts a Friend into the dbo.friend table
--Putting it together, return code, default parameters and output parameters with
--Transactions and Error Handling and logging
CREATE OR ALTER PROCEDURE dbo.usp_InsertFriend
    @FirstName NVARCHAR(200),
    @LastName NVARCHAR(200),
    @Email NVARCHAR(200) = NULL,
    @BirthDay DATETIME = NULL,
    @AddressId UNIQUEIDENTIFIER = NULL,
    @QuoteId   UNIQUEIDENTIFIER = NULL,

    --Use an output variable to return FriendId of inserted, NULL will indicate error
    @InsertedFriendId UNIQUEIDENTIFIER = NULL OUTPUT
    AS

    SET NOCOUNT ON;

    DECLARE @retCode INT;
    SET @InsertedFriendId = NULL;

    -- Table variable to capture the auto-generated FriendId via OUTPUT clause
    DECLARE @InsertedId TABLE (FriendId UNIQUEIDENTIFIER);

    BEGIN TRANSACTION    
        BEGIN TRY

            INSERT INTO dbo.Friend (FirstName, LastName, Email, Birthday, AddressId)
            OUTPUT INSERTED.FriendId INTO @InsertedId
            VALUES (@FirstName, @LastName, @Email, @BirthDay, @AddressId);

            -- Link quote to friend if provided
            IF @QuoteId IS NOT NULL
            BEGIN
                INSERT INTO dbo.FriendQuote (FriendId, QuoteId)
                VALUES ((SELECT FriendId FROM @InsertedId), @QuoteId);
            END

            COMMIT;

            --Set the output variable after commit, variables are not rolled back
            SET @InsertedFriendId = (SELECT FriendId FROM @InsertedId);
            SET @retCode = 0;

        END TRY       
        BEGIN CATCH

            ROLLBACK

            --Logg the error   
            INSERT INTO dbo.ErrorLog (err_nr, err_msg, err_line, err_sev)
            VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_LINE(), ERROR_SEVERITY())
            
            --Notify user of stored procedure that it did not succeed
            --Not really needed as I throw an error.

            SET @retCode = 1;            
            THROW 60000, 'Insert Friend Error', 1;

        END CATCH;
    RETURN @retCode;
GO

-- ============================================================
-- Test 1: Insert a friend WITHOUT an address
-- ============================================================
DECLARE @NewFriendId UNIQUEIDENTIFIER;

EXEC dbo.usp_InsertFriend
    @FirstName        = 'Bob',
    @LastName         = 'Hansen',
    @Email            = 'bob.hansen@example.com',
    @BirthDay         = '1988-11-05',
    @InsertedFriendId = @NewFriendId OUTPUT;

PRINT 'Inserted FriendId: ' + CAST(@NewFriendId AS NVARCHAR(36));

-- Verify friend without address
SELECT FriendId, FirstName, LastName, Email, Birthday, AddressId
FROM dbo.Friend
WHERE FriendId = @NewFriendId;
GO

-- ============================================================
-- Test 2: Insert a friend WITH an address
-- ============================================================
DECLARE @NewAddressId   UNIQUEIDENTIFIER;
DECLARE @NewFriendId    UNIQUEIDENTIFIER;

-- First insert the address
EXEC dbo.usp_InsertAddress
    @StreetAddress     = 'Nørrebrogade 10',
    @ZipCode           = 2200,
    @City              = 'Copenhagen',
    @Country           = 'Denmark',
    @InsertedAddressId = @NewAddressId OUTPUT;

PRINT 'Inserted AddressId: ' + CAST(@NewAddressId AS NVARCHAR(36));

-- Then insert the friend linked to that address
EXEC dbo.usp_InsertFriend
    @FirstName        = 'Alice',
    @LastName         = 'Jensen',
    @Email            = 'alice.jensen@example.com',
    @BirthDay         = '1992-03-22',
    @AddressId        = @NewAddressId,
    @InsertedFriendId = @NewFriendId OUTPUT;

PRINT 'Inserted FriendId: ' + CAST(@NewFriendId AS NVARCHAR(36));

-- Verify friend with address
SELECT f.FirstName, f.LastName, f.Email, f.Birthday,
       a.StreetAddress, a.City, a.Country
FROM dbo.Friend f
    INNER JOIN dbo.Address a ON f.AddressId = a.AddressId
WHERE f.FriendId = @NewFriendId;
GO

-- ============================================================
-- Test 3: Insert a friend on an EXISTING address with an EXISTING quote
-- ============================================================
DECLARE @ExistingAddressId  UNIQUEIDENTIFIER;
DECLARE @ExistingQuoteId    UNIQUEIDENTIFIER;
DECLARE @NewFriendId        UNIQUEIDENTIFIER;

-- Look up an existing address
SELECT TOP 1 @ExistingAddressId = AddressId FROM dbo.Address;
PRINT 'Using existing AddressId: ' + CAST(@ExistingAddressId AS NVARCHAR(36));

-- Look up an existing quote
SELECT TOP 1 @ExistingQuoteId = QuoteId FROM dbo.Quote;
PRINT 'Using existing QuoteId: ' + CAST(@ExistingQuoteId AS NVARCHAR(36));

-- Insert the friend linked to the existing address and quote
EXEC dbo.usp_InsertFriend
    @FirstName        = 'Erik',
    @LastName         = 'Madsen',
    @Email            = 'erik.madsen@example.com',
    @BirthDay         = '1985-07-14',
    @AddressId        = @ExistingAddressId,
    @QuoteId          = @ExistingQuoteId,
    @InsertedFriendId = @NewFriendId OUTPUT;

PRINT 'Inserted FriendId: ' + CAST(@NewFriendId AS NVARCHAR(36));

-- Verify friend with address and linked quote
SELECT f.FirstName, f.LastName, f.Email, f.Birthday,
       a.StreetAddress, a.City, a.Country,
       q.QuoteText, q.Author
FROM dbo.Friend f
    INNER JOIN dbo.Address    a  ON f.AddressId   = a.AddressId
    INNER JOIN dbo.FriendQuote fq ON fq.FriendId  = f.FriendId
    INNER JOIN dbo.Quote       q  ON fq.QuoteId   = q.QuoteId
WHERE f.FriendId = @NewFriendId;
GO

