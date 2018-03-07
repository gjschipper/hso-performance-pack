SELECT r.session_id,
       se.host_name,
       se.login_name,
       Db_name(r.database_id) AS dbname,
       r.status,
       r.command,
       r.cpu_time,
       r.total_elapsed_time,
       r.reads,
       r.logical_reads,
       r.writes,
       s.text sql_text,
       p.query_plan query_plan,
       SQL_CURSORSQL.text,
       SQL_CURSORPLAN.query_plan
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions se ON r.session_id = se.session_id 
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) s 
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p 
OUTER APPLY sys.dm_exec_cursors(r.session_id) AS SQL_CURSORS 
OUTER APPLY sys.dm_exec_sql_text(SQL_CURSORS.sql_handle) AS SQL_CURSORSQL
LEFT JOIN sys.dm_exec_query_stats AS SQL_CURSORSTATS ON SQL_CURSORSTATS.sql_handle = SQL_CURSORS.sql_handle 
OUTER APPLY sys.dm_exec_query_plan(SQL_CURSORSTATS.plan_handle) AS SQL_CURSORPLAN
WHERE r.session_id <> @@SPID
  AND se.is_user_process = 1

/*
What are the most resource-intensive queries on this server?
EXEC DBAtools.dbo.sp_blitzcache
*/