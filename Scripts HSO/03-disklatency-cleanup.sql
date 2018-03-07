-- Cleanup
USE DBAtools
IF EXISTS (SELECT * FROM [DBAtools].[sys].[objects]
    WHERE [name] = N'HSO_LATENCY1')
    DROP TABLE [HSO_LATENCY1];
 
IF EXISTS (SELECT * FROM [DBAtools].[sys].[objects]
    WHERE [name] = N'HSO_LATENCY2')
    DROP TABLE [HSO_LATENCY2];