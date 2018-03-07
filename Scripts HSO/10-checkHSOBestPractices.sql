-- FIRST RUN
IF OBJECT_ID('[DBAtools].[dbo].[HSO_RESULTS]') IS NOT NULL 
DROP TABLE [DBAtools].[dbo].[HSO_RESULTS]
GO

EXEC [DBAtools].[dbo].[sp_Blitz]
    @CheckUserDatabaseObjects = 1,
	@CheckServerInfo = 1,
    @CheckProcedureCache = 0,
    @OutputProcedureCache = 0,
    @CheckProcedureCacheFilter = NULL,
	@SkipChecksDatabase = 'DBAtools',
	@OutputType = 'TABLE',
	@OutputDatabaseName = 'DBAtools',
	@OutputSchemaName = 'dbo',
	@OutputTableName = 'HSO_RESULTS'

-- SECOND RUN
/*
EXECUTE JOB: HSO - Export AOS Registry. 
Note: the SQL Agent User needs windows administration permission for all AOS servers.
Fill in the right AX database name in parameter @AXDB, see below.
*/

TRUNCATE TABLE [DBAtools].[dbo].[PERF_RESULTS]
GO

EXEC [DBAtools].[dbo].[CHECK_HSO_PARAMETERS]
	@AXDB = 'AX_DATABASE'
GO

-- CHECK RESULTS
SELECT TEST as CHAPTER, FINDING as ACTION, DETAILS, STATUS
FROM [DBAtools].[dbo].[PERF_RESULTS]
ORDER BY TEST