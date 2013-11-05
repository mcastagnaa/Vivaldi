USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_NotionalNaVs]')
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_NotionalNaVs]
GO

CREATE TABLE [dbo].[tbl_NotionalNaVs] (
	[FundId] [int] NOT NULL ,
	[NaV] [float] NULL ,
 CONSTRAINT [tbl_NotionalNaVs_PK] PRIMARY KEY NONCLUSTERED 
(
	[FundId] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO