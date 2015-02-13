SELECT	Fund.FundId
		, VaR.ReportDate
		, Fund.FundCode
		, Fund.VehicleName
		, Fund.BenchLong
		, Fund.FundName
		, 1 - VaR.IndexPerc AS ActiveLast
INTO	#Last
FROM vw_RelativeVaRReports AS VaR LEFT JOIN
	 vw_FundsTypology As Fund ON (VaR.FundId = Fund.FundId)
WHERE VaR.ReportDate = '2015 Feb 4'
	AND Fund.HODCode = 'RB'
	AND Fund.VehicleName <> 'Mandate'


SELECT  Fund.FundCode
		, 1 - AVG(VaR.IndexPerc) AS Average
		, STDEV(VaR.IndexPerc) AS SDev
		, 1 - MAX(VaR.IndexPerc) AS Minimum
		, 1 - MIN(VaR.IndexPerc) AS Maximum
INTO	#Stats
FROM	vw_RelativeVaRReports AS VaR LEFT JOIN
		vw_FundsTypology As Fund ON (VaR.FundId = Fund.FundId)
WHERE		VaR.ReportDate <= '2015 Feb 4' 
			AND VaR.ReportDate > '2014 Feb 4'
			AND Fund.HODCode = 'RB'
			AND Fund.VehicleName <> 'Mandate'
GROUP BY	Fund.FundCode


SELECT	LAST.*
		, Stats.Average
		, Stats.SDev
		, Stats.Minimum 
		, Stats.Maximum
FROM	#LAST AS LAST LEFT JOIN
		#Stats as Stats ON (
			LAST.FundCode = Stats.FundCode
		)
ORDER BY LAST.BenchLong ASC

DROP TABLE #LAST, #Stats

SELECT  Fund.FundCode
		, VaR.ReportDate
		, 1 - VaR.IndexPerc AS ActiveShare
FROM	vw_RelativeVaRReports AS VaR LEFT JOIN
		vw_FundsTypology As Fund ON (VaR.FundId = Fund.FundId)
WHERE		VaR.ReportDate <= '2015 Feb 4' 
			AND VaR.ReportDate > '2013 Feb 4'
			AND Fund.FundId = 42
ORDER BY	Fund.FundCode ASC
