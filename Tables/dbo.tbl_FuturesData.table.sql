USE [Vivaldi]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_FuturesData]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_FuturesData]
GO

CREATE TABLE [dbo].[tbl_FuturesData](
	[PriceDate] datetime NOT NULL,
	[FuturesId] nvarchar (30) NOT NULL,
	[ContractSize] float NOT NULL,
	[Category] nvarchar (30) NOT NULL,
	[PointValue] float NOT NULL,
	[TickSize] float NOT NULL,
	[TickValue] float NOT NULL,
	[InitialMargin] float NOT NULL

 CONSTRAINT [tbl_FuturesData_PK] PRIMARY KEY NONCLUSTERED 
(
	[PriceDate] ASC,
	[FuturesId] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO