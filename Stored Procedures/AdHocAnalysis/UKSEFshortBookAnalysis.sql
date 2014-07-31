Use vivaldi;

SELECT PositionDate
		, Sum(ExpWeight) AS SEB
		, Sum(PLonNaV) AS TotalBpsFromSEB
		, Sum(PLonNaV)/ABS(Sum(ExpWeight)) AS NormzPL_SEB
INTO #PLSEB
FROM UKSEFDataSet
WHERE	LongShort = 'Short'
	AND industrySector <> 'Equity Index' 
	AND securityGroup = 'Equities'
GROUP BY PositionDate
ORDER BY PositionDate

SELECT	PositionDate
		, Sum(ExpWeight) AS IndexWeight
		, Sum(PLonNaV) AS TotalBpsFromIS
		, Sum(PLonNaV)/ABS(Sum(ExpWeight)) AS NormzPL_IS

INTO #IdxShort
FROM UKSEFDataSet
WHERE Underlying like 'FTSE 250%' AND LongShort = 'Short'
GROUP BY PositionDate
ORDER BY PositionDate

/*SELECT PositionDate, Underlying, IndustrySector, LongShort, Sum(ExpWeight) AS IndexWeight 
INTO #IdxLong
FROM UKSEFDataSet
WHERE IndustrySector = 'Equity Index' AND LongShort = 'Long'
GROUP BY PositionDate, underlying, IndustrySector, longShort
ORDER BY PositionDate
*/
SELECT	P.PositionDate
		, S.IndexWeight
		, P.SEB
		, P.TotalBpsFromSEB
		, P.NormzPL_SEB
		, S.TotalBpsFromIS
		, S.NormzPL_IS
FROM	#PLSEB AS P LEFT JOIN
		#IdxShort AS S ON (
			P.PositionDate = S.PositionDate
			)


DROP TABLE #IdxShort
--DROP TABLE #IdxLong
DROP TABLE #PLSEB

