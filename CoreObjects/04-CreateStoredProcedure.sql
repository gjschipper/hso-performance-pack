USE DBAtools
GO

IF EXISTS
(
    SELECT * FROM sys.procedures P
    JOIN sys.schemas S
    ON P.[schema_id] = S.[schema_id]
    WHERE
        P.[type] = 'P'
    AND
        P.[name] = 'CHECK_HSO_PARAMETERS'
    AND
        S.[name] = 'dbo'
)
BEGIN
    DROP PROCEDURE [dbo].[CHECK_HSO_PARAMETERS];
END
GO

CREATE PROCEDURE [dbo].[CHECK_HSO_PARAMETERS] @AXDB NVARCHAR(128)
AS

DECLARE @DATE DATETIME
DECLARE @STATUS CHAR(3)
DECLARE @QUERY NVARCHAR(MAX)

SET @DATE = (SELECT MAX(CHECKDATE) FROM HSO_RESULTS)
SET @STATUS = 'NOK'

INSERT INTO PERF_RESULTS
SELECT TEST, FINDING, '' as INSTANCE, 'Check this manually!' as DETAILS, 'TBC' as STATUS
FROM HSO_TESTS
WHERE TBC='Y'

INSERT INTO PERF_RESULTS 
SELECT TEST =  
	CASE
		WHEN CHECKID IN (97,128,129,157) 			THEN 3.01
		WHEN CHECKID = 76 							THEN 3.04
		WHEN CHECKID = 133 							THEN 3.05
		WHEN CHECKID IN (25,40) 					THEN 3.06
		WHEN CHECKID = 154 							THEN 3.07
		WHEN CHECKID IN (126,1044) 					THEN 4.01
		WHEN CHECKID = 1029 						THEN 4.02
		WHEN CHECKID = 74	 						THEN 4.03
		WHEN CHECKID IN (50,51,159,165,1031) 		THEN 4.04
		WHEN CHECKID = 1020	 						THEN 4.05
		WHEN CHECKID = 2	 						THEN 4.06
		WHEN CHECKID = 62	 						THEN 4.07
		WHEN CHECKID IN (15,16)				 		THEN 4.08
		WHEN CHECKID IN (42,80,82,158)			 	THEN 4.09
		WHEN CHECKID = 68	 						THEN 4.16
	END, FINDING, ('DBNAME: ' + DATABASENAME) as 'DBNAME/SERVERNAME', DETAILS, @STATUS as STATUS
FROM HSO_RESULTS
WHERE CHECKDATE = @DATE
AND (
   CHECKID = 97		-- UNUSUAL SQL SERVER EDITION
OR CHECKID = 128	-- SQL SERVER (UNSUPPORTED)
OR CHECKID = 129	-- SQL SERVER (CORRUPTION)
OR CHECKID = 157	-- SQL SERVER (SECURITY)
OR CHECKID = 76		-- COLLATION
OR CHECKID = 133	-- READ COMMITTED SNAPSHOT
OR CHECKID = 25		-- TEMPDB ON C
OR CHECKID = 40		-- TEMPDB HAS 1 DATA FILE
OR CHECKID = 154	-- 32-BIT
OR CHECKID = 126	-- PRIORITY BOOST
OR CHECKID = 1044	-- PRIORITY BOOST
OR CHECKID = 1029	-- MAXDOP
--OR CHECKID = 74		-- TRACEFLAG
OR CHECKID = 50		-- MAX MEMORY
OR CHECKID = 51		-- MEMORY
OR CHECKID = 159	-- MEMORY NUMA
OR CHECKID = 165	-- TOO MUCH FREE MEMORY
OR CHECKID = 1031	-- MAX SERVER MEMORY
--OR CHECKID = 1020		-- FILL FACTOR
OR CHECKID = 2		-- RECOVERY MODEL
OR CHECKID = 62		-- COMPATIBILITY LEVEL
OR CHECKID = 15		-- AUTO-CREATE STATS DISABLED
OR CHECKID = 16		-- AUTO-UPDATE STATS DISABLED
OR CHECKID = 42		-- UNEVEN FILE GROWTH
OR CHECKID = 80		-- MAX FILESIZE
OR CHECKID = 82		-- FILEGROWTH
OR CHECKID = 158	-- FILEGROWTH
OR CHECKID = 68		-- CHECKDB
OR CHECKID = 13		-- AUTO SHRINK
OR CHECKID = 79		-- SHRINK ENABLED
OR CHECKID = 148	-- DBFILES ON NAS
OR CHECKID = 1004	-- AFFINITY
OR CHECKID = 1005	-- AFFINITY
OR CHECKID = 1067	-- AFFINITY
OR CHECKID = 1066	-- AFFINITY
)
UNION
SELECT DISTINCT(B.TEST), A.SETTING_NAME as FINDING, ('SERVERNAME: ' + A.SERVER_NAME + ' / INSTANCE: ' + A.AOS_INSTANCE_NAME) as 'DBNAME/SERVERNAME', A.SETTING_VALUE as DETAILS, STATUS = 
CASE
	WHEN A.SETTING_NAME IN ('hint') AND A.SETTING_VALUE <> 0					THEN 'NOK'
	WHEN A.SETTING_NAME IN ('sqlbuffer') AND A.SETTING_VALUE <> 48				THEN 'NOK'
	WHEN A.SETTING_NAME IN ('opencursors') 	AND A.SETTING_VALUE <> 450			THEN 'NOK'
	WHEN A.SETTING_NAME IN ('xppdebug') AND A.SETTING_VALUE <> 0 				THEN 'NOK'
	WHEN A.SETTING_NAME IN ('sqlcomplexliterals') AND A.SETTING_VALUE <> 0		THEN 'NOK'
	WHEN A.SETTING_NAME IN ('sqlformliterals') AND A.SETTING_VALUE <> 0			THEN 'NOK'
	WHEN A.SETTING_NAME IN ('ignoredatasourceindex') AND A.SETTING_VALUE <> 0	THEN 'NOK'
	ELSE 'OK'
	END
FROM AOS_REGISTRY A, HSO_TESTS B
WHERE A.SETTING_NAME = B.FINDING
AND A.IS_CONFIGURATION_ACTIVE='Y'
AND A.SETTING_NAME IN ('hint','sqlbuffer','opencursors','xppdebug','sqlcomplexliterals','sqlformliterals','ignoredatasourceindex')

SET @QUERY = 'SELECT ''6.07'' AS TEST, NAME AS FINDING, SERVERID as ''DBNAME/SERVERNAME'', VALUE AS DETAILS, STATUS =
CASE WHEN VALUE <> 128 THEN ''NOK''
ELSE ''OK'' END
FROM ' + @AXDB + '.dbo.SYSGLOBALCONFIGURATION 
WHERE NAME = ''ENTIRETABLECACHELIMIT''
UNION
SELECT ''6.08'' AS TEST, NAME AS FINDING, SERVERID as ''DBNAME/SERVERNAME'', VALUE AS DETAILS, STATUS =
CASE WHEN VALUE <> 1 THEN ''NOK''
ELSE ''OK'' END
FROM ' + @AXDB + '.dbo.SYSGLOBALCONFIGURATION 
WHERE NAME = ''DATAAREAIDLITERAL''
UNION
SELECT ''6.08'' AS TEST, NAME AS FINDING, SERVERID as ''DBNAME/SERVERNAME'', VALUE AS DETAILS, STATUS =
CASE WHEN VALUE <> 1 THEN ''NOK''
ELSE ''OK'' END
FROM ' + @AXDB + '.dbo.SYSGLOBALCONFIGURATION 
WHERE NAME = ''PARTITIONLITERAL'''

INSERT INTO PERF_RESULTS
EXEC sp_executesql @QUERY

declare @traceflag845 varchar(10)
declare @traceflag1117 varchar(10)
declare @traceflag1118 varchar(10)
declare @traceflag1224 varchar(10)
declare @traceflag2371 varchar(10)
declare @traceflag4136 varchar(10)
declare @traceflag4199 varchar(10)

IF EXISTS (SELECT name from sysobjects where name = 'HSO_traceflags') DROP TABLE HSO_traceflags;
CREATE TABLE HSO_traceflags(traceflag smallint,status bit,global bit,session bit)
insert into HSO_traceflags execute('DBCC TRACESTATUS(-1)')
if exists (select traceflag from HSO_traceflags where traceflag=845 and global=1) set @traceflag845=(select 'OK') else set @traceflag845=(select 'NOK')
if exists (select traceflag from HSO_traceflags where traceflag=1117 and global=1) set @traceflag1117=(select 'OK') else set @traceflag1117=(select 'NOK')
if exists (select traceflag from HSO_traceflags where traceflag=1118 and global=1) set @traceflag1118=(select 'OK') else set @traceflag1118=(select 'NOK')
if exists (select traceflag from HSO_traceflags where traceflag=1224 and global=1) set @traceflag1224=(select 'OK') else set @traceflag1224=(select 'NOK')
if exists (select traceflag from HSO_traceflags where traceflag=2371 and global=1) set @traceflag2371=(select 'OK') else set @traceflag2371=(select 'NOK')
if exists (select traceflag from HSO_traceflags where traceflag=4136 and global=1) set @traceflag4136=(select 'NOK') else set @traceflag4136=(select 'OK')
if exists (select traceflag from HSO_traceflags where traceflag=4199 and global=1) set @traceflag4199=(select 'OK') else set @traceflag4199=(select 'NOK')

INSERT INTO PERF_RESULTS
SELECT '4.03' AS TEST, 'Traceflag 845' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Enable Traceflag 845' AS DETAILS, @traceflag845 as STATUS
UNION
SELECT '4.03' AS TEST, 'Traceflag 1117' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Enable Traceflag 1117' AS DETAILS, @traceflag1117 as STATUS
UNION
SELECT '4.03' AS TEST, 'Traceflag 1118' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Enable Traceflag 1118' AS DETAILS, @traceflag1118 as STATUS
UNION
SELECT '4.03' AS TEST, 'Traceflag 1224' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Enable Traceflag 1224' AS DETAILS, @traceflag1224 as STATUS
UNION
SELECT '4.03' AS TEST, 'Traceflag 2371' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Enable Traceflag 2371' AS DETAILS, @traceflag2371 as STATUS
UNION
SELECT '4.03' AS TEST, 'Traceflag 4136' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Disable traceflag 4136 and use the AX parameter sniffing option' AS DETAILS, @traceflag4136 as STATUS
UNION
SELECT '4.03' AS TEST, 'Traceflag 4199' AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
'Enable Traceflag 4199' AS DETAILS, @traceflag4199 as STATUS

DECLARE @traceflag varchar(250)
DECLARE fetch_cursor CURSOR FOR
SELECT traceflag FROM HSO_traceflags WHERE traceflag NOT IN (845,1117,1118,1224,2371,4199);
OPEN fetch_cursor
FETCH NEXT FROM fetch_cursor INTO @traceflag;

WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO PERF_RESULTS
		SELECT '4.03' AS TEST, 'Traceflag ' + @traceflag AS FINDING, 'General SQL Instance' AS 'DBNAME/SERVERNAME', 
		'Disable Traceflag ' + @traceflag AS DETAILS, 'NOK' as STATUS
		FETCH NEXT FROM fetch_cursor INTO @traceflag;
	END;
CLOSE fetch_cursor;
DEALLOCATE fetch_cursor;

DECLARE @countFillFactor NVARCHAR(8)
DECLARE @sSQL NVARCHAR(500)
SET @sSQL = 'select @countFillFactor=count(*) from ' + @AXDB + '.sys.indexes where fill_factor not in (''70'',''90'')'

EXEC sp_executesql @sSQL,N'@countFillFactor NVARCHAR(8) output', @countFillFactor output
INSERT INTO PERF_RESULTS
SELECT '4.05' AS TEST, @countFillFactor + ' indexes have a fillfactor other then 70 or 90' AS FINDING, @AXDB AS 'DBNAME/SERVERNAME', 
		'Rebuild all indexes in this database with fillfactor 90!' AS DETAILS, STATUS=
		CASE WHEN @countFillFactor > 0 THEN 'NOK' ELSE 'OK' END
GO

IF EXISTS
(
    SELECT * FROM sys.procedures P
    JOIN sys.schemas S
    ON P.[schema_id] = S.[schema_id]
    WHERE
        P.[type] = 'P'
    AND
        P.[name] = 'HSO_PACK_VERSION'
    AND
        S.[name] = 'dbo'
)
BEGIN
    DROP PROCEDURE [dbo].[HSO_PACK_VERSION];
END
GO

CREATE PROCEDURE [dbo].[HSO_PACK_VERSION]
AS
	DECLARE @Version CHAR(3)
	DECLARE @VersionDate DATETIME
	SELECT @Version = 'v19', @VersionDate = '20180209'
	PRINT 'HSO_PACK_VERSION : ' + @Version
	PRINT 'HSO_VERSION_DATE : ' + CAST(@VersionDate AS VARCHAR(20))
GO