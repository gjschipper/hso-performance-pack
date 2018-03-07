/* How to run it:
EXEC [DBAtools].dbo.sp_BlitzFirst

With extra diagnostic info:
EXEC [DBAtools].dbo.sp_BlitzFirst @ExpertMode = 1;

In Ask a Question mode:
EXEC [DBAtools].dbo.sp_BlitzFirst 'Is this cursor bad?';

Saving output to tables:
EXEC [DBAtools].dbo.sp_BlitzFirst @Seconds = 60
, @OutputDatabaseName = 'DBAtools'
, @OutputSchemaName = 'dbo'
, @OutputTableName = 'BlitzFirstResults'
, @OutputTableNameFileStats = 'BlitzFirstResults_FileStats'
, @OutputTableNamePerfmonStats = 'BlitzFirstResults_PerfmonStats'
, @OutputTableNameWaitStats = 'BlitzFirstResults_WaitStats'
*/