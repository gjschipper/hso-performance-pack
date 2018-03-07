SET NOCOUNT ON

USE [master]
GO

/****** Object:  Database [DBAtools]    Script Date: 02/28/2011 12:28:47 ******/
IF  NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DBAtools')
BEGIN


CREATE DATABASE [DBAtools] 
/***** The following commented lines are added to help setting the database files path an easier task to do. **/

--on
--(
--NAME = N'DBAtools', FILENAME = 'D:\Data\DBAtools.mdf'
--)
--log on
--(
--NAME = N'DBAtools_log', FILENAME = 'D:\Data\DBAtools_Log.ldf'
--)



ALTER DATABASE [DBAtools] MODIFY FILE(NAME = N'DBAtools', SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 10MB )

ALTER DATABASE [DBAtools] MODIFY FILE(NAME = N'DBAtools_log', SIZE =10MB , MAXSIZE = UNLIMITED , FILEGROWTH = 10MB )

ALTER DATABASE [DBAtools] SET ANSI_NULL_DEFAULT OFF 

ALTER DATABASE [DBAtools] SET ANSI_NULLS OFF 

ALTER DATABASE [DBAtools] SET ANSI_PADDING OFF 

ALTER DATABASE [DBAtools] SET ANSI_WARNINGS OFF 

ALTER DATABASE [DBAtools] SET ARITHABORT OFF 

ALTER DATABASE [DBAtools] SET AUTO_CLOSE OFF 

ALTER DATABASE [DBAtools] SET AUTO_CREATE_STATISTICS ON 

ALTER DATABASE [DBAtools] SET AUTO_SHRINK OFF 

ALTER DATABASE [DBAtools] SET AUTO_UPDATE_STATISTICS ON 

ALTER DATABASE [DBAtools] SET CURSOR_CLOSE_ON_COMMIT OFF 

ALTER DATABASE [DBAtools] SET CURSOR_DEFAULT  GLOBAL 

ALTER DATABASE [DBAtools] SET CONCAT_NULL_YIELDS_NULL OFF 

ALTER DATABASE [DBAtools] SET NUMERIC_ROUNDABORT OFF 

ALTER DATABASE [DBAtools] SET QUOTED_IDENTIFIER OFF 

ALTER DATABASE [DBAtools] SET RECURSIVE_TRIGGERS OFF 

ALTER DATABASE [DBAtools] SET ENABLE_BROKER 

ALTER DATABASE [DBAtools] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 

ALTER DATABASE [DBAtools] SET DATE_CORRELATION_OPTIMIZATION OFF 

ALTER DATABASE [DBAtools] SET TRUSTWORTHY OFF 

ALTER DATABASE [DBAtools] SET READ_COMMITTED_SNAPSHOT ON

ALTER DATABASE [DBAtools] SET ALLOW_SNAPSHOT_ISOLATION ON

ALTER DATABASE [DBAtools] SET PARAMETERIZATION SIMPLE 

ALTER DATABASE [DBAtools] SET READ_WRITE 

ALTER DATABASE [DBAtools] SET RECOVERY SIMPLE 

ALTER DATABASE [DBAtools] SET MULTI_USER 

ALTER DATABASE [DBAtools] SET PAGE_VERIFY NONE  

ALTER DATABASE [DBAtools] SET DB_CHAINING OFF 
END
GO

CREATE TABLE [DBAtools].[dbo].[AOS_REGISTRY](
	[SERVER_NAME] [nvarchar](255) NOT NULL,
	[AX_MAJOR_VERSION] [nvarchar](5) NOT NULL,
	[AOS_INSTANCE_NAME] [nvarchar](255) NOT NULL,
	[AX_BUILD_NUMBER] [nvarchar](25) NOT NULL,
	[AOS_CONFIGURATION_NAME] [nvarchar](255) NOT NULL,
	[IS_CONFIGURATION_ACTIVE] [nvarchar](1) NOT NULL,
	[SETTING_NAME] [nvarchar](255) NOT NULL,
	[SETTING_VALUE] [nvarchar](max) NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [DBAtools].[dbo].[PERF_RESULTS](
	[TEST] [numeric](18, 2) NULL,
	[FINDING] [varchar](255) NULL,
	[INSTANCE] [varchar](255) NULL,
	[DETAILS] [varchar](max) NULL,
	[STATUS] [nchar](10) NULL
) ON [PRIMARY]
GO

CREATE TABLE [DBAtools].[dbo].[HSO_TESTS](
	[TEST] [numeric](18, 2) NOT NULL,
	[FINDING] [nvarchar](max) NOT NULL,
	[TBC] [nchar](10) NOT NULL
) ON [PRIMARY]
GO

INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (3.02, 'Is SQL Server dedicated for AX?','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (3.03, 'Is Names Pipes disabled?','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (4.10, 'Is SQL domain user account added to: User Right Assignment -> Perform volume maintenance tasks','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (4.11, 'Is SQL domain user account added to: User Right Assignment ->Lock Pages in memory.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (4.12, 'Are the IndexOptimize daily en weekly jobs enabled?','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (4.13, 'Virusscanner: Exclude SQL Locations','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (4.14, 'Enable Windows High Performance Power Options','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (5.01, 'Is latest AOS Kernel installed?','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (5.02, 'Run max 1 AOS instance on a server.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (5.03, 'Define the count of batch threads.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (4.15, 'Check bytes per cluster (64k)','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.01, 'hint','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.02, 'sqlbuffer','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.03, 'opencursors','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.04, 'xppdebug','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.05, 'sqlcomplexliterals','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.05, 'sqlformliterals','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.06, 'ignoredatasourceindex','N')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.09, 'Disable Keep update objects.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.10, 'Virusscanner: Exclude AOS Locations.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.11, 'Enable Windows High Performance Power Options','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.12, 'Enable the possiblity to find user sessions from spid','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (6.13, 'Enable SQL Job ''HSO - Cleanup AX Tables''','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (7.01, 'Check client performance options.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (7.02, 'Disable debug mode in user options.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (7.03, 'Disable user options ''Filter by Grid on by default''','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (7.04, 'Virusscanner: Exclude AX Client Locations.','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (7.05, 'Enable Windows High Performance Power Options','Y')
GO
INSERT INTO [DBAtools].[dbo].[HSO_TESTS] ([TEST],[FINDING],[TBC])
VALUES (7.06, 'Change visual effects to ''Adjust for best perfrmance''','Y')
GO

CREATE TABLE [DBAtools].[dbo].[HSO_QUERY](
	[recID] [int] IDENTITY(1,1) NOT NULL,
	[sessionID] [int] NULL,
	[datum] [datetime] NULL,
	[login] [varchar](50) NULL
) ON [PRIMARY]

CREATE TABLE [DBAtools].[dbo].[BATCHJOBHISTORY](
	[STATUS] [int] NOT NULL,
	[CAPTION] [nvarchar](100) NOT NULL,
	[STARTDATETIME] [datetime] NOT NULL,
	[ENDDATETIME] [datetime] NOT NULL,
	[COMPANY] [nvarchar](4) NOT NULL,
	[BATCHCREATEDBY] [nvarchar](8) NOT NULL,
	[DURATION (minutes)] [int] NULL
) ON [PRIMARY]

-- CREATE FUNCTION
USE dbatools 

go 

IF ( Object_id('dbo.fn_ParseQueryPlan') IS NULL ) 
  BEGIN 
      EXEC ('CREATE FUNCTION dbo.Fn_parsequeryplan () returns @result TABLE (   i INT) AS   BEGIN       RETURN   END' ) 
  END 

go 

ALTER FUNCTION [dbo].[Fn_parsequeryplan] (@query_plan             XML, 
                                          @statement_start_offset INT, 
                                          @statement_end_offset   INT, 
                                          @org_query_text         NVARCHAR (max) 
) 
returns @result TABLE ( 
  new_query_text              NVARCHAR (max), 
  params_list                 NVARCHAR (4000), 
  without_sp_executesql_query NVARCHAR (max), 
  with_sp_executesql_query    NVARCHAR (max)) 
AS 
  BEGIN 
      DECLARE @new_query_text NVARCHAR (max) 

      SET @new_query_text = Substring(@org_query_text, ( 
                            @statement_start_offset / 2 ) + 1, ( ( CASE 
                                                  @statement_end_offset 
                            WHEN -1 
                            THEN Datalength(@org_query_text) 
                            ELSE 
                            @statement_end_offset 
                            END 
                            - @statement_start_offset ) / 2 ) + 1) 

      INSERT @result 
             (new_query_text) 
      SELECT @new_query_text 

      DECLARE @params_list NVARCHAR (4000) = '' 

      IF ( @statement_start_offset / 2 - 2 >= 0 
           AND @org_query_text NOT LIKE '%CREATE PROCEDURE%' ) 
        BEGIN 
            SET @params_list = Substring (@org_query_text, 2, 
                               @statement_start_offset / 2 - 2) 
        END 

      UPDATE @result 
      SET    params_list = @params_list 

      DECLARE @without_sp_executesql_query NVARCHAR (max) 
      DECLARE @with_sp_executesql_query NVARCHAR (max) 
      DECLARE @params_xml XML 
      DECLARE @query_plan_str NVARCHAR (max) 

      IF ( @params_list <> '' ) 
        BEGIN 
            SET @query_plan_str = CONVERT (NVARCHAR(max), @query_plan) 
            SET @without_sp_executesql_query = 
            'DECLARE ' + @params_list + Char (13) + 
            Char (10) 
            + Char (13) + Char (10) 
            SET @params_xml = Try_convert(xml, Substring(@query_plan_str, 
                                               Charindex('<ParameterList>', 
                                                                 @query_plan_str 
                                               ), 
                              Charindex('</ParameterList>' 
                              , @query_plan_str 
                              ) 
                              + Len( 
                                               '</ParameterList>') - 
                              Charindex('<ParameterList>' 
                              , 
                              @query_plan_str))) 

            SELECT @without_sp_executesql_query = 
                   @without_sp_executesql_query + 'SET ' 
                   + pc.compiled.value('@Column', 
                   'nvarchar(128)') 
                   + ' = ' 
                   + pc.compiled.value('@ParameterCompiledValue', 
                          'nvarchar(128)') 
                   + Char (13) + Char (10) 
            FROM   @params_xml.nodes('//ParameterList/ColumnReference') AS pc( 
                   compiled 
                   ) 
            ORDER  BY pc.compiled.value('@Column', 'nvarchar(128)') 

            SET @with_sp_executesql_query = @without_sp_executesql_query 
            SET @without_sp_executesql_query = 
            @without_sp_executesql_query + Char 
            (13 
            ) 
            + Char (10) + @new_query_text + Char ( 
            13) 
            + 
            Char (10) 
            SET @with_sp_executesql_query = @with_sp_executesql_query + Char (13 
                                            ) 
                                            + Char (10) 
                                            + 
            'DECLARE @stmt nvarchar (max), @params nvarchar (4000)' 
                                            + Char (13) + Char (10) 
            SET @with_sp_executesql_query = @with_sp_executesql_query + Char (13 
                                            ) 
                                            + Char (10) + 'SET @stmt = ' + Char 
                                            ( 
                                            39) 
                                            + Replace (@new_query_text, Char (39 
                                            ), 
                                            Char 
                                            (39) 
                                            + Char (39)) -- Replace single quote 
                                            + Char (39) + Char (13) + Char (10) 
                                            + 
                                            'SET @params = ' 
                                            + Char (39) + @params_list + Char ( 
                                            39) 
                                            + 
                                            Char ( 
                                            13) 
                                            + Char (10) 
            SET @with_sp_executesql_query = 
            @with_sp_executesql_query + Char (13) 
            + Char (10) + 'EXEC sp_executesql ' + 
            Char 
            ( 
            13) 
            + Char (10) + '           @stmt = @stmt' 
            + Char (13) + Char (10) 
            + '           ,@params = @params' + Char ( 
            13 
            ) 
            + Char (10) 

            SELECT @with_sp_executesql_query = @with_sp_executesql_query + 
                                               '           ,' 
                                               + pc.compiled.value('@Column', 
                                               'nvarchar(128)') 
                                               + ' = ' 
                                               + pc.compiled.value('@Column', 
                                               'nvarchar(128)') 
                                               + Char (13) + Char (10) 
            FROM   @params_xml.nodes('//ParameterList/ColumnReference') AS pc( 
                   compiled 
                   ) 
            ORDER  BY pc.compiled.value('@Column', 'nvarchar(128)') 

            UPDATE @result 
            SET    without_sp_executesql_query = @without_sp_executesql_query, 
                   with_sp_executesql_query = @with_sp_executesql_query 
        END 

      RETURN 
  END 

go 
-- END CREATE FUNCTION