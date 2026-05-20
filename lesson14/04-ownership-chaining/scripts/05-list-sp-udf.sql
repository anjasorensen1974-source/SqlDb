USE [friends];
GO


-- List all stored procedures, scalar UDFs, table-valued functions, and views
SELECT SCHEMA_NAME(schema_id)                AS SchemaName,
       name                                  AS ObjectName,
       type_desc                             AS ObjectType
FROM   sys.objects
WHERE  type_desc IN (
           'SQL_STORED_PROCEDURE',
           'SQL_SCALAR_FUNCTION',
           'SQL_INLINE_TABLE_VALUED_FUNCTION',
           'SQL_TABLE_VALUED_FUNCTION',
           'VIEW')
ORDER BY SchemaName, type_desc, ObjectName;