USE Vivaldi
GO

/*
UPDATE GEFOdata
SET DateYear = DATEPART(yyyy, PositionDate),
	DateMonth = DATEPART(mm, PositionDate)

-------------------

UPDATE GEFOdata
SET QuantCountry = QC.CountryName, QuantRegion = QR.QuantRegion
FROM	GEFOdata AS A LEFT JOIN 
		tbl_QuantCountry AS QC ON
			(A.BMIScode = QC.BMIScode)
		LEFT JOIN tbl_QuantRegion AS QR ON
			(QC.CountryName = QR.QuantCountry)


SELECT	SecurityGroup, BMISCode, Underlying, QuantCountry, QuantRegion
FROM	GEFOdata 
WHERE	(QuantCountry is null or QuantRegion is null)
		AND SecurityGroup <> 'CashFX'
GROUP BY SecurityGroup, BMISCode, Underlying, QuantCountry, QuantRegion

*/


SELECT MAX(PositionDate) AS MonthEnd
INTO #MonthEndDates
FROM GEFOdata
GROUP BY DateYear, DateMonth

SELECT D.*
INTO	#TmpEoM
FROM	GEFOdata AS D INNER JOIN 
		#MonthEndDates AS EoM ON (EoM.MonthEnd = D.PositionDate)

DROP TABLE #MonthEndDates

-----------------------------------
--POSITION COUNT

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)
SELECT DateYear, DateMonth, PositionDate, LongShort, COUNT(ExpWeight) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, LongShort

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.LongShort)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, LongShort, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR LongShort in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO

-------------------
-- Long & Short exposure
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, LongShort, SUM(ExpWeight) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, LongShort

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.LongShort)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, LongShort, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR LongShort in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO
-------------------
-- Industry Sector net

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, IndustrySector, Sum(ExpWeight) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, IndustrySector

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.IndustrySector)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, IndustrySector, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR IndustrySector in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO
-------------------
-- Industry Sector gross

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, IndustrySector, Sum(Abs(ExpWeight)) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, IndustrySector

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.IndustrySector)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, IndustrySector, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR IndustrySector in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO
----------------------
-- Industry Group net

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)
SELECT DateYear, DateMonth, PositionDate, IndustryGroup, SUM(ExpWeight) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, IndustryGroup

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.IndustryGroup)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear * 100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, IndustryGroup, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR IndustryGroup in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO


----------------------
-- Industry Group gross

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)
SELECT DateYear, DateMonth, PositionDate, IndustryGroup, SUM(ABS(ExpWeight)) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
GROUP BY DateYear, DateMonth, PositionDate, IndustryGroup

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.IndustryGroup)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear * 100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, IndustryGroup, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR IndustryGroup in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

--DECLARE @COL AS NVARCHAR(MAX)
SELECT DISTINCT IndustryGroup
FROM #TmpGrouping

DROP TABLE #TmpGrouping
GO
-----------------
-- Region Net

DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, QuantRegion, SUM(ExpWeight) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
AND QuantRegion <> 'NOIDEA'
GROUP BY DateYear, DateMonth, PositionDate, QuantRegion

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.QuantRegion)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, QuantRegion, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR QuantRegion in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO

-----------------
-- Region Gross
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, QuantRegion, SUM(ABS(ExpWeight)) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
AND QuantRegion <> 'NOIDEA'
GROUP BY DateYear, DateMonth, PositionDate, QuantRegion

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.QuantRegion)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, QuantRegion, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR QuantRegion in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO


-----------------
-- MarketCap Gross
DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)

SELECT DateYear, DateMonth, PositionDate, Size, SUM(ABS(ExpWeight)) AS Stat
INTO #TmpGrouping
FROM #TmpEoM
WHERE SecurityGroup = 'Equities'
--AND QuantRegion <> 'NOIDEA'
GROUP BY DateYear, DateMonth, PositionDate, Size

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.Size)
			FROM #TmpGrouping AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT DateYear*100 + DateMonth AS DATE, ' + @COL +
			'FROM (SELECT DateYear, DateMonth, Size, Stat FROM #TmpGrouping) X
			PIVOT
				(AVG(Stat) FOR Size in (' + @COL + ')
				) P ORDER BY DateYear, DateMonth'

EXECUTE(@QRY)

DROP TABLE #TmpGrouping
GO
DROP TABLE #TmpEoM
GO
