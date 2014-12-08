USE VIVALDI;

SELECT	PositionDate
		, COUNT(BMISCode) AS PosNumber
INTO	#PosNumber
FROM	GEARData
WHERE	SecurityGroup = 'Equities'
GROUP BY	PositionDate

SELECT	TOP 10 PositionDate
		, PosNumber
FROM	#PosNumber
ORDER BY PositionDate DESC

SELECT Avg(PosNumber) AS Average
		, Min(PosNumber) As Minimum
		, Max(PosNumber) As Maximum
FROM #PosNumber

DROP TABLE #PosNumber

-----------------------------------------------------------------
		
SELECT rs.PositionDate, rs.AbsWeight, rs.Rank
INTO	#Top10ByDate
FROM (
        SELECT PositionDate, ABS(ExpWeight) AS AbsWeight, Rank() 
        OVER (Partition BY PositionDate
                ORDER BY ABS(ExpWeight) DESC ) AS Rank
        FROM GEARData
		WHERE	SecurityGroup = 'Equities'
        ) rs WHERE Rank <= 10

SELECT	PositionDate
		, SUM(AbsWeight) AS Top10Weight
INTO	#SumTop10ByDate
FROM	#Top10ByDate
GROUP BY PositionDate
ORDER BY Top10Weight DESC


SELECT	Avg(Top10Weight) AS Average
		, Min(Top10weight) AS Minimum
		, Max(Top10Weight) AS Maximum
FROM #SumTop10ByDate

DROP TABLE #SumTop10ByDate


SELECT PositionDate
		, AbsWeight AS Top1Weight
--INTO	#SumTop10ByDate
FROM	#Top10ByDate
WHERE	[Rank] = 1
ORDER BY AbsWeight DESC

SELECT	Avg(AbsWeight) AS Average
		, Min(AbsWeight) AS Minimum
		, Max(AbsWeight) AS Maximum
--INTO	#SumTop10ByDate
FROM	#Top10ByDate
WHERE	[Rank] = 1


DROP TABLE #Top10ByDate
-----------------------------------------------------------------

SELECT	PositionDate
		, QuantRegion
		, SUM(ABS(ExpWeight)) AS GrossExp
INTO	#Regions
FROM	GEARdata
WHERE	SecurityGroup = 'Equities'
GROUP BY	PositionDate, QuantRegion
ORDER BY	PositionDate DESC, QuantRegion

SELECT * FROM #Regions 
WHERE QuantRegion = 'ASIA PACIFIC'
ORDER BY GrossExp DESC 

SELECT	*
FROM	(SELECT QuantRegion, GrossExp
		FROM	#Regions
		) o
PIVOT	(AVG(GrossExp)
		--, MIN(GrossExp)
		--, MAX(GrossExp) 
		FOR QuantRegion IN([ASIA PACIFIC]
					, [EUROPE]
					, [JAPAN]
					, [NORTH AMERICA]
					--, null
					)
	) p

SELECT	*
FROM	(SELECT QuantRegion, GrossExp
		FROM	#Regions
		) o
PIVOT	(MIN(GrossExp)
		--, MAX(GrossExp) 
		FOR QuantRegion IN([ASIA PACIFIC]
					, [EUROPE]
					, [JAPAN]
					, [NORTH AMERICA]
					--, null
					)
	) p

SELECT	*
FROM	(SELECT QuantRegion, GrossExp
		FROM	#Regions
		) o
PIVOT	(MAX(GrossExp) 
		FOR QuantRegion IN([ASIA PACIFIC]
					, [EUROPE]
					, [JAPAN]
					, [NORTH AMERICA]
					--, null
					)
	) p

DROP TABLE #Regions

-----------------------------------------------------------------

SELECT	PositionDate
		, Size
		, SUM(ABS(ExpWeight)) AS GrossExp
INTO	#Size
FROM	GEARdata
WHERE	SecurityGroup = 'Equities'
GROUP BY	PositionDate, Size
ORDER BY	PositionDate DESC, Size

SELECT * FROM #Size ORDER BY PositionDate DESC

SELECT	*
FROM	(SELECT Size, GrossExp
		FROM	#Size
		) o
PIVOT	(AVG(GrossExp)
		FOR Size IN([BIG]
					, [MID]
					, [SMALL]
					--, null
					)
	) p

SELECT	*
FROM	(SELECT Size, GrossExp
		FROM	#Size
		) o
PIVOT	(MIN(GrossExp)
		FOR Size IN([BIG]
					, [MID]
					, [SMALL]
					--, null
					)
	) p

SELECT	*
FROM	(SELECT Size, GrossExp
		FROM	#Size
		) o
PIVOT	(MAX(GrossExp) 
		FOR Size IN([BIG]
					, [MID]
					, [SMALL]
					--, null
					)
	) p

DROP TABLE #Size

-----------------------------------------------------------------

SELECT	PositionDate
		, AssetCCY
		, SUM(ABS(ExpWeight)) AS GrossExp
INTO	#CCY
FROM	GEARdata
WHERE	SecurityGroup = 'Equities'
GROUP BY	PositionDate, AssetCCY
ORDER BY	PositionDate DESC, AssetCCY

SELECT * FROM #CCY 
WHERE ASSETCCY = 'AUD'
ORDER BY GrossExp DESC

SELECT	*
FROM	(SELECT AssetCCY, GrossExp
		FROM	#CCY
		) o
PIVOT	(AVG(GrossExp)
		FOR AssetCCY IN(AUD
					, CAD, CHF, CNY, DKK, EUR, GBp, HKD, INR, JPY, KRW
					, NOK, NZD, SEK, SGD, TWD, USD, ZAR
					--, null
					)
		) p


SELECT	*
FROM	(SELECT AssetCCY, GrossExp
		FROM	#CCY
		) o
PIVOT	(MIN(GrossExp)
		FOR AssetCCY IN(AUD
					, CAD, CHF, CNY, DKK, EUR, GBp, HKD, INR, JPY, KRW
					, NOK, NZD, SEK, SGD, TWD, USD, ZAR
					--, null
					)
		) p

SELECT	*
FROM	(SELECT AssetCCY, GrossExp
		FROM	#CCY
		) o
PIVOT	(MAX(GrossExp)
		FOR AssetCCY IN(AUD
					, CAD, CHF, CNY, DKK, EUR, GBp, HKD, INR, JPY, KRW
					, NOK, NZD, SEK, SGD, TWD, USD, ZAR
					--, null
					)
		) p


DROP TABLE #CCY

-----------------------------------------------------------------
-- BETA

SELECT PortfBeta FROM tbl_FundsStatistics
WHERE StatsDate = '2014-Oct-1'
AND FundId = 14

SELECT Avg(PortfBeta) as Average
		, Min(PortfBeta) as Minimum
		, Max(PortfBeta) as Maximum
FROM tbl_FundsStatistics
WHERE StatsDate <= '2014-Oct-1'
	AND StatsDate > '2009-Oct-1'
	AND FundId = 14


-----------------------------------------------------------------
-- Gross exposure
SELECT GrossExposure FROM tbl_FundsNavsAndPLs
WHERE NaVPLDate = '2014-Oct-1'
AND FundId = 14

SELECT Avg(GrossExposure) as Average
		, Min(GrossExposure) as Minimum
		, Max(GrossExposure) as Maximum
FROM tbl_FundsNavsAndPLs
WHERE NaVPLDate <= '2014-Oct-1'
	AND NaVPLDate > '2009-Oct-1'
	AND FundId = 14

--SELECT NaVPLDate, GrossExposure FROM tbl_FundsNavsAndPLs
--WHERE FundId = 14
--ORDER BY GrossExposure ASC



-----------------------------------------------------------------
-- VaR


SELECT PercentVaR FROM vw_TotalVaRByFundByDate
WHERE VaRDate = '2014-Oct-1'
AND FundId = 14

SELECT Avg(PercentVaR) as Average
		, Min(PercentVaR) as Minimum
		, Max(PercentVaR) as Maximum
FROM vw_TotalVaRByFundByDate
WHERE VaRDate <= '2014-Oct-1'
	AND VaRDate > '2009-Oct-1'
	AND FundId = 14


