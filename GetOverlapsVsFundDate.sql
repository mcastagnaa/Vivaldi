USE VIVALDI
GO

DECLARE @RefDate datetime
SET @RefDate = '2012 Oct 23'

--------------------------------------------------------------

SELECT	* 
INTO	#GSAF
FROM 	tbl_Positions
WHERE 	FundShortName = 'GSAF'
	AND PositionDate = @RefDate

--------------------------------------------------------------

SELECT	AllPos.*
INTO	#MATCH
FROM	tbl_Positions AS AllPos JOIN
	#GSAF AS GSAF ON (
		AllPos.PositionId = GSAF.PositionId
		)
WHERE 	AllPos.PositionDate = @RefDate
--	AND AllPos.FundShortName = 'AS4'
	AND AllPos.SecurityType IN ('Equities', 'CFD')

--------------------------------------------------------------

SELECT 	FundShortName
	, COUNT(PositionId) AS MatchingPositions
FROM	#MATCH
GROUP BY	FundShortName
ORDER BY 	FundShortName ASC

--------------------------------------------------------------
DROP TABLE #GSAF
DROP TABLE #MATCH