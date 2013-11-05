USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_FundsNavsAndPLs]') AND 
			OBJECTPROPERTY(id, N'IsUserTable') = 1
)
DROP TABLE [dbo].[tbl_FundsNavsAndPLs]
GO

CREATE TABLE [dbo].[tbl_FundsNavsAndPLs](
	[FundId] [int] NOT NULL,
	[NaVPLDate] datetime NOT NULL,
	[CostNaV] float NOT NULL,
	[MktNaVPrices] float NOT NULL,
	[MktNaV] float NOT NULL,
	[TotalPL] float NOT NULL
 CONSTRAINT [tbl_FundsNavsAndPLs_PK] PRIMARY KEY NONCLUSTERED 
(
	[FundId] ASC,
	[NaVPLDate] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO