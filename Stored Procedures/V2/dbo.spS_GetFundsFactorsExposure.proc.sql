USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetFundsFactorsExposure_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetFundsFactorsExposure_V2
GO

CREATE PROCEDURE dbo.spS_GetFundsFactorsExposure_V2
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
,CountryName 		nvarchar(100)
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

SELECT	Rdt.*
INTO 	#RawData
FROM 	#PositionDets AS RDt LEFT JOIN
	tbl_Funds AS Funds ON (Rdt.FundId = Funds.Id)
WHERE	Funds.GetFactorsLoad = 1
	AND Funds.Alive = 1
	AND Funds.Skip = 0

---------------------------------------------------------------------------------

SELECT	*
INTO #SMBExp
FROM (	SELECT	FundId, ExpWeight, LongShort, Size 
	FROM #RawData
	WHERE len(Size)>0 ) o
PIVOT (SUM(ExpWeight) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #HMLExp
FROM (	SELECT	FundId, ExpWeight, LongShort, Value 
	FROM #RawData
	WHERE len(Value)>0) o
PIVOT (SUM(ExpWeight) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #UMDExp
FROM (	SELECT	FundId, ExpWeight, LongShort, UpDown 
	FROM #RawData
	WHERE UpDown is not null) o
PIVOT (SUM(ExpWeight) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #BetaExp
FROM (	SELECT	FundId, ExpWeight, LongShort, 
	BetaType = CASE WHEN Beta >= 1 THEN 'HiBeta' 
			WHEN Beta < 1 THEN 'LowBeta'
	END
	FROM #RawData
	WHERE Beta is not null
		AND BETA <> 0) o
PIVOT (SUM(ExpWeight) FOR LongShort IN(	[Long]
					, [Short]
					)) p


------------------------------------------------------------------------------------------

SELECT 	FundId
	, 'CompanySize' AS FactorType
	, Size As FactorName
	, ISNULL(Long, 0) AS Long
	, ISNULL(-Short,0) AS Short
	, ISNULL(Long, 0) + ISNULL(Short,0) as Net
FROM #SMBExp

UNION
SELECT 	FundId
	, 'ValueType' AS FactorType
	, Value
	, ISNULL(Long, 0)
	, ISNULL(-Short,0)
	, ISNULL(Long, 0) + ISNULL(Short,0)
FROM #HMLExp

UNION
SELECT 	FundId
	, 'ShortMom' AS FactorType
	, UpDown
	, ISNULL(Long, 0)
	, ISNULL(-Short,0)
	, ISNULL(Long, 0) + ISNULL(Short,0)
FROM #UMDExp

UNION
SELECT 	FundId
	, 'Beta' AS FactorType
	, BetaType
	, ISNULL(Long, 0)
	, ISNULL(-Short,0)
	, ISNULL(Long, 0) + ISNULL(Short,0)
FROM #BetaExp


------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------

DROP TABLE #PositionDets
DROP TABLE #RawData
DROP TABLE #HMLExp
DROP TABLE #SMBExp
DROP TABLE #UMDExp
DROP TABLE #BetaExp

GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetFundsFactorsExposure_V2 TO [OMAM\StephaneD]