USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_PLRawData]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_PLRawData]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_PLRawData]
AS

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
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Assets.ShortName AS BondIssuer,
	Positions.Units AS Size,
	Positions.StartPrice AS StartPrice,
	isnull(Assets.PxLast, Positions.StartPrice) AS MarketPrice,
	Assets.CCYIso AS AssetCCY,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	Assets.Accrual AS BondAccrual,
	Assets.DivBy100 AS DivBy100,
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
	tbl_FxQuotes AS BaseCCYQuotes ON (
		Positions.PositionDate = BaseCCYQuotes.LastQuoteDate AND
		FundsCCY.ISO3 = BaseCCYQuotes.ISO
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
		)
	

WHERE Assets.PriceDate >= '2009-8-5'