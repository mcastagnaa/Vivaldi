SELECT	NaVs.NaVPLDate
	, VaRs.VAR / NAVs.CostNaV AS VaRPerc

FROM	tbl_FundsNavsAndPLs AS NAVs LEFT JOIN 
	tbl_VaRReports AS VARs ON (NAVS.NAVPLDate = VARS.ReportDate
		AND NAVS.FundId = VARS.FundId)
WHERE 	NaVs.FundId = 14
	AND VARs.ReportId = 5
	AND VARs.SecTicker = 'Totals'

ORDER BY NaVs.NAVPLDate