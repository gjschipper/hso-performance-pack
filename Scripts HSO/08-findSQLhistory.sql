SELECT top 10 DB_NAME(qp.dbid) AS DBNAME, SUBSTRING(qt.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(qt.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2)+1) as query, 
qs.execution_count, qs.total_elapsed_time,
(qs.total_elapsed_time / qs.execution_count) as 'avg in microsec',
(qs.total_elapsed_time / qs.execution_count)/1000 as 'avg in millisec',
qs.max_elapsed_time - qs.min_elapsed_time as diff,
qs.total_logical_reads, qs.last_logical_reads,
qs.min_logical_reads, qs.max_logical_reads,
qs.total_physical_reads, qs.last_physical_reads,
qs.min_physical_reads, qs.max_physical_reads,
qs.last_elapsed_time, qs.min_elapsed_time, qs.max_elapsed_time, qs.last_execution_time,qs.creation_time,
qp.query_plan,
pqp.new_query_text,pqp.params_list,pqp.with_sp_executesql_query,pqp.without_sp_executesql_query
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY DBAtools.dbo.fn_ParseQueryPlan(qp.query_plan, qs.statement_start_offset, qs.statement_end_offset, qt.text) pqp
WHERE qt.encrypted=0
 --and qt.text like '%QUERY%'
-- ORDER BY query;
-- ORDER BY diff DESC -- To get strange performing queries, could be because of parameter sniffing
ORDER BY qs.total_elapsed_time DESC; -- To get memory intensive queries, could be full table scans
-- ORDER BY qs.total_logical_reads DESC; -- To get memory intensive queries, could be full table scans
-- ORDER BY qs.execution_count DESC; -- To get most executed queries