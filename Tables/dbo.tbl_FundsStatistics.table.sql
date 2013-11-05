USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_FundsStatistics]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_FundsStatistics]
GO

CREATE TABLE [dbo].[tbl_FundsStatistics](
	FundId INT NOT NULL
	, StatsDate datetime NOT NULL
	, PortfBeta float NULL
	, PortfBetaEqOnly float NULL
	, PortfBetaLong float NULL
	, PortfBetaShort float NULL
	, AvgDaysToLiquidate float NULL
	, RoE float NULL
	, RoEEqOnly float NULL
	, PortfRoELong float NULL
	, PortfRoEShort float NULL
	, EPSGrowth float NULL
	, EPSGrowthEqOnly float NULL
	, PortfEPSLong float NULL
	, PortfEPSShort float NULL
	, SalesGrowth float NULL
	, SalesGrowthEqOnly float NULL
	, PortfSalesLong float NULL
	, PortfSalesShort float NULL
	, BookToPrice float NULL
	, BookToPriceEqOnly float NULL
	, PortfBtPLong float NULL
	, PortfBtPShort float NULL
	, DivYield float NULL
	, DivYieldEqOnly float NULL
	, PortfDYLong float NULL
	, PortfDYShort float NULL
	, EarnYield float NULL
	, EarnYieldEqOnly float NULL
	, PortfEarnLong float NULL
	, PortfEarnShort float NULL
	, SalesToP float NULL
	, SalesToPEqOnly float NULL
	, PortfStPLong float NULL
	, PortfStPShort float NULL
	, EbitdaToP float NULL
	, EbitdaToPEqOnly float NULL
	, EbitdaToPLong float NULL
	, EbitdaToPShort float NULL
	, MarketCapUSDMn float NULL
	, MktCapUSDLong float NULL
	, MktCapUSDShort float NULL
	, YearsToMaturity float NULL
	, ManualPrices int NULL
	, KRD3m float NULL
	, KRD6m float NULL
	, KRD1y float NULL
	, KRD2y float NULL
	, KRD3y float NULL
	, KRD4y float NULL
	, KRD5y float NULL
	, KRD6y float NULL
	, KRD7y float NULL
	, KRD8y float NULL
	, KRD9y float NULL
	, KRD10y float NULL
	, KRD15y float NULL
	, KRD20y float NULL
	, KRD25y float NULL
	, KRD30y float NULL
	, EffDur float NULL
	, InflDur float NULL
	, RealDur float NULL
	, InvGrade float NULL
	, HiYield float NULL
	, NotRated float NULL
	, AverageRating float NULL
	, CleanRating nvarchar(30) NULL
	, InflationBonds float NULL
	, GovernmentBonds float NULL
	, Corporate  float NULL
	, Mortgage float null
	, Preferred float null
	, Municipals float null
	, PLPositives float null
	, PLAverage float null

, CONSTRAINT [tbl_FundsStatistics_PK] PRIMARY KEY NONCLUSTERED 

(
                [FundId],
		[StatsDate]
) ON [PRIMARY]
) ON [PRIMARY]
GO

