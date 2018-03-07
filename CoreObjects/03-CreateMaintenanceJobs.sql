-- !!!!!!!!!! MODIFY @AXDB TO THE RIGHT DATABASE NAME !!!!!!!!!!

USE DBAtools

DECLARE @AXDB nvarchar(max)
SET @AXDB = 'DB_NAME' 

SELECT 'Creating SQL Jobs for AX database: ' + name AS ACTIVITY
FROM master.dbo.sysdatabases
where name = @AXDB

IF @@ROWCOUNT < 1
BEGIN
  RAISERROR ('Modify @AXDB to the right database name!', 16, 1)
  return
END
ELSE
BEGIN

DECLARE @JobName nvarchar(max)
DECLARE @StepName1 nvarchar(max)
DECLARE @StepName2 nvarchar(max)
DECLARE @StepName3 nvarchar(max)
DECLARE @StepName4 nvarchar(max)
DECLARE @StepName5 nvarchar(max)
DECLARE @NL AS CHAR(2) = CHAR(13) + CHAR(10)

-- CREATE JOB 'HSO - DBCheck'
SET		@JobName = 'HSO - DBCheck'
SET		@StepName1 = @JobName + ' - USER DATABASES'
SET		@StepName2 = @JobName + ' - SYSTEM DATABASES'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName1, @on_success_action=3, @database_name=N'DBAtools', @subsystem=N'TSQL', 
		@command=	N'EXECUTE [dbo].[DatabaseIntegrityCheck]
@Databases = ''USER_DATABASES'',
@LogToTable = ''Y'''
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName2, @on_success_action=1, @database_name=N'DBAtools', @subsystem=N'TSQL', 
		@command=	N'EXECUTE [dbo].[DatabaseIntegrityCheck]
@Databases = ''SYSTEM_DATABASES'',
@LogToTable = ''Y''' 
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Once in a week', @freq_interval=64, @active_start_time=10000,
		@freq_type=8, @freq_recurrence_factor=1 
EXECUTE msdb.dbo.sp_add_jobserver @job_name = @JobName
END


-- CREATE JOB 'HSO - IndexOptimize Daily'
SET		@JobName = 'HSO - IndexOptimize Daily'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName,  @on_success_action=1, @database_name=N'DBAtools', @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.IndexOptimize 
@Databases = ''USER_DATABASES'', 
@MAXDOP=0, 
@fillfactor=70, 
@UpdateStatistics=''ALL'', 
@OnlyModifiedStatistics = ''Y'',
@LogToTable=''Y'', 
@Execute=''Y'''
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Every workday', @freq_interval=62, @active_start_time=10000,
		@enabled=1, @freq_type=8, @freq_recurrence_factor=1 
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END

-- CREATE JOB 'HSO - IndexOptimize Weekly'
SET		@JobName = 'HSO - IndexOptimize Weekly'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName,  @on_success_action=1, @database_name=N'DBAtools', @subsystem=N'TSQL', 
		@command=N'EXECUTE dbo.IndexOptimize 
@Databases = ''USER_DATABASES'', 
@MAXDOP=0, 
@fillfactor=70, 
@UpdateStatistics=''ALL'', 
@OnlyModifiedStatistics = ''N'',
@StatisticsSample=100,
@LogToTable=''Y'', 
@Execute=''Y'''
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Once in a week', @freq_interval=1, @active_start_time=10000,
		@freq_type=8, @freq_recurrence_factor=1 
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END

-- CREATE JOB 'HSO - CleanUpAXTables'
SET		@JobName = 'HSO - Cleanup AX Tables'
SET		@StepName1 = @JobName + ' - BATCH TABLES'
SET		@StepName2 = @JobName + ' - SYSDATABASELOG'
SET		@StepName3 = @JobName + ' - AIFLOG'
SET		@StepName4 = @JobName + ' - PRINTJOBPAGES'
SET		@StepName5 = @JobName + ' - BISHISTORY'

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName1, @on_success_action=3, @database_name=@AXDB, @subsystem=N'TSQL', 
		@command=	N'DECLARE @DAYS INT
SET @DAYS = 30

-- Backup tables
/*
select ''backup tables''
IF OBJECT_ID (''BATCHJOBHISTORY_BCK'',''U'') IS NOT NULL DROP TABLE BATCHJOBHISTORY_BCK
SELECT BATCHJOBHISTORY.* into BATCHJOBHISTORY_BCK from BATCHJOBHISTORY

IF OBJECT_ID (''BATCHHISTORY_BCK'',''U'') IS NOT NULL DROP TABLE BATCHHISTORY_BCK
SELECT BATCHHISTORY.* into BATCHHISTORY_BCK from BATCHHISTORY

IF OBJECT_ID (''BATCHCONSTRAINTSHISTORY_BCK'',''U'') IS NOT NULL DROP TABLE BATCHCONSTRAINTSHISTORY_BCK
SELECT BATCHCONSTRAINTSHISTORY.* into BATCHCONSTRAINTSHISTORY_BCK from BATCHCONSTRAINTSHISTORY
*/

-- Opschonen header tabel batchjob historie
select ''clean header table''
DECLARE @Rows INT
SET @Rows = 1

WHILE (@Rows > 0)
BEGIN
	DELETE TOP (1000) FROM BATCHJOBHISTORY
	WHERE CREATEDDATETIME < (getdate()-@DAYS)
	SET @Rows = @@ROWCOUNT
END
  
--Opschonen detail tabel batch historie op basis van verwijderde header records tabel batch historie 
select ''clean details table''
DECLARE @Rows2 INT
SET @Rows2 = 1

WHILE (@Rows2 > 0)
BEGIN
	DELETE TOP(1000) FROM BATCHHISTORY 
	WHERE  CREATEDDATETIME < (GETDATE()-@DAYS)
	SET @Rows2 = @@ROWCOUNT
END

select ''delete batchhistory''
DELETE FROM BATCHHISTORY
FROM BATCHHISTORY BH
WHERE NOT EXISTS (SELECT * FROM dbo.BATCHJOBHISTORY BJH WHERE BJH.RECID = BH.BATCHJOBHISTORYID)

-- Opschonen afhankelijkheid tabel batch historie op basis van verwijderde detail records tabel batch historie
select ''delete batchconstraints history''
DELETE FROM dbo.BATCHCONSTRAINTSHISTORY
FROM dbo.BATCHCONSTRAINTSHISTORY BCH
WHERE NOT EXISTS (SELECT * FROM dbo.BATCHHISTORY BH where BH.RECID = BCH.BATCHID)	

-- Insert records back
-- INSERT INTO BATCHHISTORY SELECT * FROM BATCHHISTORY_BCK WHERE CREATEDDATETIME < (getdate()-@DAYS)'
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName2, @on_success_action=3, @database_name=@AXDB ,@subsystem=N'TSQL', 
		@command=	N'-- Clean up SYSDATABASELOG TABLE
-- DELETE FROM SYSDATABASELOG
-- WHERE CREATEDDATETIME < (getdate()-90)'

EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName3, @on_success_action=3, @database_name=@AXDB ,@subsystem=N'TSQL', 
		@command=	N'/* CLEAN UP AIF TABLES
DECLARE @DAYS INT
DECLARE @ROWS INT
SET @DAYS = 30
SET @ROWS = 1

WHILE (@ROWS > 0)
BEGIN
	DELETE TOP (1000) FROM AIFDOCUMENTLOG
	WHERE EXISTS (SELECT * FROM AIFMESSAGELOG
	WHERE AIFDOCUMENTLOG.MESSAGEID = AIFMESSAGELOG.MESSAGEID
	AND AIFMESSAGELOG.CREATEDDATETIME < (getdate()-@DAYS)
	AND (AIFMESSAGELOG.STATUS = 1 --Processed
	OR AIFMESSAGELOG.STATUS = 2)) --Error
	SET @ROWS = @@ROWCOUNT
END

SET @ROWS = 1
WHILE (@ROWS > 0)
BEGIN
	DELETE TOP (1000) FROM AIFCORRELATION
	WHERE EXISTS (SELECT * FROM AIFMESSAGELOG
	WHERE AIFCORRELATION.MESSAGEID = AIFMESSAGELOG.MESSAGEID
	AND AIFMESSAGELOG.CREATEDDATETIME < (getdate()-@DAYS)
	AND (AIFMESSAGELOG.STATUS = 1 --Processed
	OR AIFMESSAGELOG.STATUS = 2)) --Error
	SET @ROWS = @@ROWCOUNT
END

SET @ROWS = 1
WHILE (@ROWS > 0)
BEGIN
	DELETE TOP (1000) FROM AIFRESPONSE
	WHERE EXISTS (SELECT * FROM AIFMESSAGELOG
	WHERE AIFRESPONSE.REQUESTMESSAGEID = AIFMESSAGELOG.MESSAGEID
	AND AIFMESSAGELOG.CREATEDDATETIME < (getdate()-@DAYS)
	AND (AIFMESSAGELOG.STATUS = 1 --Processed
	OR AIFMESSAGELOG.STATUS = 2)) --Error
	SET @ROWS = @@ROWCOUNT
END

SET @ROWS = 1
WHILE (@ROWS > 0)
BEGIN
	DELETE TOP (1000) FROM AIFMESSAGELOG
	WHERE AIFMESSAGELOG.CREATEDDATETIME < (getdate()-@DAYS)
	AND (AIFMESSAGELOG.STATUS = 1 --Processed
	OR AIFMESSAGELOG.STATUS = 2) --Error
	SET @ROWS = @@ROWCOUNT
END
*/'

EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName4, @on_success_action=3, @database_name=@AXDB ,@subsystem=N'TSQL', 
		@command=	N'/*DECLARE @DAYS INT
DECLARE @ROWS INT
SET @DAYS = 30
SET @ROWS = 1

WHILE (@ROWS > 0)
BEGIN
	DELETE TOP (1000) FROM PRINTJOBPAGES
	WHERE EXISTS (SELECT * from PRINTJOBHEADER
	WHERE PRINTJOBPAGES.PAGESHEADERRECID = PRINTJOBHEADER.RECID
	and PRINTJOBHEADER.CREATEDDATETIME < (getdate()-@DAYS))
	SET @ROWS = @@ROWCOUNT
END

SET @ROWS = 1
WHILE (@ROWS > 0)
BEGIN
	DELETE TOP (1000) FROM PRINTJOBHEADER
	WHERE PRINTJOBHEADER.CREATEDDATETIME < (getdate()-@DAYS)
	SET @ROWS = @@ROWCOUNT
END*/'

EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @StepName5, @on_success_action=1, @database_name=@AXDB ,@subsystem=N'TSQL', 
		@command=	N'/*
-- create temporary table for deleted IDs
CREATE TABLE BISCleanupTemp (
Id bigINT NOT NULL PRIMARY KEY)

-- save IDs of master table records (you want to delete) to temporary table    
INSERT INTO BISCleanupTemp(Id)
SELECT DISTINCT mt.Recid
FROM Bishistory mt 
WHERE Createddatetime < getdate() -180

-- delete from first detail table using join syntax
DELETE D
FROM Bishistoryentity D
INNER JOIN BISCleanupTemp X
ON D.HistoryRecordid = X.Id

-- and finally delete from master table
DELETE d
FROM Bishistory D
INNER JOIN BISCleanupTemp X
ON D.Recid = X.Id

-- do not forget to drop the temp table
DROP TABLE BISCleanupTemp
*/'

EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Once in a week', @freq_interval=64, @active_start_time=10000,
		@freq_type=8, @freq_recurrence_factor=1 
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END

-- CREATE JOB 'HSO - Export AOS Registry'
DECLARE @mycommand nvarchar(max)
set @mycommand = 'strSQLInstance = "' + @@SERVERNAME + '"
strAXDataBase = "' + @AXDB + '"

Const HKLM          = &H80000002
Const adInteger     = 3
Const adVarWChar    = 202
Const adlongVarWChar= 203
Const adParamInput  = &H0001
Const adCmdText     = &H0001
const REG_SZ        = 1
const REG_EXPAND_SZ = 2
const REG_BINARY    = 3
const REG_DWORD     = 4
const REG_MULTI_SZ  = 7

Dim objConnection
Dim objRecordset
Dim objCommandReg

Dim prmReg1
Dim prmReg2
Dim prmReg3
Dim prmReg4
Dim prmReg5
Dim prmReg6
Dim prmReg7
Dim prmReg8

Dim strAOS
Dim strRecordset'

set @mycommand += '
strRecordset = "SELECT SUBSTRING(SERVERID,(CHARINDEX(''@'',SERVERID)+1), (LEN(SERVERID)-CHARINDEX(''@'',SERVERID)))FROM SYSSERVERCONFIG"
Set objConnection=CreateObject("ADODB.Connection") 
Set objRecordset=CreateObject("ADODB.Recordset")
set objCommandReg=CreateObject("ADODB.command")
objConnection.Provider="SQLOLEDB"
objConnection.Properties("Data Source").Value = strSQLInstance
objConnection.Properties("Initial Catalog").Value = strAXDatabase
objConnection.Properties("Integrated Security").Value = "SSPI"
objConnection.Open
objCommandReg.ActiveConnection=objConnection
objCommandReg.CommandType=adCmdText
objCommandReg.CommandText="INSERT INTO DBAtools..AOS_REGISTRY VALUES (?,?,?,?,?,?,?,?)"
Set prmReg1=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg2=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,5)
Set prmReg3=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg4=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,25)
Set prmReg5=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg6=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,1)
Set prmReg7=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg8=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,8000)
objCommandReg.Parameters.Append prmReg1
objCommandReg.Parameters.Append prmReg2
objCommandReg.Parameters.Append prmReg3
objCommandReg.Parameters.Append prmReg4
objCommandReg.Parameters.Append prmReg5
objCommandReg.Parameters.Append prmReg6
objCommandReg.Parameters.Append prmReg7
objCommandReg.Parameters.Append prmReg8
objConnection.Execute "SET DATEFORMAT MDY"
objConnection.Execute "DELETE FROM DBAtools..AOS_REGISTRY WHERE AOS_INSTANCE_NAME = ''" & strAXDataBase & "''"
objRecordset.Open strRecordset, objConnection'

set @mycommand += '
Do While Not objRecordset.EOF
	strAOS =  objRecordset.Fields(0) 
	On Error Resume Next
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strAOS & "\root\cimv2")
	if Err.Number <> 0 then
		set objWMIService = nothing
		err.clear
	Else
		Set objWMIService = Nothing
		AOSreg(strAOS)
	end IF
	on error goto 0
	objRecordset.MoveNext 
Loop

Set objConnection=nothing
Set objRecordset=nothing
Set objCommandReg=nothing

Sub AOSreg(strAOS)
 Const HKLM = &H80000002
 Set ObjReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & StrAOS & "\root\default:StdRegProv")
 StrKeyPath = "System\CurrentControlSet\Services\Dynamics Server"
 ObjReg.EnumKey HKLM, StrKeyPath, ArrVersions
 For Each StrVersion In ArrVersions
  ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion, ArrInstances
   If IsArray(ArrInstances) Then
    For Each StrInstance In ArrInstances 
     objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "InstanceName", strInstanceName 
     objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "Current", strCurrentConfig 
     objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "ProductVersion", strProductVersion 
     ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, ArrConfigs
    For Each StrConfig In ArrConfigs
     If StrConfig = StrCurrentConfig Then
      strActive = "Y"
     Else
      strActive = "N"
     End if
ObjReg.EnumValues HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, ArrValueNames,  ArrValueTypes
For I=0 To UBound(arrValueNames) 
StrValueName = arrValueNames(I)           
Select Case arrValueTypes(I)
Case REG_SZ
 objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_EXPAND_SZ
 objReg.GetExpandedStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_BINARY
 objReg.GetBinaryValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_DWORD
 objReg.GetDWORDValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_MULTI_SZ
 objReg.GetMultiStringValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
End Select        
 prmReg1.value=StrAOS
 prmReg2.value=StrVersion
 prmReg3.value=strInstanceName
 prmReg4.value=StrProductVersion
 prmReg5.value=StrConfig
 prmReg6.value=strActive
 prmReg7.value=StrValueName
 prmReg8.value=StrValue
 objCommandReg.Execute
 Next
Next
Next
End If
Next
End Sub'

SET		@JobName = 'HSO - Export AOS Registry'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0, @description=N'To run this job: 
* The SQL Agent user needs administration permission on all AOS servers!'
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName, @on_success_action=1, @database_name=N'VBScript', @subsystem=N'ActiveScripting', 
		@command=@mycommand

EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Once in a week', @freq_interval=1, @active_start_time=10000,
		@freq_type=8, @freq_recurrence_factor=1 
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END

-- UPDATE JOB 'HSO - CleanUpAXTables'
SET		@JobName = 'HSO - Cleanup AX Tables'
EXEC	msdb.dbo.sp_update_jobstep @job_name=@JobName, @step_id=2,
		@command=	N'/*
--CLEAN UP SYSDATABASELOG TABLE

DECLARE @DAYS INT
DECLARE @ROWS INT
SET @DAYS = 90
SET @ROWS = 1

WHILE (@Rows > 0)
BEGIN
	DELETE TOP (1000) FROM SYSDATABASELOG
	WHERE CREATEDDATETIME < (getdate()-@DAYS)
	SET @Rows = @@ROWCOUNT
END
*/'

-- CREATE JOB 'HSO - Store-BatchHistory'
SET		@JobName = 'HSO - Store-BatchHistory'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName,  @on_success_action=1, @database_name=@AXDB, @subsystem=N'TSQL', 
		@command=N'declare @gi datetime;
declare @dd int;
declare @mm int;
declare @yy int;

set @gi = (Select DATEADD(day,-1,GETDATE()))
set @dd = DATEPART(dd,@gi)
set @mm = DATEPART(mm,@gi)
set @yy = DATEPART(yy,@gi)

INSERT INTO DBAtools.dbo.BATCHJOBHISTORY
SELECT STATUS, CAPTION, STARTDATETIME, ENDDATETIME, COMPANY, BATCHCREATEDBY,
DATEDIFF(mi,STARTDATETIME,ENDDATETIME) as "DURATION (minutes)"
FROM BATCHJOBHISTORY
where DATEPART(dd,startdatetime) = @dd
and DATEPART(mm,startdatetime) = @mm
and DATEPART(yy,startdatetime) = @yy
and DATEDIFF(mi,STARTDATETIME,ENDDATETIME) > 10'
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Every workday', @freq_interval=1, @active_start_time=500,
		@enabled=1, @freq_type=4, @freq_recurrence_factor=0 
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END

-- CREATE JOB 'HSO - CHECK QUERIES'
SET		@JobName = 'HSO - CHECK QUERIES'
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
BEGIN
EXEC	msdb.dbo.sp_add_job @job_name = @JobName, @enabled=0 
EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName,  @on_success_action=1, @database_name=@AXDB, @subsystem=N'TSQL', 
		@command=N'DECLARE @QUERY NVARCHAR(MAX)
DECLARE @TIME INT
SET @QUERY = ''(@P1 nvarchar(21),@P2 int,@P3 nvarchar(11),@P4 nvarchar(11),@P5 nvarchar(21))SELECT SUM(T1.POSTEDQTY),SUM(T1.POSTEDVALUE),SUM(T1.PHYSICALVALUE),SUM(T1.DEDUCTED),SUM(T1.RECEIVED),SUM(T1.RESERVPHYSICAL),SUM(T1.RESERVORDERED),SUM(T1.REGISTERED),SUM(T1.PICKED),SUM(T1.ONORDER),SUM(T1.ORDERED),SUM(T1.ARRIVED),SUM(T1.QUOTATIONRECEIPT),SUM(T1.QUOTATIONISSUE),SUM(T1.AVAILPHYSICAL),SUM(T1.AVAILORDERED),SUM(T1.PHYSICALINVENT),SUM(T1.POSTEDVALUESECCUR_RU),SUM(T1.PHYSICALVALUESECCUR_RU) FROM INVENTSUM T1 WHERE (((T1.PARTITION=5637144576) AND (T1.DATAAREAID=N''fhq'')) AND ((T1.ITEMID=@P1) AND (T1.CLOSED=@P2))) AND EXISTS (SELECT ''x'' FROM INVENTDIM T2 WHERE (((T2.PARTITION=5637144576) AND (T2.DATAAREAID=N''fhq'')) AND ((((T2.INVENTDIMID=T1.INVENTDIMID) AND (T2.INVENTSITEID=@P3)) AND (T2.INVENTLOCATIONID=@P4)) AND (T2.INVENTBATCHID=@P5))))''

SET @TIME = (
	SELECT TOP 1 (qs.total_elapsed_time / qs.execution_count)/1000
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	WHERE qt.encrypted=0
	and qt.text like @query
	ORDER BY qs.total_elapsed_time DESC
)

IF @TIME > 0
BEGIN

	DECLARE @plan_handle varbinary(64);
	SELECT 	TOP 1 @plan_handle = plan_handle
	FROM 	sys.dm_exec_cached_plans 
	CROSS 	APPLY sys.dm_exec_sql_text(plan_handle) AS st
	WHERE 	text LIKE @QUERY
	PRINT @plan_handle

	DBCC FREEPROCCACHE (@plan_handle)
	INSERT INTO DBAtools.dbo.HSO_QUERY values (999,getdate(),''SUMQUERY_I QUERY > THAN 10ms'')
END'
EXEC	msdb.dbo.sp_add_jobschedule @job_name=@JobName, @name=N'Every 5 minute', @freq_interval=1, @active_start_time=0,
		@enabled=1, @freq_type=4, @freq_recurrence_factor=0, @schedule_id=37, @freq_subday_type=4, @freq_subday_interval=5
EXEC	msdb.dbo.sp_add_jobserver @job_name = @JobName
END
END