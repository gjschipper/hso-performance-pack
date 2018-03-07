/********  CREATE JOB  ********/
USE [msdb]
GO

/****** Object:  Job [HSO - Trace Blocking Information]    Script Date: 10/19/2011 15:23:06 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 10/19/2011 15:23:06 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'HSO - Trace Blocking Information', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Records all blocking information into a trace file C:\SQLTRACE\DYNAMICS_DEFAULT.TRC. You must edit the steps to change the location of this file.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Start Tracing]    Script Date: 10/19/2011 15:23:06 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Start Tracing', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SP_SQLTRACE
	@FILE_PATH 		= ''C:\SQLTRACE'', -- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		= ''DYNAMICS_DEFAULT'', -- Trace name - becomes base of trace file name
	@DATABASE_NAME	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		= ''N'',			-- When set to ''Y'' will stop the trace and exit
	@TRACE_RUN_HOURS  	= 25 			-- Number of hours to run trace

	', 
		@database_name=N'DBAtools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110313, 
		@active_end_date=99991231, 
		@active_start_time=000000, 
		@active_end_time=235959, 
		@schedule_uid=N'3aa2d032-645a-4a48-b96e-a40fb57097aa'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Startup', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20111019, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'bce0cd16-d38d-4b96-b90b-b352600980b1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/********  CREATE STORED PROCEDURE  ********/
/****** Object:  StoredProcedure [dbo].[SP_SQLTRACE]    Script Date: 02/28/2011 12:23:40 ******/
USE [DBAtools]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SP_SQLTRACE]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SP_SQLTRACE]
GO

/****** Object:  StoredProcedure [dbo].[SP_SQLTRACE]    Script Date: 02/28/2011 12:23:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ***********************************************************************
-- ***********************************************************************
CREATE           PROCEDURE [dbo].[SP_SQLTRACE]
-- ***********************************************************************
-- ***********************************************************************
-- ***********************************************************************
-- This stored procedure is provided AS IS with no warranties and confers no rights.
-- ***********************************************************************
	
	@FILE_PATH 			NVARCHAR(200)	= 'C:\SQLTRACE',-- Location to write trace files.  Note: directory must exist before start of trace
	@TRACE_NAME  		NVARCHAR(40)	= 'DYNAMICS_DEFAULT', -- Trace name - becomes base of trace file name
	@DATABASE_NAME		NVARCHAR(128)	= NULL,			-- Name of database to trace; default (NULL) will trace all databases
	@TRACE_FILE_SIZE	BIGINT			= 10,			-- maximum trace file size - will rollover when reached
	@TRACE_FILE_COUNT	INT				= 100,			-- maximum numer of trace files  - will delete oldest when reached
	@TRACE_STOP  		NVARCHAR(1)		= 'N',			-- When set to 'Y' will stop the trace and exit
	@TRACE_RUN_HOURS  	SMALLINT		= 48, 			-- Number of hours to run trace
	@HOSTNAME			NVARCHAR(128)	= NULL,			--Hostname filter for trace		
	@DURATION_SECS			BIGINT			= 0				-- enables statment, rpc, batch trace by specified duration			


AS

SET NOCOUNT ON
SET DATEFORMAT MDY
--
-- Schedulable server-side trace script
--
--
-- This script can be used to start, run and manage several traces.
-- The trace name is used as unique identifier to represent trace, so make it meaningful.
-- When this script runs, it deletes the existing trace with the same filename,
-- and creates a new trace, adding a date/time extension to the trace file name
-- Change the following as appropriate:
--
--	DATA COLUMNS
--	EVENT CLASSES
--	FILTERS
--


-- -----------------------------------------------------------------------
-- Declare variables
-- -----------------------------------------------------------------------
DECLARE	@CMD			NVARCHAR(1000),	-- Used for command or sql strings
		@RC				INT,			-- Return status for stored procedures
		@ON				BIT,			-- Used as on bit for set event
		@TRACEID 		INT, 			-- Queue handle running trace queue
		@DATABASE_ID 	INT, 			-- DB ID to filter trace
		@EVENT_ID 		INT, 			-- Trace Event
		@COLUMN_ID 		INT, 			-- Trace Event Column
		@TRACE_STOPTIME	DATETIME, 		-- Trace will be set to stop 25 hours after starting
		@FILE_NAME 		NVARCHAR(245)	-- Trace file name
DECLARE	@EVENTS_VAR		TABLE(EVENT_ID INT PRIMARY KEY(EVENT_ID))

SET @ON				= 1
SET @TRACE_STOPTIME = DATEADD(HH, @TRACE_RUN_HOURS, GETDATE())

-- -----------------------------------------------------------------------
-- Edit parameters
-- -----------------------------------------------------------------------

IF @FILE_PATH LIKE '%\'
    BEGIN
		PRINT 'OMIT TRAILING \ FROM PATH NAME'
		SET @RC = 1
		GOTO ERROR
    END


IF @DATABASE_NAME IS NOT NULL
    BEGIN
		SELECT	@DATABASE_ID = database_id 
		FROM	sys.databases
		WHERE	name =  @DATABASE_NAME
		IF @@ROWCOUNT = 0
			BEGIN
				PRINT @DATABASE_NAME + ' DOES NOT EXIST'
				SET @RC = 1
				GOTO ERROR
			END
    END


-- -----------------------------------------------------------------------
-- Stop the trace queue if running
-- -----------------------------------------------------------------------
IF EXISTS	
	(
	SELECT	*
	FROM 	fn_trace_getinfo(DEFAULT)
	WHERE 	property = 2	-- TRACE FILE NAME
	AND		CONVERT(NVARCHAR(245),value)  LIKE '%\'+@TRACE_NAME+'%'
	)
    BEGIN
		SELECT	@TRACEID = traceid
		FROM 	fn_trace_getinfo(DEFAULT)
		WHERE 	property = 2	-- TRACE FILE NAME
		AND		CONVERT(VARCHAR(240),value)  LIKE '%\'+@TRACE_NAME+'%'
		EXEC @RC = sp_trace_setstatus @TRACEID, 0	-- STOPS SPECIFIED TRACE
		IF @RC = 0  PRINT 'SP_TRACE_SETSTATUS: STOPPED TRACE ID ' + STR(@TRACEID )
		IF @RC = 1  PRINT 'SP_TRACE_SETSTATUS: - UNKNOWN ERROR'
		IF @RC = 8  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID'
		IF @RC = 9  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID'
		IF @RC = 13 PRINT 'SP_TRACE_SETSTATUS: OUT OF MEMORY'
		IF @RC <> 0 GOTO ERROR

		EXEC sp_trace_setstatus @TRACEID, 2 -- DELETE SPECIFIED TRACE

		IF @RC = 0  PRINT 'SP_TRACE_SETSTATUS: DELETED TRACE ID ' + STR(@TRACEID)
		IF @RC = 1  PRINT 'SP_TRACE_SETSTATUS: - UNKNOWN ERROR'
		IF @RC = 8  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID'
		IF @RC = 9  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID'
		IF @RC = 13 PRINT 'SP_TRACE_SETSTATUS: OUT OF MEMORY'
		IF @RC <> 0 GOTO ERROR
    END


-- -----------------------------------------------------------------------
-- Stop trace and leave if requested via   @TRACE_STOP
-- -----------------------------------------------------------------------
IF @TRACE_STOP = 'Y' GOTO ENDPROC


-- -----------------------------------------------------------------------
-- Build the trace file name 
-- -----------------------------------------------------------------------

SELECT 	@FILE_NAME = 	@FILE_PATH 	+ '\' + @TRACE_NAME 				
PRINT 'FILE NAME = ' + @FILE_NAME+'.trc'

-- Convert @DURATION_SECS to appropriate time for sp_trace
IF @DURATION_SECS > 0
BEGIN
SET @DURATION_SECS = @DURATION_SECS * 1000000   -- convert to microseconds
END
-- -----------------------------------------------------------------------
-- Create trace
-- -----------------------------------------------------------------------


EXEC @RC = sp_trace_create
	@TRACEID OUTPUT, 	--	TRACE HANDLE - NEEDED FOR SUBSEQUENT TRACE OPERATIONS
	2, 					--	2 INDICATES FILE ROLLOVER
	@FILE_NAME,			--	FULL TRACE FILE NAME
	@TRACE_FILE_SIZE, 	--	MAXIMUM TRACE FILE SIZE BEFORE ROLLOVER
	@TRACE_STOPTIME,	--	TRACE STOP TIME
	@TRACE_FILE_COUNT	--	MAXIMUM TRACE FILE COUNT BEFORE OLDEST DELETED

IF @RC = 0  PRINT 'SP_TRACE_CREATE: CREATED TRACE ID ' + STR(@TRACEID )
IF @RC = 1  PRINT 'SP_TRACE_CREATE: - UNKNOWN ERROR'
IF @RC = 10 PRINT 'SP_TRACE_CREATE: INVALID OPTIONS'
IF @RC = 12 PRINT 'SP_TRACE_CREATE: FILE NAME ALREADY EXISTS; NEW TRACE NOT CREATED'
IF @RC = 13 PRINT 'SP_TRACE_CREATE: OUT OF MEMORY'
IF @RC = 14 PRINT 'SP_TRACE_CREATE: INVALID STOP TIME'
IF @RC = 15 PRINT 'SP_TRACE_CREATE: INVALID PARAMETERS'
IF @RC <> 0 
	BEGIN
		PRINT 'SP_TRACE_CREATE: Confirm that directory '+@FILE_PATH+ ' exists'
		GOTO ERROR
	END


-- -----------------------------------------------------------------------
-- Set trace events to capture
-- -----------------------------------------------------------------------
IF @DURATION_SECS > 0
	BEGIN
		INSERT INTO @EVENTS_VAR VALUES(10) --  Stored Procedures: RPC:Completed
		INSERT INTO @EVENTS_VAR VALUES(45) --  Stored Procedures: SP:StmtCompleted
		INSERT INTO @EVENTS_VAR VALUES(12) --  TSQL: SQL:BatchCompleted
		INSERT INTO @EVENTS_VAR VALUES(41) --  TSQL: SQL:StmtCompleted
		INSERT INTO @EVENTS_VAR VALUES(43) --  Stored Procedures: SP:Completed  
	END
ELSE
	BEGIN
		INSERT INTO @EVENTS_VAR VALUES(55)	-- Hash Warning
		-- INSERT INTO @EVENTS_VAR VALUES(58)	-- Auto Stats
		INSERT INTO @EVENTS_VAR VALUES(60)	-- Lock Escalation
		INSERT INTO @EVENTS_VAR VALUES(67)	-- Execution Warnings
		INSERT INTO @EVENTS_VAR VALUES(80)	-- Missing Join Predicate
		INSERT INTO @EVENTS_VAR VALUES(92)	-- Data File Grow
		INSERT INTO @EVENTS_VAR VALUES(93)	-- Log File Grow
		INSERT INTO @EVENTS_VAR VALUES(137)	-- Blocked Process Report
		INSERT INTO @EVENTS_VAR VALUES(148)	-- Deadlock Graph
		--REH added these in 1.10
		INSERT INTO @EVENTS_VAR VALUES(94) --  Database: Data File Auto Shrink
		INSERT INTO @EVENTS_VAR VALUES(95) --  Database: Log File Auto Shrink
		INSERT INTO @EVENTS_VAR VALUES(155) --  Full text: FT:Crawl Started
		INSERT INTO @EVENTS_VAR VALUES(156) --  Full text: FT:Crawl Stopped
		INSERT INTO @EVENTS_VAR VALUES(157) --  Full text: FT:Crawl Aborted
		INSERT INTO @EVENTS_VAR VALUES(115) --  Security Audit: Audit Backup/Restore Event
	END

-- -----------------------------------------------------------------------
-- INSERT INTO @EVENTS_VAR VALUES(165)	-- Performance Statistics
-- -----------------------------------------------------------------------

-- -----------------------------------------------------------------------
-- Remaining events are provided here and can be enabled by uncommenting
-- Use EXTREME CAUTION as continous tracing of these events can introduce
-- significant overhead.
-- -----------------------------------------------------------------------


 --INSERT INTO @EVENTS_VAR VALUES(10) --  Stored Procedures: RPC:Completed
-- INSERT INTO @EVENTS_VAR VALUES(11) --  Stored Procedures: RPC:Starting
--INSERT INTO @EVENTS_VAR VALUES(12) --  TSQL: SQL:BatchCompleted
-- INSERT INTO @EVENTS_VAR VALUES(13) --  TSQL: SQL:BatchStarting
-- INSERT INTO @EVENTS_VAR VALUES(14) --  Security Audit: Audit Login
-- INSERT INTO @EVENTS_VAR VALUES(15) --  Security Audit: Audit Logout
 --INSERT INTO @EVENTS_VAR VALUES(16) --  Errors and Warnings: Attention  ---reh
-- INSERT INTO @EVENTS_VAR VALUES(17) --  Sessions: ExistingConnection
-- INSERT INTO @EVENTS_VAR VALUES(18) --  Security Audit: Audit Server Starts And Stops
-- INSERT INTO @EVENTS_VAR VALUES(19) --  Transactions: DTCTransaction
-- INSERT INTO @EVENTS_VAR VALUES(20) --  Security Audit: Audit Login Failed
-- INSERT INTO @EVENTS_VAR VALUES(21) --  Errors and Warnings: EventLog
-- INSERT INTO @EVENTS_VAR VALUES(22) --  Errors and Warnings: ErrorLog
-- INSERT INTO @EVENTS_VAR VALUES(23) --  Locks: Lock:Released
-- INSERT INTO @EVENTS_VAR VALUES(24) --  Locks: Lock:Acquired
-- INSERT INTO @EVENTS_VAR VALUES(25) --  Locks: Lock:Deadlock
-- INSERT INTO @EVENTS_VAR VALUES(26) --  Locks: Lock:Cancel
-- INSERT INTO @EVENTS_VAR VALUES(27) --  Locks: Lock:Timeout
-- INSERT INTO @EVENTS_VAR VALUES(28) --  Performance: Degree of Parallelism (7.0 Insert)
 --INSERT INTO @EVENTS_VAR VALUES(33) --  Errors and Warnings: Exception   ---reh
-- INSERT INTO @EVENTS_VAR VALUES(34) --  Stored Procedures: SP:CacheMiss
-- INSERT INTO @EVENTS_VAR VALUES(35) --  Stored Procedures: SP:CacheInsert
-- INSERT INTO @EVENTS_VAR VALUES(36) --  Stored Procedures: SP:CacheRemove
-- INSERT INTO @EVENTS_VAR VALUES(37) --  Stored Procedures: SP:Recompile
-- INSERT INTO @EVENTS_VAR VALUES(38) --  Stored Procedures: SP:CacheHit
-- INSERT INTO @EVENTS_VAR VALUES(39) --  Stored Procedures: Deprecated
-- INSERT INTO @EVENTS_VAR VALUES(40) --  TSQL: SQL:StmtStarting
 --INSERT INTO @EVENTS_VAR VALUES(41) --  TSQL: SQL:StmtCompleted
-- INSERT INTO @EVENTS_VAR VALUES(42) --  Stored Procedures: SP:Starting
 --INSERT INTO @EVENTS_VAR VALUES(43) --  Stored Procedures: SP:Completed   
-- INSERT INTO @EVENTS_VAR VALUES(44) --  Stored Procedures: SP:StmtStarting
 --INSERT INTO @EVENTS_VAR VALUES(45) --  Stored Procedures: SP:StmtCompleted  
-- INSERT INTO @EVENTS_VAR VALUES(46) --  Objects: Object:Created
-- INSERT INTO @EVENTS_VAR VALUES(47) --  Objects: Object:Deleted
-- INSERT INTO @EVENTS_VAR VALUES(50) --  Transactions: SQLTransaction
-- INSERT INTO @EVENTS_VAR VALUES(51) --  Scans: Scan:Started
-- INSERT INTO @EVENTS_VAR VALUES(52) --  Scans: Scan:Stopped
-- INSERT INTO @EVENTS_VAR VALUES(53) --  Cursors: CursorOpen
-- INSERT INTO @EVENTS_VAR VALUES(54) --  Transactions: TransactionLog
-- INSERT INTO @EVENTS_VAR VALUES(59) --  Locks: Lock:Deadlock Chain
-- INSERT INTO @EVENTS_VAR VALUES(60)   --  Locks: Lock:escalation
-- INSERT INTO @EVENTS_VAR VALUES(61) --  OLEDB: OLEDB Errors
 --INSERT INTO @EVENTS_VAR VALUES(68) --  Performance: Showplan Text (Unencoded)  
-- INSERT INTO @EVENTS_VAR VALUES(69) --  Errors and Warnings: Sort Warnings
-- INSERT INTO @EVENTS_VAR VALUES(70) --  Cursors: CursorPrepare
-- INSERT INTO @EVENTS_VAR VALUES(71) --  TSQL: Prepare SQL
-- INSERT INTO @EVENTS_VAR VALUES(72) --  TSQL: Exec Prepared SQL
-- INSERT INTO @EVENTS_VAR VALUES(73) --  TSQL: Unprepare SQL
-- INSERT INTO @EVENTS_VAR VALUES(74) --  Cursors: CursorExecute
-- INSERT INTO @EVENTS_VAR VALUES(75) --  Cursors: CursorRecompile
-- INSERT INTO @EVENTS_VAR VALUES(76)	-- Cursor Conversion
-- INSERT INTO @EVENTS_VAR VALUES(77) --  Cursors: CursorUnprepare
-- INSERT INTO @EVENTS_VAR VALUES(78) --  Cursors: CursorClose
--INSERT INTO @EVENTS_VAR VALUES(79)	-- Missing Column Statistics
-- INSERT INTO @EVENTS_VAR VALUES(81) --  Server: Server Memory Change
-- INSERT INTO @EVENTS_VAR VALUES(82) --  User configurable: UserConfigurable:0
-- INSERT INTO @EVENTS_VAR VALUES(83) --  User configurable: UserConfigurable:1
-- INSERT INTO @EVENTS_VAR VALUES(84) --  User configurable: UserConfigurable:2
-- INSERT INTO @EVENTS_VAR VALUES(85) --  User configurable: UserConfigurable:3
-- INSERT INTO @EVENTS_VAR VALUES(86) --  User configurable: UserConfigurable:4
-- INSERT INTO @EVENTS_VAR VALUES(87) --  User configurable: UserConfigurable:5
-- INSERT INTO @EVENTS_VAR VALUES(88) --  User configurable: UserConfigurable:6
-- INSERT INTO @EVENTS_VAR VALUES(89) --  User configurable: UserConfigurable:7
-- INSERT INTO @EVENTS_VAR VALUES(90) --  User configurable: UserConfigurable:8
-- INSERT INTO @EVENTS_VAR VALUES(91) --  User configurable: UserConfigurable:9
-- INSERT INTO @EVENTS_VAR VALUES(94) --  Database: Data File Auto Shrink
-- INSERT INTO @EVENTS_VAR VALUES(95) --  Database: Log File Auto Shrink
-- INSERT INTO @EVENTS_VAR VALUES(96) --  Performance: Showplan Text
-- INSERT INTO @EVENTS_VAR VALUES(97) --  Performance: Showplan All
-- INSERT INTO @EVENTS_VAR VALUES(98) --  Performance: Showplan Statistics Profile
-- INSERT INTO @EVENTS_VAR VALUES(100) --  Stored Procedures: RPC Output Parameter
-- INSERT INTO @EVENTS_VAR VALUES(102) --  Security Audit: Audit Database Scope GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(103) --  Security Audit: Audit Schema Object GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(104) --  Security Audit: Audit Addlogin Event
-- INSERT INTO @EVENTS_VAR VALUES(105) --  Security Audit: Audit Login GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(106) --  Security Audit: Audit Login Change Property Event
-- INSERT INTO @EVENTS_VAR VALUES(107) --  Security Audit: Audit Login Change Password Event
-- INSERT INTO @EVENTS_VAR VALUES(108) --  Security Audit: Audit Add Login to Server Role Event
-- INSERT INTO @EVENTS_VAR VALUES(109) --  Security Audit: Audit Add DB User Event
-- INSERT INTO @EVENTS_VAR VALUES(110) --  Security Audit: Audit Add Member to DB Role Event
-- INSERT INTO @EVENTS_VAR VALUES(111) --  Security Audit: Audit Add Role Event
-- INSERT INTO @EVENTS_VAR VALUES(112) --  Security Audit: Audit App Role Change Password Event
-- INSERT INTO @EVENTS_VAR VALUES(113) --  Security Audit: Audit Statement Permission Event
-- INSERT INTO @EVENTS_VAR VALUES(114) --  Security Audit: Audit Schema Object Access Event
-- INSERT INTO @EVENTS_VAR VALUES(115) --  Security Audit: Audit Backup/Restore Event
-- INSERT INTO @EVENTS_VAR VALUES(116) --  Security Audit: Audit DBCC Event
-- INSERT INTO @EVENTS_VAR VALUES(117) --  Security Audit: Audit Change Audit Event
-- INSERT INTO @EVENTS_VAR VALUES(118) --  Security Audit: Audit Object Derived Permission Event
-- INSERT INTO @EVENTS_VAR VALUES(119) --  OLEDB: OLEDB Call Event
-- INSERT INTO @EVENTS_VAR VALUES(120) --  OLEDB: OLEDB QueryInterface Event
-- INSERT INTO @EVENTS_VAR VALUES(121) --  OLEDB: OLEDB DataRead Event
-- INSERT INTO @EVENTS_VAR VALUES(122) --  Performance: Showplan XML
-- INSERT INTO @EVENTS_VAR VALUES(123) --  Performance: SQL:FullTextQuery
-- INSERT INTO @EVENTS_VAR VALUES(124) --  Broker: Broker:Conversation
-- INSERT INTO @EVENTS_VAR VALUES(125) --  Deprecation: Deprecation Announcement
-- INSERT INTO @EVENTS_VAR VALUES(126) --  Deprecation: Deprecation Final Support
-- INSERT INTO @EVENTS_VAR VALUES(127) --  Errors and Warnings: Exchange Spill Event
-- INSERT INTO @EVENTS_VAR VALUES(128) --  Security Audit: Audit Database Management Event
-- INSERT INTO @EVENTS_VAR VALUES(129) --  Security Audit: Audit Database Object Management Event
-- INSERT INTO @EVENTS_VAR VALUES(130) --  Security Audit: Audit Database Principal Management Event
-- INSERT INTO @EVENTS_VAR VALUES(131) --  Security Audit: Audit Schema Object Management Event
-- INSERT INTO @EVENTS_VAR VALUES(132) --  Security Audit: Audit Server Principal Impersonation Event
-- INSERT INTO @EVENTS_VAR VALUES(133) --  Security Audit: Audit Database Principal Impersonation Event
-- INSERT INTO @EVENTS_VAR VALUES(134) --  Security Audit: Audit Server Object Take Ownership Event
-- INSERT INTO @EVENTS_VAR VALUES(135) --  Security Audit: Audit Database Object Take Ownership Event
-- INSERT INTO @EVENTS_VAR VALUES(136) --  Broker: Broker:Conversation Group
-- INSERT INTO @EVENTS_VAR VALUES(138) --  Broker: Broker:Connection
-- INSERT INTO @EVENTS_VAR VALUES(139) --  Broker: Broker:Forwarded Message Sent
-- INSERT INTO @EVENTS_VAR VALUES(140) --  Broker: Broker:Forwarded Message Dropped
-- INSERT INTO @EVENTS_VAR VALUES(141) --  Broker: Broker:Message Classify
-- INSERT INTO @EVENTS_VAR VALUES(142) --  Broker: Broker:Transmission
-- INSERT INTO @EVENTS_VAR VALUES(143) --  Broker: Broker:Queue Disabled
-- INSERT INTO @EVENTS_VAR VALUES(144) --  Broker: Broker:Mirrored Route State Changed
-- INSERT INTO @EVENTS_VAR VALUES(146) --  Performance: Showplan XML Statistics Profile
-- INSERT INTO @EVENTS_VAR VALUES(149) --  Broker: Broker:Remote Message Acknowledgement
-- INSERT INTO @EVENTS_VAR VALUES(150) --  Server: Trace File Close
-- INSERT INTO @EVENTS_VAR VALUES(152) --  Security Audit: Audit Change Database Owner
-- INSERT INTO @EVENTS_VAR VALUES(153) --  Security Audit: Audit Schema Object Take Ownership Event
-- INSERT INTO @EVENTS_VAR VALUES(155) --  Full text: FT:Crawl Started
-- INSERT INTO @EVENTS_VAR VALUES(156) --  Full text: FT:Crawl Stopped
-- INSERT INTO @EVENTS_VAR VALUES(157) --  Full text: FT:Crawl Aborted
-- INSERT INTO @EVENTS_VAR VALUES(158) --  Security Audit: Audit Broker Conversation
-- INSERT INTO @EVENTS_VAR VALUES(159) --  Security Audit: Audit Broker Login
-- INSERT INTO @EVENTS_VAR VALUES(160) --  Broker: Broker:Message Undeliverable
-- INSERT INTO @EVENTS_VAR VALUES(161) --  Broker: Broker:Corrupted Message
-- INSERT INTO @EVENTS_VAR VALUES(162) --  Errors and Warnings: User Error Message
-- INSERT INTO @EVENTS_VAR VALUES(163) --  Broker: Broker:Activation
-- INSERT INTO @EVENTS_VAR VALUES(164) --  Objects: Object:Altered
-- INSERT INTO @EVENTS_VAR VALUES(166) --  TSQL: SQL:StmtRecompile
-- INSERT INTO @EVENTS_VAR VALUES(167) --  Database: Database Mirroring State Change
-- INSERT INTO @EVENTS_VAR VALUES(168) --  Performance: Showplan XML For Query Compile
-- INSERT INTO @EVENTS_VAR VALUES(169) --  Performance: Showplan All For Query Compile
-- INSERT INTO @EVENTS_VAR VALUES(170) --  Security Audit: Audit Server Scope GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(171) --  Security Audit: Audit Server Object GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(172) --  Security Audit: Audit Database Object GDR Event
-- INSERT INTO @EVENTS_VAR VALUES(173) --  Security Audit: Audit Server Operation Event
-- INSERT INTO @EVENTS_VAR VALUES(175) --  Security Audit: Audit Server Alter Trace Event
-- INSERT INTO @EVENTS_VAR VALUES(176) --  Security Audit: Audit Server Object Management Event
-- INSERT INTO @EVENTS_VAR VALUES(177) --  Security Audit: Audit Server Principal Management Event
-- INSERT INTO @EVENTS_VAR VALUES(178) --  Security Audit: Audit Database Operation Event
-- INSERT INTO @EVENTS_VAR VALUES(180) --  Security Audit: Audit Database Object Access Event
-- INSERT INTO @EVENTS_VAR VALUES(181) --  Transactions: TM: Begin Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(182) --  Transactions: TM: Begin Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(183) --  Transactions: TM: Promote Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(184) --  Transactions: TM: Promote Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(185) --  Transactions: TM: Commit Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(186) --  Transactions: TM: Commit Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(187) --  Transactions: TM: Rollback Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(188) --  Transactions: TM: Rollback Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(189) --  Locks: Lock:Timeout (timeout > 0)
-- INSERT INTO @EVENTS_VAR VALUES(190) --  Progress Report: Progress Report: Online Index Operation
-- INSERT INTO @EVENTS_VAR VALUES(191) --  Transactions: TM: Save Tran starting
-- INSERT INTO @EVENTS_VAR VALUES(192) --  Transactions: TM: Save Tran completed
-- INSERT INTO @EVENTS_VAR VALUES(193) --  Errors and Warnings: Background Job Error
-- INSERT INTO @EVENTS_VAR VALUES(194) --  OLEDB: OLEDB Provider Information
-- INSERT INTO @EVENTS_VAR VALUES(195) --  Server: Mount Tape
-- INSERT INTO @EVENTS_VAR VALUES(196) --  CLR: Assembly Load
-- INSERT INTO @EVENTS_VAR VALUES(198) --  TSQL: XQuery Static Type
-- INSERT INTO @EVENTS_VAR VALUES(199) --  Query Notifications: QN: Subscription
-- INSERT INTO @EVENTS_VAR VALUES(200) --  Query Notifications: QN: Parameter table
-- INSERT INTO @EVENTS_VAR VALUES(201) --  Query Notifications: QN: Template
-- INSERT INTO @EVENTS_VAR VALUES(202) --  Query Notifications: QN: Dynamics


-- -----------------------------------------------------------------------
-- Set the events and columns to capture.  
-- Join the list of events (@EVENTS_VAR) 
-- to their valid columns (from sys.trace_event_bindings) 
-- and execute sp_trace_setevent for each event/column combination
-- -----------------------------------------------------------------------
DECLARE SETEVENTS CURSOR FOR
	SELECT	trace_event_id, trace_column_id
	FROM	@EVENTS_VAR, sys.trace_event_bindings
	WHERE	EVENT_ID = trace_event_id
	ORDER BY 1,2

OPEN	SETEVENTS
FETCH	SETEVENTS INTO @EVENT_ID, @COLUMN_ID
WHILE	@@FETCH_STATUS = 0
	BEGIN
		exec sp_trace_setevent @TRACEID, @EVENT_ID, @COLUMN_ID, @ON
		FETCH	SETEVENTS INTO @EVENT_ID, @COLUMN_ID
	END
DEALLOCATE SETEVENTS


-- -----------------------------------------------------------------------
-- Set filters
-- -----------------------------------------------------------------------
IF @HOSTNAME IS NOT NULL
	EXEC sp_trace_setfilter @TRACEID, 7,0,6, @HOSTNAME
-- -----------------------------------------------------------------------
--  Filter on Database ID if Database Name is supplied
-- -----------------------------------------------------------------------

IF @DATABASE_NAME IS NOT NULL
	EXEC sp_trace_setfilter @TRACEID,  3, 0, 0, @DATABASE_ID

-- -----------------------------------------------------------------------
--   Applicationname not like 'sql profiler'
-- -----------------------------------------------------------------------
EXEC sp_trace_setfilter @TRACEID, 10, 0, 7, N'SQL PROFILER'


-- -----------------------------------------------------------------------
--   Database name not like 'DBAtools'
-- -----------------------------------------------------------------------
EXEC sp_trace_setfilter @TRACEID, 35, 0, 7, N'DBAtools%'

--  If@DURATION_SECS is specified, add events and set duration filter

IF @DURATION_SECS > 0
	BEGIN
		EXEC sp_trace_setfilter @TRACEID, 13, 0, 4, @DURATION_SECS
	END

-- -----------------------------------------------------------------------
--   Objectid >= 100 (excludes system objects)
-- -----------------------------------------------------------------------
--EXEC sp_trace_setfilter @TRACEID, 22, 0, 4, 100

-- -----------------------------------------------------------------------
-- Start the trace
-- -----------------------------------------------------------------------

EXEC @RC = sp_trace_setstatus @TRACEID, 1

IF @RC = 0  PRINT 'SP_TRACE_SETSTATUS: STARTED TRACE ID  ' + STR(@TRACEID )
IF @RC = 1  PRINT 'SP_TRACE_SETSTATUS: - UNKNOWN ERROR'
IF @RC = 8  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED STATUS IS NOT VALID'
IF @RC = 9  PRINT 'SP_TRACE_SETSTATUS: THE SPECIFIED TRACE HANDLE IS NOT VALID'
IF @RC = 13 PRINT 'SP_TRACE_SETSTATUS: OUT OF MEMORY'

IF @DURATION_SECS > 0
	BEGIN
	PRINT ''
	--Don't update the trace file path as this is not our default trace we are creating
	END
ELSE
	BEGIN
		UPDATE DBAtools..DBAtools_SETUP SET TRACE_FULL_PATH_NAME = @FILE_PATH 	+ '\' + @TRACE_NAME +'.trc'
	END

ENDPROC:

ERROR:
RETURN @RC
GO

/********  CREATE TABLE  ********/
USE [DBAtools]
GO

/****** Object:  Table [dbo].[DBAtools_SETUP]    Script Date: 03/14/2011 16:33:45 ******/
IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = Object_id(N'[dbo].[DBAtools_SETUP]')
                  AND type IN ( N'U' ))
  DROP TABLE [dbo].[DBAtools_SETUP] 

GO

USE [DBAtools]
GO

/****** Object:  Table [dbo].[DBAtools_SETUP]    Script Date: 03/14/2011 16:33:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DBAtools_SETUP](
	[VERSION] [nvarchar](256) NULL,
	[INSTALLED_DATE] [smalldatetime] NULL,
	[TRACE_FULL_PATH_NAME]   [nvarchar] (512) NULL
) ON [PRIMARY]

GO
INSERT [DBAtools]..[DBAtools_SETUP]
VALUES('1.20', GETDATE(), '') 

GO

/********  CREATE VIEW  ********/
USE [DBAtools]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[BLOCKED_PROCESS_VW]'))
DROP VIEW [dbo].[BLOCKED_PROCESS_VW]
GO

/****** Object:  View [dbo].[BLOCKED_PROCESS_VW]    Script Date: 10/17/2011 15:26:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BLOCKED_PROCESS_VW]
AS
 SELECT
END_TIME,
BLOCKED_SQL,
BLOCKED_SPID,
[WAIT_TIME(MS)],
WAIT_RESOURCE,
LOCK_MODE_REQUESTED,
BLOCKED_TRANS_COUNT,
BLOCKED_CLIENT_APP,
BLOCKED_HOST_NAME,
BLOCKED_ISOLATION_LEVEL,
BLOCKING_SQL,
BLOCKING_SPID,
BLOCKING_SPID_STATUS,
BLOCKING_TRANS_COUNT,
BLOCKING_LAST_BATCH_STARTED,
BLOCKING_LAST_BATCH_COMPLETED,
BLOCKING_CLIENT_APP,
BLOCKING_HOST_NAME,
BLOCKING_ISOLATION_LEVEL,
ObjectID


 FROM 
(
	SELECT	
	CONVERT(DATETIME, EndTime) AS END_TIME,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@spid)[1]','INT')						AS BLOCKED_SPID,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/inputbuf)[1]','nvarchar(max)')		AS BLOCKED_SQL,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@waittime)[1]','INT')					AS [WAIT_TIME(MS)],
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@waitresource)[1]','nvarchar(50)')	AS WAIT_RESOURCE,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@lockMode)[1]','nvarchar(50)')		AS LOCK_MODE_REQUESTED,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@transcount)[1]','INT')				AS BLOCKED_TRANS_COUNT,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@clientapp)[1]','nvarchar(50)')		AS BLOCKED_CLIENT_APP,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@hostname)[1]','nvarchar(50)')		AS BLOCKED_HOST_NAME,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/@isolationlevel)[1]','nvarchar(50)')	AS BLOCKED_ISOLATION_LEVEL,
	convert(xml, TextData).value('(blocked-process-report/blocked-process/process/executionStack/frame/@SQLhandle)[1]','NVARCHAR(64)') as BLOCKED_SQL_HANDLE,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@spid)[1]','INT')					AS BLOCKING_SPID,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/inputbuf)[1]','nvarchar(max)')		AS BLOCKING_SQL,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@status)[1]','NVARCHAR(10)')			AS BLOCKING_SPID_STATUS,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@transcount)[1]','INT')				AS BLOCKING_TRANS_COUNT,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@lastbatchstarted)[1]','DATETIME')	AS BLOCKING_LAST_BATCH_STARTED,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@lastbatchcompleted)[1]','DATETIME') AS BLOCKING_LAST_BATCH_COMPLETED,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@clientapp)[1]','nvarchar(50)')		AS BLOCKING_CLIENT_APP,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@hostname)[1]','nvarchar(50)')		AS BLOCKING_HOST_NAME,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/@isolationlevel)[1]','nvarchar(50)') AS BLOCKING_ISOLATION_LEVEL,
	convert(xml, TextData).value('(blocked-process-report/blocking-process/process/executionStack/frame/@SQLhandle)[1]','NVARCHAR(64)') as BLOCKING_SQL_HANDLE,
	ObjectID
	FROM fn_trace_gettable(
	ISNULL(
	(SELECT TRACE_FULL_PATH_NAME FROM DBAtools_SETUP)
	,(SELECT TOP 1 path FROM sys.traces WHERE path like '%DYNAMICS_DEFAULT%'))
	, default) F,
	sys.trace_events E
	WHERE EventClass = trace_event_id
	and name = 'Blocked process report'
)	AS Trace