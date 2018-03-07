/*****************************
 Start voor de Batch
 ******************************/
USE DBATools
IF EXISTS (SELECT * FROM [DBATools].[sys].[objects]
    WHERE [name] = N'HSO_LATENCY1')
    DROP TABLE [HSO_LATENCY1];
 
SELECT [database_id], [file_id], [num_of_reads], [io_stall_read_ms],
       [num_of_writes], [io_stall_write_ms], [io_stall],
       [num_of_bytes_read], [num_of_bytes_written], [file_handle]
INTO HSO_LATENCY1
FROM sys.dm_io_virtual_file_stats (NULL, NULL);
GO