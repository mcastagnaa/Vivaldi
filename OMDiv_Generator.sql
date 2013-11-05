SELECT 	FundShortName + 'DIV' AS FundCode
	, PositionId
	, ROUND(Units * (CASE FundShortName 
			WHEN 'GSAF' THEN 0.4
			WHEN 'GEAR' THEN 0.4
			WHEN 'MFUT' THEN 0.2
		END),0) AS Units
	, StartPrice
	, PositionDate
	

FROM 	tbl_Positions
WHERE 	FundSHortName IN ('GEAR', 'MFUT', 'GSAF')
	AND PositionDate = '2011/dec/14'
--ORDER BY PositionId