USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CalcFundStatistics]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CalcFundStatistics]
GO

CREATE PROCEDURE [dbo].[spS_CalcFundStatistics] 
	@RefDate datetime
	, @FundId int
	, @LiqPerc float
AS

SET NOCOUNT ON;


CREATE TABLE #RawDataTmp (
	SecurityGroup		nvarchar(30)
	, PostionValue		float 
	, FundBaseCCYCode 	nvarchar(3)
	, BMISCode             	nvarchar(30)
	, BBGTicker		nvarchar(40)  
	, AssetCCY		nvarchar(3)
	, PositionSize		float                           
	, StartPrice		float                           
	, MarketPrice		float                           
	, AssetEffect		float                           
	, FxEffect		float                           
	, PortfolioShare	float                           
	, AssetPL		float                           
	, FxPL			float                           
	, PositionPL		float                           
	, BpPositionPL		float                           
	, MargVaRPerc		float                     
	, CountryISO		nvarchar(10)
	, CountryName		nvarchar(100)                                                                   
	, CountryRegionName	nvarchar(100)                                                                   
	, IndustrySector	nvarchar(40)       
	, IndustryGroup		nvarchar(40)       
	, SPCleanRating		nvarchar(30)      
	, SPRatingRank		int
	, BondYearsToMaturity	float                      
	, EquityMarketStatus	nvarchar(10)
	, LongShort		nvarchar(20)
	, DaysToLiquidate	float                           
	, RiskOnPtflSh		float                           
	, PlOnRisk		float                           
	, Beta			float                    
	, Size			nvarchar(30)
	, Value			nvarchar(30)
	, IsManualPrice		bit
	, ROE			float
	, EPSGrowth		float
	, SalesGrowth		float
	, BtP			float
	, DivYield		float
	, EarnYield		float
	, StP			float
	, EbitdaTP		float
	, MktCapLocal		float
	, MktCapUSD		float
	, KRD3m			float
	, KRD6m			float
	, KRD1y			float
	, KRD2y			float
	, KRD3y			float
	, KRD4y			float
	, KRD5y			float
	, KRD6y			float
	, KRD7y			float
	, KRD8y			float
	, KRD9y			float
	, KRD10y		float
	, KRD15y		float
	, KRD20y		float
	, KRD25y		float
	, KRD30y		float
	, EffDur		float
	, InflDur		float
	, RealDur		float
	, SpreadDur		float
	, CoupType		nvarchar(30)
	, Bullet		bit
	, SecType		nvarchar(30)
	, CollType		nvarchar(30)
	, MktSector		nvarchar(20)
	, ShortMom		float
	, UpDown		nvarchar(5)
	, AssetPlBps		float
	, FxPlBps		float
	, Delta			float
	, Underlying		nvarchar(30)
	, UnderSize		float
	, UnderNotional		float
	)	

------------------------------------------------------------------------------------------

INSERT INTO #RawDataTmp
EXEC spS_GenerateFundDetailsByDate @RefDate, @FundID, @LiqPerc


------------------------------------------------------------------------------------------

SELECT	RData.*
	, PortfolioShare * 
		ISNULL(UnderNotional, 
			NULLIF(RData.PostionValue,0)) / 
		NULLIF(RData.PostionValue,0) 
		AS PortfolioShareAdj 

INTO	#RawData 

FROM	#RawDataTmp AS RData LEFT JOIN
	vw_FxQuotes AS AssetFxData ON (AssetFxData.FxQuoteDate = @RefDate
		AND AssetFxData.ISO = RData.AssetCCY) LEFT JOIN
	vw_FxQuotes AS BaseFxData ON (BaseFxData.FxQuoteDate = @RefDate
		AND BaseFxData.ISO = RData.FundBaseCCYCode)

------------------------------------------------------------------------------------------



SELECT	@FundId AS FundId
	, @RefDate AS StatsDate

	-- EQUITIES STATISTICS --
-------------------------------------------------
--- BETAs
	, SUM(Beta * PortfolioShareAdj) AS PortfBeta
	, SUM(Beta * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS PortfBetaEqOnly
	, SUM(Beta * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0)
		AS PortfBetaLong
	, SUM(Beta * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0)
		AS PortfBetaShort
--- DaysToLiquidate
	, SUM(CASE WHEN MktSector = 'Equity' THEN DaysToLiquidate * ABS(PortfolioShareAdj) 
			ELSE 0 END) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ABS(PortfolioShareAdj)
			ELSE 0 END),0)
		AS AvgDaysToLiquidate
--- ROEs
	, SUM(ROE * PortfolioShareAdj) AS RoE
	, SUM(ROE * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END) ,0)
		AS RoEEqOnly
	, SUM(ROE * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfRoELong
	, SUM(ROE * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0)
		AS PortfRoEShort
--- EPSs
	, SUM(EpsGrowth * PortfolioShareAdj) AS EPSGrowth
	, SUM(EPSGrowth * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj 
			ELSE 0 END),0)
		AS EPSGrowthEqOnly
	, SUM(EpsGrowth * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0)  
		AS PortfEPSLong
	, SUM(EpsGrowth * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfEPSShort

--- SalesGrowths
	, SUM(SalesGrowth * PortfolioShareAdj) AS SalesGrowth
	, SUM(SalesGrowth * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS SalesGrowthEqOnly
	, SUM(SalesGrowth * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfSalesLong
	, SUM(SalesGrowth * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfSalesShort

--- BtPs
	, SUM(BtP * PortfolioShareAdj) AS BookToPrice
	, SUM(BtP * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS BookToPriceEqOnly
	, SUM(BtP * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfBtPLong
	, SUM(Btp * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfBtPShort

--- DivYields
	, SUM(DivYield * PortfolioShareAdj)  AS DivYield
	, SUM(DivYield * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS DivYieldEqOnly
	, SUM(DivYield * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfDYLong
	, SUM(DivYield * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfDYShort


--- EarnYields
	, SUM(EarnYield * PortfolioShareAdj) AS EarnYield
	, SUM(EarnYield * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS EarnYieldEqOnly
	, SUM(EarnYield * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfEarnLong
	, SUM(EarnYield * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfEarnShort

--- SalesToPrices
	, SUM(StP * PortfolioShareAdj)  AS SalesToP
	, SUM(StP * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS SalesToPEqOnly
	, SUM(StP * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfStPLong
	, SUM(StP * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS PortfStPShort

--- EbitdaToPrices
	, SUM(EbitdaTP * PortfolioShareAdj)  AS EbitdaToP
	, SUM(EbitdaTP * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		AS EbitdaToPEqOnly
	, SUM(EbitdaTP * (CASE WHEN PortfolioShareAdj > 0 THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS EbitdaToPLong
	, SUM(EbitdaTP * (CASE WHEN PortfolioShareAdj < 0 THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS EbitdaToPShort


--- MarketSizes
	, SUM(CASE WHEN MktSector = 'Equity' THEN MktCapUSD * ABS(PortfolioShareAdj) 
			ELSE 0 END)
			/
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ABS(PortfolioShareAdj) 
			ELSE 0 END),0)
		AS MarketCapUSDMn
	, SUM(MktCapUSD * (CASE WHEN (MktSector = 'Equity' AND PortfolioShareAdj > 0) THEN PortfolioShareAdj ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj > 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS MktCapUSDLong
	, SUM(MktCapUSD * (CASE WHEN (MktSector = 'Equity' AND PortfolioShareAdj < 0) THEN PortfolioShareAdj ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (PortfolioShareAdj < 0 AND MktSector = 'Equity') 
			THEN PortfolioShareAdj ELSE 0 END)),0) 
		AS MktCapUSDShort

	-- FINCOME STATISTICS --
-------------------------------------------------
	, SUM(BondYearsToMaturity * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN MktSector <> 'Equity' THEN PortfolioShareAdj
			ELSE 0 END),0)
		 AS YearsToMaturity
	, SUM(CAST(IsManualPrice AS INT)) AS ManualPrices

	, SUM(KRD3m * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END), 0)
		 AS KRD3m
	, SUM(KRD6m * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		 AS KRD6m
	, SUM(KRD1y * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD1y
	, SUM(KRD2y * PortfolioShareAdj)  /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD2y
	, SUM(KRD3y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD3y
	, SUM(KRD4y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD4y
	, SUM(KRD5y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD5y
	, SUM(KRD6y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD6y
	, SUM(KRD7y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD7y
	, SUM(KRD8y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD8y
	, SUM(KRD9y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD9y
	, SUM(KRD10y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD10y
	, SUM(KRD15y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD15y
	, SUM(KRD20y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD20y
	, SUM(KRD25y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD25y
	, SUM(KRD30y * PortfolioShareAdj) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'FixedIn' THEN PortfolioShareAdj ELSE 0 END),	0)
		AS KRD30y
	, SUM(EffDur * PortfolioShareAdj) AS EffDur
	, SUM(InflDur * PortfolioShareAdj) AS InflDur
	, SUM(RealDur * PortfolioShareAdj) AS RealDur
	, SUM(SpreadDur * PortfolioShareAdj) AS SpreadDur
	, SUM(CAST(Bullet AS INT) * PortfolioShareAdj) AS BulletBonds
	, SUM(CASE WHEN SPRatingRank <= 10 AND MktSector <> 'Commodity' THEN PortfolioShareAdj ELSE 0 END) AS InvGrade
	, SUM(CASE WHEN (SPRatingRank > 10 AND SPRatingRank <= 22 AND MktSector <> 'Commodity') THEN PortfolioShareAdj ELSE 0 END) AS HiYield
	, SUM(CASE WHEN (SPRatingRank > 22 AND MktSector NOT IN ('Equity', 'Currency', 'Commodity')) THEN PortfolioShareAdj ELSE 0 END) AS NotRated
	, SUM(SPRatingRank * (CASE WHEN SPRatingRank <= 22 AND MktSector <> 'Commodity' THEN PortfolioShareAdj ELSE 0 END)) / 
		NULLIF(SUM(CASE WHEN SPRatingRank <= 22 AND MktSector <> 'Commodity' THEN PortfolioShareAdj ELSE 0 END),0) AS AverageRating
	, SUM(CASE WHEN InflDur > 0 THEN PortfolioShareAdj ELSE 0 END) AS InflationBonds
	, SUM(CASE WHEN MktSector = 'Government' THEN PortfolioShareAdj ELSE 0 END) AS GovernmentBonds
	, SUM(CASE WHEN MktSector = 'Corporate' THEN PortfolioShareAdj ELSE 0 END) AS Corporate
	, SUM(CASE WHEN MktSector = 'Mortgage' THEN PortfolioShareAdj ELSE 0 END) AS Mortgage
	, SUM(CASE WHEN MktSector = 'Preferred' THEN PortfolioShareAdj ELSE 0 END) AS Preferred
	, SUM(CASE WHEN MktSector = 'Municipals' THEN PortfolioShareAdj ELSE 0 END) AS Municipals


INTO	#Statistics
	
FROM 	#RawData
------------------------------------------------------------------------------------------

SELECT 	TOP 5 PL.TotalPL/PL.CostNaV AS PLPerc
INTO	#LastPls
FROM	tbl_FundsNaVsAndPLs AS PL
WHERE		FundId = @FundID
GROUP BY	PL.NaVPLDate
		, PL.TotalPL
		, PL.CostNaV
ORDER BY	PL.NaVPLDate DESC

------------------------------------------------------------------------------------------

SELECT	 SUM(CASE WHEN LastPls.PLPerc < 0 THEN 0 ELSE 1 END) AS PLPositives
	, AVG(LastPls.PLPerc) AS PLAverage
INTO #PLs
FROM #LastPLs AS LastPls

------------------------------------------------------------------------------------------
SELECT	MAX(Ratings.CleanRating) AS CleanRating

INTO #Rate

FROM	#Statistics AS FStats JOIN
	tbl_SPRatingsCodes AS Ratings ON (
		ROUND(FStats.AverageRating,0) = Ratings.RankNo
		)


------------------------------------------------------------------------------------------

SELECT	FStats.FundId
	, FStats.StatsDate
	, FStats.PortfBeta
	, FStats.PortfBetaEqOnly
	, FStats.PortfBetaLong
	, FStats.PortfBetaShort
	, FStats.AvgDaysToLiquidate
	, FStats.RoE
	, FStats.RoEEqOnly
	, FStats.PortfRoELong
	, FStats.PortfRoEShort
	, FStats.EPSGrowth
	, FStats.EPSGrowthEqOnly
	, FStats.PortfEPSLong
	, FStats.PortfEPSShort
	, FStats.SalesGrowth
	, FStats.SalesGrowthEqOnly
	, FStats.PortfSalesLong
	, FStats.PortfSalesShort
	, FStats.BookToPrice
	, FStats.BookToPriceEqOnly
	, FStats.PortfBtPLong
	, FStats.PortfBtPShort
	, FStats.DivYield
	, FStats.DivYieldEqOnly
	, FStats.PortfDYLong
	, FStats.PortfDYShort
	, FStats.EarnYield
	, FStats.EarnYieldEqOnly
	, FStats.PortfEarnLong
	, FStats.PortfEarnShort
	, FStats.SalesToP
	, FStats.SalesToPEqOnly
	, FStats.PortfStPLong
	, FStats.PortfStPShort
	, FStats.EbitdaToP
	, FStats.EbitdaToPEqOnly
	, FStats.EbitdaToPLong
	, FStats.EbitdaToPShort
	, FStats.MarketCapUSDMn
	, FStats.MktCapUSDLong
	, FStats.MktCapUSDShort
	, FStats.YearsToMaturity
	, FStats.ManualPrices
	, FStats.KRD3m
	, FStats.KRD6m
	, FStats.KRD1y
	, FStats.KRD2y
	, FStats.KRD3y
	, FStats.KRD4y
	, FStats.KRD5y
	, FStats.KRD6y
	, FStats.KRD7y
	, FStats.KRD8y
	, FStats.KRD9y
	, FStats.KRD10y
	, FStats.KRD15y
	, FStats.KRD20y
	, FStats.KRD25y
	, FStats.KRD30y
	, FStats.EffDur
	, FStats.InflDur
	, FStats.RealDur
	, FStats.SpreadDur
	, FStats.BulletBonds
	, FStats.InvGrade
	, FStats.HiYield
	, FStats.NotRated
	, FStats.AverageRating
	, Rate.CleanRating
	, FStats.InflationBonds
	, FStats.GovernmentBonds
	, FStats.Corporate
	, FStats.Mortgage
	, FStats.Preferred
	, FStats.Municipals
	, LastPLs.PLPositives
	, LastPLs.PLAverage

FROM	#Statistics AS FStats, #Rate AS Rate, #PLs AS LastPls

------------------------------------------------------------------------------------------
DROP TABLE #RawData
DROP TABLE #RawDataTmp
DROP TABLE #Statistics
DROP TABLE #LastPls
DROP TABLE #PLs
DROP TABLE #Rate
------------------------------------------------------------------------------------------

GO


GRANT EXECUTE ON spS_CalcFundStatistics TO [OMAM\StephaneD], [OMAM\MargaretA] 

