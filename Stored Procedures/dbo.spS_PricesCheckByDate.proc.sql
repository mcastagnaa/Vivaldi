USE VIVALDI
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_PricesCheckByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_PricesCheckByDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_PricesCheckByDate] 
	@RefDate datetime,
	@FItolerance float,
	@EQtolerance float

AS
SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate,
	Assets.SecurityGroup AS SecurityGroup,
	(CASE Assets.SecurityGroup 
		WHEN 'FixedIn'	THEN @FItolerance
		--WHEN 'Equities'	THEN @EQtolerance END) AS Tolerance,
		ELSE @EQtolerance END) AS Tolerance,
	Assets.SecurityType AS SecurityType,
	BMISAssets.PriceDivider AS PriceDivider,
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Assets.ShortName AS BondIssuer,
	Positions.StartPrice AS StartPrice,
	ISNULL(Assets.PxLast, Positions.StartPrice) AS MarketPrice,
	PriceChange = 
	CASE
		WHEN Positions.StartPrice = 0 THEN NULL
		ELSE (ISNULL(Assets.PxLast, Positions.StartPrice)/Positions.StartPrice - 1)
	END,
	Assets.CCYIso AS AssetCCY,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	Assets.Accrual AS BondAccrual,
	PenceQuotesDivider =
	CASE
		WHEN Assets.DivBy100 = 1 THEN 100
		ELSE 1
	END,
	Assets.CountryISO AS CountryISO,
	Assets.TotalReturnEq AS EquityTR,
	Country.CountryName AS CountryName,
	Regions.RegionName As CountryRegionName,
	Assets.IndustrySector AS IndustrySector,
	Assets.IndustryGroup AS IndustryGroup,
	VolumeAvg20d =
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
	Assets.Accrual1dBond AS BondAccrual1D

INTO	#RawData

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_CcyDetails AS AssetsCCY ON (
		Assets.CCYIso = AssetsCCY.ISO3
		) LEFT JOIN
	tbl_FxQuotes AS AssetsCCYQuotes ON (
		Positions.PositionDate = AssetsCCYQuotes.LastQuoteDate AND
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
		)
	
WHERE 	Assets.PriceDate = @RefDate AND
	BMISAssets.PricePercChangeMethod = 1

----------------------------------------------------------------------------------

SELECT	RawData.SecurityType,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.StartPrice,
	RawData.MarketPrice,
	RawData.PriceChange,
	RawData.EquityTR,
	RawData.CountryName,
	RawData.IndustrySector,
	RawData.IndustryGroup,
	RawData.SPCleanRating,
	RawData.BondYearsToMaturity,
	RawData.EquityMarketStatus

FROM	#RawData AS RawData 

WHERE	ABS(PriceChange) > RawData.Tolerance
--WHERE RawData.SecurityType = 'CFD'

GROUP BY	RawData.SecurityType,
		RawData.BMISCode,
		RawData.BBGTicker,
		RawData.AssetCCY,
		RawData.StartPrice,
		RawData.MarketPrice,
		RawData.EquityTR,
		RawData.PriceChange,
		RawData.CountryName,
		RawData.IndustrySector,
		RawData.IndustryGroup,
		RawData.SPCleanRating,
		RawData.BondYearsToMaturity,
		RawData.EquityMarketStatus

DROP Table #RawData

GO

GRANT EXECUTE ON spS_PricesCheckByDate TO [OMAM\StephaneD]