USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_BenchmarksSources]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_BenchmarksSources]
GO


CREATE TABLE [dbo].[tbl_BenchmarksSources](
                [ID] [int] IDENTITY(1,1) NOT NULL,
                [ShortName] [nvarchar](10) NOT NULL,
                [LongName] [nvarchar](100) NULL,
 	CONSTRAINT [tbl_BenchmarksSources_PK] PRIMARY KEY NONCLUSTERED 
(
                [ID]
) ON [PRIMARY]
) ON [PRIMARY]

GO

