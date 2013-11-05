USE Vivaldi
GO

IF  EXISTS (
	SELECT * 
	FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GenerateNaVPLByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_GenerateNaVPLByDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_GenerateNaVPLByDate] 
	@RefDate datetime

AS
SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate,
	Funds.Id AS FundId,
	Positions.FundShortName AS FundCode,
	FundsCCY.ID AS FundBaseCCYId,
	FundsCCY.ISO3 AS FundBaseCCYCode,
	FundsCCY.IsInverse AS FundBaseCCYIsInverse,
	BaseCCYquotes.LastQuote AS BaseCCYQuote,
	BaseCCYquotes.PreviousQuote AS BaseCCYPrevQuote,
	Positions.SecurityType AS SecurityType,
	Assets.SecurityGroup AS SecurityGroup,
	BMISAssets.PricePercChangeMethod AS IsAssetPriceChange,
	BMISAssets.PriceDivider AS PriceDivider,
	BMISAssets.IsDerivative AS IsDerivative,
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Assets.ShortName AS BondIssuer,
	Positions.Units AS PositionSize,
	Positions.StartPrice AS StartPrice,
	isnull(Assets.PxLast, Positions.StartPrice) AS MarketPrice,
	Assets.CCYIso AS AssetCCY,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	Assets.Accrual AS BondAccrual,
	PenceQuotesDivider =
	CASE
		WHEN Assets.DivBy100 = 1 THEN 100
		WHEN Positions.SecurityType = 'Bonds'
			AND Assets.CCYIso = 'BRL' THEN 0.01
		ELSE 1
	END,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Country.RegionID AS CountryRegionID,
	Regions.RegionName As CountryRegionName,
	Assets.IndustrySector AS IndustrySector,
	Assets.IndustryGroup AS IndustryGroup,
	Assets.VolumeAvg20d AS VolumeAvg20d,
	Assets.SPRating AS BBGSPRating,
	Ratings.CleanRating AS SPCleanRating,
	Ratings.RankNo AS SPRatingRank,
	Assets.YearsToMaturity AS BondYieldToMaturity,
	Assets.MarketStatus AS EquityMarketStatus,
	Assets.TotalReturnEq AS EquityTotalReturn,
	Assets.Accrual1dBond AS BondAccrual1D
	, Options.Delta
	, Options.Underlying
	, Options.UnderEffDur
	, Options.UnderMult
	, Options.Strike
	, Options.UnderPrice
	, Options.UnderPxScale
	, Options.CCYUnder
	, Options.UnderBeta
	, Options.UnderValPt


INTO	#RawData

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_CcyDetails AS FundsCCY ON (
		Funds.BaseCCYId = FundsCCY.Id
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	vw_FxQuotes AS BaseCCYQuotes ON (
		Positions.PositionDate = BaseCCYQuotes.FXQuoteDate AND
		FundsCCY.ISO3 = BaseCCYQuotes.ISO
		) LEFT JOIN
	tbl_CcyDetails AS AssetsCCY ON (
		Assets.CCYIso = AssetsCCY.ISO3
		) LEFT JOIN
	vw_FxQuotes AS AssetsCCYQuotes ON (
		Positions.PositionDate = AssetsCCYQuotes.FXQuoteDate AND
		AssetsCCY.ISO3 = AssetsCCYQuotes.ISO
		) LEFT JOIN
	tbl_CountryCodes AS Country ON (
		Assets.CountryISO = Country.ISOCode
		) LEFT JOIN
	tbl_RegionsCodes AS Regions ON (
		Country.RegionId = Regions.ID
		) LEFT JOIN
	tbl_SPRatingsCodes AS Ratings ON (
		Assets.SPRating = Ratings.RatingSPBB
		) LEFT JOIN
	tbl_BMISAssets AS BMISAssets ON (
		Positions.SecurityType = BMISAssets.AssetName
		) LEFT JOIN
	tbl_OptionsData AS Options ON (
		Assets.SecurityId = Options.SecurityId
		AND Assets.PriceDate = Options.PriceDate	
		)

WHERE 	Positions.PositionDate = @RefDate AND
	Assets.CCYIso <> '---' AND
	Funds.alive = 1

----------------------------------------------------------------------------------

SELECT 	Positions.PositionDate AS PositionDate,
	Funds.Id AS FundId,
	Positions.FundShortName AS FundCode,
	FundsCCY.ID AS FundBaseCCYId,
	FundsCCY.ISO3 AS FundBaseCCYCode,
	FundsCCY.IsInverse AS FundBaseCCYIsInverse,
	BaseCCYquotes.LastQuote AS BaseCCYQuote,
	BaseCCYquotes.PreviousQuote AS BaseCCYPrevQuote,
	Positions.SecurityType AS SecurityType,
	Assets.SecurityGroup AS SecurityGroup,
	BMISAssets.PricePercChangeMethod AS IsAssetPriceChange,
	BMISAssets.PriceDivider AS PriceDivider,
	BMISAssets.IsDerivative AS IsDerivative,
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Assets.ShortName AS BondIssuer,
	PositionSize = 
	CASE
		WHEN Assets.SecurityGroup = 'CashFX' AND Funds.FundClassId <> 5 THEN 0
		ELSE Positions.Units
	END,
	CountMe = 
	CASE
		WHEN Assets.SecurityGroup = 'CashFX' AND Funds.FundClassId <> 5 THEN 0
		ELSE 1
	END,
	Positions.StartPrice AS StartPrice,
	isnull(Assets.PxLast, Positions.StartPrice) AS MarketPrice,
	Assets.CCYIso AS AssetCCY,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	Assets.Accrual AS BondAccrual,
	PenceQuotesDivider =
	CASE
		WHEN Assets.DivBy100 = 1 THEN 100
		WHEN Positions.SecurityType = 'Bonds'
			AND Assets.CCYIso = 'BRL' THEN 0.01
		ELSE 1
	END,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Country.RegionID AS CountryRegionID,
	Regions.RegionName As CountryRegionName,
	Assets.IndustrySector AS IndustrySector,
	Assets.IndustryGroup AS IndustryGroup,
	Assets.VolumeAvg20d AS VolumeAvg20d,
	Assets.SPRating AS BBGSPRating,
	Ratings.CleanRating AS SPCleanRating,
	Ratings.RankNo AS SPRatingRank,
	Assets.YearsToMaturity AS BondYieldToMaturity,
	Assets.MarketStatus AS EquityMarketStatus,
	Assets.TotalReturnEq AS EquityTotalReturn,
	Assets.Accrual1dBond AS BondAccrual1D
	, Options.Delta
	, Options.Underlying
	, Options.UnderEffDur
	, Options.UnderMult
	, Options.Strike
	, Options.UnderPrice
	, Options.UnderPxScale
	, Options.CCYUnder
	, Options.UnderBeta
	, Options.UnderValPt
	, CcyOptUnderCcyQuotes.LastQuote AS CcyOptUnderQuote
	, CcyOptUnderCcyQuotes.IsInverse AS CcyOptUnderIsInverse


INTO	#RawDataExp

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_CcyDetails AS FundsCCY ON (
		Funds.BaseCCYId = FundsCCY.Id
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	vw_FxQuotes AS BaseCCYQuotes ON (
		Positions.PositionDate = BaseCCYQuotes.FXQuoteDate AND
		FundsCCY.ISO3 = BaseCCYQuotes.ISO
		) LEFT JOIN
	tbl_CcyDetails AS AssetsCCY ON (
		Assets.CCYIso = AssetsCCY.ISO3
		) LEFT JOIN
	vw_FxQuotes AS AssetsCCYQuotes ON (
		Positions.PositionDate = AssetsCCYQuotes.FXQuoteDate AND
		AssetsCCY.ISO3 = AssetsCCYQuotes.ISO
		) LEFT JOIN
	tbl_CountryCodes AS Country ON (
		Assets.CountryISO = Country.ISOCode
		) LEFT JOIN
	tbl_RegionsCodes AS Regions ON (
		Country.RegionId = Regions.ID
		) LEFT JOIN
	tbl_SPRatingsCodes AS Ratings ON (
		Assets.SPRating = Ratings.RatingSPBB
		) LEFT JOIN
	tbl_BMISAssets AS BMISAssets ON (
		Positions.SecurityType = BMISAssets.AssetName
		) LEFT JOIN
	tbl_OptionsData AS Options ON (
		Assets.SecurityId = Options.SecurityId
		AND Assets.PriceDate = Options.PriceDate	
		) LEFT JOIN
	vw_FxQuotes AS CcyOptUnderCcyQuotes ON (
		Positions.PositionDate = CcyOptUnderCcyQuotes.FXQuoteDate AND
		Options.CCYUnder = CcyOptUnderCcyQuotes.ISO
		) 
	

WHERE 	Positions.PositionDate = @RefDate AND
	Assets.CCYIso <> '---' AND
	Funds.alive = 1 AND
	Assets.SecurityType not in ('CashOft', 'FutOft')

----------------------------------------------------------------------------------


SELECT	RawData.SecurityType,
	RaWData.SecurityGroup,
	RawData.FundId,
	RawData.FundCode,
	RawData.FundBaseCCYCode,
	RawData.BMISCode,
	RawData.BBGid,
	RawData.PositionDate,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.StartPrice,
	RawData.MarketPrice,
	RawData.BondAccrual,
	RawData.BondAccrual1D,
	AssetReturn = 
	CASE
		WHEN RawData.SecurityType in ('Equities', 'CFD') THEN RawData.EquityTotalReturn
		WHEN RawData.SecurityType in ('Cash','CashOft','FutOft', 'FX', 'MMFunds','CD') THEN 0
		ELSE	dbo.fn_GetPriceChange(
			RawData.IsAssetPriceChange,
			RawData.StartPrice + RawData.BondAccrual,
			RawData.MarketPrice + RawData.BondAccrual + RawData.BondAccrual1D,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse) 
	END,
	FxReturn =
	CASE RawData.IsDerivative
		WHEN 1 THEN 0
	ELSE 
		CASE
		WHEN RawData.IsAssetPriceChange = 1 THEN
			dbo.fn_GetFxChange(
				RawData.AssetCCYPrevQuote,
				RawData.AssetCCYQuote,
				RawData.BaseCCYPrevQuote,
				RawData.BaseCCYQuote,
				RawData.FundBaseCCYIsInverse,
				RawData.AssetCCYIsInverse)
		ELSE 	dbo.fn_GetPriceChange(
			RawData.IsAssetPriceChange,
			RawData.StartPrice + RawData.BondAccrual,
			RawData.MarketPrice + RawData.BondAccrual + RawData.BondAccrual1D,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse)
		END
	END,
	dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual 
			* (CASE WHEN RawData.SecurityType = 'Bonds'
				AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END)
		, RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.PositionSize * 
		(CASE WHEN RawData.SecurityType in ('IntRateOpt', 'CcyOpt')
			THEN
				RawData.UnderValPt
			ELSE
				RawData.FuturesMultiplier/
				RawData.PriceDivider/
				RawData.PenceQuotesDivider 
		END) AS BaseCCYCostValue,
	dbo.fn_GetBaseCCYPrice(RawData.MarketPrice + RawData.BondAccrual 
			* (CASE WHEN RawData.SecurityType = 'Bonds'
				AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END)
		+ RawData.BondAccrual1D,
		RawData.AssetCCYQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		0)* RawData.PositionSize *
 		(CASE WHEN RawData.SecurityType in ('IntRateOpt', 'CcyOpt')
			THEN
				RawData.UnderValPt
			ELSE
				RawData.FuturesMultiplier/
				RawData.PriceDivider/
				RawData.PenceQuotesDivider 
		END) AS BaseCCYMarketValue,

	LongShort = dbo.fn_GetLongShort(
			RawData.PositionSize,
			RawData.SecurityGroup,
			RawData.AssetCCY,
			RawData.FundBaseCCYCode
			)
		
INTO	#PerformanceData
FROM	#RawData AS RawData

-----------------------------------------------------------------------

SELECT	RawData.SecurityType,
	RaWData.SecurityGroup,
	RawData.IsDerivative,
	RawData.FundId,
	RawData.CountMe,
	RawData.FundCode,
	RawData.FundBaseCCYCode,
	RawData.BMISCode,
	RawData.BBGid,
	RawData.BBGTicker,
	RawData.AssetCCY,
	(CASE 
		WHEN RawData.SecurityType in ('Bonds', 'Cash', 'CFD', 'Equities', 'FutOft', 'FX', 'Others', 'Placing',
			'MMFunds', 'TBills', 'CD', 'IndexFut', 'BondFut', 'IntRateFut') THEN
		dbo.fn_GetBaseCCYPrice(
			(CASE WHEN RawData.SecurityType = 'IntRateFutXX'
				THEN 1 ELSE RawData.MarketPrice END) + 
			(RawData.BondAccrual + RawData.BondAccrual1D) *
				(CASE WHEN RawData.SecurityType = 'Bonds'
				AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END),
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.FuturesMultiplier/
		RawData.PriceDivider/
		RawData.PenceQuotesDivider 
		
		WHEN RawData.SecurityType in ('IntRateOpt') THEN 
		dbo.fn_GetBaseCCYPrice(1,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.Delta * 
		RawData.FuturesMultiplier/
		RawData.PriceDivider
		
		WHEN RawData.SecurityType in ('CCYOpt') THEN
		dbo.fn_GetBaseCCYPrice(RawData.UnderPrice,
			RawData.CcyOptUnderQuote,
			RawData.CcyOptUnderIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.Delta * 
		RawData.FuturesMultiplier/
		RawData.UnderPXScale

		WHEN RawData.SecurityType in ('BondFutOpt', 'EqOpt', 'IndexOpt') THEN 
		dbo.fn_GetBaseCCYPrice(RawData.UnderPrice,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.Delta * 
		RawData.FuturesMultiplier /
		RawData.UnderPXScale /
		RawData.PenceQuotesDivider /
		RawData.PriceDivider

		WHEN RawData.SecurityType in ('CCYFut') THEN 0 -- This has to be developed
	END) AS BaseCCYValue,
	LongShort = dbo.fn_GetLongShort(
			RawData.PositionSize,
			RawData.SecurityGroup,
			RawData.AssetCCY,
			RawData.FundBaseCCYCode
			)
		
INTO	#PerformanceDataExp
FROM	#RawDataExp AS RawData

-----------------------------------------------------------------------

SELECT	PerformanceData.FundId,
	PerformanceData.SecurityType,
	PerformanceData.SecurityGroup,
	PerformanceData.BBGId,
	PerformanceData.PositionDate,
	PerformanceData.AssetCCY,
	SUM(PerformanceData.BaseCCYCostValue) AS CostNAV,
	SUM(PerformanceData.BaseCCYMarketValue) AS MktNAVPricesOnly,
	SUM(PerformanceData.BaseCCYCostValue * (1 + PerformanceData.AssetReturn) * 
				(1 + PerformanceData.FxReturn)) AS MktNAV,
	SUM(PerformanceData.BaseCCYCostValue * PerformanceData.AssetReturn) AS AssetPL,
	SUM(PerformanceData.BaseCCYCostValue * PerformanceData.FxReturn) AS FxPL,
	SUM(PerformanceData.BaseCCYCostValue * PerformanceData.AssetReturn) +
		SUM(PerformanceData.BaseCCYCostValue * PerformanceData.FxReturn) AS TotalPL,
	LongShort = dbo.fn_GetLongShort(SUM(PerformanceData.BaseCCYCostValue),
			PerformanceData.SecurityGroup,
			PerformanceData.AssetCCY,
			PerformanceData.FundBaseCCYCode
			)


INTO	#TypeAggregation
	
FROM	#PerformanceData AS PerformanceData 

GROUP BY	PerformanceData.FundId,
		PerformanceData.SecurityGroup,
		PerformanceData.SecurityType,
		PerformanceData.BBGId,
		PerformanceData.AssetCCY,
		PerformanceData.FundBaseCCYCode,
		PerformanceData.PositionDate




-----------------------------------------------------------------------

SELECT	FundId,
	SecurityGroup,
	BBGId,
	PositionDate,
	AssetCCY,
	SUM(CostNav) AS CostNAV,
	SUM(MktNAVPricesOnly) AS MktNAVPricesOnly,
	SUM(MktNAV) AS MktNAV,
	SUM(AssetPL) AS AssetPL,
	SUM(FxPL) AS FxPL,
	SUM(TotalPL) AS TotalPL,
	LongShort 

INTO	#GroupAggregation
	
FROM	#TypeAggregation AS PerformanceData 

GROUP BY	PerformanceData.FundId,
		PerformanceData.SecurityGroup,
		PerformanceData.BBGId,
		PerformanceData.AssetCCY,
		PerformanceData.PositionDate,
		PerformanceData.LongShort


-----------------------------------------------------------------------

SELECT	FundId
	, AssetCCY
	, SUM(BaseCCYCostValue) AS CCYExp

INTO	#CCYExp1

FROM	#PerformanceData

WHERE	LongShort <> 'CashBaseCCY'
	AND AssetCCY <> FundBaseCCYCode

GROUP BY	FundId
		, AssetCCY

-----------------------------------------------------------------------

SELECT	CCYExp.FundId
	, SUM(ABS(CCYExp.CCYExp)) AS CCYExp

INTO	#CCYExp
	
FROM 	#CCYExp1 AS CCYExp 

GROUP BY CCYExp.FundId


-----------------------------------------------------------------------


SELECT	PerformanceData.FundId,
	PerformanceData.SecurityGroup,
	PerformanceData.BBGId,
	SUM(PerformanceData.BaseCCYValue) AS NAV,
	SUM(PerformanceData.CountMe) AS PositionsCount

INTO	#GroupAggregationExp
	
FROM	#PerformanceDataExp AS PerformanceData 

WHERE	PerformanceData.LongShort <> 'CashBaseCCY'

GROUP BY	PerformanceData.FundId,
		PerformanceData.SecurityGroup,
		PerformanceData.BBGId,
		PerformanceData.AssetCCY,
		PerformanceData.FundBaseCCYCode


-----------------------------------------------------------------------


SELECT	GroupAggregation.FundId,
	GroupAggregation.PositionDate,
	ManualNaVs.NaV AS ManualNaV,
	ISNULL(ManualNAVs.NaV,SUM(GroupAggregation.CostNaV)) AS CostNAV,
	SUM(GroupAggregation.MktNAVPricesOnly) AS MktNAVPricesOnly,
	SUM(GroupAggregation.MktNAV) AS MktNAV,
	SUM(GroupAggregation.AssetPL) AS AssetPL,
	SUM(GroupAggregation.FXPL) AS FxPL,
	SUM(GroupAggregation.TotalPL) AS TotalPL
	

INTO	#FundAggregation
	
FROM	#GroupAggregation AS GroupAggregation LEFT JOIN
	tbl_NotionalNaVs AS ManualNaVs ON (
		GroupAggregation.FundId = ManualNavs.FundId
			)

GROUP BY	GroupAggregation.FundId,
		GroupAggregation.PositionDate,
		ManualNaVs.Nav
-----------------------------------------------------------------------


SELECT	GroupAggregation.FundId,
	SUM(GroupAggregation.PositionsCount) AS PositionsCount

INTO	#FundRelevantCount
	
FROM	#GroupAggregationExp AS GroupAggregation 

GROUP BY	GroupAggregation.FundId


-----------------------------------------------------------------------

SELECT	PerformanceData.FundId
	, SUM(PerformanceData.NaV/ISNULL(Aggregation.ManualNaV,Aggregation.MktNaV)) AS NetExposure
	, SUM(ABS(PerformanceData.NaV)/ISNULL(Aggregation.ManualNaV,Aggregation.MktNaV)) AS GrossExposure
	, RelevantCount.PositionsCount
	
INTO	#Exposure

FROM	#GroupAggregationExp AS PerformanceData RIGHT JOIN
	#FundAggregation AS Aggregation ON (
		PerformanceData.FundId = Aggregation.FundId
			) LEFT JOIN
	#FundRelevantCount AS RelevantCount ON (
		Aggregation.FundId = RelevantCount.FundId
			) 

GROUP BY	PerformanceData.FundId
		, RelevantCount.PositionsCount

-----------------------------------------------------------------------

SELECT	Aggr.FundId
	, Aggr.PositionDate
	, Aggr.CostNAV
	, Aggr.MktNAVPricesOnly
	, Aggr.MktNAV
	, Aggr.AssetPL
	, Aggr.FxPL
	, Aggr.TotalPL
	, Exposure.PositionsCount
	, Exposure.NetExposure
	, Exposure.GrossExposure
	, CCYExp.CCYExp/Aggr.CostNAV AS CCYExp

FROM	#FundAggregation AS Aggr LEFT JOIN
	#Exposure AS Exposure ON (
		Aggr.FundId = Exposure.FundId
		) LEFT JOIN
	#CCYExp AS CCYExp ON (
		Aggr.FundId = CCYExp.FundId
		)

-----------------------------------------------------------------------

DROP Table #RawData
DROP Table #PerformanceData
DROP Table #GroupAggregation
DROP Table #TypeAggregation
DROP Table #FundAggregation
DROP Table #RawDataExp
DROP Table #PerformanceDataExp
DROP Table #GroupAggregationExp
DROP Table #FundRelevantCount
DROP Table #Exposure
DROP Table #CCYExp1
DROP Table #CCYExp

GO

GRANT EXECUTE ON spS_GenerateNaVPLByDate TO [OMAM\StephaneD], [OMAM\MargaretA]