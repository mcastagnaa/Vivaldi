USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_Benchmarks]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_Benchmarks]
GO

CREATE TABLE [dbo].[tbl_Benchmarks](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShortName] [nvarchar](10) NOT NULL,
	[LongName] [nvarchar](100) NULL,
	[IsPortfolio] bit DEFAULT 0 NOT NULL,
	[SourceId] int DEFAULT 0 NOT NULL,
	[UpdateFreqDays] int DEFAULT 7 NOT NULL,
	[FileName] nvarchar (15) NULL,
	[CCY] nvarchar (3) DEFAULT 'USD' NOT NULL, 
 CONSTRAINT [tbl_Benchmarks_PK] PRIMARY KEY NONCLUSTERED 

(
                [ID]
) ON [PRIMARY]
) ON [PRIMARY]
GO

