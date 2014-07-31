USE Vivaldi
GO

/*DECLARE @PercDayVol float
SET @PercDayVol = 0.1

-------------------------------------------------------------------
SELECT * INTO #CubeData FROM fn_GetCubeDataTable(null, 14)
-------------------------------------------------------------------

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

INTO GEARtmpdata							
FROM	#CubeData AS CubeData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(CubeData.FundId = NaVs.FundId
		AND CubeData.PositionDate = NaVs.NaVPLDate) LEFT JOIN
	tbl_CountryCodes AS Countries ON
		(CubeData.CountryISO = Countries.ISOCode)

WHERE	CubeData.PositionDate >= '1/Oct/2009'
		AND CubeData.PositionDate <= '31/Mar/2014'

--------------------------------------------------------------------
DROP TABLE #CubeData
*/
--------------------------------------------------------------------

ALTER TABLE GEARtmpdata
ADD DateYear integer, DateMonth integer
GO

UPDATE GEARtmpdata
SET DateYear = DATEPART(yyyy, PositionDate),
	DateMonth = DATEPART(mm, PositionDate)

-------------------
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, LongShort, COUNT(ExpWeight) AS Stat
INTO #LongShortDay
FROM GEARtmpdata
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, LongShort

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.LongShort)
			FROM #LongShortDay AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, LongShort, Stat FROM #LongShortDay) X
			PIVOT
				(AVG(Stat) FOR LongShort in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #LongShortDay
GO

-------------------

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, IndustrySector, Sum(ExpWeight) AS Stat
INTO #LongShortDay
FROM GEARtmpdata
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, IndustrySector

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.IndustrySector)
			FROM #LongShortDay AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, IndustrySector, Stat FROM #LongShortDay) X
			PIVOT
				(AVG(Stat) FOR IndustrySector in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #LongShortDay
GO
----------------------
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, IndustrySector, SUM(ABS(ExpWeight)) AS Stat
INTO #LongShortDay
FROM GEARtmpdata
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, IndustrySector

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.IndustrySector)
			FROM #LongShortDay AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear * 100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, IndustrySector, Stat FROM #LongShortDay) X
			PIVOT
				(AVG(Stat) FOR IndustrySector in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #LongShortDay
GO

-----------------
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, CountryRegion, SUM(ExpWeight) AS Stat
INTO #LongShortDay
FROM GEARtmpdata
WHERE SecurityGroup = 'Equities'
AND CountryRegion <> 'NOIDEA'
GROUP BY DateYear, DateMonth, PositionDate, CountryRegion

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.CountryRegion)
			FROM #LongShortDay AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, CountryRegion, Stat FROM #LongShortDay) X
			PIVOT
				(AVG(Stat) FOR CountryRegion in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #LongShortDay
GO

-----------------
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, CountryRegion, SUM(ABS(ExpWeight)) AS Stat
INTO #LongShortDay
FROM GEARtmpdata
WHERE SecurityGroup = 'Equities'
AND CountryRegion <> 'NOIDEA'
GROUP BY DateYear, DateMonth, PositionDate, CountryRegion

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.CountryRegion)
			FROM #LongShortDay AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, CountryRegion, Stat FROM #LongShortDay) X
			PIVOT
				(AVG(Stat) FOR CountryRegion in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #LongShortDay
GO
