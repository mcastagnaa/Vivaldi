USE Vivaldi
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GenerateAllDetailsByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_GenerateAllDetailsByDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_GenerateAllDetailsByDate] 
	@RefDate datetime,
	@PercDayVol float

AS
SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate,
	Funds.FundId AS FundId,
	Funds.FundClass AS FundClass,
	Positions.FundShortName AS FundCode,
	FundsCCY.ID AS FundBaseCCYId,
	FundsCCY.ISO3 AS FundBaseCCYCode,
	FundsCCY.IsInverse AS FundBaseCCYIsInverse,
	BaseCCYquotes.LastQuote AS BaseCCYQuote,
	BaseCCYquotes.PreviousQuote AS BaseCCYPrevQuote,
	MAX(Positions.SecurityType) AS SecurityType,
	Assets.SecurityGroup AS SecurityGroup,
	BMISAssets.PricePercChangeMethod AS IsAssetPriceChange,
	BMISAssets.PriceDivider AS PriceDivider,
	BMISAssets.IsDerivative AS IsDerivative, 
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Assets.ShortName AS BondIssuer,
	SUM(Positions.Units) AS PositionSize,
	Positions.StartPrice AS StartPrice,
	ISNULL(Assets.PxLast, Positions.StartPrice) AS MarketPrice,
	Assets.CCYIso AS AssetCCY,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	Assets.Accrual AS BondAccrual,
	PenceQuotesDivider =
	CASE
		WHEN Assets.DivBy100 = 1 THEN 100
		WHEN MAX(Positions.SecurityType) = 'Bonds'
			AND Assets.CCYIso = 'BRL' THEN 0.01
		ELSE 1
	END,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Regions.RegionName As CountryRegionName,
	IndustrySector = 
	CASE 
		WHEN (Funds.SectorsDef = 'GICS') AND (@RefDate >= '2010-May-04')
			THEN Assets.GICSSector
		ELSE
			Assets.IndustrySector
	END,
	IndustryGroup =
	CASE 
		WHEN (Funds.SectorsDef = 'GICS') AND (@RefDate >= '2010-May-04')
			THEN Assets.GICSIndustry
		ELSE
			Assets.IndustryGroup
	END,
	NULLIF(Assets.VolumeAvg20d, 0) AS VolumeAvg20d,
	Assets.SPRating AS BBGSPRating,
	Ratings.CleanRating AS SPCleanRating,
	Ratings.RankNo AS SPRatingRank,
	Assets.YearsToMaturity AS BondYearsToMaturity,
	Assets.MarketStatus AS EquityMarketStatus,
	Assets.TotalReturnEq AS EquityTotalReturn,
	Assets.Accrual1dBond AS BondAccrual1D,
	Assets.Beta,
	Assets.Size,
	Assets.Value,
	Assets.IsManualPrice
	, Assets.ROE
	, Assets.EPSGrowth
	, Assets.SalesGrowth
	, Assets.BtP
	, Assets.DivYield
	, Assets.EarnYield
	, Assets.StP
	, Assets.EbitdaTP
	, Assets.MktCapLocal
	, Assets.MktCapUSD
	, Assets.KRD3m
	, Assets.KRD6m
	, Assets.KRD1y
	, Assets.KRD2y
	, Assets.KRD3y
	, Assets.KRD4y
	, Assets.KRD5y
	, Assets.KRD6y
	, Assets.KRD7y
	, Assets.KRD8y
	, Assets.KRD9y
	, Assets.KRD10y
	, Assets.KRD15y
	, Assets.KRD20y
	, Assets.KRD25y
	, Assets.KRD30y
	, Assets.EffDur
	, Assets.InflDur
	, Assets.RealDur
	, Assets.SpreadDur
	, Assets.CoupType
	, Assets.Bullet
	, Assets.SecType
	, Assets.CollType
	, MktSector.Name AS MktSector
	, Assets.ShortMom
	, Funds.ADVField
	, NULLIF(Assets.VolumeAvg3m, 0) AS VolumeAvg3m
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


	
INTO	#RawData

FROM 	tbl_Positions AS Positions LEFT JOIN
	vw_FundsTypology AS Funds ON (
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
	tbl_EnumFiMktSector AS MktSector ON (
		Assets.MktSector = MktSector.Id
		) LEFT JOIN
	tbl_OptionsData AS Options ON (
		Assets.securityId = Options.SecurityId
		AND Assets.PriceDate = Options.PriceDate	
		) LEFT JOIN
	vw_FxQuotes AS CcyOptUnderCcyQuotes ON (
		Positions.PositionDate = CcyOptUnderCcyQuotes.FXQuoteDate AND
		Options.CCYUnder = CcyOptUnderCcyQuotes.ISO
		) 
	
WHERE 	Assets.PriceDate = @RefDate
	AND Assets.CCYIso <> '---'
	AND Funds.IsAlive = 1
	AND Funds.IsSkip = 0


GROUP BY	Positions.PositionDate,
		Funds.FundId,
		Funds.FundClass,
		Funds.SectorsDef,
		Positions.FundShortName,
		FundsCCY.ID,
		FundsCCY.ISO3,
		FundsCCY.IsInverse,
		BaseCCYquotes.LastQuote,
		BaseCCYquotes.PreviousQuote,
		Assets.SecurityGroup,
		BMISAssets.PricePercChangeMethod,
		BMISAssets.IsDerivative,
		BMISAssets.PriceDivider,
		Assets.Multiplier,
		Positions.PositionId,
		Assets.IDBloomberg,
		Assets.Description,
		Assets.ShortName,
		Positions.StartPrice,
		Assets.PxLast,
		Assets.CCYIso,
		AssetsCCY.IsInverse,
		AssetsCCYQuotes.LastQuote,
		AssetsCCYQuotes.PreviousQuote,
		Assets.Accrual,		
		Assets.DivBy100,
		Assets.CountryISO,
		Country.CountryName,
		Regions.RegionName,
		Assets.IndustrySector,
		Assets.IndustryGroup,
		Assets.GICSSector,
		Assets.GICSIndustry,
		Assets.VolumeAvg20d,
		Assets.SPRating,
		Ratings.CleanRating,
		Ratings.RankNo,
		Assets.YearsToMaturity,
		Assets.MarketStatus,
		Assets.TotalReturnEq,
		Assets.Accrual1dBond,
		Assets.Beta,
		Assets.Size,
		Assets.Value,
		Assets.IsManualPrice
		, Assets.ROE
		, Assets.EPSGrowth
		, Assets.SalesGrowth
		, Assets.BtP
		, Assets.DivYield
		, Assets.EarnYield
		, Assets.StP
		, Assets.EbitdaTP
		, Assets.MktCapLocal
		, Assets.MktCapUSD
		, Assets.KRD3m
		, Assets.KRD6m
		, Assets.KRD1y
		, Assets.KRD2y
		, Assets.KRD3y
		, Assets.KRD4y
		, Assets.KRD5y
		, Assets.KRD6y
		, Assets.KRD7y
		, Assets.KRD8y
		, Assets.KRD9y
		, Assets.KRD10y
		, Assets.KRD15y
		, Assets.KRD20y
		, Assets.KRD25y                                                
		, Assets.KRD30y
		, Assets.EffDur
		, Assets.InflDur
		, Assets.RealDur
		, Assets.SpreadDur
		, Assets.CoupType
		, Assets.Bullet
		, Assets.SecType
		, Assets.CollType
		, MktSector.Name
		, Assets.ShortMom
		, Funds.ADVField
		, Assets.VolumeAvg3m
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
		, CcyOptUnderCcyQuotes.LastQuote
		, CcyOptUnderCcyQuotes.IsInverse


----------------------------------------------------------------------------------

SELECT	RawData.FundId,
	RawData.FundCode,
	RawData.FundClass,
	RaWData.SecurityGroup,
	RawData.FundBaseCCYCode,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.PositionSize,
	RawData.StartPrice,	
	RawData.IsDerivative,
	RawData.MarketPrice,
	RawData.FuturesMultiplier, 
	RawData.PenceQuotesDivider,
	RawData.PriceDivider,
	AssetReturn = 
	CASE
		WHEN RawData.SecurityType in ('Equities', 'CFD') THEN RawData.EquityTotalReturn
		WHEN RawData.SecurityType in ('Cash','CashOft','FutOft', 'FX', 'MMFunds', 'CD') THEN 0
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
		1) AS BaseCCYCostPrice,
	dbo.fn_GetBaseCCYPrice(RawData.MarketPrice + RawData.BondAccrual 
		* (CASE WHEN RawData.SecurityType = 'Bonds'
			AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END)
		+ RawData.BondAccrual1D,
		RawData.AssetCCYQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		0) AS BaseCCYMarketPrice,
	dbo.fn_GetBaseCCYPrice(1
		, (CASE WHEN RawData.SecurityType in ('CcyOpt') THEN RawData.CcyOptUnderQuote
			ELSE RawData.AssetCCYQuote END)
		, (CASE WHEN RawData.SecurityType in ('CcyOpt') THEN RawData.CcyOptUnderIsInverse
			ELSE RawData.AssetCCYIsInverse END)
		, RawData.BaseCCYQuote
		, RawData.FundBaseCCYIsInverse
		, RawData.SecurityType
		, 0) AS OptCCYConverter,
	dbo.fn_GetBaseCCYPrice(
		(CASE WHEN RawData.SecurityType in ('IntRateFutXX')
			THEN 1 ELSE RawData.StartPrice END) + 
		RawData.BondAccrual *
		(CASE WHEN RawData.SecurityType = 'Bonds'
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
		dbo.fn_GetBaseCCYPrice(
		(CASE WHEN RawData.SecurityType in ('IntRateFutXX')
			THEN 1 ELSE RawData.MarketPrice END) + 
		(RawData.BondAccrual + RawData.BondAccrual1D) *
		(CASE WHEN RawData.SecurityType = 'Bonds'
			AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END),
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
	NaVs.CostNaV AS CostNaV,
	NaVs.MktNaVPrices AS MktNaV,
	NaVs.TotalPL AS TotalPl,
	VaRReports.MargVAR as MargVAR,
	TotalVaR.DollarVaR as FundVaR,
	RawData.CountryISO,
	RawData.CountryName,
	RawData.CountryRegionName,
	RawData.IndustrySector,
	RawData.IndustryGroup,
	Adv = 	CASE 
		WHEN RawData.AdvField = 'VolumeAvg3m' AND @RefDate >= '2010-07-15' 
			THEN RawData.VolumeAvg3m
		ELSE RawData.VolumeAvg20d
		END,
	RawData.SPCleanRating,
	RawData.SPRatingRank,
	RawData.BondYearsToMaturity,
	RawData.EquityMarketStatus,
	LongShort = dbo.fn_GetLongShort(
			RawData.PositionSize,
			RawData.SecurityGroup,
			RawData.AssetCCY,
			RawData.FundBaseCCYCode
			),
	RawData.Beta,
	RawData.Size,
	RawData.Value,
	RawData.IsManualPrice
	, RawData.ROE
	, RawData.EPSGrowth
	, RawData.SalesGrowth
	, RawData.BtP
	, RawData.DivYield
	, RawData.EarnYield
	, RawData.StP
	, RawData.EbitdaTP
	, RawData.MktCapLocal
	, RawData.MktCapUSD
	, RawData.KRD3m
	, RawData.KRD6m
	, RawData.KRD1y
	, RawData.KRD2y
	, RawData.KRD3y
	, RawData.KRD4y
	, RawData.KRD5y
	, RawData.KRD6y
	, RawData.KRD7y
	, RawData.KRD8y
	, RawData.KRD9y
	, RawData.KRD10y
	, RawData.KRD15y
	, RawData.KRD20y
	, RawData.KRD25y
	, RawData.KRD30y
	, EffDur = ISNULL(RawData.UnderEffDur, RawData.EffDur)
	, RawData.InflDur
	, RawData.RealDur
	, RawData.SpreadDur
	, RawData.CoupType
	, RawData.Bullet
	, RawData.SecType
	, RawData.CollType
	, RawData.MktSector
	, RawData.ShortMom
	, RawData.Delta
	, RawData.Underlying
	, RawData.UnderMult
	, RawData.Strike
	, UnderPrice = 	(CASE WHEN RawData.SecurityType in ('IntRateFutXX', 'IntRateOptXX') THEN 1
		ELSE RawData.UnderPrice END)
	, RawData.UnderPxScale
	, RawData.CCYUnder
	, NotionalNaVs.NaV AS NotionalNaV


INTO #Interim

FROM	#RawData AS RawData LEFT JOIN
	tbl_VaRReports AS VaRReports ON (
		RawData.FundId = VaRReports.FundId AND
		RawData.PositionDate = VaRReports.ReportDate AND
		RawData.BBGId = VaRReports.BBGInstrId
		) LEFT JOIN
	tbl_EnumVaRReports AS EnumVaRReports ON (
		VaRReports.ReportId = EnumVaRReports.Id
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		RawData.FundId = NaVs.FundId AND
		RawData.PositionDate = NaVs.NaVPLDate
		) LEFT JOIN
	vw_TotalVaRByFundByDate AS TotalVaR ON (
		RawData.FundId = TotalVaR.FundId AND
		RawData.PositionDate = TotalVaR.VaRDate
		) LEFT JOIN
	tbl_NotionalNaVs AS NotionalNaVs ON (
		RawData.FundId = NotionalNaVs.FundId)

WHERE	EnumVaRReports.IsRelative = 0 OR
	EnumVaRReports.IsRelative IS NULL


-----------------------------------------------------------------------

SELECT	Interim.FundId,
	Interim.FundCode,
	Interim.FundClass,
	Interim.SecurityGroup,
	Interim.BaseCCYMarketValue /* * (CASE Interim.IsDerivative
			WHEN 1 THEN 0
			ELSE 1
		END) */ AS PositionValue,
	Interim.FundBaseCCYCode,
	Interim.BMISCode,
	Interim.BBGTicker,
	Interim.AssetCCY,
	Interim.PositionSize,
	Interim.StartPrice,
	Interim.MarketPrice,
	Interim.AssetReturn AS AssetEffect,
	Interim.FxReturn AS FxEffect,
	Interim.BaseCCYMarketValue/ISNULL(Interim.NotionalNaV,Interim.MktNaV) AS PortfolioShare,
	Interim.BaseCCYCostValue * Interim.AssetReturn AS AssetPL,
	Interim.BaseCCYCostValue * Interim.FxReturn  *
		(CASE Interim.IsDerivative
			WHEN 1 THEN 0
			ELSE 1
		END) AS FxPL,
	Interim.BaseCCYCostValue * Interim.AssetReturn + 
		(Interim.BaseCCYCostValue * Interim.FxReturn *
		(CASE Interim.IsDerivative
			WHEN 1 THEN 0
			ELSE 1
		END)) AS PositionPL,
	(Interim.BaseCCYCostValue * Interim.AssetReturn + 
		(Interim.BaseCCYCostValue * Interim.FxReturn *
		(CASE Interim.IsDerivative
			WHEN 1 THEN 0
			ELSE 1
		END)))/Interim.CostNaV AS BpPositionPL,
	ISNULL(Interim.MargVaR,0)/Interim.FundVaR*100 AS MargVaRPerc,
	CountryISO,
	CountryName,
	CountryRegionName,
	IndustrySector,
	IndustryGroup,
	SPCleanRating,
	SPRatingRank,
	BondYearsToMaturity,
	EquityMarketStatus,
	LongShort,
	DaysToLiquidate = 
		CASE
			WHEN ADV IS NULL THEN
				ADV
			ELSE
				ABS(PositionSize)/(ADV*@PercDayVol)
		END,
	RiskOnPtflSh =
		CASE
			WHEN	Interim.BaseCCYCostValue/Interim.CostNaV <> 0 THEN
					(ISNULL(Interim.MargVaR,0)/Interim.FundVaR*100) /
					(Interim.BaseCCYCostValue/Interim.CostNaV)
		ELSE
			NULL
		END,
	PlOnRisk = 
		CASE
			WHEN	Interim.TotalPl <> 0 AND
				ISNULL(Interim.MargVaR,0) <> 0 THEN
					ABS(((Interim.BaseCCYCostValue * Interim.AssetReturn + 
					Interim.BaseCCYCostValue * Interim.FxReturn *
						(CASE Interim.IsDerivative
							WHEN 1 THEN 0
							ELSE 1 END)
						) / Interim.TotalPl) /
					(ISNULL(Interim.MargVaR,0)/Interim.FundVaR*100)) * 
					SIGN(Interim.BaseCCYCostValue * Interim.AssetReturn + 
						Interim.BaseCCYCostValue * Interim.FxReturn *
						(CASE Interim.IsDerivative
						WHEN 1 THEN 0
						ELSE 1 END)
					)
					
		ELSE
			NULL
		END,
	Interim.Beta,
	Interim.Size,
	Interim.Value,
	Interim.IsManualPrice
	, Interim.ROE
	, Interim.EPSGrowth
	, Interim.SalesGrowth
	, Interim.BtP
	, Interim.DivYield
	, Interim.EarnYield
	, Interim.StP
	, Interim.EbitdaTP
	, Interim.MktCapLocal
	, Interim.MktCapUSD
	, Interim.KRD3m
	, Interim.KRD6m
	, Interim.KRD1y
	, Interim.KRD2y
	, Interim.KRD3y
	, Interim.KRD4y
	, Interim.KRD5y
	, Interim.KRD6y
	, Interim.KRD7y
	, Interim.KRD8y
	, Interim.KRD9y
	, Interim.KRD10y
	, Interim.KRD15y
	, Interim.KRD20y
	, Interim.KRD25y
	, Interim.KRD30y
	, Interim.EffDur
	, Interim.InflDur
	, Interim.RealDur
	, Interim.SpreadDur
	, Interim.CoupType
	, Interim.Bullet
	, Interim.SecType
	, Interim.CollType
	, Interim.MktSector
	, Interim.ShortMom
	, UpDown = CASE	WHEN Interim.ShortMom > 0 THEN 'Up' 
			WHEN Interim.ShortMom < 0 Then 'Down' 
			ELSE NULL 
		END
	, (Interim.BaseCCYCostValue * Interim.AssetReturn)/Interim.CostNaV AS AssetPlBps
	, (Interim.BaseCCYCostValue * Interim.FxReturn)/Interim.CostNaV AS FxPlBps
	, Interim.Delta
	, Interim.Underlying
	, Interim.PositionSize * Interim.Delta * Interim.FuturesMultiplier / 
		Interim.UnderMult AS UnderSize
	, Interim.Delta * Interim.FuturesMultiplier * Interim.PositionSize * 
		Interim.UnderPrice *
		Interim.OptCCYConverter /
		Interim.PriceDivider /
		Interim.UnderPxScale /
		Interim.PenceQuotesDivider AS UnderNotional



FROM	#Interim as Interim

ORDER BY	Interim.FundCode ASC
		, Interim.SecurityGroup ASC
		, BBGTicker ASC

DROP Table #RawData
DROP Table #Interim

GO

GRANT EXECUTE ON spS_GenerateAllDetailsByDate TO [OMAM\StephaneD], [OMAM\MargaretA]