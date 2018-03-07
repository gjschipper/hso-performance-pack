--EXEC sp_whoisactive @help = 1

USE DBATools
EXEC sp_whoisactive @get_plans = 1, 
	@get_additional_info = 1, 
	@get_locks = 1, 
	@get_task_info = 2

/* Find Block Leaders
USE DBATools
EXEC sp_WhoIsActive 
    @find_block_leaders = 1, 
    @sort_order = '[blocked_session_count] DESC'
*/