USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_Limits]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_Limits]
GO

CREATE TABLE [dbo].[tbl_Limits](
	[LimitID] [int] NOT NULL,
	[FundID] [int] NOT NULL,
	[LowerBound] float NULL,
	[UpperBound] float NULL
 CONSTRAINT [tbl_Limits_PK] PRIMARY KEY NONCLUSTERED 
(
	[LimitID] ASC,
	[FundID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO