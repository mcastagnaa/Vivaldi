USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CubeData_V2]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CubeData_V2]
GO

CREATE PROCEDURE [dbo].[spS_CubeData_V2] 
	@RefDate datetime
	, @FundId int
AS

SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate
	, Funds.Id AS FundId
	, Funds.Alive AS FundIsAlive
	, Funds.Skip AS FundIsSkip
	, Positions.FundShortName AS FundCode
	, FundsCCY.ID AS FundBaseCCYId
	, FundsCCY.ISO3 AS FundBaseCCYCode
	, FundsCCY.IsInverse AS FundBaseCCYIsInverse
	, BaseCCYquotes.LastQuote AS BaseCCYQuote
	, BaseCCYquotes.PreviousQuote AS BaseCCYPrevQuote
	, Positions.SecurityType AS SecurityType
	, Assets.SecurityGroup AS SecurityGroup
	, BMISAssets.PricePercChangeMethod AS IsAssetPriceChange
	, BMISAssets.PriceDivider AS PriceDivider
	, BMISAssets.IsDerivative AS IsDerivative 
	, Assets.Multiplier AS Multiplier
	, Positions.PositionId AS BMISCode
	, Assets.IDBloomberg AS BBGId
	, Assets.Description AS BBGTicker
	, Assets.ShortName AS ShortName
	, Positions.Units AS PositionSize
	, Positions.StartPrice AS StartPrice
	, ISNULL(Assets.PxLast, Positions.StartPrice) AS MarketPrice
	, Assets.CCYIso AS AssetCCY
	, AssetsCCY.IsInverse AS AssetCCYIsInverse
	, AssetsCCYQuotes.LastQuote AS AssetCCYQuote
	, AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote
	, Assets.Accrual AS BondAccrual
	, PenceQuotesDivider =
		CASE
			WHEN Assets.DivBy100 = 1 THEN 100
			WHEN Positions.SecurityType = 'Bonds'
				AND Assets.CCYIso = 'BRL' THEN 0.01
		ELSE 1
		END
	, Assets.CountryISO AS CountryISO
	, Country.CountryName AS CountryName
	, Regions.RegionName As CountryRegionName
	, IndustrySector = 
		CASE 
			WHEN (Funds.SectorsDef = 'GICS') AND (@RefDate >= '2010-May-04')
			THEN Assets.GICSSector
		ELSE
			Assets.IndustrySector
		END
	, IndustryGroup =
		CASE 
			WHEN (Funds.SectorsDef = 'GICS') AND (@RefDate >= '2010-May-04')
			THEN Assets.GICSIndustry
		ELSE
			Assets.IndustryGroup
		END
	--, Funds.ADVField
	, ADV = (	CASE 	WHEN (Funds.ADVField = 'VolumeAvg3m') 
					AND (Assets.VolumeAvg3m IS NOT NULL)
				THEN NULLIF(Assets.VolumeAvg3m, 0)
				ELSE NULLIF(Assets.VolumeAvg20d, 0)
				END)
	, Assets.SPRating AS SPRating
	, Ratings.CleanRating AS SPCleanRating
	, Ratings.RankNo AS SPRatingRank
	, Assets.YearsToMaturity AS BondYearsToMaturity
	, Assets.MarketStatus AS EquityMarketStatus
	, Assets.TotalReturnEq AS EquityTotalReturn
	, Assets.Accrual1dBond AS BondAccrual1D
	, ISNULL(ISNULL(Options.UnderBeta, Assets.Beta),1) AS Beta
	, Assets.Size
	, Assets.Value
	, Assets.IsManualPrice
	, Assets.ROE
	, Assets.EPSGrowth
	, Assets.SalesGrowth
	, Assets.BtP
	, (CASE WHEN Assets.SecurityGroup = 'FixedIn' THEN NULL ELSE Assets.DivYield END) AS DivYield
	, (CASE WHEN Assets.SecurityGroup = 'FixedIn' THEN NULL ELSE Assets.EarnYield END) AS EarnYield
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
	, (CASE WHEN Assets.SecurityGroup = 'FixedIn' THEN Assets.DivYield ELSE NULL END) AS OAS
	, (CASE WHEN Assets.SecurityGroup = 'FixedIn' THEN Assets.EarnYield ELSE NULL END) AS CnvYield
	, ISNULL(Options.UnderEffDur, Assets.EffDur) AS EffDur
	, Assets.InflDur
	, Assets.RealDur
	, Assets.SpreadDur
	, Assets.CoupType
	, Assets.Bullet AS IsBullet
	, Assets.SecType
	, Assets.CollType
	, MktSector.Name AS MktSector
	, Assets.ShortMoM
	, Options.Description AS OptDescription
	, Options.CallPut AS OptCallPut
	, Options.Delta AS OptDelta
	, Options.Gamma AS OptGamma
	, Options.Vega AS OptVega
	, Options.DaysToExp AS OptDaysToExp
	, Options.ExpiryDate AS OptExpiryDate
	, Options.Underlying AS OptUnderlying
	, Options.UnderEffDur AS OptUnderEffDur
	, Options.UnderMult AS OptUnderMult
	, Options.Strike AS OptStrike
	, Options.UnderPrice AS OptUnderPrice
	, Options.UnderPxScale AS OptPxScale
	, Options.CCYUnder AS OptCCYUnder
	, Options.UnderValPt AS OptUnderValPt
	, Options.IsCashSettle AS OptIsCashSettle
	, Options.ConvFactor AS UnderFutConvFactor
	, ISNULL(Options.CTD, Futures.CTD) AS UnderlyingCTD
	, CcyOptUnderCcyQuotes.LastQuote AS CcyOptUnderQuote
	, CcyOptUnderCcyQuotes.IsInverse AS CcyOptUnderIsInverse
	, Futures.Contractsize As FutContractSize
	, Futures.Category AS FutCategory
	, Futures.PointValue AS FutPointValue
	, Futures.TickSize AS FutTickSize
	, ISNULL(Futures.InitialMargin, 0) AS FutInitialMargin
	, ISNULL(Futures.ConvFactor, 1) AS ConvFactor
	, CountMeExp = 
		CASE
			WHEN Assets.SecurityGroup = 'CashFX' AND Funds.FundClassId <> 5 
			THEN 0
			ELSE 1
		END
	, IsFuture = CASE WHEN Futures.ListDerivType = 'Future' THEN 1 ELSE 0 END

INTO	#BASEDATA

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
		) LEFT JOIN
	tbl_OptionsData AS Options ON (
		Assets.securityId = Options.SecurityId
		AND Assets.PriceDate = Options.PriceDate	
		) LEFT JOIN
	vw_FxQuotes AS CcyOptUnderCcyQuotes ON (
		Positions.PositionDate = CcyOptUnderCcyQuotes.FXQuoteDate AND
		Options.CCYUnder = CcyOptUnderCcyQuotes.ISO
		) LEFT JOIN
	tbl_FuturesData AS Futures ON (
		Assets.securityId = Futures.FuturesId
		AND Assets.PriceDate = Futures.PriceDate	
		)
	
WHERE 	((@RefDate IS NULL) OR (Assets.PriceDate = @RefDate)) AND
	((@FundId Is NULL) OR (Funds.Id = @FundId)) AND
	Assets.CCYIso <> '---'
--------------------------------------------------------------------------------------------------
	

SELECT	PositionDate
	, Fundid
	, SecurityType
	, BMISCode
	--, Get CostValue
	, dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual 
			* (CASE WHEN RawData.SecurityType = 'Bonds'
				AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END) 
		- RawData.BondAccrual1d 		-- this is a change from Live
		, RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.PositionSize * 
		(CASE WHEN RawData.SecurityType in ('IntRateOpt', 'CcyOpt')
			THEN
				-- not happy about this one: need to check why and possibly amend
				RawData.OptUnderValPt
			ELSE
				RawData.Multiplier/
				RawData.PriceDivider/
				RawData.PenceQuotesDivider 
		END) AS BaseCCYCostValue

	-- Get MarketValue
	, dbo.fn_GetBaseCCYPrice(RawData.MarketPrice + RawData.BondAccrual 
			* (CASE WHEN RawData.SecurityType = 'Bonds'
				AND RawData.AssetCCY = 'BRL' THEN 0 ELSE 1 END)
		, RawData.AssetCCYQuote		-- matching change above getting rid of 1d accrual vs. live
		, RawData.AssetCCYIsInverse
		, RawData.BaseCCYQuote
		, RawData.FundBaseCCYIsInverse
		, RawData.SecurityType
		, 0) * RawData.PositionSize * 
		(CASE WHEN RawData.SecurityType in ('IntRateOpt', 'CcyOpt')
			THEN
				-- not happy about this one: need to check why and possibly amend
				RawData.OptUnderValPt
			ELSE
				RawData.Multiplier/
				RawData.PriceDivider/
				RawData.PenceQuotesDivider 
		END) AS BaseCCYMarketValue

	-- Get Asset performance
	, AssetReturn = 
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
		END

	-- Get Fx performance
	, FxReturn =
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
		END
	-- Get Asset Exposure
	, BaseCCYExposure = (CASE 
		WHEN RawData.SecurityType in ('IntRateFut') THEN 
		dbo.fn_GetBaseCCYPrice(
			100 ,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.Multiplier/
		RawData.PriceDivider

		WHEN RawData.SecurityType in ('IntRateOpt') THEN 
		dbo.fn_GetBaseCCYPrice(1,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.OptDelta * 
		RawData.Multiplier/
		RawData.PriceDivider
		
		WHEN RawData.SecurityType in ('BondFutOpt', 'EqOpt', 'IndexOpt') THEN 
		dbo.fn_GetBaseCCYPrice(RawData.OptUnderPrice,
			RawData.AssetCCYQuote,
			RawData.AssetCCYIsInverse,
			RawData.BaseCCYQuote,
			RawData.FundBaseCCYIsInverse,
			RawData.SecurityType,
			0) * 
		RawData.PositionSize * 
		RawData.OptDelta * 
		RawData.Multiplier /
		RawData.OptPXScale /
		RawData.PenceQuotesDivider /
		RawData.PriceDivider * 
		RawData.UnderFutConvFactor

		WHEN RawData.SecurityType in ('CCYOpt') THEN 0 -- This has to be developed
		WHEN RawData.SecurityType in ('CCYFut') THEN 0 -- This has to be developed

		ELSE 
		dbo.fn_GetBaseCCYPrice(
			RawData.MarketPrice + 
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
		RawData.Multiplier/
		RawData.PriceDivider/
		RawData.PenceQuotesDivider *
		RawData.ConvFactor
	END)
	, LongShort = dbo.fn_GetLongShort(
			RawData.PositionSize,
			RawData.SecurityGroup,
			RawData.AssetCCY,
			RawData.FundBaseCCYCode
			)		


INTO	#ADDEDCALC

FROM	#BASEDATA AS RawData

--------------------------------------------------------------------------------------------------
	
SELECT	BaseData.PositionDate
	, BaseData.FundId
	, BaseData.FundIsAlive
	, BaseData.FundIsSkip
	, BaseData.FundCode
	, BaseData.FundBaseCCYId
	, BaseData.FundBaseCCYCode
	, BaseData.FundBaseCCYIsInverse
	, BaseData.BaseCCYQuote
	, BaseData.BaseCCYPrevQuote
	, BaseData.SecurityType
	, BaseData.SecurityGroup
	, BaseData.IsAssetPriceChange
	, BaseData.PriceDivider
	, BaseData.IsDerivative 
	, BaseData.Multiplier
	, BaseData.BMISCode
	, BaseData.BBGId
	, BaseData.BBGTicker
	, BaseData.ShortName
	, BaseData.PositionSize
	, BaseData.StartPrice
	, BaseData.MarketPrice
	, BaseData.AssetCCY
	, BaseData.AssetCCYIsInverse
	, BaseData.AssetCCYQuote
	, BaseData.AssetCCYPrevQuote
	, BaseData.BondAccrual
	, BaseData.PenceQuotesDivider
	, BaseData.CountryISO
	, BaseData.CountryName
	, BaseData.CountryRegionName
	, BaseData.IndustrySector
	, BaseData.IndustryGroup
	, BaseData.ADV
	, CASE WHEN LEFT(BaseData.SPRating, 1) = '#' THEN NULL ELSE BaseData.SPRating END 
		AS SPRating
	, CASE WHEN LEFT(BaseData.SPCleanRating, 1) = 'I' THEN NULL ELSE BaseData.SPCleanRating END 
		AS SPCleanRating
	, BaseData.SPRatingRank
	, BaseData.BondYearsToMaturity
	, BaseData.EquityMarketStatus
	, BaseData.EquityTotalReturn
	, BaseData.BondAccrual1D
	, BaseData.Beta
	, CASE WHEN LEN(BaseData.Size) = 0 THEN NULL ELSE BaseData.Size END AS Size
	, CASE WHEN LEN(BaseData.Value) = 0 THEN NULL ELSE BaseData.Value END AS Value
	, BaseData.IsManualPrice
	, BaseData.ROE
	, BaseData.EPSGrowth
	, BaseData.SalesGrowth
	, BaseData.BtP
	, BaseData.DivYield
	, BaseData.EarnYield
	, BaseData.StP
	, BaseData.EbitdaTP
	, BaseData.MktCapLocal
	, BaseData.MktCapUSD
	, NULLIF(BaseData.KRD3m, 0) AS KRD3m
	, NULLIF(BaseData.KRD6m, 0) AS KRD6m
	, NULLIF(BaseData.KRD1y, 0) AS KRD1y
	, NULLIF(BaseData.KRD2y, 0) AS KRD2y
	, NULLIF(BaseData.KRD3y, 0) AS KRD3y
	, NULLIF(BaseData.KRD4y, 0) AS KRD4y
	, NULLIF(BaseData.KRD5y, 0) AS KRD5y
	, NULLIF(BaseData.KRD6y, 0) AS KRD6y
	, NULLIF(BaseData.KRD7y, 0) AS KRD7y
	, NULLIF(BaseData.KRD8y, 0) AS KRD8y
	, NULLIF(BaseData.KRD9y, 0) AS KRD9y
	, NULLIF(BaseData.KRD10y, 0) AS KRD10y
	, NULLIF(BaseData.KRD15y, 0) AS KRD15y
	, NULLIF(BaseData.KRD20y, 0) AS KRD20y
	, NULLIF(BaseData.KRD25y, 0) AS KRD25y
	, NULLIF(BaseData.KRD30y, 0) AS KRD30y
	, BaseData.OAS
	, BaseData.CnvYield
	, NULLIF(BaseData.EffDur, 0) AS EffDur
	, NULLIF(BaseData.InflDur, 0) AS InflDur
	, NULLIF(BaseData.RealDur, 0) AS RealDur
	, NULLIF(BaseData.SpreadDur, 0) AS SpreadDur
	, CASE WHEN LEN(BaseData.CoupType) = 0 THEN NULL ELSE BaseData.CoupType END AS CoupType
	, BaseData.IsBullet
	, CASE WHEN LEN(BaseData.SecType) = 0 THEN NULL ELSE BaseData.SecType END AS SecType
	, CASE WHEN LEN(BaseData.CollType) = 0 THEN NULL ELSE BaseData.CollType END AS CollType
	, BaseData.MktSector
	, BaseData.ShortMoM
	, BaseData.OptDescription
	, BaseData.OptCallPut
	, BaseData.OptDelta
	, BaseData.OptGamma
	, BaseData.OptVega
	, BaseData.OptDaysToExp
	, BaseData.OptExpiryDate
	, BaseData.OptUnderlying
	, BaseData.OptUnderEffDur
	, BaseData.OptUnderMult
	, BaseData.OptStrike
	, BaseData.OptUnderPrice
	, BaseData.OptPxScale
	, BaseData.OptCCYUnder
	, BaseData.OptUnderValPt
	, BaseData.OptIsCashSettle
	, BaseData.UnderFutConvFactor
	, CASE 	WHEN (LEN(BaseData.UnderlyingCTD) = 0) OR (BaseData.UnderlyingCTD IS NULL)
			THEN BaseData.BBGTicker 
		ELSE BaseData.UnderlyingCTD END AS UnderlyingCTD
	, BaseData.CcyOptUnderQuote
	, BaseData.CcyOptUnderIsInverse
	, BaseData.FutContractSize
	, BaseData.FutCategory
	, BaseData.FutPointValue
	, BaseData.FutTickSize
	, BaseData.FutInitialMargin
	, BaseData.ConvFactor
	, BaseData.CountMeExp
	, BaseData.IsFuture 
	, AddedCalc.BaseCCYCostValue
	, AddedCalc.BaseCCYMarketValue
	, AddedCalc.AssetReturn
	, AddedCalc.FXReturn
	, CASE WHEN BaseData.SecurityType IN ('FutOft') THEN 0 ELSE AddedCalc.BaseCCYExposure END
		AS BaseCCYExposure
	, AddedCalc.LongShort

FROM	#BASEDATA AS BaseData LEFT JOIN
	#ADDEDCALC AS AddedCalc ON
		(BaseData.PositionDate = AddedCalc.PositionDate
		AND BaseData.FundId = AddedCalc.FundId
		AND BaseData.SecurityType = AddedCalc.SecurityType
		AND BaseData.BMISCode = AddedCalc.BMIScode)

--------------------------------------------------------------------------------------------------

DROP TABLE #BASEDATA
DROP TABLE #ADDEDCALC

--------------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spS_CubeData_V2 TO [OMAM\StephaneD], [OMAM\MargaretA] 
