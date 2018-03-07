USE [master]
GO

IF EXISTS(select * from sys.databases where name='DBAtools')
DROP DATABASE DBAtools
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - Cleanup AX Tables')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - Cleanup AX Tables' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - Cleanup Perfmon Tables')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - Cleanup Perfmon Tables' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - Cleanup SQL Jobs')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - Cleanup SQL Jobs' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - DBCheck')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - DBCheck' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - Export AOS Registry')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - Export AOS Registry' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - IndexOptimize Daily')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - IndexOptimize Daily' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - IndexOptimize Weekly')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - IndexOptimize Weekly' , @delete_unused_schedule=1
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'HSO - Who Is Active')
EXEC msdb.dbo.sp_delete_job @job_name = N'HSO - Who Is Active' , @delete_unused_schedule=1
GO