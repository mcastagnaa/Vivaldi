USE Vivaldi
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_HedgeFundsReport_V2]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_HedgeFundsReport_V2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_HedgeFundsReport_V2] 
	@RefDate datetime
	, @FundId Integer

AS
SET NOCOUNT ON;

----------------------------------------------------------------------------------

SELECT 	*
	, ROUND(MktCapLocal/(MarketPrice/PenceQuotesDivider),0) AS MKtUnits
INTO 	#RawData
FROM 	dbo.fn_GetCubeDataTable(@RefDate, @FundId)
WHERE 	FundVehicleId IN (2, 3)
	AND FundCode <> 'MFUT'
	AND FundIsAlive = 1
	AND FundIsSkip = 0
	AND AssetCCY <> '---'

----------------------------------------------------------------------------------

SELECT	RawData.FundId
	, RawData.FundCode
	, RawData.FundClass
	, RaWData.SecurityType
	, RaWData.SecurityGroup
	, RawData.FundBaseCCYCode
	, RawData.BMISCode
	, RawData.BBGTicker
	, RawData.AssetCCY
	, RawData.PositionSize
	, RawData.StartPrice
	, RawData.BaseCCYExposure/NaVs.CostNaV AS PercBaseCCYExposure
	--, NaVs.CostNaV AS NaV
	--, NaVs.NetExposure - ISNULL(NaVs.FiShortBonds,0) AS NetExposure
	--, NaVs.GrossExposure - ISNULL(NaVs.FiShortBonds, 0) AS GrossExposure
	--, NaVs.PositionsCount
	--, NaVs.CCYExposure
	, RawData.CountryISO
	, RawData.CountryName
	, ABS(RawData.PositionSize)/RawData.ADV AS PercDayVol
	, ABS(RawData.PositionSize)/RawData.MktUnits AS PercMarketCap
	, RawData.IsLxEM
	, RawData.CountryRegionName
	, RawData.IndustrySector
	, RawData.IndustryGroup
	, RawData.LongShort

INTO	#Interim

FROM	#RawData AS RawData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		RawData.FundId = NaVs.FundId AND
		RawData.PositionDate = NaVs.NaVPLDate
		)

WHERE	RawData.LongShort <> 'CashBaseCCY'



-----------------------------------------------------------------------

SELECT	*  
INTO 	#InterimNames  
FROM 	#Interim 
WHERE	IndustrySector NOT IN ('Funds', 'Equity Index')

-----------------------------------------------------------------------

SELECT	one.FundCode
	, one.FundBaseCCYCode AS FundCCY
	, one.BBGTicker AS TopTicker
	, one.PercBaseCCYExposure AS TopSecPerc
	, COUNT(*) AS Id

INTO	#TopTwoSec

FROM	#InterimNames as one INNER JOIN
	#InterimNames as two ON (
		two.FundCode = one.FundCode
		AND two.PercBaseCCYExposure >= one.PercBaseCCYExposure
		AND two.securityGroup = one.SecurityGroup
		)

WHERE	one.securityGroup <> 'CashFx' OR
	one.FundClass = 'FX'

GROUP BY	one.FundCode
		, one.FundBaseCCYCode
		, one.BBGTicker
		, one.PercBaseCCYExposure

HAVING COUNT(*) <= 2
	
-------------------------------------------------------------------------

SELECT	one.FundCode
	, one.BBGTicker AS BotTicker
	, one.PercBaseCCYExposure AS BotSecPerc
	, COUNT(*) AS Id

INTO	#BotTwoSec

FROM	#InterimNames as one INNER JOIN
	#InterimNames as two ON (
		two.FundCode = one.FundCode
		AND two.PercBaseCCYExposure <= one.PercBaseCCYExposure
		AND two.securityGroup = one.SecurityGroup
		)

WHERE	one.securityGroup <> 'CashFx' OR
	one.FundClass = 'FX'

GROUP BY	one.FundCode
		, one.BBGTicker
		, one.PercBaseCCYExposure

HAVING COUNT(*) <= 2


-------------------------------------------------------------------------

SELECT	BaseData.FundCode
	, BaseData.IndustrySector
	, SUM(ABS(BaseData.PercBaseCCYExposure)) AS IndSecGrossExposure
	, SUM(BaseData.PercBaseCCYExposure) AS IndSecNetExposure

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
	, BaseData.IsLXEM
	, SUM(ABS(BaseData.PercBaseCCYExposure)) AS CountryGrossExposure
	, SUM(BaseData.PercBaseCCYExposure) AS CountryNetExposure

INTO	#CountryExp

FROM	#Interim AS BaseData

WHERE	BaseData.securityGroup <> 'CashFx' OR 
	BaseData.FundClass = 'FX'		

GROUP BY	BaseData.FundCode
		, BaseData.CountryName
		, BaseData.IsLXEM


-------------------------------------------------------------------------

SELECT	FundCode
	, SUM(CountryNetExposure) AS LxEMNetExp
	, SUM(ABS(CountryNetExposure)) AS LxEMGrossExp

INTO	#LxEM

FROM	#CountryExp
WHERE	IsLXEM = 1

GROUP BY FundCOde


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

SELECT	FundCode
	, IlliquidShare = SUM(CASE WHEN ItmData.IsLxEM = 1
		OR ItmData.PercDayVol > 0.5
		OR ItmData.PercMarketCap > 0.01
			THEN ABS(PercBaseCCYExposure)
			ELSE 0 END)

INTO	#IlliquidData
FROM	#Interim AS ItmData
WHERE	SecurityGroup <> 'CashFx'

GROUP BY	FundCode


-------------------------------------------------------------------------

SELECT	FundCode
	, VeryIllShare = SUM(CASE WHEN ItmData.PercDayVol > 2
		OR ItmData.PercMarketCap > 0.02
			THEN ABS(PercBaseCCYExposure)
			ELSE 0 END)

INTO	#VeryIllData
FROM	#Interim AS ItmData
	
GROUP BY	FundCode

-------------------------------------------------------------------------

SELECT	FundCode
	, NotAllowedShare = SUM(CASE WHEN ItmData.PercDayVol > 7
			THEN ABS(PercBaseCCYExposure)
			ELSE 0 END)

INTO	#NotAllowed
FROM	#Interim AS ItmData
	
GROUP BY	FundCode


-------------------------------------------------------------------------

SELECT	TopTwoSec.FundCode AS FundCode
	, TopTwoSec.FundCCY As FundCCY
	, Main.PositionsCount AS PositionsCount
	, Main.GrossExposure - ISNULL(Main.FiShortBonds,0) As GrossExposure
	, Main.NetExposure - ISNULL(Main.FiShortBonds,0) AS NetExposure
	, (Main.GrossExposure + Main.NetExposure - 2 * ISNULL(Main.FiShortBonds,0))/2 AS LMV	
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
	, Main.CCYExposure AS CCyExp
	, CtryExp.LxEMGrossExp
	, CtryExp.LxEMNetExp
	, IllShares.IlliquidShare AS LxIlliquid
	, VeryIllShares.VeryIllShare AS LxVeryIlliquid
	, NotAllwdShares.NotAllowedShare AS LxNotAllowed
	, Main.CostNaV AS NaV
	
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
		) LEFT JOIN
	#LxEM AS CtryExp ON (
		CtryExp.FundCode = Funds.FundCode 
		) LEFT JOIN
	#IlliquidData AS IllShares ON (
		IllShares.FundCode = Funds.FundCode
		) LEFT JOIN
	#VeryIllData AS VeryIllShares ON (
		VeryIllShares.FundCode = Funds.FundCode
		) LEFT JOIN 
	#NotAllowed AS NotAllwdShares ON (
		NotAllwdShares.FundCode = Funds.FundCode
		)

WHERE	Main.NaVPLDate = @RefDate

ORDER BY	TopTwoSec.FundCode ASC
		, TopTwoSec.Id DESC

-------------------------------------------------------------------------

DROP Table #RawData
DROP Table #Interim
DROP Table #InterimNames

DROP Table #TopTwoSec
DROP Table #BotTwoSec

DROP Table #IndSecExp
DROP Table #TopTwoIndSecExp
DROP Table #BotTwoIndSecExp

DROP Table #IlliquidData
DROP Table #VeryIllData
DROP Table #NotAllowed

DROP Table #CountryExp
DROP Table #LxEM
DROP Table #TopTwoCountryExp
DROP Table #BotTwoCountryExp

-------------------------------------------------------------------------

GO

GRANT EXECUTE ON spS_HedgeFundsReport_V2 TO [OMAM\StephaneD], [OMAM\MargaretA]