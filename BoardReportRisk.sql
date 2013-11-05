USE Vivaldi
GO
DECLARE @RefDate datetime
	, @FirstDate datetime
SET @RefDate = '2012 Dec 31'

SET @FirstDate = DATEADD(m, -3, @RefDate)


SELECT 	AV.FundId
	, F.FundCode
	, F.FundName
	, F.BenchLong AS Benchmark
	, F.HoDCode AS HoD
	, F.VaRModelDetails
	, AVG(S.NetExposure) AS AvgNetExp
	, MIN(S.NetExposure) AS MinNetExp
	, MAX(S.NetExposure) AS MaxNetExp

	, AVG(S.GrossExposure) AS AvgGrossExp
	, MIN(S.GrossExposure) AS MinGrossExp
	, MAX(S.GrossExposure) AS MaxGrossExp

	, AVG(AV.PercentVAR) AS AvgAbsVaR
	, MIN(AV.PercentVAR) AS MinAbsVaR
	, MAX(AV.PercentVAR) AS MaxAbsVaR 

	, AVG(RV.ExAnteTE1d) AS AvgRelVaR
	, MIN(RV.ExAnteTE1d) AS MinRelVaR
	, MAX(RV.ExAnteTE1d) AS MaxRelVaR 


FROM	Vw_TotalVaRByFundByDate AS AV LEFT JOIN
	VW_FundsTypology AS F ON (
		AV.FundId = F.FundId
		) LEFT JOIN
	VW_RelativeVaRReports AS RV ON (
		RV.FundId = AV.FundID
		AND RV.ReportDate = AV.VARDate
		) LEFT JOIN
	tbl_FundsNavsAndPLs AS S ON (
		S.NaVPLDate = AV.VARDate
		AND S.FundId = AV.FundId
		)

WHERE	AV.VaRDate<= @RefDate
	AND AV.VaRDate > @FirstDate

GROUP BY	AV.FundId
		, F.FundCode
		, F.FundName
		, F.BenchLong
		, F.HoDCode
		, F.VaRModelDetails

ORDER BY 	F.HoDCode
		, F.FundCode
