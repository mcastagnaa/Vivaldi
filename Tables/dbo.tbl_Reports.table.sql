USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_Reports]')
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_Reports]
GO

CREATE TABLE [dbo].[tbl_Reports](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShortName] [nvarchar](10) NOT NULL,
	[LongName] [nvarchar](30) NOT NULL,
	[FileName] [nvarchar](30) NOT NULL,
	[ReportType] INT NOT NULL,
	[EMailAddresses] [nvarchar] (100) NULL,
	[LastFileFolder] [nvarchar] (100) NULL,
	[HistFileFolder] [nvarchar] (100) NULL,
 CONSTRAINT [tbl_Reports_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO