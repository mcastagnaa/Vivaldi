USE Vivaldi
GO

DECLARE
	@RefDate datetime
	, @FundId int
	, @PercDayVol float

SET @RefDate = '2012/Jan/4'
SET @FundId = null
SET @PercDayVol = null


CREATE TABLE #PositionDets (
FundCode 		nvarchar(15)
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
)
----------------------------------------------------------------------------------
INSERT INTO #PositionDets
EXEC spS_GetFundsDetailsByDate_V2 @RefDate, @FundId, @PercDayVol
----------------------------------------------------------------------------------


SELECT *
INTO #AllWeights

FROM 	(SELECT FundCode, BMISCode, BBGTicker, Weight
	FROM #PositionDets
	WHERE SecurityGroup = 'Equities') o
PIVOT	(AVG(Weight) FOR FundCode in ([GEFO], [AS4], [ASFO], [EEFO], [EQIO], [GEAR], [GSAF], [HBOS], [JSFO], 
					[MSJPMN],[NAEO], [OMDUS], [SFSYPT], [SKAN], [SMFO], [SMID], 
					[UKDEFOS], [UKMCO], [UKSEF], [UKSEO], [UKSSO], 
					[TEWK], [SKANMC], [UKOPP])
	) p

----------------------------------------------------------------------------------

SELECT * FROM #AllWeights
WHERE GEFO is not null

----------------------------------------------------------------------------------
DROP TABLE #PositionDets
DROP TABLE #AllWeights

GO
