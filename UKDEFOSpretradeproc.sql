SELECT	TOP 100 VaRDate
	, PercentVaR
	, (SELECT TOP 1 PercentVaR
		FROM vw_TotalVaRByFundByDate AS SubVaRTable 
		WHERE	VaRDate < MainVaRTable.VaRDate
			AND ReportId = 1
		ORDER BY VaRDate DESC ) AS PrevVaR

INTO	#VaRList

FROM	vw_TotalVaRByFundByDate AS MainVaRTable
WHERE	ReportId = 1
GROUP BY	VaRDate
		, percentVaR
ORDER BY 	VaRDate DESC

---------------------------------------------------------------

SELECT 	MAX(PercentVaR-PrevVaR) AS MaxVaRChange
FROM	#VaRList

DROP TABLE #VaRList