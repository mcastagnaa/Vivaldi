USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetFundsDetailsByDate_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetFundsDetailsByDate_V2
GO

CREATE PROCEDURE dbo.spS_GetFundsDetailsByDate_V2
	@RefDate datetime
	, @FundId int
	, @PercDayVol float
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
	, CubeData.SecurityGroup
	, CubeData.SecurityType
	, CubeData.IsDerivative
	, CubeData.BMISCode
	, CubeData.BBGTicker
	, CubeData.UnderlyingCTD AS Underlying
	, CubeData.BaseCCYCostValue AS CostMarketVal
	, CubeData.BaseCCYCostValue / NaVs.CostNaV AS Weight
	, CubeData.BaseCCYExposure AS CostExposureVal
	, CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp AS ExpWeight
	, CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta AS ExpWeightBetaAdj
	, CubeData.AssetCCY
	, CubeData.PositionSize
	, CubeData.StartPrice
	, CubeData.MarketPrice
	, CubeData.AssetReturn AS AssetChange
	, CubeData.FxReturn AS FxChange
--BaseCCY PL
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue AS AssetPL
	, CubeData.FXReturn * CubeData.BaseCCYCostValue AS FxPL
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) AS TotalPL
--PL in Bps of CostNaV
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue / NaVs.CostNaV AS AssetPLOnNaV
	, CubeData.FXReturn * CubeData.BaseCCYCostValue / NaVs.CostNaV AS FXPLOnNaV
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1)/ NaVs.CostNaV
		 AS PLOnNaV
--PL over TotalPL
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue/NaVs.TotalPL AS AssetPLonTotalPL
	, CubeData.FXReturn * CubeData.BaseCCYCostValue/NaVs.TotalPL AS FxPLonTotalPL
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) / NaVs.TotalPL
		 AS PLOnTotalPL

	, CubeData.CountryISO
	, CubeData.CountryRegionName AS CountryRegion
	, CubeData.IndustrySector
	, CubeData.IndustryGroup
	, CubeData.SPCleanRating
	, CubeData.SPRatingRank
	, CubeData.BondYearsToMaturity AS YearsToMat
	, CubeData.EquityMarketStatus AS EquityMktStatus
	, CubeData.LongShort
	, DaysToLiquidate = NULLIF(ABS(CubeData.PositionSize)/(CubeData.ADV * @PercDayVol), CubeData.ADV)
	, CubeData.Beta
	, CubeData.Size
	, CubeData.Value
	, CubeData.IsManualPrice
	, CubeData.ROE
	, CubeData.EPSGrowth
	, CubeData.SalesGrowth
	, CubeData.BtP
	, CubeData.DivYield
	, CubeData.EarnYield
	, CubeData.StP
	, CubeData.EbitdaTP
	, CubeData.MktCapLocal
	, CubeData.MktCapUSD
	, CubeData.KRD3m
	, CubeData.KRD6m
	, CubeData.KRD1y
	, CubeData.KRD2y
	, CubeData.KRD3y
	, CubeData.KRD4y
	, CubeData.KRD5y
	, CubeData.KRD6y
	, CubeData.KRD7y
	, CubeData.KRD8y
	, CubeData.KRD9y
	, CubeData.KRD10y
	, CubeData.KRD15y
	, CubeData.KRD20y
	, CubeData.KRD25y
	, CubeData.KRD30y
	, CubeData.EffDur
	, CubeData.InflDur
	, CubeData.RealDur
	, CubeData.SpreadDur
	, CubeData.OAS
	, CubeData.CnvYield
	, CubeData.CoupType
	, CubeData.Bullet AS IsBullet
	, CubeData.SecType
	, CubeData.CollType
	, CubeData.MktSector
	, CubeData.ShortMom
	, UpDown = CASE	WHEN CubeData.ShortMom > 0 THEN 'Up' 
			WHEN CubeData.ShortMom < 0 THEN 'Down' 
			ELSE NULL 
		END
	, OptDelta
	, OptGamma
	, OptVega
	, OptDaysToExp
	, BBGId
				
				

FROM	#CubeData AS CubeData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(CubeData.FundId = NaVs.FundId
		AND CubeData.PositionDate = NaVs.NaVPLDate)
	

ORDER BY	FundId
		, SecurityGroup
		, AssetCCY
		, Underlying


----------------------------------------------------------------------------------
DROP TABLE #CubeData
GO
----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetFundsDetailsByDate_V2 TO [OMAM\StephaneD], [OMAM\MargaretA] 
