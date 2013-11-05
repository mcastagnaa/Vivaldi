Use Vivaldi;
--------------------------------------------------------------------
SELECT PortfolioCode
		, Security
		, [ID ISIN]
		, StartPrice

FROM	tbl_Vivaldi_StageIn
WHERE	[ID ISIN] IN ('6418801', '6755821', '6801575', 'B0L6750', 
					'B17BBR6', '6100089')
ORDER BY [ID ISIN]
--------------------------------------------------------------------
CREATE TABLE #RublStPx (SecurityId NVarchar(7), StPx float); 
INSERT INTO #RublStPx 
				SELECT '6418801', 16888 
	UNION ALL	SELECT '6755821', 4099
	UNION ALL	SELECT '6801575', 17575
	UNION ALL	SELECT 'B0L6750', 4790
	UNION ALL	SELECT 'B17BBR6', 6815
	UNION ALL	SELECT '6100089', 24501
--
UPDATE	tbl_Vivaldi_StageIn
SET		StartPrice = GoodPx.StPx 
FROM	#RublStPx AS GoodPx JOIN tbl_Vivaldi_StageIn AS P ON (
				Goodpx.SecurityId = P.[ID ISIN]
				)
WHERE	P.[ID ISIN] IN ('6418801', '6755821', '6801575', 'B0L6750', 
					'B17BBR6', '6100089')
--
DROP TABLE #RublStPx
--------------------------------------------------------------------
SELECT PortfolioCode
		, Security
		, [ID ISIN]
		, StartPrice

FROM	tbl_Vivaldi_StageIn
WHERE	[ID ISIN] IN ('6418801', '6755821', '6801575', 'B0L6750', 
					'B17BBR6', '6100089')
ORDER BY [ID ISIN]

