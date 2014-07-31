SELECT	S.*
		, F.FundCode
INTO	#ScenData
FROM	tbl_ScenReports AS S LEFT JOIN
		tbl_Funds AS F ON (
			S.FundId = F.Id
			)
WHERE	S.Reportdate >= '2014/Jul/17' 
		AND S.Reportdate < '2014/Jul/19'
ORDER BY S.ReportDate

SELECT	ReportDate
		, Count(ReportId) 
FROM	#ScenData 
GROUP BY ReportDate
ORDER BY ReportDate


DECLARE @COL AS NVARCHAR(MAX), @QRY AS NVARCHAR(MAX)
--SELECT DateYear, DateMonth, PositionDate, LongShort, COUNT(ExpWeight) AS Stat
--INTO #LongShortDay
--FROM #GEARtmpEoM
--WHERE SecurityGroup = 'Equities'
--GROUP BY DateYear, DateMonth, PositionDate, LongShort

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(ReportDate)
			FROM #ScenData 
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

SET @QRY =	'SELECT FundCode, FundId,' + @COL +
			'FROM (SELECT ReportId, ReportDate, FundCode, FundId FROM #ScenData) X
			PIVOT
				(Count(ReportId) FOR ReportDate in (' + @COL + ')
				) P ORDER BY FundCode'

EXECUTE(@QRY)


DROP TABLE #ScenData

--DELETE
--FROM tbl_scenreports 
--where FundId in (135,110)
--		AND reportDate = '2014/Jul/18'
