USE friends;
GO

-- Verify the row before the attempted update
SELECT [Name], OwnerId FROM dbo.Pet WHERE [Name] = 'Charlie';

BEGIN TRY
    BEGIN TRAN

        -- This UPDATE violates the FK constraint on OwnerId:
        -- '00000000-...' does not exist in dbo.Friend
        UPDATE dbo.Pet
        SET OwnerId = '00000000-0000-0000-0000-000000000000'
        WHERE [Name] = 'Charlie';

    COMMIT;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
    PRINT 'Rolling back transaction';
    IF @@TRANCOUNT > 0 BEGIN
        ROLLBACK;
    END;
END CATCH;

-- Confirm the row is unchanged — original OwnerId still intact
SELECT [Name], OwnerId FROM dbo.Pet WHERE [Name] = 'Charlie';
