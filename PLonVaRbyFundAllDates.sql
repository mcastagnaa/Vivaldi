SELECT	VaRs.VarDate	
	, Vars.FundShortName
	, VaRs.DollarVaR/NaV AS VaRPerc
	, Vars.DollarVaR/ZScores.ZScore AS OneSigmaDollarVaR
	, (Vars.DollarVaR/ZScores.Zscore) / NaV AS OneSigmaVaRPerc
	, VaRs.PL
	, VaRs.PL / (VaRs.DollarVaR/ZScores.ZScore) AS PLonRisk

FROM	Vw_TotalVaRByFundByDate AS VaRs LEFT JOIN
	tbl_ZScores AS ZScores ON
		(VaRs.VaRConfidence = ZScores.Probability)

WHERE	VaRs.FundId = 44
	AND VaRs.VaRDate >= '1/oct/2010'
	AND VaRs.VaRDate <= '12/oct/2010'
