USE Vivaldi
GO

/*
DECLARE @PercDayVol float
SET @PercDayVol = 0.1

----------------------------------------------------------------------------------
SELECT * INTO #CubeData FROM fn_GetCubeDataTable(null, 43)
----------------------------------------------------------------------------------

SELECT	CubeData.PositionDate
	, CubeData.SecurityGroup
	, CubeData.SecurityType
	, CubeData.IsDerivative
	, CubeData.BMISCode
	, CubeData.BBGTicker
	, CubeData.UnderlyingCTD AS Underlying
	, CubeData.BaseCCYCostValue AS CostMarketVal
	, CubeData.BaseCCYCostValue / NaVs.CostNaV AS Weight
	, CubeData.BaseCCYExposure AS CostExposureVal
	, CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp AS ExpWeight
	, CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta AS ExpWeightBetaAdj
	, CubeData.AssetCCY
	, CubeData.PositionSize
	, CubeData.StartPrice
	, CubeData.MarketPrice
	, CubeData.AssetReturn AS AssetChange
	, CubeData.FxReturn AS FxChange
--BaseCCY PL
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue AS AssetPL
	, CubeData.FXReturn * CubeData.BaseCCYCostValue AS FxPL
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) AS TotalPL
--PL in Bps of CostNaV
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue / NaVs.CostNaV AS AssetPLOnNaV
	, CubeData.FXReturn * CubeData.BaseCCYCostValue / NaVs.CostNaV AS FXPLOnNaV
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1)/ NaVs.CostNaV
		 AS PLOnNaV
--PL over TotalPL
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue/NULLIF(NaVs.TotalPL, 0) AS AssetPLonTotalPL
	, CubeData.FXReturn * CubeData.BaseCCYCostValue/NULLIF(NaVs.TotalPL, 0) AS FxPLonTotalPL
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) / NULLIF(NaVs.TotalPL, 0)
		 AS PLOnTotalPL

	, CubeData.CountryISO
	, CubeData.CountryName
	, CubeData.CountryRegionName AS CountryRegion
	, CubeData.IndustrySector
	, CubeData.IndustryGroup
	, CubeData.SPCleanRating
	, CubeData.SPRatingRank
	, CubeData.BondYearsToMaturity AS YearsToMat
	, CubeData.EquityMarketStatus AS EquityMktStatus
	, CubeData.LongShort
	, (CASE WHEN (CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta) >= 0 THEN 'LongBAdj'
		ELSE 'ShortBAdj' END) AS LongShortBAdj
	, DaysToLiquidate = 
		NULLIF(
			ABS(CubeData.PositionSize) / 
			(CubeData.ADV * ISNULL(@PercDayVol, CubeData.PercDayVolume))
		, CubeData.ADV)
	, CubeData.Beta
	, CubeData.Size
	, CubeData.Value
	, CubeData.IsManualPrice
	, CubeData.ROE
	, CubeData.EPSGrowth
	, CubeData.SalesGrowth
	, CubeData.BtP
	, CubeData.DivYield
	, CubeData.EarnYield
	, CubeData.StP
	, CubeData.EbitdaTP
	, CubeData.MktCapLocal
	, CubeData.MktCapUSD
	, CubeData.SecType
	, CubeData.CollType
	, CubeData.MktSector
	, CubeData.ShortMom
	, UpDown = CASE	WHEN CubeData.ShortMom > 0 THEN 'Up' 
			WHEN CubeData.ShortMom < 0 THEN 'Down' 
			ELSE NULL 
		END
	, CASE WHEN CubeData.FutInitialMargin <> 0 THEN
		dbo.fn_GetBaseCCYPrice(ABS(CubeData.PositionSize) * CubeData.FutInitialMargin
			, CubeData.AssetCCYQuote
			, CubeData.AssetCCYIsInverse
			, CubeData.BaseCCYQuote
			, CubeData.FundBaseCCYIsInverse
			, CubeData.SecurityType
			, 0) / NaVs.CostNaV 
		ELSE 0 END
		AS MarginBaseOnNaV
	, BBGId
	, AllExpWeights = CASE  WHEN CubeData.LongShort <> 'CashBaseCCY'
				THEN CubeData.BaseCCYExposure / NaVs.CostNaV
				ELSE 0
				END
	, CubeData.FundClass
	, CubeData.FundIsAlive
	, CubeData.FundIsSkip
	, CubeData.FundBaseCCYCode AS FundBaseCCY
	, CubeData.IsCCYExp
	, Countries.ISLxEM AS IsEM
	, CAST((CASE 	WHEN CubeData.SPRatingRank <= 11 THEN 0
			WHEN (CubeData.SPRatingRank > 11 AND CubeData.SPCleanRating IS NOT NULL) THEN 1
		 	ELSE NULL END) AS Bit) AS IsHY
	, ABS(CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta) AS ExpWeightBetaAdjAbs
	, ABS(CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp) AS ExpWeightAbs

INTO UKSEFtmpdata							
FROM	#CubeData AS CubeData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(CubeData.FundId = NaVs.FundId
		AND CubeData.PositionDate = NaVs.NaVPLDate) LEFT JOIN
	tbl_CountryCodes AS Countries ON
		(CubeData.CountryISO = Countries.ISOCode)

WHERE	CubeData.PositionDate >= '1/Jan/2013'
		AND CubeData.PositionDate < '1/Jan/2014'
	
--ORDER BY	CubeData.PositionDate
*/

--DROP TABLE UKSEFtmpdatadel 

SELECT	CubeData.DetsDate AS PositionDate
	, CubeData.SecurityGroup
	, 'NotRelevant' AS SecurityType
	--, CubeData.IsDerivative
	, CubeData.BMISCode
	, CubeData.BBGTicker
	, CubeData.Underlying
	, CubeData.CostMarketVal
	, CubeData.Weight
	, CubeData.CostExposureVal
	, CubeData.ExpWeight
	, CubeData.ExpWeightBetaAdj
	, CubeData.AssetCCY
	, CubeData.PositionSize
	, CubeData.StartPrice
	, CubeData.MarketPrice
	, CubeData.AssetChange
	, CubeData.FxChange
	, CubeData.AssetPL
	, CubeData.FxPL
	, CubeData.TotalPL
--PL in Bps of CostNaV
	, CubeData.AssetPLOnNaV
	, CubeData.FXPLOnNaV
	, CubeData.PLOnNaV
--PL over TotalPL
	, CubeData.AssetPLonTotalPL
	, CubeData.FxPLonTotalPL
	, CubeData.PLOnTotalPL

	, CubeData.CountryISO
	, CubeData.CountryName
	, CubeData.CountryRegion
	, CubeData.IndustrySector
	, CubeData.IndustryGroup
	, CubeData.SPCleanRating
	, CubeData.SPRatingRank
	, CubeData.YearsToMat
	, CubeData.EquityMktStatus
	, CubeData.LongShort
	--, CubeData.LongShortBAdj
	, CubeData.DaysToLiquidate
	, CubeData.Beta
	, CubeData.Size
	, CubeData.Value
	--, CubeData.IsManualPrice
	, CubeData.ROE
	, CubeData.EPSGrowth
	, CubeData.SalesGrowth
	, CubeData.BtP
	, CubeData.DivYield
	, CubeData.EarnYield
	, CubeData.StP
	, CubeData.EbitdaTP
	, CubeData.MktCapLocal
	, CubeData.MktCapUSD
	, CubeData.SecType
	, CubeData.CollType
	, CubeData.MktSector
	, CubeData.ShortMom
	, CubeData.UpDown
	, CubeData.MarginBaseOnNaV
	, CubeData.BBGId
	, CubeData.ExpWeight AS AllExpWeights
	--, CubeData.FundClass
	--, CubeData.FundIsAlive
	--, CubeData.FundIsSkip
	, CubeData.FundBaseCCY
	--, CubeData.IsCCYExp
	--, CubeData.IsEM
	--, CubeData.IsHY
	--, CubeData.ExpWeightBetaAdjAbs
	--, CubeData.ExpWeightAbs

INTO	#UKSEFtmpdata							
FROM	TmpFundRiskDetails AS CubeData 
WHERE	CubeData.DetsDate >= '1/Jan/2013'
		AND CubeData.DetsDate < '1/Jan/2014'
--		CubeData.DetsDate = '31/Dec/2013'
		AND FundCode = 'UKSEF'
--		AND MktSector = 'Equity'

--SELECT * FROM #UKSEFtmpdata

----------------------------------------------------------------------------------

SELECT		PositionDate
			, LongShort
			, SUM(ABS(ExpWeight)) AS GrossExp
--INTO		#GrossIdxExp
FROM		#UKSEFtmpdata
WHERE 		MktSector = 'Index'
			--AND MktCapUSD IS NOT NULL
GROUP BY	PositionDate, LongShort
ORDER BY	PositionDate, LongShort


DELETE
FROM		#UKSEFtmpdata
WHERE 		MktSector = 'Index'

----------------------------------------------------------------------------------
--DROP TABLE #CubeData
--GO

DECLARE	@Thr50b float
DECLARE @Thr10b float
DECLARE @Thr5b float
DECLARE @Thr1b float
DECLARE @USDEURFX float

SET @USDEURFX = 1.39
SET @Thr50b = 50000 / @USDEURFX
SET @Thr10b = 10000 / @USDEURFX
SET @Thr5b = 5000 / @USDEURFX
SET @Thr1b = 1000 / @USDEURFX


SELECT	PositionDate
		, SecurityType
		, BMISCode
		, BBGTicker AS Description
		, AllExpweights AS NWeight
		, ABS(AllExpweights) AS GWeight
		, (SELECT CASE WHEN MktCapUSD > @Thr50b THEN '>50€'
						WHEN MktCapUSD > @Thr10b THEN '(10€, 50€]'
						WHEN MktCapUSD > @Thr5b THEN '(5€, 10€]'
						WHEN MktCapUSD > @Thr1b THEN '(1€, 5€]'
						WHEN MktCapUSD <= @Thr1b THEN '<1€' END) AS Bracket
		, LongShort

INTO	#Dets

FROM	#UKSEFtmpdata
WHERE 	SecurityGroup = 'Equities'
		AND MktCapUSD IS NOT NULL


--SELECT * FROM #Dets
--SELECT PositionDate FROM #Dets GROUP BY PositionDate ORDER BY PositionDate
----------------------------------------------------------------------------------
SELECT		PositionDate
			, SUM(ABS(AllExpweights)) AS GrossExp
INTO		#GrossExp
FROM		#UKSEFtmpdata
WHERE 		SecurityGroup = 'Equities'
			AND MktCapUSD IS NOT NULL
GROUP BY	PositionDate
ORDER BY	PositionDate

SELECT * FROM #GrossExp
----------------------------------------------------------------------------------

SELECT		M.PositionDate
			, SUM(ABS(M.AllExpweights)* M.MktCapUSD / @USDEURFX)/ G.GrossExp AS AvgMktCap -- 
INTO		#AvgMktCap
FROM		#UKSEFtmpdata AS M LEFT JOIN #GrossExp AS G ON (
				M.PositionDate = G.PositionDate)
WHERE 		M.SecurityGroup = 'Equities'
			AND M.MktCapUSD IS NOT NULL
GROUP BY	M.PositionDate, G.GrossExp
ORDER BY	M.PositionDate

SELECT * FROM #AvgMktCap

----------------------------------------------------------------------------------
SELECT		PositionDate
			, SUM(GWeight) AS Weight
			, Bracket
			, LongShort
INTO		#DailyStats
FROM		#Dets
GROUP BY	PositionDate, Bracket, LongShort

SELECT * FROM #DailyStats
----------------------------------------------------------------------------------

SELECT		AVG(Weight) AS AvgWeight
			, STDEV(Weight) AS StDWeight	
			, Bracket
			, LongShort
INTO		#AverageDaily
FROM		#DailyStats
GROUP BY	Bracket, LongShort
ORDER BY	Bracket, LongShort

SELECT * FROM #AverageDaily
----------------------------------------------------------------------------------

SELECT		SUM(AvgWeight) AS AvgWeight
			, Bracket
INTO		#AverageGrossBkt
FROM		#AverageDaily
GROUP BY	Bracket
ORDER BY	Bracket

SELECT * FROM #AverageGrossBkt
	
----------------------------------------------------------------------------------
SELECT		SUM(AvgWeight) AS AvgWeight
INTO		#AverageGross
FROM		#AverageGrossBkt

SELECT * FROM #AverageGross
	
----------------------------------------------------------------------------------


DROP TABLE #Dets
DROP TABLE #GrossExp
DROP TABLE #AvgMktCap
DROP TABLE #DailyStats
DROP TABLE #UKSEFtmpdata
DROP TABLE #AverageDaily
DROP TABLE #AverageGrossBkt
DROP TABLE #AverageGross



SELECT	MAX(NetExposure) AS MaxNetExp
		, MIN(NetExposure) AS MinNetExp
		, AVG(NetExposure) AS AvgNetExp
		, STDEV(NetExposure) AS StDevNetExp
		, MAX(GrossExposure) AS MaxGrossExp
		, MIN(GrossExposure) AS MinGrossExp
		, AVG(GrossExposure) AS AvgGrossExp
		, STDEV(GrossExposure) AS StDevGrossExp

FROM tbl_FundsNavsAndPLs
WHERE	NAVPLDate < '1/Jan/2014'
		AND NAVPLDate >= '1/Jan/2011'
		AND FundId = 43
		AND GrossExposure > 1