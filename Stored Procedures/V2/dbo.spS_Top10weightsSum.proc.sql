USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_Top10WeightsSum') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_Top10WeightsSum
GO

CREATE PROCEDURE dbo.spS_Top10WeightsSum
	@RefDate datetime
	, @FundId int
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

;WITH WRanks (FundCode, Weight, W_Rank)
AS
(
    SELECT P.FundCode, ABS(P.ExpWeight) as Weight,
        RANK() OVER (PARTITION BY P.FundCode ORDER BY ABS(P.ExpWeight) DESC) AS W_Rank
    FROM #PositionDets P
    WHERE SecurityType <> 'CFDi'
)

SELECT	WRanks.*
INTO	#TopTen
FROM	WRanks
WHERE   WRanks.W_Rank <= 10

---------------------------------------------------------------------------------

SELECT	FundCode
	, SUM(ABS(Weight)) AS GrossExpTop10
	, @RefDate As RefDate
INTO	#Conc
FROM 	#TopTen
GROUP BY FundCode

---------------------------------------------------------------------------------

SELECT	Conc.FundCode
	, Conc.GrossExpTop10
	, Stats.PositionsCount
	, Stats.GrossExposure
	, Stats.NetExposure
	, Funds.HoDCode
	, Conc.RefDate

FROM	#Conc AS Conc LEFT JOIN
	vw_FundsTypology AS Funds ON (
		Conc.FundCode = Funds.FundCode
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS Stats ON (
		Funds.FundId = Stats.FundId
		AND Conc.RefDate = Stats.NaVPLDate
		)

WHERE	Funds.IsAlive = 1
--		AND Funds.FundClassId = 1 -- only equity funds
		AND Funds.IsSkip = 0
--		AND Funds.VehicleId = 2 -- UCITS4
ORDER BY HoDCode, FundCode



---------------------------------------------------------------------------------

DROP TABLE #PositionDets
DROP TABLE #TopTen
DROP TABLE #Conc
GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_Top10WeightsSum TO [OMAM\StephaneD]
		, [OMAM\OMAM UK OpsTAsupport] 