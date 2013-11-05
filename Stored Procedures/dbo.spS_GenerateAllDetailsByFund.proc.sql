USE Vivaldi
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GenerateAllDetailsByFund]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_GenerateAllDetailsByFund]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_GenerateAllDetailsByFund] 
	@FundId Int,
	@StartDate Datetime,
	@EndDate Datetime,
	@PercDayVol float
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
	MAX(Positions.SecurityType) AS SecurityType,
	Assets.SecurityGroup AS SecurityGroup,
	BMISAssets.PricePercChangeMethod AS IsAssetPriceChange,
	BMISAssets.PriceDivider AS PriceDivider,
	BMISAssets.IsDerivative AS IsDerivative, 
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.PriceDate,
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
	/*CASE 
		WHEN (Funds.SectorsDef = 'GICS') AND (@RefDate >= '2010-May-04')
			THEN Assets.GICSSector
		ELSE*/
			Assets.IndustrySector
	--END
	, IndustryGroup =
	/*CASE 
		WHEN (Funds.SectorsDef = 'GICS') AND (@RefDate >= '2010-May-04')
			THEN Assets.GICSIndustry
		ELSE*/
			Assets.IndustryGroup
	--END
	, VolumeAvg20d =
		CASE 
			WHEN Assets.VolumeAvg20d = 0 THEN NULL
		ELSE
			Assets.VolumeAvg20d
		END,
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
	, Assets.ShortMoM
	
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
	tbl_EnumFiMktSector AS MktSector ON (
		Assets.MktSector = MktSector.Id
		)
	
WHERE 	Assets.PriceDate >= @StartDate AND
	Assets.PriceDate <= @EndDate AND
	Funds.Id = @FundId AND
	Assets.CCYIso <> '---'


GROUP BY	Assets.PriceDate,
		Positions.PositionDate,
		Funds.Id,
		Funds.SectorsDef,
		Positions.FundShortName,
		FundsCCY.ID,
		FundsCCY.ISO3,
		FundsCCY.IsInverse,
		BaseCCYquotes.LastQuote,
		BaseCCYquotes.PreviousQuote,
		Assets.SecurityGroup,
		BMISAssets.PricePercChangeMethod,
		BMISAssets.PriceDivider,
		BMISAssets.IsDerivative,
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

----------------------------------------------------------------------------------

SELECT	RawData.PriceDate,
	RawData.FundId,
	RaWData.SecurityGroup,
	RawData.FundBaseCCYCode,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.PositionSize,
	RawData.StartPrice,
	RawData.IsDerivative,
	RawData.MarketPrice,
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
	dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual
		* (CASE WHEN RawData.SecurityType = 'Bonds'
			AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END)
		, RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.PositionSize * 
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider AS BaseCCYCostValue,
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
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider AS BaseCCYMarketValue,
	NaVs.CostNaV AS NaV,
	NaVs.TotalPL AS TotalPl,
	VaRReports.MargVAR as MargVAR,
	TotalVaR.DollarVaR as FundVaR,
	RawData.CountryISO,
	RawData.CountryName,
	RawData.CountryRegionName,
	RawData.IndustrySector,
	RawData.IndustryGroup,
	RawData.VolumeAvg20d,
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
	, RawData.EffDur
	, RawData.InflDur
	, RawData.RealDur
	, RawData.SpreadDur
	, RawData.CoupType
	, RawData.Bullet
	, RawData.SecType
	, RawData.CollType
	, RawData.MktSector
	, RawData.ShortMom

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
		)
WHERE	EnumVaRReports.IsRelative = 0 OR
	EnumVaRReports.IsRelative IS NULL


-----------------------------------------------------------------------

SELECT	Interim.SecurityGroup,
	Interim.BaseCCYMarketValue /* * (CASE Interim.IsDerivative
			WHEN 1 THEN 0
			ELSE 1
		END) */ AS PostionValue,
	Interim.PriceDate,
	Interim.FundBaseCCYCode,
	Interim.BMISCode,
	Interim.BBGTicker,
	Interim.AssetCCY,
	Interim.PositionSize,
	Interim.StartPrice,
	Interim.MarketPrice,
	Interim.AssetReturn AS AssetEffect,
	Interim.FxReturn AS FxEffect,
	Interim.BaseCCYCostValue/Interim.NaV AS PortfolioShare,
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
		END))  AS PositionPL,
	(Interim.BaseCCYCostValue * Interim.AssetReturn + 
		(Interim.BaseCCYCostValue * Interim.FxReturn  *
		(CASE Interim.IsDerivative
			WHEN 1 THEN 0
			ELSE 1
		END)))/Interim.NaV AS BpPositionPL,
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
			WHEN VolumeAvg20d IS NULL THEN
				VolumeAvg20d
			ELSE
				ABS(PositionSize)/(VolumeAvg20d*@PercDayVol)
		END,
	RiskOnPtflSh =
		CASE
			WHEN	Interim.BaseCCYCostValue/Interim.NaV <> 0 THEN
					(ISNULL(Interim.MargVaR,0)/Interim.FundVaR*100) /
					(Interim.BaseCCYCostValue/Interim.NaV)
		ELSE
			NULL
		END,
	PlOnRisk = 
		CASE
			WHEN	Interim.TotalPl <> 0 AND
				ISNULL(Interim.MargVaR,0) <> 0 THEN
					ABS(((Interim.BaseCCYCostValue * Interim.AssetReturn + 
					Interim.BaseCCYCostValue * Interim.FxReturn) / Interim.TotalPl) /
					(ISNULL(Interim.MargVaR,0)/Interim.FundVaR*100)) * 
					SIGN(Interim.BaseCCYCostValue * Interim.AssetReturn + 
						Interim.BaseCCYCostValue * Interim.FxReturn)
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
	, (Interim.BaseCCYCostValue * Interim.AssetReturn)/Interim.NaV AS AssetPlBps
	, (Interim.BaseCCYCostValue * Interim.FxReturn)/Interim.NaV AS FxPlBps

FROM	#Interim as Interim

ORDER BY	Interim.SecurityGroup ASC, 
		BBGTicker ASC

DROP Table #RawData
DROP Table #Interim

GO

GRANT EXECUTE ON spS_GenerateAllDetailsByFund TO [OMAM\StephaneD], [OMAM\MargaretA]