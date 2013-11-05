SELECT	StatDate
	, FactorType AS Factor
	, Sum(Abs(Net)) AS GrossFactorExposure
INTO	#FactorsLoads
FROM	tbl_FundsFactorsLoads
WHERE	FundId = 25 
	AND StatDate > DATEADD(month,-3,'2010-02-27')
GROUP BY	StatDate
		, FactorType
ORDER BY	StatDate


--------------------------------------------------------

SELECT	Factor
	, AVG(GrossFactorExposure) AS FactorAvg
INTO	#FactorAvgs
FROM	#FactorsLoads
GROUP BY	Factor


--------------------------------------------------------

SELECT	*
INTO	#PivotData
FROM 	(SELECT	StatDate, Factor, GrossFactorExposure
	FROM	#FactorsLoads) o
PIVOT	(SUM(GrossFactorExposure) 
	FOR Factor IN(	
			Beta
			, CompanySize
			, ShortMom
			, ValueType
			)
	) p

--------------------------------------------------------

SELECT	StatDate
	, Beta
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'Beta') AS BetaAvg
	, CompanySize AS Size
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'CompanySize') AS SizeAvg
	, ValueType AS Value
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'ValueType') AS ValueAvg
	, ShortMom AS Reversal
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'ShortMom') AS ReversalAvg

FROM	#PivotData

DROP Table #PivotData
DROP Table #FactorsLoads
DROP Table #FactorAvgs