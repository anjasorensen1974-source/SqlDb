USE sakila;
GO

DROP TABLE IF EXISTS #tmp_customer_processed;
GO
CREATE TABLE #tmp_customer_processed(
    row_id INT IDENTITY (1, 1) NOT NULL,
    customer_id INT,
    firstname NVARCHAR (50),
    lastname NVARCHAR (50),
    Processed BIT NOT NULL);
GO

INSERT INTO #tmp_customer_processed(customer_id, firstname, lastname, Processed)
SELECT customer_id, first_name, last_name, 0 FROM dbo.customer;

--SELECT * FROM #tmp_customer_processed;


--Use array style iteration through the #tmp_customer_processed table, row by row
DECLARE @row_id INT = 1;
DECLARE @customer_id INT;
DECLARE @fullname NVARCHAR(100);
WHILE EXISTS (SELECT 1 From #tmp_customer_processed  WHERE Processed = 0) 
BEGIN
    
    PRINT 'Do something with row: ' + CAST (@row_id AS NVARCHAR);
   
    SELECT @customer_id = customer_id,  @fullname = CONCAT_WS(' ', firstname, lastname)
    FROM #tmp_customer_processed 
    WHERE row_id = @row_id;
    
    PRINT '  - customer_id: ' + CAST (@customer_id AS NVARCHAR);
    PRINT '  - customer name: ' + @fullname;
   
    PRINT 'Done';
    
    UPDATE #tmp_customer_processed SET Processed = 1
    WHERE row_id = @row_id;

    SET @row_id += 1;
END;
PRINT 'Done!';
