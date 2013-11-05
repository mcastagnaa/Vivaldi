USE VIVALDI
GO

SELECT Funds.SectorsDef AS SectorDefinition
	, Funds.FundCode + ' - ' + Funds.FundName AS FundName
	, Funds.BaseCCY AS BaseCCY
	, NaVs.CostNaV AS AuM

FROM 	vw_FundsTypology AS Funds LEFT JOIN
	tbl_FundsNavsAndPLs AS NaVs ON (
		Funds.FundId = NaVs.FundId
		)

WHERE NaVs.NAVPLDate = '2012 Dec 17' AND
	Funds.IsAlive = 1	

ORDER BY Funds.SectorsDef
/*GROUP BY Funds.SectorsDef
	, Funds.BaseCCY*/

