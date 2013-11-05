USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_EnumScenFiles]') 
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_EnumScenFiles]
GO

CREATE TABLE [dbo].[tbl_EnumScenFiles](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar] (15) NOT NULL,
	[ScenId] INT NOT NULL,
	[LastUpdate] DATETIME NULL,
	[FundId] INT NOT NULL,
	[IsRelative] BIT DEFAULT 0 NOT NULL,
 CONSTRAINT [tbl_EnumScenFiles_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO