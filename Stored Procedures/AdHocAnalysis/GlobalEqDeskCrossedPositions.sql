USE Vivaldi;
DECLARE @refDate as datetime

SET @refDate = '2014 Jun 18'

SELECT	P.SecurityType AS Instrument
		, P.PositionId
		, P.FundShortName
		, SUM(P.Units) AS TotalDeskPosition
--		, AVG(P.StartPrice) AS StartPrice
--		, P.PositionDate

INTO	#Positions
FROM	tbl_Positions AS P LEFT JOIN vw_FundsTypology AS F ON (
			P.FundShortName = F.FundCode) 
		
WHERE	F.HODCode = 'PS'
		AND P.SecurityType IN ('CFD', 'Equities')
		AND F.FundCode NOT IN ('GSAF', 'GSAFLF')
		AND P.PositionDate = @RefDate

GROUP BY P.SecurityType, P.PositionId, P.FundShortName--, P.StartPrice

ORDER BY P.PositionId--, P.StartPrice

---------------------------

SELECT	PositionId
INTO	#LongsShorts
FROM	#Positions
GROUP BY PositionId
HAVING ABS(SUM(TotalDeskPosition)) <> SUM(ABS(TotalDeskPosition))
---------------------------

SELECT * 
FROM #Positions AS P INNER JOIN #LongsShorts AS LS
		ON (P.PositionId = LS.PositionId)

---------------------------

DROP TABLE #Positions
DROP TABLE #LongsShorts




