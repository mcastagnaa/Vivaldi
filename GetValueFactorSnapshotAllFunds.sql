USE VIVALDI

SELECT	*

FROM (	SELECT	Funds.FundCode, Factors.FactorName, Factors.Net AS NetExposure 
	FROM	tbl_FundsFactorsLoads AS Factors JOIN
		tbl_Funds AS Funds ON (Funds.Id = Factors.FundId)
	WHERE	Factors.StatDate = '23/Jan/2012'
		AND Factors.FactorType = 'ValueType') o

PIVOT (avg(NetExposure) FOR FactorName IN(	
					[Hi]
					, [Mid]
					, [Low]
					)
	) p
