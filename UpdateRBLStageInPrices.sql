Use Vivaldi;
--------------------------------------------------------------------
SELECT PortfolioCode
		, Security
		, [ID ISIN]
		, StartPrice

FROM	tbl_Vivaldi_StageIn
WHERE	[ID ISIN] IN ('3189876', '5140989', 'B01WHG9', 'B0DK750'
					, 'B0RTNX3', 'B17FSC2', 'B1G4YH7', 'B1G50G1'
					, 'SBER S1')
ORDER BY [ID ISIN]
--------------------------------------------------------------------
CREATE TABLE #RublStPx (SecurityId NVarchar(7), StPx float); 
INSERT INTO #RublStPx 
				SELECT '3189876', 65.5
	UNION ALL	SELECT '5140989', 9.065
	UNION ALL	SELECT 'B01WHG9', 10.06
	UNION ALL	SELECT 'B0DK750', 115.1
	UNION ALL	SELECT 'B0RTNX3', 19.96
	UNION ALL	SELECT 'B17FSC2', 8.345
	UNION ALL	SELECT 'B1G4YH7', 12.0
	UNION ALL	SELECT 'B1G50G1', 43.8
	UNION ALL	SELECT 'SBER S1', 14.54
--
UPDATE	tbl_Vivaldi_StageIn
SET		StartPrice = GoodPx.StPx 
FROM	#RublStPx AS GoodPx JOIN tbl_Vivaldi_StageIn AS P ON (
				Goodpx.SecurityId = P.[ID ISIN]
				)
WHERE	P.[ID ISIN] IN ('3189876', '5140989', 'B01WHG9', 'B0DK750'
					, 'B0RTNX3', 'B17FSC2', 'B1G4YH7', 'B1G50G1'
					, 'SBER S1')
--
DROP TABLE #RublStPx
--------------------------------------------------------------------
SELECT PortfolioCode
		, Security
		, [ID ISIN]
		, StartPrice

FROM	tbl_Vivaldi_StageIn
WHERE	[ID ISIN] IN ('3189876', '5140989', 'B01WHG9', 'B0DK750'
					, 'B0RTNX3', 'B17FSC2', 'B1G4YH7', 'B1G50G1'
					, 'SBER S1')
ORDER BY [ID ISIN]

