USE friends;
GO

CREATE OR ALTER PROCEDURE dbo.usp_InsertFriend
    @FirstName NVARCHAR(200),
    @LastName NVARCHAR(200),
    @Email NVARCHAR(200) = NULL,
    @BirthDay DATETIME = NULL,

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
            VALUES (@FirstName, @LastName, @Email, @BirthDay, NULL);

            COMMIT;

            --Set the output variable after commit, variables are not rolled back
            SET @InsertedFriendId = (SELECT FriendId FROM @InsertedId);
            SET @retCode = 0;

        END TRY       
        BEGIN CATCH

            ROLLBACK

            SET @retCode = 1;            
            THROW 60000, 'Insert Friend Error', 1;

        END CATCH;
    RETURN @retCode;
GO


