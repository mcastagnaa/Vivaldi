SELECT	VaRReports.ReportDate
	, VaRReports.VaR As PortfVaR
	, VaRReports.VaRBench AS BenchVaR
	, VaRReports.VaR - VaRReports.VaRBench AS VaRDiff
	
FROM 	tbl_VaRReports AS VaRReports LEFT JOIN
	tbl_ENUMVaRReports AS ReportsList ON
		(VaRReports.ReportId = ReportsList.Id)
WHERE	ReportsList.IsRelative = 1
	AND VaRReports.FundId = 3
	AND VaRReports.SecTicker = 'Totals'

ORDER BY	VaRReports.ReportDate