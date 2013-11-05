USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetNaVPLExpData_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetNaVPLExpData_V2
GO

CREATE PROCEDURE dbo.spS_GetNaVPLExpData_V2
	@RefDate datetime
	, @FundId int
AS

SET NOCOUNT ON;


CREATE TABLE #CubeData (
PositionDate			datetime
, FundId			integer
, FundIsAlive			bit
, FundIsSkip			bit	
, FundCode			nvarchar(15)
, FundBaseCCYId			integer
, FundBaseCCYCode		nvarchar(3)
, FundBaseCCYIsInverse		bit
, BaseCCYQuote			float
, BaseCCYPrevQuote		float
, SecurityType			nvarchar(30)
, SecurityGroup			nvarchar(30)
, IsAssetPriceChange		bit
, PriceDivider			float
, IsDerivative			bit
, Multiplier			float
, BMISCode			nvarchar(30)
, BBGId				nvarchar(30)
, BBGTicker			nvarchar(40)
, ShortName			nvarchar(30)
, PositionSize			float
, StartPrice			float
, MarketPrice			float
, AssetCCY			nvarchar(3)
, AssetCCYIsInverse		bit
, AssetCCYQuote			float
, AssetCCYPrevQuote		float
, BondAccrual			float
, PenceQuotesDivider		float
, CountryISO			nvarchar(10)
, CountryName			nvarchar(100)
, CountryRegionName		nvarchar(100)
, IndustrySector		nvarchar(40)
, IndustryGroup			nvarchar(40)
, ADV				float
, SPRating			nvarchar(30)
, SPCleanRating			nvarchar(30)
, SPRatingRank			integer
, BondYearsToMaturity		float
, EquityMarketStatus		nvarchar(10)
, EquityTotalReturn		float
, BondAccrual1D			float
, Beta				float
, Size				nvarchar(10)
, Value				nvarchar(10)
, IsManualPrice			bit
, ROE				float
, EPSGrowth			float
, SalesGrowth			float
, BtP				float
, DivYield			float
, EarnYield			float
, StP				float
, EbitdaTP			float
, MktCapLocal			float
, MktCapUSD			float
, KRD3m				float
, KRD6m				float
, KRD1y				float
, KRD2y				float
, KRD3y				float
, KRD4y				float
, KRD5y				float
, KRD6y				float
, KRD7y				float
, KRD8y				float
, KRD9y				float
, KRD10y			float
, KRD15y			float
, KRD20y			float
, KRD25y			float
, KRD30y			float
, OAS				float
, CnvYield			float
, EffDur			float
, InflDur			float
, RealDur			float
, SpreadDur			float
, CoupType			nvarchar(30)
, Bullet			bit
, SecType			nvarchar(30)
, CollType			nvarchar(30)
, MktSector			nvarchar(20)
, ShortMoM			float
, OptDescription		nvarchar(40)
, OptCallPut			nvarchar(1)
, OptDelta			float
, OptGamma			float
, OptVega			float
, OptDaysToExp			integer
, OptExpiryDate			datetime
, OptUnderlying			nvarchar(30)
, OptUnderEffDur		float
, OptUnderMult			float
, OptStrike			float
, OptUnderPrice			float
, OptPxScale			float
, OptCCYUnder			nvarchar(3)
, OptUnderValPt			float
, OptIsCashSettle		bit
, UnderFutConvFactor		float
, UnderlyingCTD			nvarchar(40)
, CcyOptUnderQuote		float
, CcyOptUnderIsInverse		bit
, FutContractSize		float
, FutCategory			nvarchar(30)
, FutPointValue			float
, FutTickSize			float
, FutInitialMargin		float
, ConvFactor			float
, CountMeExp			bit
, IsFuture			bit
, BaseCCYCostValue		float
, BaseCCYMarketValue		float
, AssetReturn			float
, FXReturn			float
, BaseCCYExposure		float
, LongShort			nvarchar(20)
)

----------------------------------------------------------------------------------

INSERT INTO #CubeData
EXEC spS_CubeData_V2 @RefDate, @FundId

----------------------------------------------------------------------------------

SELECT	CubeData.FundCode
	, CubeData.FundId
	, CubeData.PositionDate
	, ISNULL(ManualNaVs.NaV, SUM(CubeData.BaseCCYCostValue)) AS CostNaV
	, SUM(CubeData.BaseCCYMarketValue) AS MktNaVPricesOnly
	, SUM(CubeData.BaseCCYCostValue * (1 + CubeData.AssetReturn) * 
			(1 + CubeData.FxReturn)) AS MktNaV
	, SUM(BaseCCYCostValue * CubeData.AssetReturn) AS AssetPL
	, SUM(BaseCCYCostValue * CubeData.FxReturn) AS FxPL
	, SUM(BaseCCYCostValue * (CubeData.AssetReturn + CubeData.FxReturn)) AS TotalPL

INTO	#NaVs

FROM	#CubeData AS CubeData LEFT JOIN
	tbl_NotionalNaVs AS ManualNaVs ON (CubeData.FundId = ManualNaVs.FundId)

WHERE	FundIsAlive = 1

GROUP BY	CubeData.FundCode
		, CubeData.FundId
		, CubeData.PositionDate
		, ManualNaVs.NaV

----------------------------------------------------------------------------------

SELECT	CubeData.FundId
	, CubeData.PositionDate
	, COUNT(DISTINCT CubeData.BMISCode) AS PositionsCount

INTO	#TickerCounts

FROM	#CubeData AS CubeData

WHERE	CubeData.FundIsAlive = 1
	AND LongShort <> 'CashBaseCCY'
	AND CountMeExp = 1

GROUP BY	CubeData.FundId
		, CubeData.PositionDate

----------------------------------------------------------------------------------
SELECT	CubeData.FundId
	, CubeData.PositionDate
	, SUM(CubeData.BaseCCYExposure) AS NetExposure
	, SUM(ABS(CubeData.BaseCCYExposure)) AS GrossExposure

INTO	#Exposures

FROM	#CubeData AS CubeData

WHERE	CubeData.FundIsAlive = 1
	AND LongShort <> 'CashBaseCCY'
	AND CountMeExp = 1

GROUP BY	CubeData.FundId
		, CubeData.PositionDate

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

SELECT	CubeData.FundId
	, CubeData.PositionDate
	, CubeData.AssetCCY
	, SUM(CubeData.BaseCCYExposure) AS CCYExp

INTO	#CCYExposuresTMP

FROM	#CubeData AS CubeData

WHERE	CubeData.AssetCCY <> CubeData.FundBaseCCYCode
 	AND CubeData.SecurityType NOT IN ('FutOft')
	AND CubeData.IsFuture = 0

GROUP BY	FundId
		, PositionDate
		, AssetCCY
----------------------------------------------------------------------------------
SELECT	CCYExpT.FundId
	, CCYExpT.PositionDate
	, SUM(ABS(CCYExpT.CCYExp)) AS CCYExp

INTO	#CCYExposures

FROM	#CCYExposuresTMP AS CCYExpT

GROUP BY	CCYExpT.FundId
		, CCYExpT.PositionDate

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

SELECT	NaVs.*
	, TickerCounts.PositionsCount
	, Exposures.NetExposure/NaVs.CostNaV AS NetExposure
	, Exposures.GrossExposure/NaVs.CostNaV AS GrossExposure
	, CCYExposures.CCYExp/NaVs.CostNaV AS CCYExp

FROM	#NaVs AS NaVs 
	LEFT JOIN #TickerCounts AS TickerCounts ON
		(NaVs.FundId = TickerCounts.FundId
		AND NaVs.PositionDate = TickerCounts.PositionDate)
	LEFT JOIN #Exposures AS Exposures ON
		(NaVs.FundId = Exposures.FundId
		AND NaVs.PositionDate = Exposures.PositionDate)
	LEFT JOIN #CCYExposures AS CCYExposures ON
		(NaVs.FundId = CCYExposures.FundId
		AND NaVs.PositionDate = CCYExposures.PositionDate)

----------------------------------------------------------------------------------

DROP TABLE #CubeData
DROP TABLE #TickerCounts
DROP TABLE #CCYExposuresTMP
DROP TABLE #CCYExposures
DROP TABLE #Exposures
DROP TABLE #NaVs

GO

GRANT EXECUTE ON dbo.spS_GetNaVPLExpData_V2 TO [OMAM\StephaneD], [OMAM\MargaretA] 
