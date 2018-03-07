/* Query Problems - Plan Cache Erased Recently */
SELECT	TOP 1 'Last Plan Cache Erased' AS Finding,
		CAST(creation_time AS VARCHAR(100)) AS Date
FROM sys.dm_exec_query_stats 
ORDER BY creation_time  

/* Check SQL Server Last Restart */
SELECT  'SQL Server Last Restart' AS Finding ,
		CAST(create_date AS VARCHAR(100)) AS Date
FROM    sys.databases
WHERE   database_id = 2

/* Clean specific SQL Plan
SELECT 	plan_handle, st.text
FROM 	sys.dm_exec_cached_plans 
CROSS 	APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE 	text LIKE N'SELECT * FROM Person.Address%';

DBCC FREEPROCCACHE (0x060006001ECA270EC0215D05000000000000000000000000);

===============================

DECLARE @plan_handle varbinary(64);
SELECT 	TOP 1 @plan_handle = plan_handle
FROM 	sys.dm_exec_cached_plans 
CROSS 	APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE 	text LIKE N'QUERY';
PRINT @plan_handle

DBCC FREEPROCCACHE (@plan_handle)

*/

/* Search Column in Table
SELECT 		t.name AS table_name,
			SCHEMA_NAME(schema_id) AS schema_name,
			c.name AS column_name
FROM 		sys.tables AS t
INNER JOIN 	sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
WHERE 		c.name LIKE '%EmployeeID%'
ORDER BY 	schema_name, table_name;
*/

/* Check records in SYSDATABASELOG
SELECT	COUNT(*) 'AANTAL RECORDS', B.NAME
FROM	SYSDATABASELOG A, SQLDICTIONARY B
WHERE	A.TABLE_ = B.TABLEID
		AND B.FIELDID = 0
GROUP BY A.TABLE_, B.NAME
ORDER BY COUNT(*) DESC
*/

/* Check WhoIsActive LOG table --Shows head blockers in the last 10 minutes, with a duration longer than 5 minutes.
SELECT * 
FROM [DBAtools].[dbo].[WhoIsActive_LOG]
where  collection_time > DATEADD(minute,-10, SYSDATETIME());
AND [dd hh:mm:ss.mss] > '00 00:05:00.000'
*/

/* Check BATCHJOBHISTORY
declare @dd int;
declare @mm int;
declare @yy int;

set @dd = DATEPART(dd,getdate())
set @mm = DATEPART(mm,getdate())
set @yy = DATEPART(yy,getdate())

SELECT STATUS, CAPTION, STARTDATETIME, ENDDATETIME, COMPANY, BATCHCREATEDBY,
DATEDIFF(mi,STARTDATETIME,ENDDATETIME) as "DURATION (minutes)"
FROM BATCHJOBHISTORY
WHERE DATEPART(dd,startdatetime) = @dd
and DATEPART(mm,startdatetime) = @mm
and DATEPART(yy,startdatetime) = @yy
and DATEDIFF(mi,STARTDATETIME,ENDDATETIME) > 0
ORDER BY DATEDIFF(mi,STARTDATETIME,ENDDATETIME) desc
*/


/*
SELECT STATUS = 
      CASE STATUS  
		WHEN '0' THEN 'Withhold'
		WHEN '1' THEN 'Waiting'
		WHEN '2' THEN 'Executing'
		WHEN '3' THEN 'Error'
		WHEN '4' THEN 'Ended'  
		WHEN '5' THEN 'Unknown'
		WHEN '6' THEN 'Unknown'
		WHEN '7' THEN 'Unknown'
		WHEN '8' THEN 'Canceled'  
        ELSE 'Unknown'  
      END,  
CAPTION, STARTDATETIME, ENDDATETIME, COMPANY, 
DATEDIFF(mi,STARTDATETIME,ENDDATETIME) as "DURATION (minutes)"
FROM BATCHJOBHISTORY
WHERE CAPTION like '%Invoicing%'
ORDER BY STARTDATETIME
*/

/* Find tables that have Change Tracking enabled
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT 
   sct1.name AS CT_schema,
   sot1.name AS CT_table,
   ps1.row_count AS CT_rows,
   ps1.reserved_page_count*8./1024. AS CT_reserved_MB,
   sct2.name AS tracked_schema,
   sot2.name AS tracked_name,
   ps2.row_count AS tracked_rows,
   ps2.reserved_page_count*8./1024. AS tracked_base_table_MB,
   change_tracking_min_valid_version(sot2.object_id) AS min_valid_version
FROM sys.internal_tables it
JOIN sys.objects sot1 ON it.object_id=sot1.object_id
JOIN sys.schemas AS sct1 ON sot1.schema_id=sct1.schema_id
JOIN sys.dm_db_partition_stats ps1 ON it.object_id = ps1. object_id AND ps1.index_id in (0,1)
LEFT JOIN sys.objects sot2 ON it.parent_object_id=sot2.object_id
LEFT JOIN sys.schemas AS sct2 ON sot2.schema_id=sct2.schema_id
LEFT JOIN sys.dm_db_partition_stats ps2 ON sot2.object_id = ps2. object_id AND ps2.index_id in (0,1)
WHERE it.internal_type IN (209, 210);
GO
*/

/* SET USER OPTIONS TO DEFAULT
UPDATE USERINFO 
SET DEBUGINFO=12, QUERYTIMELIMIT=0, TRACEINFO=0, FILTERBYGRIDONBYDEFAULT=0
*/

/*
USE [DBAtools]

SELECT *
FROM   [BLOCKED_PROCESS_VW]
ORDER  BY END_TIME DESC 

SELECT datepart(dd,END_TIME) as DAY, datepart(mm,END_TIME) as MONTH, COUNT(*) as "BLOCKS PER DAY"
FROM [BLOCKED_PROCESS_VW]
where BLOCKED_SQL like '%AIFRUNTIMECACHE%'
GROUP BY datepart(dd,END_TIME) , datepart(mm,END_TIME)

*/

/* Space per table
SELECT 
    t.NAME AS TableName,
    p.rows AS RowCounts,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) DESC
*/

/*
--COUNT temporary tables in tempdb
select  COUNT(*) as "CNT" , SUBSTRING(a.name,2,CHARINDEX('_',a.name)-2) as "TABLEID" , b.Name
from tempdb..sysobjects a, AX2012_PROD_model..ModelElement b
where a.xtype ='u'
and a.name like 't%'
and (
SUBSTRING(a.name,2,CHARINDEX('_',a.name)-2) = b.AxId
and b.ElementType=44
)
group by SUBSTRING(a.name,2,CHARINDEX('_',a.name)-2), b.Name
order by 1 desc
*/

/*
SELECT top 100 *
  FROM [DBAtools].[dbo].[WhoIsActive_LOG]
  where CAST(sql_text as nvarchar(max)) like '%SELECT SUM(T1.POSTEDQTY),SUM(T1.POSTEDVALUE),SUM(T1.PHYSICALVALUE),SUM(T1.DEDUCTED),SUM(T1.RECEIVED),SUM(T1.RESERVPHYSICAL),SUM(T1.RESERVORDERED),SUM(T1.REGISTERED),SUM(T1.PICKED),SUM(T1.ONORDER),SUM(T1.ORDERED),SUM(T1.ARRIVED),SUM(T1.QUOTATIONRECEIPT),SUM(T1.QUOTATIONISSUE),SUM(T1.AVAILPHYSICAL),SUM(T1.AVAILORDERED),SUM(T1.PHYSICALINVENT),SUM(T1.POSTEDVALUESECCUR_RU),SUM(T1.PHYSICALVALUESECCUR_RU),T3.CHECKTYPE,T3.ITEMID,T3.INVENTSITEID,T3.INVENTLOCATIONID,T3.INVENTSTATUSID,T3.LICENSEPLATEID,T3.INVENTBATCHID,T3.WMSLOCATIONID,T3.INVENTSERIALID FROM INVENTSUM T1 CROSS JOIN INVENTDIM T2 CROSS JOIN INVENTSUMDELTADIM T3 WHERE (((T1.PARTITION=5637144576) AND (T1.DATAAREAID=N''1001'')) AND (T1.CLOSED=@P1))%'
  and [dd hh:mm:ss.mss] > '00 00:00:01.000'
  order by collection_time desc
*/

/*
-- DROP TEMP TABLES
DECLARE @DAYS INT
DECLARE @SQL NVARCHAR(MAX)
DECLARE @ROWS INT
DECLARE @ROWS2 INT

SET @DAYS = (SELECT DATEPART(dd,GETDATE() - MIN (LOGINDATETIME))+1 FROM SYSSERVERSESSIONS)
SET @ROWS = (SELECT COUNT(*) FROM TEMPDB..SYSOBJECTS A WHERE A.XTYPE ='U' AND A.NAME like 't%' AND CRDATE < (GETDATE()-@DAYS))
SET @ROWS2 = 0
PRINT 'ROWS: '+CAST(@ROWS as varchar(10))
PRINT 'DAYS: '+CAST(@DAYS as varchar(10))

WHILE (@ROWS > 0)
BEGIN
	SET @SQL = (
	SELECT TOP 1 'DROP TABLE TEMPDB.DBO.' + A.NAME AS STATEMENT
	FROM TEMPDB..SYSOBJECTS A
	WHERE A.XTYPE ='U'
	AND A.NAME like 't%'
	AND CRDATE < (GETDATE()-@DAYS)
	)
	EXECUTE sp_executesql @SQL
	--PRINT @SQL
	SET @ROWS = @ROWS-1
	IF @ROWS2 = 1000
	BEGIN
		--SELECT CAST(@ROWS2 as VARCHAR(10)) +' TABLES DROPPED'
		SET @ROWS2 = 0
	END
	ELSE SET @ROWS2 = @ROWS2+1
END
*/

/*
FIND GHOST RECORDS

SELECT
db_name(database_id),
object_name(object_id),
ghost_record_count,
version_ghost_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(N'AX2012DB_ACC'), OBJECT_ID(N'AIFGATEWAYQUEUE'), NULL, NULL , 'DETAILED')
GO


SELECT alloc_unit_type_desc, avg_page_space_used_in_percent, record_count,
ghost_record_count FROM sys.dm_db_index_physical_stats
(DB_ID(N'AX2012DB_ACC'), OBJECT_ID(N'BATCH'), NULL, NULL , 'DETAILED');


SELECT object_name(object_id),
ghost_record_count from sys.dm_db_index_physical_stats(DB_ID(N'AX2012DB_ACC'),NULL,NULL,NULL,'DETAILED')
order by ghost_record_count desc

*/