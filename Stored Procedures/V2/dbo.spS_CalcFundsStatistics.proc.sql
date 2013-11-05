USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_CalcFundsStatistics_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_CalcFundsStatistics_V2
GO

CREATE PROCEDURE dbo.spS_CalcFundsStatistics_V2
	@RefDate datetime
	, @FundId integer
	, @PercDayVol float

AS

SET NOCOUNT ON;


CREATE TABLE #PositionDets (
FundCode 		nvarchar(25)
,FundId 		integer
,SecurityGroup 		nvarchar(30)
,SecurityType 		nvarchar(30)
,IsDerivative 		bit
,BMISCode 		nvarchar(30)
,BBGTicker		nvarchar(40)
,Underlying 		nvarchar(40)
,CostMarketVal 		float
,Weight 		float
,CostExposureVal 	float
,ExpWeight 		float
,ExpWeightBetaAdj 	float
,AssetCCY 		nvarchar(3)
,PositionSize 		float
,StartPrice 		float
,MarketPrice 		float
,AssetChange 		float
,FxChange 		float
,AssetPL 		float
,FxPL 			float
,TotalPL 		float
,AssetPLOnNaV 		float
,FXPLOnNaV 		float
,PLOnNaV 		float
,AssetPLonTotalPL 	float
,FxPLonTotalPL 		float
,PLOnTotalPL 		float
,CountryISO 		nvarchar(10)
,CountryName		nvarchar(100)
,CountryRegion 		nvarchar(100)
,IndustrySector 	nvarchar(40)
,IndustryGroup 		nvarchar(40)
,SPCleanRating 		nvarchar(30)
,SPRatingRank 		integer
,YearsToMat 		float
,EquityMktStatus 	nvarchar(10)
,LongShort 		nvarchar(20)
,DaysToLiquidate 	float
,Beta 			float
,Size 			nvarchar(10)
,Value 			nvarchar(10)
,IsManualPrice 		bit
,ROE 			float
,EPSGrowth 		float
,SalesGrowth 		float
,BtP 			float
,DivYield 		float
,EarnYield 		float
,StP 			float
,EbitdaTP 		float
,MktCapLocal 		float
,MktCapUSD 		float
,KRD3m 			float
,KRD6m 			float
,KRD1y 			float
,KRD2y 			float
,KRD3y 			float
,KRD4y 			float
,KRD5y 			float
,KRD6y 			float
,KRD7y 			float
,KRD8y 			float
,KRD9y 			float
,KRD10y 		float
,KRD15y 		float
,KRD20y 		float
,KRD25y 		float
,KRD30y 		float
,EffDur 		float
,InflDur 		float
,RealDur 		float
,SpreadDur 		float
,OAS 			float
,CnvYield 		float
,CoupType 		nvarchar(30)
,IsBullet 		bit
,SecType 		nvarchar(30)
,CollType 		nvarchar(30)
,MktSector 		nvarchar(20)
,ShortMom 		float
,CDSPayFreq		nvarchar(1)
,CDSMaturityDate	datetime
,CDSRecRate		float
,CDSNotionalSpread	float
,CDSMktSpread		float
,CDSMktPremium		float
,CDSAccrued 		float
,CDSModel		nvarchar(1)
,CDSPrevPremium 	float
,UpDown 		nvarchar(4)
,OptDelta 		float
,OptGamma 		float
,OptVega 		float
,OptDaysToExp 		integer
,MarginLocal		float
,MarginBase		float
,MarginBaseOnNaV	float
,BBGId			nvarchar(30)
,AllExpWeights		float
,FundClass		nvarchar(30)
,FundIsAlive		bit
,FundIsSkip		bit
,FundBaseCCY		nvarchar(3)
,IsCCYExp		bit
,IsEM			bit
,IsHY			bit
,PositionDate		datetime
)
----------------------------------------------------------------------------------
INSERT INTO #PositionDets
EXEC spS_GetFundsDetailsByDate_V2 @RefDate, @FundId, @PercDayVol
----------------------------------------------------------------------------------


SELECT	FundCode
	, FundId
	, @RefDate AS StatsDate

	-- EQUITIES STATISTICS --
-------------------------------------------------
--- BETAs
	, SUM(Beta * (CASE WHEN SecurityGroup = 'Equities' THEN ExpWeight ELSE NULL END)) AS PortfBeta
	, SUM(Beta * (CASE WHEN SecurityGroup = 'Equities' THEN ExpWeight ELSE NULL END)) /
		NULLIF(SUM(CASE WHEN SecurityGroup = 'Equities' THEN ExpWeight
			ELSE 0 END),0)
		AS PortfBetaEqOnly
	, SUM(NULLIF(Beta, 0) * (CASE WHEN ExpWeight > 0 AND SecurityGroup = 'Equities' THEN ExpWeight ELSE NULL END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND SecurityGroup = 'Equities') 
			THEN ExpWeight ELSE 0 END)),0)
		AS PortfBetaLong
	, SUM(Beta * (CASE WHEN ExpWeight < 0 AND SecurityGroup = 'Equities' THEN ExpWeight ELSE NULL END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND SecurityGroup = 'Equities') 
			THEN ExpWeight ELSE 0 END)),0)
		AS PortfBetaShort
--- DaysToLiquidate
	, SUM(CASE WHEN MktSector = 'Equity' THEN DaysToLiquidate * ABS(ExpWeight) 
			ELSE 0 END) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ABS(ExpWeight)
			ELSE 0 END),0)
		AS AvgDaysToLiquidate
--- ROEs
	, SUM(ROE * ExpWeight) AS RoE
	, SUM(ROE * ExpWeight) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END) ,0)
		AS RoEEqOnly
	, SUM(ROE * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfRoELong
	, SUM(ROE * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0)
		AS PortfRoEShort
--- EPSs
	, SUM(EpsGrowth * ExpWeight) AS EPSGrowth
	, SUM(EPSGrowth * ExpWeight)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS EPSGrowthEqOnly
	, SUM(EpsGrowth * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0)  
		AS PortfEPSLong
	, SUM(EpsGrowth * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfEPSShort

--- SalesGrowths
	, SUM(SalesGrowth * ExpWeight) AS SalesGrowth
	, SUM(SalesGrowth * ExpWeight)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS SalesGrowthEqOnly
	, SUM(SalesGrowth * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfSalesLong
	, SUM(SalesGrowth * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfSalesShort

--- BtPs
	, SUM(BtP * ExpWeight) AS BookToPrice
	, SUM(BtP * ExpWeight) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS BookToPriceEqOnly
	, SUM(BtP * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfBtPLong
	, SUM(Btp * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfBtPShort

--- DivYields
	, SUM(DivYield * ExpWeight)  AS DivYield
	, SUM(DivYield * ExpWeight)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS DivYieldEqOnly
	, SUM(DivYield * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfDYLong
	, SUM(DivYield * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfDYShort


--- EarnYields
	, SUM(EarnYield * ExpWeight) AS EarnYield
	, SUM(EarnYield * ExpWeight)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS EarnYieldEqOnly
	, SUM(EarnYield * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfEarnLong
	, SUM(EarnYield * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfEarnShort

--- SalesToPrices
	, SUM(StP * ExpWeight)  AS SalesToP
	, SUM(StP * ExpWeight)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS SalesToPEqOnly
	, SUM(StP * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfStPLong
	, SUM(StP * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS PortfStPShort

--- EbitdaToPrices
	, SUM(EbitdaTP * ExpWeight)  AS EbitdaToP
	, SUM(EbitdaTP * ExpWeight)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ExpWeight
			ELSE 0 END),0)
		AS EbitdaToPEqOnly
	, SUM(EbitdaTP * (CASE WHEN ExpWeight > 0 THEN ExpWeight ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS EbitdaToPLong
	, SUM(EbitdaTP * (CASE WHEN ExpWeight < 0 THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
		AS EbitdaToPShort


--- MarketSizes
	, SUM(MktCapUSD * (CASE WHEN MktSector = 'Equity' THEN ABS(ExpWeight) 
			ELSE 0 END)) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ABS(ExpWeight) 
			ELSE 0 END),0)
	AS MarketCapUSDMn
	, SUM(MktCapUSD * (CASE WHEN (MktSector = 'Equity' AND ExpWeight > 0) THEN ExpWeight 
			ELSE 0 END))  /
		NULLIF(SUM((CASE WHEN (ExpWeight > 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
	AS MktCapUSDLong
	, SUM(MktCapUSD * (CASE WHEN (MktSector = 'Equity' AND ExpWeight < 0) THEN ExpWeight ELSE 0 END)) /
		NULLIF(SUM((CASE WHEN (ExpWeight < 0 AND MktSector = 'Equity') 
			THEN ExpWeight ELSE 0 END)),0) 
	AS MktCapUSDShort

	-- FINCOME STATISTICS --
-------------------------------------------------
	, SUM( YearsToMat * (CASE WHEN SecurityGroup IN ('FixedIn') THEN ExpWeight ELSE 0 END)
		) 
		/*/ NULLIF(SUM(CASE WHEN SecurityGroup IN ('FixedIn') THEN ExpWeight ELSE 0 END),0)*/
		 AS YearsToMaturity

	, SUM(CAST(IsManualPrice AS INT)) AS ManualPrices

	, SUM(KRD3m * ExpWeight) AS KRD3m
	, SUM(KRD6m * ExpWeight) AS KRD6m
	, SUM(KRD1y * ExpWeight) AS KRD1y
	, SUM(KRD2y * ExpWeight) AS KRD2y
	, SUM(KRD3y * ExpWeight) AS KRD3y
	, SUM(KRD4y * ExpWeight) AS KRD4y
	, SUM(KRD5y * ExpWeight) AS KRD5y
	, SUM(KRD6y * ExpWeight) AS KRD6y
	, SUM(KRD7y * ExpWeight) AS KRD7y
	, SUM(KRD8y * ExpWeight) AS KRD8y
	, SUM(KRD9y * ExpWeight) AS KRD9y
	, SUM(KRD10y * ExpWeight) AS KRD10y
	, SUM(KRD15y * ExpWeight) AS KRD15y
	, SUM(KRD20y * ExpWeight) AS KRD20y
	, SUM(KRD25y * ExpWeight) AS KRD25y
	, SUM(KRD30y * ExpWeight) AS KRD30y
	, SUM(EffDur * ExpWeight) AS EffDur
	, SUM(InflDur * ExpWeight) AS InflDur
	, SUM(RealDur * ExpWeight) AS RealDur
	, SUM(SpreadDur * ExpWeight) AS SpreadDur
	, SUM(OAS * ExpWeight) AS OAS
	, SUM(CnvYield * ExpWeight) AS CnvYield
	, SUM(CAST(IsBullet AS INT) * ExpWeight) AS BulletBonds
-- Ratings
	, SUM(	CASE WHEN SPRatingRank <= 10 
			AND MktSector <> 'Commodity' 
			AND SecurityGroup = 'FixedIn'
		THEN ExpWeight ELSE 0 
		END) AS InvGrade

	, SUM(	CASE WHEN SPRatingRank > 10 
			AND SPRatingRank <= 22 
			AND MktSector <> 'Commodity' 
			AND SecurityGroup = 'FixedIn'
		THEN ExpWeight ELSE 0 END) AS HiYield

	, SUM(	CASE WHEN SPRatingRank > 22 
			AND MktSector NOT IN ('Equity', 'Currency', 'Commodity')
			AND SecurityGroup = 'FixedIn'
		THEN ExpWeight ELSE 0 END) AS NotRated

	, SUM(SPRatingRank * (CASE WHEN SPRatingRank <= 22 
			AND MktSector <> 'Commodity' 
			AND SecurityGroup = 'FixedIn'
		THEN ExpWeight ELSE 0 END)) / 
		NULLIF(SUM(	CASE WHEN SPRatingRank <= 22 
					AND MktSector <> 'Commodity' 
					AND SecurityGroup = 'FixedIn'
				THEN ExpWeight ELSE 0 END),0) AS AverageRating


	, SUM(CASE WHEN InflDur > 0 THEN ExpWeight ELSE 0 END) AS InflationBonds
	, SUM(CASE WHEN MktSector = 'Government' THEN ExpWeight ELSE 0 END) AS GovernmentBonds
	, SUM(CASE WHEN MktSector = 'Corporate' THEN ExpWeight ELSE 0 END) AS Corporate
	, SUM(CASE WHEN MktSector = 'Mortgage' THEN ExpWeight ELSE 0 END) AS Mortgage
	, SUM(CASE WHEN MktSector = 'Preferred' THEN ExpWeight ELSE 0 END) AS Preferred
	, SUM(CASE WHEN MktSector = 'Municipals' THEN ExpWeight ELSE 0 END) AS Municipals


INTO	#Statistics
	
FROM 	#PositionDets

WHERE	FundIsAlive = 1
	AND FundIsSkip = 0

GROUP BY	FundCode
		, FundId
------------------------------------------------------------------------------------------

SELECT 	PL.FundId
	, PL.NaVPLDate
	, PL.TotalPL/PL.CostNaV AS PLPerc
INTO	#LastPls
FROM	tbl_FundsNaVsAndPLs AS PL

WHERE	PL.NaVPLDate IN (	SELECT TOP 5 NaVPLDate 
			FROM tbl_FundsNaVsAndPLs
			WHERE NaVPLDate <= @RefDate
			GROUP BY NaVPLDate 
			ORDER BY NaVPLDate DESC)

GROUP BY	FundId
		, PL.NaVPLDate
		, PL.TotalPL
		, PL.CostNaV

------------------------------------------------------------------------------------------

SELECT	FundId 
	, SUM(CASE WHEN LastPls.PLPerc < 0 THEN 0 ELSE 1 END) AS PLPositives
	, AVG(LastPls.PLPerc) AS PLAverage
INTO #PLs
FROM #LastPLs AS LastPls
GROUP BY FundId

---------------------------------------------------------------------------------

SELECT	FundId
	, MAX(Ratings.CleanRating) AS CleanRating

INTO	#Rate

FROM	#Statistics AS FStats JOIN
	tbl_SPRatingsCodes AS Ratings ON (
		ROUND(FStats.AverageRating,0) = Ratings.RankNo
		)
GROUP BY	FundId

---------------------------------------------------------------------------------

SELECT	FStats.FundCode
	, FStats.FundId
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
	, FStats.SpreadDur
	, FStats.BulletBonds
	, FStats.OAS
	, FStats.CnvYield

FROM	#Statistics AS FStats 
	LEFT JOIN #Rate AS Rate ON (
	FStats.FundId = Rate.FundId
		) LEFT JOIN 
	#PLs AS LastPls ON (
	FStats.FundId = LastPLs.FundId
		) 

---------------------------------------------------------------------------------

DROP TABLE #PositionDets
DROP TABLE #PLs
DROP TABLE #LastPLs
DROP TABLE #Rate

GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_CalcFundsStatistics_V2 TO [OMAM\StephaneD]