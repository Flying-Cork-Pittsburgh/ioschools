USE [master]
GO
/****** Object:  Database [t3stdata]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE DATABASE [t3stdata]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N't3stdata_data', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\t3stdata.mdf' , SIZE = 83328KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N't3stdata_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\t3stdata_1.ldf' , SIZE = 1024KB , MAXSIZE = 1058816KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [t3stdata] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [t3stdata].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [t3stdata] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [t3stdata] SET ANSI_NULLS ON 
GO
ALTER DATABASE [t3stdata] SET ANSI_PADDING ON 
GO
ALTER DATABASE [t3stdata] SET ANSI_WARNINGS ON 
GO
ALTER DATABASE [t3stdata] SET ARITHABORT ON 
GO
ALTER DATABASE [t3stdata] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [t3stdata] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [t3stdata] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [t3stdata] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [t3stdata] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [t3stdata] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [t3stdata] SET CONCAT_NULL_YIELDS_NULL ON 
GO
ALTER DATABASE [t3stdata] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [t3stdata] SET QUOTED_IDENTIFIER ON 
GO
ALTER DATABASE [t3stdata] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [t3stdata] SET  DISABLE_BROKER 
GO
ALTER DATABASE [t3stdata] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [t3stdata] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [t3stdata] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [t3stdata] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [t3stdata] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [t3stdata] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [t3stdata] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [t3stdata] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [t3stdata] SET  MULTI_USER 
GO
ALTER DATABASE [t3stdata] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [t3stdata] SET DB_CHAINING OFF 
GO
ALTER DATABASE [t3stdata] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [t3stdata] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N't3stdata', N'ON'
GO
USE [t3stdata]
GO
/****** Object:  User [NETWORK_SERVICE]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE USER [NETWORK_SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [lodge]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE USER [lodge] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [NETWORK_SERVICE]
GO
ALTER ROLE [db_owner] ADD MEMBER [lodge]
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCachePollingStoredProcedure]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCachePollingStoredProcedure] AS
         SELECT tableName, changeId FROM dbo.AspNet_SqlCacheTablesForChangeNotification
         RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheQueryRegisteredTablesStoredProcedure]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheQueryRegisteredTablesStoredProcedure] 
         AS
         SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification   
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheRegisterTableStoredProcedure]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheRegisterTableStoredProcedure] 
             @tableName NVARCHAR(450) 
         AS
         BEGIN

         DECLARE @triggerName AS NVARCHAR(3000) 
         DECLARE @fullTriggerName AS NVARCHAR(3000)
         DECLARE @canonTableName NVARCHAR(3000) 
         DECLARE @quotedTableName NVARCHAR(3000) 

         /* Create the trigger name */ 
         SET @triggerName = REPLACE(@tableName, '[', '__o__') 
         SET @triggerName = REPLACE(@triggerName, ']', '__c__') 
         SET @triggerName = @triggerName + '_AspNet_SqlCacheNotification_Trigger' 
         SET @fullTriggerName = 'dbo.[' + @triggerName + ']' 

         /* Create the cannonicalized table name for trigger creation */ 
         /* Do not touch it if the name contains other delimiters */ 
         IF (CHARINDEX('.', @tableName) <> 0 OR 
             CHARINDEX('[', @tableName) <> 0 OR 
             CHARINDEX(']', @tableName) <> 0) 
             SET @canonTableName = @tableName 
         ELSE 
             SET @canonTableName = '[' + @tableName + ']' 

         /* First make sure the table exists */ 
         IF (SELECT OBJECT_ID(@tableName, 'U')) IS NULL 
         BEGIN 
             RAISERROR ('00000001', 16, 1) 
             RETURN 
         END 

         BEGIN TRAN
         /* Insert the value into the notification table */ 
         IF NOT EXISTS (SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification WITH (NOLOCK) WHERE tableName = @tableName) 
             IF NOT EXISTS (SELECT tableName FROM dbo.AspNet_SqlCacheTablesForChangeNotification WITH (TABLOCKX) WHERE tableName = @tableName) 
                 INSERT  dbo.AspNet_SqlCacheTablesForChangeNotification 
                 VALUES (@tableName, GETDATE(), 0)

         /* Create the trigger */ 
         SET @quotedTableName = QUOTENAME(@tableName, '''') 
         IF NOT EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = @triggerName AND type = 'TR') 
             IF NOT EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = @triggerName AND type = 'TR') 
                 EXEC('CREATE TRIGGER ' + @fullTriggerName + ' ON ' + @canonTableName +'
                       FOR INSERT, UPDATE, DELETE AS BEGIN
                       SET NOCOUNT ON
                       EXEC dbo.AspNet_SqlCacheUpdateChangeIdStoredProcedure N' + @quotedTableName + '
                       END
                       ')
         COMMIT TRAN
         END
   
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheUnRegisterTableStoredProcedure]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheUnRegisterTableStoredProcedure] 
             @tableName NVARCHAR(450) 
         AS
         BEGIN

         BEGIN TRAN
         DECLARE @triggerName AS NVARCHAR(3000) 
         DECLARE @fullTriggerName AS NVARCHAR(3000)
         SET @triggerName = REPLACE(@tableName, '[', '__o__') 
         SET @triggerName = REPLACE(@triggerName, ']', '__c__') 
         SET @triggerName = @triggerName + '_AspNet_SqlCacheNotification_Trigger' 
         SET @fullTriggerName = 'dbo.[' + @triggerName + ']' 

         /* Remove the table-row from the notification table */ 
         IF EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = 'AspNet_SqlCacheTablesForChangeNotification' AND type = 'U') 
             IF EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = 'AspNet_SqlCacheTablesForChangeNotification' AND type = 'U') 
             DELETE FROM dbo.AspNet_SqlCacheTablesForChangeNotification WHERE tableName = @tableName 

         /* Remove the trigger */ 
         IF EXISTS (SELECT name FROM sysobjects WITH (NOLOCK) WHERE name = @triggerName AND type = 'TR') 
             IF EXISTS (SELECT name FROM sysobjects WITH (TABLOCKX) WHERE name = @triggerName AND type = 'TR') 
             EXEC('DROP TRIGGER ' + @fullTriggerName) 

         COMMIT TRAN
         END
   
GO
/****** Object:  StoredProcedure [dbo].[AspNet_SqlCacheUpdateChangeIdStoredProcedure]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AspNet_SqlCacheUpdateChangeIdStoredProcedure] 
             @tableName NVARCHAR(450) 
         AS

         BEGIN 
             UPDATE dbo.AspNet_SqlCacheTablesForChangeNotification WITH (ROWLOCK) SET changeId = changeId + 1 
             WHERE tableName = @tableName
         END
   
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_GetErrorsXml]
(
    @Application NVARCHAR(60),
    @PageIndex INT = 0,
    @PageSize INT = 15,
    @TotalCount INT OUTPUT
)
AS 

    SET NOCOUNT ON

    DECLARE @FirstTimeUTC DATETIME
    DECLARE @FirstSequence INT
    DECLARE @StartRow INT
    DECLARE @StartRowIndex INT

    SELECT 
        @TotalCount = COUNT(1) 
    FROM 
        [ELMAH_Error]
    WHERE 
        [Application] = @Application

    -- Get the ID of the first error for the requested page

    SET @StartRowIndex = @PageIndex * @PageSize + 1

    IF @StartRowIndex <= @TotalCount
    BEGIN

        SET ROWCOUNT @StartRowIndex

        SELECT  
            @FirstTimeUTC = [TimeUtc],
            @FirstSequence = [Sequence]
        FROM 
            [ELMAH_Error]
        WHERE   
            [Application] = @Application
        ORDER BY 
            [TimeUtc] DESC, 
            [Sequence] DESC

    END
    ELSE
    BEGIN

        SET @PageSize = 0

    END

    -- Now set the row count to the requested page size and get
    -- all records below it for the pertaining application.

    SET ROWCOUNT @PageSize

    SELECT 
        errorId     = [ErrorId], 
        application = [Application],
        host        = [Host], 
        type        = [Type],
        source      = [Source],
        message     = [Message],
        [user]      = [User],
        statusCode  = [StatusCode], 
        time        = CONVERT(VARCHAR(50), [TimeUtc], 126) + 'Z'
    FROM 
        [ELMAH_Error] error
    WHERE
        [Application] = @Application
    AND
        [TimeUtc] <= @FirstTimeUTC
    AND 
        [Sequence] <= @FirstSequence
    ORDER BY
        [TimeUtc] DESC, 
        [Sequence] DESC
    FOR
        XML AUTO

GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_GetErrorXml]
(
    @Application NVARCHAR(60),
    @ErrorId UNIQUEIDENTIFIER
)
AS

    SET NOCOUNT ON

    SELECT 
        [AllXml]
    FROM 
        [ELMAH_Error]
    WHERE
        [ErrorId] = @ErrorId
    AND
        [Application] = @Application

GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ELMAH_LogError]
(
    @ErrorId UNIQUEIDENTIFIER,
    @Application NVARCHAR(60),
    @Host NVARCHAR(30),
    @Type NVARCHAR(100),
    @Source NVARCHAR(60),
    @Message NVARCHAR(500),
    @User NVARCHAR(50),
    @AllXml NVARCHAR(MAX),
    @StatusCode INT,
    @TimeUtc DATETIME
)
AS

    SET NOCOUNT ON

    INSERT
    INTO
        [ELMAH_Error]
        (
            [ErrorId],
            [Application],
            [Host],
            [Type],
            [Source],
            [Message],
            [User],
            [AllXml],
            [StatusCode],
            [TimeUtc]
        )
    VALUES
        (
            @ErrorId,
            @Application,
            @Host,
            @Type,
            @Source,
            @Message,
            @User,
            @AllXml,
            @StatusCode,
            @TimeUtc
        )

GO
/****** Object:  Table [dbo].[attendance_terms]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[attendance_terms](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[schoolid] [int] NOT NULL,
	[termid] [smallint] NOT NULL,
	[year] [int] NOT NULL,
	[startdate] [date] NOT NULL,
	[enddate] [date] NOT NULL,
	[days] [int] NOT NULL,
 CONSTRAINT [PK_attendance_terms] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[attendances]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[attendances](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[classid] [int] NULL,
	[ecaid] [int] NULL,
	[date] [datetime] NOT NULL,
	[studentid] [bigint] NOT NULL,
	[reason] [nvarchar](500) NOT NULL,
	[status] [varchar](10) NOT NULL,
	[creator] [bigint] NULL,
 CONSTRAINT [PK_attendances] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[blog_files]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[blog_files](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[url] [varchar](1000) NULL,
	[blogid] [bigint] NULL,
	[name] [nvarchar](320) NOT NULL,
 CONSTRAINT [PK_blog_files] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[blog_images]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[blog_images](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[url] [varchar](1000) NULL,
	[blogid] [bigint] NULL,
 CONSTRAINT [PK_blog_images] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[blogs]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blogs](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[creator] [bigint] NOT NULL,
	[body] [text] NOT NULL,
	[created] [datetime] NOT NULL,
	[ispublic] [bit] NOT NULL,
	[emailed] [bit] NOT NULL,
	[layoutMethod] [tinyint] NULL,
 CONSTRAINT [PK_blogs] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[calendar]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[calendar](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[date] [date] NOT NULL,
	[details] [nvarchar](500) NOT NULL,
	[isHoliday] [bit] NOT NULL,
 CONSTRAINT [PK_calendar] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[changelogs]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[changelogs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userid] [bigint] NOT NULL,
	[created] [datetime] NOT NULL,
	[changes] [text] NOT NULL,
 CONSTRAINT [PK_changelogs] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[classes_students_allocated]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[classes_students_allocated](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[year] [int] NOT NULL,
	[studentid] [bigint] NOT NULL,
	[classid] [int] NOT NULL,
 CONSTRAINT [PK_classes_students] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[classes_teachers_allocated]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[classes_teachers_allocated](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[schoolid] [int] NOT NULL,
	[teacherid] [bigint] NOT NULL,
	[subjectid] [bigint] NULL,
	[classid] [int] NOT NULL,
	[day] [int] NOT NULL,
	[year] [int] NOT NULL,
	[time_start] [time](7) NOT NULL,
	[time_end] [time](7) NOT NULL,
 CONSTRAINT [PK_classes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[conducts]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[conducts](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[min] [smallint] NULL,
	[max] [smallint] NULL,
	[isdemerit] [bit] NOT NULL,
 CONSTRAINT [PK_conducts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[eca_students]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[eca_students](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[studentid] [bigint] NOT NULL,
	[post] [nvarchar](100) NULL,
	[ecaid] [int] NOT NULL,
	[year] [int] NOT NULL,
	[achievement] [nvarchar](1000) NULL,
	[type] [varchar](10) NULL,
	[remarks] [nvarchar](500) NULL,
 CONSTRAINT [PK_ECAstudents] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[ecas]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ecas](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[schoolid] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ECAs] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[employments]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employments](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[userid] [bigint] NOT NULL,
	[remarks] [nvarchar](500) NULL,
 CONSTRAINT [PK_employments] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[exam_classes]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exam_classes](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[classid] [int] NOT NULL,
	[examid] [bigint] NOT NULL,
 CONSTRAINT [PK_exam_classes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[exam_marks]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[exam_marks](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[studentid] [bigint] NOT NULL,
	[exam_subjectid] [bigint] NOT NULL,
	[mark] [varchar](3) NULL,
	[examid] [bigint] NOT NULL,
	[absent] [bit] NOT NULL,
 CONSTRAINT [PK_exam_marks] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[exam_subjects]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[exam_subjects](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[examid] [bigint] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[code] [varchar](10) NULL,
	[position] [tinyint] NULL,
	[subjectid] [bigint] NULL,
 CONSTRAINT [PK_exam_subjects] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[exam_template_subjects]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[exam_template_subjects](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[code] [varchar](10) NULL,
	[templateid] [int] NOT NULL,
	[position] [tinyint] NULL,
	[subjectid] [bigint] NULL,
 CONSTRAINT [PK_exam_template_subjects] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[exam_templates]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exam_templates](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[schoolid] [int] NOT NULL,
	[maxMark] [smallint] NOT NULL,
	[creator] [bigint] NULL,
	[description] [nvarchar](500) NULL,
	[isprivate] [bit] NOT NULL,
 CONSTRAINT [PK_exam_templates] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[exams]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exams](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[exam_date] [datetime] NOT NULL,
	[schoolid] [int] NOT NULL,
	[year] [int] NOT NULL,
	[creator] [bigint] NOT NULL,
	[description] [nvarchar](500) NULL,
	[maxMark] [smallint] NOT NULL,
 CONSTRAINT [PK_exams] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[feedbacks]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[feedbacks](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[message] [text] NOT NULL,
	[status] [varchar](20) NOT NULL,
	[created] [datetime] NOT NULL,
	[creator] [bigint] NOT NULL,
 CONSTRAINT [PK_feedbacks] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[feegroups]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[feegroups](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[schoolid] [int] NOT NULL,
 CONSTRAINT [PK_fees_groups] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[feegroups_members]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[feegroups_members](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[groupid] [int] NOT NULL,
	[feetypeid] [int] NOT NULL,
	[amount] [money] NOT NULL,
	[dueday] [int] NOT NULL,
	[duemonth] [int] NOT NULL,
	[discount] [bit] NOT NULL,
 CONSTRAINT [PK_feegroups_members] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fees]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[fees](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[created] [datetime] NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[typeid] [int] NULL,
	[studentid] [bigint] NOT NULL,
	[status] [varchar](7) NOT NULL,
	[amount] [money] NOT NULL,
	[duedate] [datetime] NOT NULL,
	[discount] [bit] NOT NULL,
 CONSTRAINT [PK_fees_paids] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[fees_reminders]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[fees_reminders](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[templatename] [nvarchar](100) NOT NULL,
	[created] [datetime] NOT NULL,
	[paymentdue] [datetime] NOT NULL,
	[receiver] [bigint] NOT NULL,
	[sender] [bigint] NOT NULL,
	[feeid] [bigint] NOT NULL,
	[uniqueid] [varchar](10) NOT NULL,
	[viewed] [bit] NOT NULL,
	[reference] [nvarchar](50) NULL,
	[deliverymethod] [tinyint] NOT NULL,
	[content] [text] NULL,
 CONSTRAINT [PK_fees_reminders] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[fees_types]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fees_types](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NOT NULL,
	[schoolid] [int] NOT NULL,
	[amount] [money] NULL,
	[dueday] [int] NULL,
	[duemonth] [int] NULL,
	[discount] [bit] NOT NULL,
 CONSTRAINT [PK_fees] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[grades_methods]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[grades_methods](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_school_years_groups] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[grades_rules]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[grades_rules](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[methodid] [int] NOT NULL,
	[grade] [nvarchar](5) NULL,
	[gradepoint] [decimal](3, 1) NULL,
	[mark] [smallint] NOT NULL,
 CONSTRAINT [PK_grades_rules] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[homework_answers]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[homework_answers](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[url] [nvarchar](320) NOT NULL,
	[homeworkid] [bigint] NOT NULL,
	[filename] [nvarchar](100) NOT NULL,
	[size] [bigint] NOT NULL,
	[homeworkstudentid] [bigint] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_homework_answers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[homework_classes]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[homework_classes](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[homeworkid] [bigint] NOT NULL,
	[classid] [int] NOT NULL,
 CONSTRAINT [PK_homework_classes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[homework_files]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[homework_files](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[url] [nvarchar](320) NOT NULL,
	[homeworkid] [bigint] NULL,
	[filename] [nvarchar](100) NOT NULL,
	[size] [bigint] NOT NULL,
 CONSTRAINT [PK_homework_files] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[homework_students]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[homework_students](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[studentid] [bigint] NOT NULL,
	[homeworkid] [bigint] NOT NULL,
	[classid] [int] NOT NULL,
	[marks] [varchar](3) NULL,
 CONSTRAINT [PK_homework_students] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[homeworks]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[homeworks](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[message] [text] NOT NULL,
	[subjectid] [bigint] NOT NULL,
	[created] [datetime] NOT NULL,
	[creator] [bigint] NOT NULL,
	[title] [nvarchar](200) NOT NULL,
	[notifyme] [bit] NOT NULL,
 CONSTRAINT [PK_homeworks] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[leaves]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[leaves](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[defaultTotal] [int] NULL,
 CONSTRAINT [PK_leaves] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[leaves_allocated]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[leaves_allocated](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[type] [int] NOT NULL,
	[staffid] [bigint] NOT NULL,
	[annualTotal] [int] NULL,
	[remaining] [decimal](4, 1) NULL,
 CONSTRAINT [PK_leaves_allocateds] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[leaves_taken]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[leaves_taken](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[allocatedid] [bigint] NOT NULL,
	[startdate] [datetime] NOT NULL,
	[starttime] [tinyint] NOT NULL,
	[enddate] [datetime] NOT NULL,
	[endtime] [tinyint] NOT NULL,
	[status] [tinyint] NOT NULL,
	[details] [nvarchar](1000) NULL,
	[staffid] [bigint] NOT NULL,
	[reason] [nvarchar](1000) NULL,
	[days] [decimal](4, 1) NOT NULL,
 CONSTRAINT [PK_leaves_taken] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[mails]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mails](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[toName] [nvarchar](200) NOT NULL,
	[toEmail] [nvarchar](320) NOT NULL,
	[subject] [nvarchar](200) NOT NULL,
	[body] [nvarchar](max) NOT NULL,
	[fromEmail] [nvarchar](320) NULL,
	[fromName] [nvarchar](200) NULL,
 CONSTRAINT [PK_mails] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[message_templates]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[message_templates](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](100) NOT NULL,
	[body] [text] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [PK_fees_templates] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[messages]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[messages](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[sent] [datetime] NOT NULL,
	[receiver] [bigint] NOT NULL,
	[messagetype] [int] NOT NULL,
	[deliveryMethod] [tinyint] NOT NULL,
 CONSTRAINT [PK_messages] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[modules]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[modules](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[isActive] [bit] NOT NULL,
	[updated] [datetime] NOT NULL,
	[type] [smallint] NOT NULL,
	[settings] [xml] NOT NULL,
 CONSTRAINT [PK_modules] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[pages]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pages](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[content] [text] NOT NULL,
	[type] [int] NOT NULL,
 CONSTRAINT [PK_pages] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[registration_notifications]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[registration_notifications](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userid] [bigint] NOT NULL,
 CONSTRAINT [PK_registration_notifications] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[registrations]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[registrations](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[created] [date] NOT NULL,
	[status] [varchar](20) NULL,
	[applicantid] [bigint] NULL,
	[studentid] [bigint] NOT NULL,
	[schoolid] [int] NULL,
	[schoolyearid] [int] NULL,
	[reviewer] [bigint] NULL,
	[reviewMessage] [nvarchar](1000) NULL,
	[enrollingYear] [int] NULL,
	[previous_school] [nvarchar](200) NULL,
	[previous_report] [varchar](100) NULL,
	[previous_class] [varchar](50) NULL,
	[leaving_reason] [nvarchar](500) NULL,
	[isHandicap] [bit] NULL,
	[hasLearningProblem] [bit] NULL,
	[disability_details] [nvarchar](500) NULL,
	[admissionDate] [date] NULL,
	[rank] [int] NULL,
	[leftDate] [date] NULL,
	[test_academic] [varchar](1) NULL,
	[test_diligence] [varchar](1) NULL,
	[test_attendance] [varchar](1) NULL,
	[test_responsible] [varchar](1) NULL,
	[test_initiative] [varchar](1) NULL,
	[test_conduct] [varchar](1) NULL,
	[test_honesty] [varchar](1) NULL,
	[test_reliance] [varchar](1) NULL,
	[test_collaborate] [varchar](1) NULL,
	[test_appearance] [varchar](1) NULL,
	[test_bm] [varchar](1) NULL,
	[test_english] [varchar](1) NULL,
	[test_remarks] [nvarchar](1000) NULL,
	[cert_reason] [nvarchar](200) NULL,
	[cert_remarks] [nvarchar](100) NULL,
 CONSTRAINT [PK_registrations] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[school_classes]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[school_classes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[schoolid] [int] NOT NULL,
	[nextclass] [int] NULL,
	[schoolyearid] [int] NOT NULL,
 CONSTRAINT [PK_levels] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[school_terms]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[school_terms](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[schoolid] [int] NOT NULL,
 CONSTRAINT [PK_school_exams] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[school_years]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[school_years](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[schoolid] [int] NOT NULL,
	[grademethodid] [int] NULL,
 CONSTRAINT [PK_school_years] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[schools]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[schools](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](20) NOT NULL,
 CONSTRAINT [PK_schools] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[siblings]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[siblings](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[siblingid] [bigint] NOT NULL,
	[otherid] [bigint] NOT NULL,
 CONSTRAINT [PK_siblings] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[students_disciplines]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[students_disciplines](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[studentid] [bigint] NOT NULL,
	[points] [int] NOT NULL,
	[reason] [nvarchar](1000) NOT NULL,
	[creator] [bigint] NOT NULL,
	[created] [datetime] NOT NULL,
	[type] [int] NULL,
 CONSTRAINT [PK_disciplines] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[students_guardians]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[students_guardians](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[studentid] [bigint] NOT NULL,
	[parentid] [bigint] NOT NULL,
	[type] [tinyint] NOT NULL,
 CONSTRAINT [PK_students_guardians] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[students_remarks]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[students_remarks](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[studentid] [bigint] NOT NULL,
	[year] [int] NOT NULL,
	[term] [smallint] NOT NULL,
	[remarks] [nvarchar](1000) NULL,
	[conduct] [nvarchar](1) NULL,
 CONSTRAINT [PK_students_remarks] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[subject_teachers]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[subject_teachers](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[teacherid] [bigint] NOT NULL,
	[subjectid] [bigint] NOT NULL,
	[classid] [int] NOT NULL,
	[year] [int] NOT NULL,
 CONSTRAINT [PK_subject_teachers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[subjects]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[subjects](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[schoolid] [int] NOT NULL,
 CONSTRAINT [PK_subjects] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[user_files]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_files](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[url] [nvarchar](320) NOT NULL,
	[userid] [bigint] NOT NULL,
	[filename] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_user_files] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[user_images]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user_images](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[url] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_images] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[user_parents]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user_parents](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[userid] [bigint] NOT NULL,
	[occupation] [varchar](100) NULL,
	[employer] [nvarchar](200) NULL,
	[phone_office] [varchar](50) NULL,
 CONSTRAINT [PK_user_parents] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[user_staff]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user_staff](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[userid] [bigint] NOT NULL,
	[salary_grade] [varchar](10) NULL,
	[income_tax] [varchar](20) NULL,
	[epf] [varchar](20) NULL,
	[socso] [varchar](20) NULL,
	[spouse_name] [nvarchar](100) NULL,
	[spouse_employer] [nvarchar](200) NULL,
	[spouse_employer_address] [nvarchar](200) NULL,
	[spouse_phone_cell] [varchar](50) NULL,
	[spouse_phone_work] [varchar](50) NULL,
 CONSTRAINT [PK_user_staff] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [dbo].[users]    Script Date: 29/3/2018 7:00:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[users](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[status] [tinyint] NULL,
	[email] [varchar](320) NULL,
	[passwordhash] [varchar](128) NULL,
	[designation] [varchar](10) NULL,
	[name] [nvarchar](100) NOT NULL,
	[usergroup] [int] NOT NULL,
	[photo] [bigint] NULL,
	[settings] [int] NOT NULL,
	[nric_new] [varchar](50) NULL,
	[dob] [date] NULL,
	[race] [varchar](50) NULL,
	[dialect] [varchar](20) NULL,
	[gender] [varchar](6) NULL,
	[pob] [nvarchar](50) NULL,
	[citizenship] [nvarchar](50) NULL,
	[birthcertno] [varchar](50) NULL,
	[passportno] [varchar](50) NULL,
	[isbumi] [bit] NULL,
	[religion] [varchar](20) NULL,
	[phone_home] [varchar](50) NULL,
	[phone_cell] [varchar](50) NULL,
	[address] [nvarchar](200) NULL,
	[schoolid] [int] NULL,
	[notes] [nvarchar](3000) NULL,
	[updated] [datetime] NULL,
	[marital_status] [varchar](10) NULL,
	[permissions] [bigint] NOT NULL,
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_classes_students_allocated]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_classes_students_allocated] ON [dbo].[classes_students_allocated]
(
	[studentid] ASC,
	[classid] ASC,
	[year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_classes_teachers_allocated]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_classes_teachers_allocated] ON [dbo].[classes_teachers_allocated]
(
	[classid] ASC,
	[year] ASC,
	[teacherid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_classes_teachers_allocated_1]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_classes_teachers_allocated_1] ON [dbo].[classes_teachers_allocated]
(
	[schoolid] ASC,
	[year] ASC,
	[teacherid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_eca_students]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_eca_students] ON [dbo].[eca_students]
(
	[ecaid] ASC,
	[year] ASC,
	[studentid] ASC,
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ELMAH_Error_App_Time_Seq]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_App_Time_Seq] ON [dbo].[ELMAH_Error]
(
	[Application] ASC,
	[TimeUtc] DESC,
	[Sequence] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_exam_marks]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_exam_marks] ON [dbo].[exam_marks]
(
	[exam_subjectid] ASC,
	[examid] ASC,
	[studentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_students_guardians]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_students_guardians] ON [dbo].[students_guardians]
(
	[parentid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_students_guardians1]    Script Date: 29/3/2018 7:00:27 PM ******/
CREATE NONCLUSTERED INDEX [IX_students_guardians1] ON [dbo].[students_guardians]
(
	[studentid] ASC
)
INCLUDE ( 	[id],
	[parentid],
	[type]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [DF_ELMAH_Error_ErrorId]  DEFAULT (newid()) FOR [ErrorId]
GO
ALTER TABLE [dbo].[exam_templates] ADD  CONSTRAINT [DF_exam_templates_isprivate]  DEFAULT ((0)) FOR [isprivate]
GO
ALTER TABLE [dbo].[exams] ADD  CONSTRAINT [DF_exams_maxMark]  DEFAULT ((100)) FOR [maxMark]
GO
ALTER TABLE [dbo].[feegroups_members] ADD  CONSTRAINT [DF_feegroups_members_discount]  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[fees] ADD  CONSTRAINT [DF_fees_discount]  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[fees_types] ADD  CONSTRAINT [DF_fees_types_discount]  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[homeworks] ADD  CONSTRAINT [DF_homeworks_notifyme]  DEFAULT ((0)) FOR [notifyme]
GO
ALTER TABLE [dbo].[leaves_taken] ADD  CONSTRAINT [DF_leaves_taken_starttime]  DEFAULT ((1)) FOR [starttime]
GO
ALTER TABLE [dbo].[leaves_taken] ADD  CONSTRAINT [DF_leaves_taken_endtime]  DEFAULT ((3)) FOR [endtime]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_permissions]  DEFAULT ((0)) FOR [permissions]
GO
ALTER TABLE [dbo].[attendance_terms]  WITH CHECK ADD  CONSTRAINT [FK_attendance_terms_school_exams] FOREIGN KEY([termid])
REFERENCES [dbo].[school_terms] ([id])
GO
ALTER TABLE [dbo].[attendance_terms] CHECK CONSTRAINT [FK_attendance_terms_school_exams]
GO
ALTER TABLE [dbo].[attendance_terms]  WITH CHECK ADD  CONSTRAINT [FK_attendance_terms_school_terms] FOREIGN KEY([termid])
REFERENCES [dbo].[school_terms] ([id])
GO
ALTER TABLE [dbo].[attendance_terms] CHECK CONSTRAINT [FK_attendance_terms_school_terms]
GO
ALTER TABLE [dbo].[attendance_terms]  WITH CHECK ADD  CONSTRAINT [FK_attendance_terms_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[attendance_terms] CHECK CONSTRAINT [FK_attendance_terms_schools]
GO
ALTER TABLE [dbo].[attendances]  WITH CHECK ADD  CONSTRAINT [FK_attendances_ecas] FOREIGN KEY([ecaid])
REFERENCES [dbo].[ecas] ([id])
GO
ALTER TABLE [dbo].[attendances] CHECK CONSTRAINT [FK_attendances_ecas]
GO
ALTER TABLE [dbo].[attendances]  WITH CHECK ADD  CONSTRAINT [FK_attendances_school_classes] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[attendances] CHECK CONSTRAINT [FK_attendances_school_classes]
GO
ALTER TABLE [dbo].[attendances]  WITH CHECK ADD  CONSTRAINT [FK_attendances_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[attendances] CHECK CONSTRAINT [FK_attendances_users]
GO
ALTER TABLE [dbo].[blog_files]  WITH CHECK ADD  CONSTRAINT [FK_blog_files_blogs] FOREIGN KEY([blogid])
REFERENCES [dbo].[blogs] ([id])
GO
ALTER TABLE [dbo].[blog_files] CHECK CONSTRAINT [FK_blog_files_blogs]
GO
ALTER TABLE [dbo].[blog_images]  WITH CHECK ADD  CONSTRAINT [FK_blog_images_blogs] FOREIGN KEY([blogid])
REFERENCES [dbo].[blogs] ([id])
GO
ALTER TABLE [dbo].[blog_images] CHECK CONSTRAINT [FK_blog_images_blogs]
GO
ALTER TABLE [dbo].[blogs]  WITH CHECK ADD  CONSTRAINT [FK_blogs_users] FOREIGN KEY([creator])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[blogs] CHECK CONSTRAINT [FK_blogs_users]
GO
ALTER TABLE [dbo].[changelogs]  WITH CHECK ADD  CONSTRAINT [FK_changelogs_users] FOREIGN KEY([userid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[changelogs] CHECK CONSTRAINT [FK_changelogs_users]
GO
ALTER TABLE [dbo].[classes_students_allocated]  WITH CHECK ADD  CONSTRAINT [FK_classes_students_classes_teachers] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[classes_students_allocated] CHECK CONSTRAINT [FK_classes_students_classes_teachers]
GO
ALTER TABLE [dbo].[classes_students_allocated]  WITH CHECK ADD  CONSTRAINT [FK_classes_students_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[classes_students_allocated] CHECK CONSTRAINT [FK_classes_students_users]
GO
ALTER TABLE [dbo].[classes_teachers_allocated]  WITH CHECK ADD  CONSTRAINT [FK_classes_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[classes_teachers_allocated] CHECK CONSTRAINT [FK_classes_schools]
GO
ALTER TABLE [dbo].[classes_teachers_allocated]  WITH CHECK ADD  CONSTRAINT [FK_classes_teachers_allocated_school_classes] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[classes_teachers_allocated] CHECK CONSTRAINT [FK_classes_teachers_allocated_school_classes]
GO
ALTER TABLE [dbo].[classes_teachers_allocated]  WITH CHECK ADD  CONSTRAINT [FK_classes_teachers_allocated_subjects] FOREIGN KEY([subjectid])
REFERENCES [dbo].[subjects] ([id])
GO
ALTER TABLE [dbo].[classes_teachers_allocated] CHECK CONSTRAINT [FK_classes_teachers_allocated_subjects]
GO
ALTER TABLE [dbo].[classes_teachers_allocated]  WITH CHECK ADD  CONSTRAINT [FK_classes_users] FOREIGN KEY([teacherid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[classes_teachers_allocated] CHECK CONSTRAINT [FK_classes_users]
GO
ALTER TABLE [dbo].[eca_students]  WITH CHECK ADD  CONSTRAINT [FK_ECAstudents_ECAs] FOREIGN KEY([ecaid])
REFERENCES [dbo].[ecas] ([id])
GO
ALTER TABLE [dbo].[eca_students] CHECK CONSTRAINT [FK_ECAstudents_ECAs]
GO
ALTER TABLE [dbo].[eca_students]  WITH CHECK ADD  CONSTRAINT [FK_ECAstudents_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[eca_students] CHECK CONSTRAINT [FK_ECAstudents_users]
GO
ALTER TABLE [dbo].[ecas]  WITH CHECK ADD  CONSTRAINT [FK_ECAs_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[ecas] CHECK CONSTRAINT [FK_ECAs_schools]
GO
ALTER TABLE [dbo].[employments]  WITH CHECK ADD  CONSTRAINT [FK_employments_users] FOREIGN KEY([userid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[employments] CHECK CONSTRAINT [FK_employments_users]
GO
ALTER TABLE [dbo].[exam_classes]  WITH CHECK ADD  CONSTRAINT [FK_exam_classes_exams] FOREIGN KEY([examid])
REFERENCES [dbo].[exams] ([id])
GO
ALTER TABLE [dbo].[exam_classes] CHECK CONSTRAINT [FK_exam_classes_exams]
GO
ALTER TABLE [dbo].[exam_classes]  WITH CHECK ADD  CONSTRAINT [FK_exam_classes_school_classes] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[exam_classes] CHECK CONSTRAINT [FK_exam_classes_school_classes]
GO
ALTER TABLE [dbo].[exam_marks]  WITH CHECK ADD  CONSTRAINT [FK_exam_marks_exam_subjects] FOREIGN KEY([exam_subjectid])
REFERENCES [dbo].[exam_subjects] ([id])
GO
ALTER TABLE [dbo].[exam_marks] CHECK CONSTRAINT [FK_exam_marks_exam_subjects]
GO
ALTER TABLE [dbo].[exam_marks]  WITH CHECK ADD  CONSTRAINT [FK_exam_marks_exams] FOREIGN KEY([examid])
REFERENCES [dbo].[exams] ([id])
GO
ALTER TABLE [dbo].[exam_marks] CHECK CONSTRAINT [FK_exam_marks_exams]
GO
ALTER TABLE [dbo].[exam_marks]  WITH CHECK ADD  CONSTRAINT [FK_exam_marks_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[exam_marks] CHECK CONSTRAINT [FK_exam_marks_users]
GO
ALTER TABLE [dbo].[exam_subjects]  WITH CHECK ADD  CONSTRAINT [FK_exam_subjects_exams] FOREIGN KEY([examid])
REFERENCES [dbo].[exams] ([id])
GO
ALTER TABLE [dbo].[exam_subjects] CHECK CONSTRAINT [FK_exam_subjects_exams]
GO
ALTER TABLE [dbo].[exam_subjects]  WITH CHECK ADD  CONSTRAINT [FK_exam_subjects_subjects] FOREIGN KEY([subjectid])
REFERENCES [dbo].[subjects] ([id])
GO
ALTER TABLE [dbo].[exam_subjects] CHECK CONSTRAINT [FK_exam_subjects_subjects]
GO
ALTER TABLE [dbo].[exam_template_subjects]  WITH CHECK ADD  CONSTRAINT [FK_exam_template_subjects_exam_templates] FOREIGN KEY([templateid])
REFERENCES [dbo].[exam_templates] ([id])
GO
ALTER TABLE [dbo].[exam_template_subjects] CHECK CONSTRAINT [FK_exam_template_subjects_exam_templates]
GO
ALTER TABLE [dbo].[exam_template_subjects]  WITH CHECK ADD  CONSTRAINT [FK_exam_template_subjects_subjects] FOREIGN KEY([subjectid])
REFERENCES [dbo].[subjects] ([id])
GO
ALTER TABLE [dbo].[exam_template_subjects] CHECK CONSTRAINT [FK_exam_template_subjects_subjects]
GO
ALTER TABLE [dbo].[exam_templates]  WITH CHECK ADD  CONSTRAINT [FK_exam_templates_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[exam_templates] CHECK CONSTRAINT [FK_exam_templates_schools]
GO
ALTER TABLE [dbo].[exam_templates]  WITH CHECK ADD  CONSTRAINT [FK_exam_templates_users] FOREIGN KEY([creator])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[exam_templates] CHECK CONSTRAINT [FK_exam_templates_users]
GO
ALTER TABLE [dbo].[exams]  WITH CHECK ADD  CONSTRAINT [FK_exams_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[exams] CHECK CONSTRAINT [FK_exams_schools]
GO
ALTER TABLE [dbo].[exams]  WITH CHECK ADD  CONSTRAINT [FK_exams_users] FOREIGN KEY([creator])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[exams] CHECK CONSTRAINT [FK_exams_users]
GO
ALTER TABLE [dbo].[feedbacks]  WITH CHECK ADD  CONSTRAINT [FK_feedbacks_users] FOREIGN KEY([creator])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[feedbacks] CHECK CONSTRAINT [FK_feedbacks_users]
GO
ALTER TABLE [dbo].[feegroups]  WITH CHECK ADD  CONSTRAINT [FK_feegroups_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[feegroups] CHECK CONSTRAINT [FK_feegroups_schools]
GO
ALTER TABLE [dbo].[feegroups_members]  WITH CHECK ADD  CONSTRAINT [FK_feegroups_members_feegroups] FOREIGN KEY([groupid])
REFERENCES [dbo].[feegroups] ([id])
GO
ALTER TABLE [dbo].[feegroups_members] CHECK CONSTRAINT [FK_feegroups_members_feegroups]
GO
ALTER TABLE [dbo].[feegroups_members]  WITH CHECK ADD  CONSTRAINT [FK_feegroups_members_fees_types] FOREIGN KEY([feetypeid])
REFERENCES [dbo].[fees_types] ([id])
GO
ALTER TABLE [dbo].[feegroups_members] CHECK CONSTRAINT [FK_feegroups_members_fees_types]
GO
ALTER TABLE [dbo].[fees_reminders]  WITH CHECK ADD  CONSTRAINT [FK_fees_reminders_fees] FOREIGN KEY([feeid])
REFERENCES [dbo].[fees] ([id])
GO
ALTER TABLE [dbo].[fees_reminders] CHECK CONSTRAINT [FK_fees_reminders_fees]
GO
ALTER TABLE [dbo].[fees_reminders]  WITH CHECK ADD  CONSTRAINT [FK_fees_reminders_users] FOREIGN KEY([receiver])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[fees_reminders] CHECK CONSTRAINT [FK_fees_reminders_users]
GO
ALTER TABLE [dbo].[fees_reminders]  WITH CHECK ADD  CONSTRAINT [FK_fees_reminders_users1] FOREIGN KEY([sender])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[fees_reminders] CHECK CONSTRAINT [FK_fees_reminders_users1]
GO
ALTER TABLE [dbo].[fees_types]  WITH CHECK ADD  CONSTRAINT [FK_fees_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[fees_types] CHECK CONSTRAINT [FK_fees_schools]
GO
ALTER TABLE [dbo].[grades_rules]  WITH CHECK ADD  CONSTRAINT [FK_grades_rules_grades_methods] FOREIGN KEY([methodid])
REFERENCES [dbo].[grades_methods] ([id])
GO
ALTER TABLE [dbo].[grades_rules] CHECK CONSTRAINT [FK_grades_rules_grades_methods]
GO
ALTER TABLE [dbo].[homework_answers]  WITH CHECK ADD  CONSTRAINT [FK_homework_answers_homework_students] FOREIGN KEY([homeworkstudentid])
REFERENCES [dbo].[homework_students] ([id])
GO
ALTER TABLE [dbo].[homework_answers] CHECK CONSTRAINT [FK_homework_answers_homework_students]
GO
ALTER TABLE [dbo].[homework_answers]  WITH CHECK ADD  CONSTRAINT [FK_homework_answers_homeworks] FOREIGN KEY([homeworkid])
REFERENCES [dbo].[homeworks] ([id])
GO
ALTER TABLE [dbo].[homework_answers] CHECK CONSTRAINT [FK_homework_answers_homeworks]
GO
ALTER TABLE [dbo].[homework_classes]  WITH CHECK ADD  CONSTRAINT [FK_homework_classes_homeworks] FOREIGN KEY([homeworkid])
REFERENCES [dbo].[homeworks] ([id])
GO
ALTER TABLE [dbo].[homework_classes] CHECK CONSTRAINT [FK_homework_classes_homeworks]
GO
ALTER TABLE [dbo].[homework_classes]  WITH CHECK ADD  CONSTRAINT [FK_homework_classes_school_classes] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[homework_classes] CHECK CONSTRAINT [FK_homework_classes_school_classes]
GO
ALTER TABLE [dbo].[homework_files]  WITH CHECK ADD  CONSTRAINT [FK_homework_files_homeworks] FOREIGN KEY([homeworkid])
REFERENCES [dbo].[homeworks] ([id])
GO
ALTER TABLE [dbo].[homework_files] CHECK CONSTRAINT [FK_homework_files_homeworks]
GO
ALTER TABLE [dbo].[homework_students]  WITH CHECK ADD  CONSTRAINT [FK_homework_students_homeworks] FOREIGN KEY([homeworkid])
REFERENCES [dbo].[homeworks] ([id])
GO
ALTER TABLE [dbo].[homework_students] CHECK CONSTRAINT [FK_homework_students_homeworks]
GO
ALTER TABLE [dbo].[homework_students]  WITH CHECK ADD  CONSTRAINT [FK_homework_students_school_classes] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[homework_students] CHECK CONSTRAINT [FK_homework_students_school_classes]
GO
ALTER TABLE [dbo].[homework_students]  WITH CHECK ADD  CONSTRAINT [FK_homework_students_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[homework_students] CHECK CONSTRAINT [FK_homework_students_users]
GO
ALTER TABLE [dbo].[homeworks]  WITH CHECK ADD  CONSTRAINT [FK_homeworks_subjects] FOREIGN KEY([subjectid])
REFERENCES [dbo].[subjects] ([id])
GO
ALTER TABLE [dbo].[homeworks] CHECK CONSTRAINT [FK_homeworks_subjects]
GO
ALTER TABLE [dbo].[homeworks]  WITH CHECK ADD  CONSTRAINT [FK_homeworks_users] FOREIGN KEY([creator])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[homeworks] CHECK CONSTRAINT [FK_homeworks_users]
GO
ALTER TABLE [dbo].[leaves_allocated]  WITH CHECK ADD  CONSTRAINT [FK_leaves_allocateds_leaves] FOREIGN KEY([type])
REFERENCES [dbo].[leaves] ([id])
GO
ALTER TABLE [dbo].[leaves_allocated] CHECK CONSTRAINT [FK_leaves_allocateds_leaves]
GO
ALTER TABLE [dbo].[leaves_allocated]  WITH CHECK ADD  CONSTRAINT [FK_leaves_allocateds_users] FOREIGN KEY([staffid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[leaves_allocated] CHECK CONSTRAINT [FK_leaves_allocateds_users]
GO
ALTER TABLE [dbo].[leaves_taken]  WITH CHECK ADD  CONSTRAINT [FK_leaves_taken_leaves_allocateds] FOREIGN KEY([allocatedid])
REFERENCES [dbo].[leaves_allocated] ([id])
GO
ALTER TABLE [dbo].[leaves_taken] CHECK CONSTRAINT [FK_leaves_taken_leaves_allocateds]
GO
ALTER TABLE [dbo].[leaves_taken]  WITH CHECK ADD  CONSTRAINT [FK_leaves_taken_users] FOREIGN KEY([staffid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[leaves_taken] CHECK CONSTRAINT [FK_leaves_taken_users]
GO
ALTER TABLE [dbo].[messages]  WITH CHECK ADD  CONSTRAINT [FK_messages_users] FOREIGN KEY([receiver])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[messages] CHECK CONSTRAINT [FK_messages_users]
GO
ALTER TABLE [dbo].[registration_notifications]  WITH CHECK ADD  CONSTRAINT [FK_registration_notifications_users] FOREIGN KEY([userid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[registration_notifications] CHECK CONSTRAINT [FK_registration_notifications_users]
GO
ALTER TABLE [dbo].[registrations]  WITH CHECK ADD  CONSTRAINT [FK_registrations_school_years] FOREIGN KEY([schoolyearid])
REFERENCES [dbo].[school_years] ([id])
GO
ALTER TABLE [dbo].[registrations] CHECK CONSTRAINT [FK_registrations_school_years]
GO
ALTER TABLE [dbo].[registrations]  WITH CHECK ADD  CONSTRAINT [FK_registrations_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[registrations] CHECK CONSTRAINT [FK_registrations_schools]
GO
ALTER TABLE [dbo].[registrations]  WITH CHECK ADD  CONSTRAINT [FK_registrations_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[registrations] CHECK CONSTRAINT [FK_registrations_users]
GO
ALTER TABLE [dbo].[registrations]  WITH CHECK ADD  CONSTRAINT [FK_registrations_users1] FOREIGN KEY([applicantid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[registrations] CHECK CONSTRAINT [FK_registrations_users1]
GO
ALTER TABLE [dbo].[registrations]  WITH CHECK ADD  CONSTRAINT [FK_registrations_users2] FOREIGN KEY([reviewer])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[registrations] CHECK CONSTRAINT [FK_registrations_users2]
GO
ALTER TABLE [dbo].[school_classes]  WITH CHECK ADD  CONSTRAINT [FK_levels_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[school_classes] CHECK CONSTRAINT [FK_levels_schools]
GO
ALTER TABLE [dbo].[school_classes]  WITH CHECK ADD  CONSTRAINT [FK_school_classes_school_classes] FOREIGN KEY([nextclass])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[school_classes] CHECK CONSTRAINT [FK_school_classes_school_classes]
GO
ALTER TABLE [dbo].[school_classes]  WITH CHECK ADD  CONSTRAINT [FK_school_classes_school_years] FOREIGN KEY([schoolyearid])
REFERENCES [dbo].[school_years] ([id])
GO
ALTER TABLE [dbo].[school_classes] CHECK CONSTRAINT [FK_school_classes_school_years]
GO
ALTER TABLE [dbo].[school_terms]  WITH CHECK ADD  CONSTRAINT [FK_school_exams_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[school_terms] CHECK CONSTRAINT [FK_school_exams_schools]
GO
ALTER TABLE [dbo].[school_years]  WITH CHECK ADD  CONSTRAINT [FK_school_years_grades_methods] FOREIGN KEY([grademethodid])
REFERENCES [dbo].[grades_methods] ([id])
GO
ALTER TABLE [dbo].[school_years] CHECK CONSTRAINT [FK_school_years_grades_methods]
GO
ALTER TABLE [dbo].[school_years]  WITH CHECK ADD  CONSTRAINT [FK_school_years_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[school_years] CHECK CONSTRAINT [FK_school_years_schools]
GO
ALTER TABLE [dbo].[siblings]  WITH CHECK ADD  CONSTRAINT [FK_siblings_users] FOREIGN KEY([otherid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[siblings] CHECK CONSTRAINT [FK_siblings_users]
GO
ALTER TABLE [dbo].[siblings]  WITH CHECK ADD  CONSTRAINT [FK_siblings_users1] FOREIGN KEY([siblingid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[siblings] CHECK CONSTRAINT [FK_siblings_users1]
GO
ALTER TABLE [dbo].[students_disciplines]  WITH CHECK ADD  CONSTRAINT [FK_disciplines_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[students_disciplines] CHECK CONSTRAINT [FK_disciplines_users]
GO
ALTER TABLE [dbo].[students_disciplines]  WITH CHECK ADD  CONSTRAINT [FK_disciplines_users1] FOREIGN KEY([creator])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[students_disciplines] CHECK CONSTRAINT [FK_disciplines_users1]
GO
ALTER TABLE [dbo].[students_disciplines]  WITH CHECK ADD  CONSTRAINT [FK_students_disciplines_conducts] FOREIGN KEY([type])
REFERENCES [dbo].[conducts] ([id])
GO
ALTER TABLE [dbo].[students_disciplines] CHECK CONSTRAINT [FK_students_disciplines_conducts]
GO
ALTER TABLE [dbo].[students_guardians]  WITH CHECK ADD  CONSTRAINT [FK_students_guardians_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[students_guardians] CHECK CONSTRAINT [FK_students_guardians_users]
GO
ALTER TABLE [dbo].[students_guardians]  WITH CHECK ADD  CONSTRAINT [FK_students_guardians_users1] FOREIGN KEY([parentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[students_guardians] CHECK CONSTRAINT [FK_students_guardians_users1]
GO
ALTER TABLE [dbo].[students_remarks]  WITH CHECK ADD  CONSTRAINT [FK_students_remarks_school_exams] FOREIGN KEY([term])
REFERENCES [dbo].[school_terms] ([id])
GO
ALTER TABLE [dbo].[students_remarks] CHECK CONSTRAINT [FK_students_remarks_school_exams]
GO
ALTER TABLE [dbo].[students_remarks]  WITH CHECK ADD  CONSTRAINT [FK_students_remarks_users] FOREIGN KEY([studentid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[students_remarks] CHECK CONSTRAINT [FK_students_remarks_users]
GO
ALTER TABLE [dbo].[subject_teachers]  WITH CHECK ADD  CONSTRAINT [FK_subject_teachers_school_classes] FOREIGN KEY([classid])
REFERENCES [dbo].[school_classes] ([id])
GO
ALTER TABLE [dbo].[subject_teachers] CHECK CONSTRAINT [FK_subject_teachers_school_classes]
GO
ALTER TABLE [dbo].[subject_teachers]  WITH CHECK ADD  CONSTRAINT [FK_subject_teachers_subjects] FOREIGN KEY([subjectid])
REFERENCES [dbo].[subjects] ([id])
GO
ALTER TABLE [dbo].[subject_teachers] CHECK CONSTRAINT [FK_subject_teachers_subjects]
GO
ALTER TABLE [dbo].[subject_teachers]  WITH CHECK ADD  CONSTRAINT [FK_subject_teachers_users] FOREIGN KEY([teacherid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[subject_teachers] CHECK CONSTRAINT [FK_subject_teachers_users]
GO
ALTER TABLE [dbo].[subjects]  WITH CHECK ADD  CONSTRAINT [FK_subjects_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[subjects] CHECK CONSTRAINT [FK_subjects_schools]
GO
ALTER TABLE [dbo].[user_files]  WITH CHECK ADD  CONSTRAINT [FK_user_files_users] FOREIGN KEY([userid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[user_files] CHECK CONSTRAINT [FK_user_files_users]
GO
ALTER TABLE [dbo].[user_parents]  WITH CHECK ADD  CONSTRAINT [FK_user_parents_users] FOREIGN KEY([userid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[user_parents] CHECK CONSTRAINT [FK_user_parents_users]
GO
ALTER TABLE [dbo].[user_staff]  WITH CHECK ADD  CONSTRAINT [FK_user_staff_users] FOREIGN KEY([userid])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[user_staff] CHECK CONSTRAINT [FK_user_staff_users]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_images] FOREIGN KEY([photo])
REFERENCES [dbo].[user_images] ([id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_images]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_users_schools] FOREIGN KEY([schoolid])
REFERENCES [dbo].[schools] ([id])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_users_schools]
GO
USE [master]
GO
ALTER DATABASE [t3stdata] SET  READ_WRITE 
GO
