USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
SELECT	* 
FROM	dbo.sysobjects 
WHERE	id = OBJECT_ID(N'[dbo].[tbl_ZScores]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
)
DROP TABLE [dbo].[tbl_ZScores]
GO

CREATE TABLE [dbo].[tbl_ZScores](
	[Probability] float NOT NULL,
	[ZScore] float NOT NULL,
 CONSTRAINT [tbl_ZScores_PK] PRIMARY KEY NONCLUSTERED 
(
	[Probability] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO