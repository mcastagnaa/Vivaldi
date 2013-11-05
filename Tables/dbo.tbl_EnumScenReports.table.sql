USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_EnumScenReports]') 
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_EnumScenReports]
GO

CREATE TABLE [dbo].[tbl_EnumScenReports](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LetterCode] [nvarchar] (2) NOT NULL,
	[ScenarioName] [nvarchar](50) NOT NULL,
 CONSTRAINT [tbl_EnumScenReports_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO