USE Vivaldi;

SELECT 'PORTVaR' AS Source
		, PORT.* 
		, -PORT.PL/PORT.DollarVAR AS AbsPLtoVARRatio
		, DETS.SumPortWeights AS TotWeight
		, DETS.SumMarg
		, DETS.SumMarg * 100/PORT.DollarVaR AS MargTotalRatio
		, DETS.ExceptionsCount AS Exptns
INTO	#TEMPAbsVaR
FROM	vw_TotalVaRByFundByDatePORT AS PORT  LEFT JOIN
		vw_VaRByFundByDatePORTDets AS DETS ON (
			PORT.ReportId = DETS.ReportId
			AND PORT.VaRDate = DETS.ReportDate
			)
UNION 
SELECT 'ALGOVaR'
		, ALGO.*
		, -ALGO.PL/ALGO.DollarVAR AS AbsPLtoVARRatio
		, null
		, null
		, null
		, null
FROM vw_TotalVaRByFundByDatePORT AS PORT LEFT JOIN
	vw_TotalVaRByFundByDate AS ALGO ON (
		PORT.FundId = ALGO.FundId
		AND PORT.ReportId = ALGO.ReportId
		AND PORT.VaRdate = ALGO.VaRdate
		)
WHERE	PORT.FundId IS NOT NULL

SELECT * FROM #TEMPAbsVaR AS TEMP
ORDER BY	TEMP.FundId


SELECT 'PORTVaR' AS Source, * 
INTO #TEMPRelVaR
FROM vw_RelativeVaRReportsPORT

UNION 
SELECT 'ALGOVaR', ALGO.*
FROM vw_RelativeVaRReportsPORT AS PORT LEFT JOIN
	vw_RelativeVaRReports AS ALGO ON (
		PORT.FundId = ALGO.FundId
		AND PORT.ReportDate = ALGO.ReportDate
		)
WHERE	PORT.FundId IS NOT NULL

SELECT * FROM #TEMPRelVaR AS TEMP
ORDER BY	TEMP.FundId

DROP TABLE #TEMPAbsVaR
DROP TABLE #TEMPRelVaR
