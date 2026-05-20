USE friends;
GO


BEGIN TRY
     PRINT 1/0;
--    DROP TABLE dbo.nonExistingTable;
--;THROW 999999, 'This is a test error.', 1;
END TRY
BEGIN CATCH
    PRINT 'Inside the Catch block';
    PRINT ERROR_NUMBER();
    PRINT ERROR_MESSAGE();
    PRINT ERROR_LINE();
    PRINT ERROR_SEVERITY();
END CATCH

PRINT 'Execution Continues Outside the catch block';
