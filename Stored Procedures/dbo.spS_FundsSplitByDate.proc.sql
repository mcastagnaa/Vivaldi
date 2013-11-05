USE RM_PTFL
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_FundsSplitByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_FundsSplitByDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_FundsSplitByDate] 
	@RefDate datetime
AS
SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate,
	Funds.Id AS FundId,
	FundClasses.ShortName AS FundClass,
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
	Assets.Multiplier AS FuturesMultiplier,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGTicker,
	Assets.ShortName AS BondIssuer,
	Positions.Units AS PositionSize,
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
		WHEN Positions.SecurityType = 'Bonds'
			AND Assets.CCYIso = 'BRL' THEN 0.01
		ELSE 1
	END,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Regions.RegionName As CountryRegionName,
	Assets.IndustrySector AS IndustrySector,
	Assets.IndustryGroup AS IndustryGroup,
	LongShort = dbo.fn_GetLongShort(
			Positions.Units,
			Assets.SecurityGroup,
			Assets.CCYIso,
			FundsCCY.ISO3
			)	

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
		) LEFT JOIN
	tbl_FundClasses AS FundClasses ON (
		Funds.FundClassId = FundClasses.Id
		)
	
WHERE 	Assets.PriceDate = @RefDate AND
	Assets.CCYIso <> '---' AND
	Funds.Alive = 1

----------------------------------------------------------------------------------

SELECT	RawData.FundId,
	RawData.FundCode,
	RawData.FundClass,
	RawData.FundBaseCCYCode,
	RawData.SecurityType,
	RawData.SecurityGroup,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	(dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual
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
			RawData.PenceQuotesDivider)/Navs.CostNaV AS PercBaseCCYCostValue,
	RawData.CountryISO,
	RawData.CountryName,
	RawData.CountryRegionName,
	RawData.IndustrySector,
	RawData.IndustryGroup,
	RawData.LongShort

--INTO	#Interim

FROM	#RawData AS RawData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		RawData.FundId = NaVs.FundId AND
		RawData.PositionDate = NaVs.NaVPLDate
		)

--WHERE RawData.LongShort <> 'CashBaseCCY'

-----------------------------------------------------------------------



-------------------------------------------------------------------------

DROP Table #RawData

-------------------------------------------------------------------------

GO

GRANT EXECUTE ON spS_FundsSplitByDate TO [OMAM\StephaneD], [OMAM\MargaretA]