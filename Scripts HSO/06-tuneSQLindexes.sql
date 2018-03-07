--  For help and how-to info, visit http://www.BrentOzar.com/BlitzIndex
--  sp_BlitzIndex - "How could I tune indexes to make this database faster?" Instructions: http://www.BrentOzar.com/blitzindex/

--  How to use: @Mode: 0=diagnose, 1=summarize, 2=index detail, 3=missing index detail, 4=diagnose detail';


-- Run below command to analyse the complete AX database. Fill in the outcome in excel template: FilterBlitzIndex.xlsm sheet SOURCE - Inclusive headers and press the button Filter the data on sheet FILTER.
EXEC DBAtools.dbo.sp_BlitzIndex @DatabaseName='AX_DATABASE', @Mode=4;


--	Return detail for a specific table:
--- EXEC DBAtools.dbo.sp_BlitzIndex @DatabaseName='AX_DATABASE', @SchemaName='dbo', @TableName='SALESTABLE';