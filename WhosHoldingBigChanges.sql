SELECT 	Positions.PositionDate AS PositionDate,
	Assets.SecurityGroup AS SecurityGroup,
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
	
WHERE 	Assets.PriceDate = '2010-Feb-22' AND
	BMISAssets.PricePercChangeMethod = 1

----------------------------------------------------------------------------------

SELECT	RawData.SecurityType,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.StartPrice,
	RawData.MarketPrice,
	RawData.PriceChange,
	RawData.FuturesMultiplier,
	RawData.PriceDivider,
	RawData.EquityTR,
	RawData.CountryName,
	RawData.IndustrySector,
	RawData.IndustryGroup,
	RawData.SPCleanRating,
	RawData.BondYearsToMaturity,
	RawData.EquityMarketStatus, 
	RawData.BondAccrual, 
	RawData.AssetCCYPrevQuote,
	RawData.AssetCCYIsInverse,
	RawData.PositionDate,
	RawData.PenceQuotesDivider

INTO	#BigChanges
FROM	#RawData AS RawData 

WHERE	(PriceChange > 0.1 OR
		PriceChange < -0.1)

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
		RawData.EquityMarketStatus, 
		RawData.BondAccrual, 
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.SecurityType,
		RawData.FuturesMultiplier,
		RawData.PriceDivider,
		Rawdata.PositionDate, 
		RawData.PenceQuotesDivider


----------------------------------------------------------------------------------

SELECT	BigChanges.BMISCode
	, BigChanges.BBGTicker
	, BigChanges.StartPrice
	, BigChanges.MarketPrice
	, BigChanges.PriceChange
	, BigChanges.EquityTR
	, Funds.FundCode
	, Positions.Units AS PositionSize
	, NaVs.CostNaV
	, (dbo.fn_GetBaseCCYPrice(BigChanges.StartPrice + BigChanges.BondAccrual,
		BigChanges.AssetCCYPrevQuote,
		BigChanges.AssetCCYIsInverse,
		BaseCCYData.PreviousQuote, 
		BaseCCY.IsInverse,
		BigChanges.SecurityType,
		1) * Positions.Units * 
			BigChanges.FuturesMultiplier/
			BigChanges.PriceDivider/
			BigChanges.PenceQuotesDivider)/NaVs.CostNaV AS PtflWeight
	, (dbo.fn_GetBaseCCYPrice(BigChanges.StartPrice + BigChanges.BondAccrual,
		BigChanges.AssetCCYPrevQuote,
		BigChanges.AssetCCYIsInverse,
		BaseCCYData.PreviousQuote, 
		BaseCCY.IsInverse,
		BigChanges.SecurityType,
		1) * Positions.Units * 
			BigChanges.FuturesMultiplier/
			BigChanges.PriceDivider/
			BigChanges.PenceQuotesDivider)/NaVs.CostNaV *
		BigChanges.EquityTR * 10000 AS BPSEffect

FROM	#BigChanges AS BigChanges LEFT JOIN
	tbl_Positions AS Positions ON (
		BigChanges.BMISCode = Positions.PositionId
		AND BigChanges.SecurityType = Positions.SecurityType
		AND BigChanges.PositionDate = Positions.PositionDate
		) LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_FundsNavsAndPLs AS NAVs ON (
		Funds.Id = Navs.FundId
		AND Navs.NaVPLDate = BigChanges.PositionDate
		) LEFT JOIN
	tbl_CCYDetails AS BaseCCY ON (
		Funds.BaseCCYId = BaseCCY.Id
		) LEFT JOIN
	tbl_FxQuotes AS BaseCCYData ON (
		BaseCCY.ISO3 = BaseCCYData.ISO
		AND BaseCCYData.LastQuoteDate = BigChanges.PositionDate
		)


----------------------------------------------------------------------------------

DROP Table #RawData
DROP Table #BigChanges
