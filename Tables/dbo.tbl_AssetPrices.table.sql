USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_AssetPrices]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_AssetPrices]
GO

CREATE TABLE [dbo].[tbl_AssetPrices](
	[PriceDate] datetime NOT NULL,
	[SecurityId] nvarchar (30) NOT NULL,
	[SecurityType] nvarchar (30) NOT NULL,
	[Description] nvarchar (30) NULL,
	[Multiplier] float NULL,
	[CcyIso] [nvarchar] (3) NOT NULL,
	[PxLast] float NULL,
	[Accrual] float NULL,
	[DivBy100] bit NULL,
	[CountryISO] nvarchar (10) NULL,
	[IndustrySector] nvarchar (40) NULL,
	[IndustryGroup] nvarchar (40) NULL,
	[VolumeAvg20d] float NULL,
	[SPRating] nvarchar (30) NULL,
	[ShortName] nvarchar (30) NULL,
	[YearsToMaturity] float NULL,
	[MarketStatus] nvarchar (10) NULL,
	[IDBloomberg] nvarchar (30) NULL,
	[TotalReturnEq] float NULL,
	[Accrual1dBond] float NULL,
	[SecurityGroup] nvarchar (30) NULL,
	
 CONSTRAINT [tbl_AssetPrices_PK] PRIMARY KEY NONCLUSTERED 
(
	[PriceDate] ASC,
	[SecurityId] ASC,
	[SecurityType] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO