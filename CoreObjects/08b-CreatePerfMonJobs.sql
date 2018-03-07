USE DBAtools
GO

DECLARE @JobName nvarchar(max)
DECLARE @StepName1 nvarchar(max)
DECLARE @StepName2 nvarchar(max)
DECLARE @NL AS CHAR(2) = CHAR(13) + CHAR(10)


IF OBJECT_ID('dbo.WhoIsActive_LOG', 'U') IS NOT NULL  DROP TABLE dbo.WhoIsActive_LOG; 

DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_LOG';
DECLARE @schema VARCHAR(4000) ;
EXEC sp_WhoIsActive 
    @find_block_leaders = 1, 
    @sort_order = '[blocked_session_count] DESC',
	@get_transaction_info = 1,
	@get_plans = 1,
	@return_schema = 1,
	@schema = @schema OUTPUT ;
SET @schema = REPLACE(@schema, '<table_name>', @destination_table) ;
PRINT @schema
EXEC(@schema);

-- CREATE JOB 'HSO - Log Activity in WhoIsActive_LOG table'
SET		@JobName = 'HSO - Who Is Active'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName,  @on_success_action=1, @database_name=N'DBAtools', @subsystem=N'TSQL', 
		@command=N'EXECUTE sp_WhoIsActive 
@find_block_leaders = 1, 
@get_transaction_info = 1,
@get_plans = 1,
@destination_table = ''WhoIsActive_LOG'';'
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Every 5 minutes', @freq_interval=127, @active_start_time=0,
		@enabled=1, @freq_type=8, @freq_recurrence_factor=1, @freq_subday_type=4, @freq_subday_interval=5
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END

-- CREATE JOB 'HSO - Cleanup Perfmon Tables'
SET		@JobName = 'HSO - Cleanup Perfmon Tables'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName,  @on_success_action=1, @database_name=N'DBAtools', @subsystem=N'TSQL', 
		@command=N'DELETE FROM WhoIsActive_LOG 
WHERE collection_time < (getdate()-30)'
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Once in a week', @freq_interval=1, @active_start_time=10000,
		@freq_type=8, @freq_recurrence_factor=1 
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END


