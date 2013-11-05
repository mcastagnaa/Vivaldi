USE VIVALDI
SELECT	'| ' + FundCode + ' | '+ FundName + ' | '+ FundClass + ' | '+ HoDCode + ' | '+
	'[Click here|http://omamwiki/RiskReports/Risk/Lastreports/' + 
	FundCode + '.pdf]' AS Line1, 
	'|[Click here|http://omamwiki/RiskReports/Risk/Lastreports/' +  
	FundCode + 'scenarios.pdf]| ' AS Line2
FROM 	vw_FundsTypology
WHERE	ReportName <> 'NotReady' 
	AND ReportName is not null
	AND IsSkip = 0
	AND IsAlive = 1

ORDER BY	HoDCode
		, FundClass
		, FundCode

-- Run it in grid, copy into EXCEL, save it as txt and then 
-- paste everything on the wiki page for "Vivaldi single fund reports"
-- There will be scenarios link that do not work because they do no exist (e.g. U3)