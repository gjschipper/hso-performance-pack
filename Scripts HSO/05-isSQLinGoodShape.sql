-- Sample execution call with the most common parameters:
-- Documentation: https://www.brentozar.com/blitz/documentation/

EXEC [DBAtools].[dbo].[sp_Blitz]
    @CheckUserDatabaseObjects = 1 ,
    @CheckProcedureCache = 0 ,
    @OutputType = 'TABLE' ,
    @OutputProcedureCache = 0 ,
    @CheckProcedureCacheFilter = NULL,
    @CheckServerInfo = 1