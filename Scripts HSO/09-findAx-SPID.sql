select cast(context_info as varchar(128)) as ci,* 
from sys.dm_exec_sessions 
where program_name like '%Dynamics%'
--and context_info like '%schip%'