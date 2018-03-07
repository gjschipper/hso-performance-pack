-- Check current version:
USE DBAtools
EXEC HSO_PACK_VERSION

--Enable SQLCMD Mode --> Query --> SQLCMD Mode

-- Migrate from v13 - v14
-- Drop database DBAtools

IF EXISTS(select * from sys.databases where name='DBAtools')
DROP DATABASE DBAtools
GO

:setvar path "CoreObjects\"
:r $(path)"01-CreateDatabase.sql"
:r $(path)"02-OlaHallengren.sql"
:r $(path)"03-CreateMaintenanceJobs.sql"
:r $(path)"04-CreateStoredProcedure.sql"
:r $(path)"05a-BlitzFirst.sql"
:r $(path)"05b-Blitz.sql"
:r $(path)"05c-BlitzCache.sql"
:r $(path)"05d-BlitzIndex.sql"
:r $(path)"05e-BlitzTrace.sql"
:r $(path)"05f-BlitzWho.sql"
:r $(path)"06-sp_who3.sql"
:r $(path)"08a-whoIsActive.sql"

-- Migrate from v12 - v13
:setvar path "CoreObjects\"
:r $(path)"08a-whoIsActive.sql"
:r $(path)"08b-CreatePerfMonJobs.sql"
:r $(path)"04-CreateStoredProcedure.sql"

/*
!!!!!!!!!! MODIFY @AXDB TO THE RIGHT DATABASE NAME !!!!!!!!!! in script '97-upgradeSteps.sql'
Open script '97-upgradeSteps.sql' and execute it.
*/

-- Migrate from v11 - v12
:setvar path "CoreObjects\"
:r $(path)"05a-AskBrent.sql"
:r $(path)"05b-Blitz.sql"
:r $(path)"05c-BlitzCache.sql"
:r $(path)"05d-BlitzIndex.sql"
:r $(path)"04-CreateStoredProcedure.sql"

