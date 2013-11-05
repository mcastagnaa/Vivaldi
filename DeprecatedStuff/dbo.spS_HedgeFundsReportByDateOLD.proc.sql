USE RM_PTFL
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_HedgeFundsReportByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_HedgeFundsReportByDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_HedgeFundsReportByDate] 
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
	PositionSize = 
	CASE
		WHEN Positions.SecurityType = 'FX' AND Funds.FundClassId <> 5 THEN 0
		ELSE Positions.Units
	END,
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
	Funds.VehicleId IN (2, 3) AND
	Assets.CCYIso <> '---' AND
	Positions.SecurityType <> 'CashOft'	


----------------------------------------------------------------------------------

SELECT	RawData.FundId,
	RawData.FundCode,
	RawData.FundClass,
	RaWData.SecurityType,
	RaWData.SecurityGroup,
	RawData.FundBaseCCYCode,
	RawData.BMISCode,
	RawData.BBGTicker,
	RawData.AssetCCY,
	RawData.PositionSize,
	RawData.StartPrice,
	(dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual,
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.PositionSize * 
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider)/Navs.CostNaV AS PercBaseCCYCostValue,
	NaVs.CostNaV AS NaV,
	NaVs.NetExposure,
	NaVs.GrossExposure,
	NaVs.PositionsCount,
	RawData.CountryISO,
	RawData.CountryName,
	RawData.CountryRegionName,
	RawData.IndustrySector,
	RawData.IndustryGroup,
	RawData.LongShort

INTO	#Interim

FROM	#RawData AS RawData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		RawData.FundId = NaVs.FundId AND
		RawData.PositionDate = NaVs.NaVPLDate
		)

WHERE	RawData.LongShort <> 'CashBaseCCY'

-----------------------------------------------------------------------

SELECT	one.FundCode
	, one.BBGTicker AS TopTicker
	, one.PercBaseCCYCostValue AS TopSecPerc
	, COUNT(*) AS Id

INTO	#TopTwoSec

FROM	#Interim as one INNER JOIN
	#Interim as two ON (
		two.FundCode = one.FundCode
		AND two.PercBaseCCYCostValue >= one.PercBaseCCYCostValue
		AND two.securityGroup = one.SecurityGroup
		)

WHERE	one.securityGroup <> 'CashFx' OR
	one.FundClass = 'FX'

GROUP BY	one.FundCode
		, one.BBGTicker
		, one.PercBaseCCYCostValue

HAVING COUNT(*) <= 2
	
-------------------------------------------------------------------------

SELECT	one.FundCode
	, one.BBGTicker AS BotTicker
	, one.PercBaseCCYCostValue AS BotSecPerc
	, COUNT(*) AS Id

INTO	#BotTwoSec

FROM	#Interim as one INNER JOIN
	#Interim as two ON (
		two.FundCode = one.FundCode
		AND two.PercBaseCCYCostValue <= one.PercBaseCCYCostValue
		AND two.securityGroup = one.SecurityGroup
		)

WHERE	one.securityGroup <> 'CashFx' OR
	one.FundClass = 'FX'

GROUP BY	one.FundCode
		, one.BBGTicker
		, one.PercBaseCCYCostValue

HAVING COUNT(*) <= 2


-------------------------------------------------------------------------

SELECT	BaseData.FundCode
	, BaseData.IndustrySector
	, SUM(ABS(BaseData.PercBaseCCYCostValue)) AS IndSecGrossExposure
	, SUM(BaseData.PercBaseCCYCostValue) AS IndSecNetExposure

INTO	#IndSecExp

FROM	#Interim AS BaseData

WHERE	BaseData.securityGroup <> 'CashFx' AND
	BaseData.FundClass <> 'FX'

GROUP BY	BaseData.FundCode
		, BaseData.IndustrySector

-------------------------------------------------------------------------

SELECT	one.FundCode
	, one.IndustrySector AS TopIndSec
	, one.IndSecNetExposure AS TopIndSecNetExp
	, (one.IndSecGrossExposure + one.IndSecNetExposure)/2 AS TopIndSecLong	
	, (one.IndSecNetExposure - one.IndSecGrossExposure)/2 AS TopIndSecShort
	, COUNT(*) AS Id

INTO	#TopTwoIndSecExp

FROM	#IndSecExp as one INNER JOIN
	#IndSecExp as two ON (
		two.FundCode = one.FundCode 
		AND two.IndSecNetExposure >= one.IndSecNetExposure
		)

GROUP BY	one.FundCode
		, one.IndustrySector
		, one.IndSecNetExposure
		, one.IndSecGrossExposure

HAVING COUNT(*) <= 2

-------------------------------------------------------------------------

SELECT	one.FundCode
	, one.IndustrySector AS BotIndSec
	, one.IndSecNetExposure AS BotIndSecNetExp
	, (one.IndSecGrossExposure + one.IndSecNetExposure)/2 AS BotIndSecLong	
	, (one.IndSecNetExposure - one.IndSecGrossExposure)/2 AS BotIndSecShort
	, COUNT(*) AS Id


INTO	#BotTwoIndSecExp

FROM	#IndSecExp as one INNER JOIN
	#IndSecExp as two ON (
		two.FundCode = one.FundCode 
		AND two.IndSecNetExposure <= one.IndSecNetExposure
		)

GROUP BY	one.FundCode
		, one.IndustrySector
		, one.IndSecNetExposure
		, one.IndSecGrossExposure

HAVING COUNT(*) <= 2

-------------------------------------------------------------------------

SELECT	BaseData.FundCode
	, BaseData.CountryName
	, SUM(ABS(BaseData.PercBaseCCYCostValue)) AS CountryGrossExposure
	, SUM(BaseData.PercBaseCCYCostValue) AS CountryNetExposure

INTO	#CountryExp

FROM	#Interim AS BaseData

WHERE	BaseData.securityGroup <> 'CashFx' OR 
	BaseData.FundClass = 'FX'		

GROUP BY	BaseData.FundCode
		, BaseData.CountryName

-------------------------------------------------------------------------

SELECT	one.FundCode
	, one.CountryName AS TopCountry
	, one.CountryNetExposure AS TopCountryNetExp
	, (one.CountryGrossExposure + one.CountryNetExposure)/2 AS TopCountryLong	
	, (one.COuntryNetExposure - one.CountryGrossExposure)/2 AS TopCountryShort
	, COUNT(*) AS Id

INTO	#TopTwoCountryExp

FROM	#CountryExp as one INNER JOIN
	#CountryExp as two ON (
		two.FundCode = one.FundCode 
		AND two.CountryNetExposure >= one.CountryNetExposure
		)

GROUP BY	one.FundCode
		, one.CountryName
		, one.CountryNetExposure
		, one.CountryGrossExposure

HAVING COUNT(*) <= 2

-------------------------------------------------------------------------

SELECT	one.FundCode
	, one.CountryName AS BotCountry
	, one.CountryNetExposure AS BotCountryNetExp
	, (one.CountryGrossExposure + one.CountryNetExposure)/2 AS BotCountryLong	
	, (one.CountryNetExposure - one.CountryGrossExposure)/2 AS BotCountryShort
	, COUNT(*) AS Id

INTO	#BotTwoCountryExp

FROM	#CountryExp as one INNER JOIN
	#CountryExp as two ON (
		two.FundCode = one.FundCode 
		AND two.COuntryNetExposure <= one.CountryNetExposure
		)

GROUP BY	one.FundCode
		, one.CountryName
		, one.CountryNetExposure
		, one.CountryGrossExposure

HAVING COUNT(*) <= 2


-------------------------------------------------------------------------

SELECT	TopTwoSec.FundCode AS FundCode
	, Main.PositionsCount AS PositionsCount
	, Main.GrossExposure As GrossExposure
	, Main.NetExposure AS NetExposure
	, (Main.GrossExposure + Main.NetExposure)/2 AS LMV	
	, (Main.NetExposure - Main.GrossExposure)/2 AS SMV
	, TopTwoSec.TopTicker 
	, TopTwoSec.TopSecPerc
	, BotTwoSec.BotTicker
	, BotTwoSec.BotSecPerc
	, TopTwoIndSecExp.TopIndSec
	, TopTwoIndSecExp.TopIndSecNetExp
	, TopTwoIndSecExp.TopIndSecLong	
	, TopTwoIndSecExp.TopIndSecShort
	, BotTwoIndSecExp.BotIndSec
	, BotTwoIndSecExp.BotIndSecNetExp
	, BotTwoIndSecExp.BotIndSecLong	
	, BotTwoIndSecExp.BotIndSecShort
	, TopTwoCountryExp.TopCountry
	, TopTwoCountryExp.TopCountryNetExp
	, TopTwoCountryExp.TopCountryLong	
	, TopTwoCountryExp.TopCountryShort
	, BotTwoCountryExp.BotCountry
	, BotTwoCountryExp.BotCountryNetExp
	, BotTwoCountryExp.BotCountryLong	
	, BotTwoCountryExp.BotCountryShort
	
FROM 	#TopTwoSec AS TopTwoSec LEFT JOIN 
	tbl_Funds AS Funds ON (
		TopTwoSec.FundCode = Funds.FundCode
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS Main ON (
		Funds.Id = Main.FundId
		) LEFT JOIN
	#BotTwoSec AS BotTwoSec ON (
		TopTwoSec.FundCode = BotTwoSec.FundCode
		AND TopTwoSec.Id = BotTwoSec.Id
		) LEFT JOIN
	#TopTwoIndSecExp AS TopTwoIndSecExp ON (
		TopTwoSec.FundCode = TopTwoIndSecExp.FundCode
		AND TopTwoSec.Id = TopTwoIndSecExp.Id
		) LEFT JOIN
	#BotTwoIndSecExp AS BotTwoIndSecExp ON (
		TopTwoSec.FundCode = BotTwoIndSecExp.FundCode
		AND TopTwoSec.Id = BotTwoIndSecExp.Id
		) LEFT JOIN
	#TopTwoCountryExp AS TopTwoCountryExp ON (
		TopTwoSec.FundCode = TopTwoCountryExp.FundCode
		AND TopTwoSec.Id = TopTwoCountryExp.Id
		) LEFT JOIN
	#BotTwoCountryExp AS BotTwoCountryExp ON (
		TopTwoSec.FundCode = BotTwoCountryExp.FundCode
		AND TopTwoSec.Id = BotTwoCountryExp.Id
		)

WHERE	Main.NaVPLDate = @RefDate

ORDER BY	TopTwoSec.FundCode ASC
		, TopTwoSec.Id DESC

-------------------------------------------------------------------------

DROP Table #RawData
DROP Table #Interim

DROP Table #TopTwoSec
DROP Table #BotTwoSec

DROP Table #IndSecExp
DROP Table #TopTwoIndSecExp
DROP Table #BotTwoIndSecExp

DROP Table #CountryExp
DROP Table #TopTwoCountryExp
DROP Table #BotTwoCountryExp

-------------------------------------------------------------------------

GO

GRANT EXECUTE ON spS_HedgeFundsReportByDate TO [OMAM\StephaneD], [OMAM\MargaretA]