USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CashReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CashReport]
GO

CREATE PROCEDURE [dbo].[spS_CashReport] 
	@RefDate datetime,
	@FundId int 
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
	BMISAssets.SecGroup AS SecurityGroup,
	BMISAssets.PricePercChangeMethod AS IsAssetPriceChange,
	BMISAssets.PriceDivider AS PriceDivider,
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Positions.Units AS PositionSize,
	Positions.StartPrice AS StartPrice,
	ISNULL(Assets.PxLast, Positions.StartPrice) AS MarketPrice,
	Assets.CCYIso AS AssetCCY,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	PenceQuotesDivider =
	CASE
		WHEN Assets.DivBy100 = 1 THEN 100
		ELSE 1
	END,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Regions.RegionName As CountryRegionName

INTO #RawData

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
	tbl_BMISAssets AS BMISAssets ON (
		Positions.SecurityType = BMISAssets.AssetName
		)
	
WHERE 	Assets.PriceDate = @RefDate AND
	Funds.Id = @FundId AND
	Assets.CCYIso <> '---' AND
	Positions.SecurityType in ('Cash', 'MMFunds', 'TBills', 'CD')

----------------------------------------------------------------------------------

SELECT	RawData.FundId,
	RaWData.SecurityType,
	RaWData.SecurityGroup,
	RawData.FundBaseCCYCode,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.PositionSize,
	RawData.StartPrice,
	RawData.MarketPrice,
	dbo.fn_GetBaseCCYPrice(RawData.StartPrice,
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) AS BaseCCYCostPrice,
	dbo.fn_GetBaseCCYPrice(RawData.MarketPrice,
		RawData.AssetCCYQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		0) AS BaseCCYMarketPrice,
	dbo.fn_GetBaseCCYPrice(RawData.StartPrice,
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.PositionSize * 
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider AS BaseCCYCostValue,
	dbo.fn_GetBaseCCYPrice(RawData.MarketPrice,
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
	RawData.CountryISO,
	RawData.CountryName,
	RawData.CountryRegionName,
	LongShort = dbo.fn_GetLongShort(
			RawData.PositionSize,
			RawData.SecurityGroup,
			RawData.AssetCCY,
			RawData.FundBaseCCYCode
			)

INTO #Interim

FROM	#RawData AS RawData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		RawData.FundId = NaVs.FundId AND
		RawData.PositionDate = NaVs.NaVPLDate
		)


-----------------------------------------------------------------------

SELECT	Interim.SecurityType,
	Interim.BaseCCYMarketValue AS PostionValue,
	Interim.FundBaseCCYCode,
	Interim.BMISCode,
	Interim.BBGTicker,
	Interim.AssetCCY,
	Interim.PositionSize,
	Interim.StartPrice,
	Interim.MarketPrice,
	Interim.BaseCCYCostValue/Interim.NaV AS PortfolioShare,
	CountryISO,
	CountryName,
	CountryRegionName,
	LongShort

FROM	#Interim as Interim

ORDER BY	Interim.SecurityGroup ASC, 
		BBGTicker ASC

DROP Table #RawData
DROP Table #Interim

GO

GRANT EXECUTE ON spS_CashReport TO [OMAM\StephaneD]
				, [OMAM\MargaretA]
				, [OMAM\OMAM UK OpsTAsupport] 