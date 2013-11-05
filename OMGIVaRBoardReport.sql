USE PerfRep;

DECLARE	@RefDate datetime
DECLARE @FirstDate datetime
SET	@RefDate = Dateadd(dd, 0, GetDate())
SET @FirstDate = Dateadd(mm, -3, @RefDate)

/* 
	TO-DO LIST
	- classify funds by desk
	- daily check
	- add exposure numbers
*/

----------------------------------------------------------------------
--== THE DATES BIT SIG ==--
SELECT	V.FundName
		, MAX(NAVDate) AS LastDate
INTO	#LDatesSIG
FROM	[OMAMPROD01].[Product].dbo.vew_FSR_FacstetDailyRisk AS V 
WHERE		V.NaVDate <= @RefDate
GROUP BY	V.FundName


SELECT	V.FundName
		, MAX(NAVDate) AS PrevDate
INTO	#PDatesSIG
FROM	[OMAMPROD01].[Product].dbo.vew_FSR_FacstetDailyRisk AS V FULL JOIN
		#LDatesSIG AS L ON (
			V.Fundname = L.FundName
		)
WHERE		V.NaVDate < L.LastDate
GROUP BY	V.FundName

--== THE DATES BIT OMAM ==--
SELECT	V.FundId
		, MAX(V.VaRDate) AS LastDate
INTO	#LDatesOMAM
FROM	[OMAMPROD01].[VIVALDI].dbo.vw_TotalVaRByFundByDate AS V 
WHERE		V.VaRDate <= @RefDate
GROUP BY	V.FundId


SELECT	V.FundId
		, MAX(V.VaRDate) AS PrevDate
INTO	#PDatesOMAM
FROM	[OMAMPROD01].[VIVALDI].dbo.vw_TotalVaRByFundByDate AS V FULL JOIN
		#LDatesOMAM AS L ON (
			V.FundId = L.FundId
		)
WHERE		V.VaRDate < L.LastDate
GROUP BY	V.FundId	

----------------------------------------------------------------------
--== LAST VALUES SIG ==--

SELECT	V.FundName
		, V.[PortFolio VaR]/100 AS PortVaR
		, V.[Benchmark VaR]/100 AS BenchVaR
		, L.LastDate
INTO	#LastVaRSIG
FROM	[OMAMPROD01].[PRODUCT].dbo.vew_FSR_FacstetDailyRisk AS V FULL JOIN
		#LDatesSIG AS L ON (
			V.NaVDate = L.LastDate
			AND V.FundName = L.FundName
		)
WHERE L.LastDate IS NOT NULL

SELECT	V.FundName
		, V.[PortFolio VaR]/100 AS PortVaR
		, V.[Benchmark VaR]/100 AS BenchVaR
		, L.PrevDate
INTO	#PrevVaRSIG
FROM	[OMAMPROD01].[PRODUCT].dbo.vew_FSR_FacstetDailyRisk AS V FULL JOIN
		#PDatesSIG AS L ON (
			V.NaVDate = L.PrevDate
			AND V.FundName = L.FundName
		)
WHERE L.PrevDate IS NOT NULL

----------------------------------------------------------------------
--== LAST VALUES OMAM ==--
SELECT	V.FundId
		, V.PercentVaR AS PortVaR
		, B.VaRbench/CostNaV AS BenchVaR
		, L.LastDate
INTO	#LastVaROMAM
FROM	[OMAMPROD01].[VIVALDI].dbo.vw_TotalVaRByFundByDate AS V FULL JOIN
		#LDatesOMAM AS L ON (
			V.VaRDate = L.LastDate
			AND V.FundId = L.FundId
			) LEFT JOIN
		[OMAMPROD01].[VIVALDI].dbo.vw_RelativeVaRReports AS B ON (
			V.VaRDate = B.ReportDate
			AND V.FundId = B.FundId
			)
WHERE L.LastDate IS NOT NULL

SELECT	V.FundId
		, V.PercentVaR AS PortVaR
		, B.VaRbench/CostNaV AS BenchVaR
		, L.PrevDate
INTO	#PrevVaROMAM
FROM	[OMAMPROD01].[VIVALDI].dbo.vw_TotalVaRByFundByDate AS V FULL JOIN
		#PDatesOMAM AS L ON (
			V.VaRDate = L.PrevDate
			AND V.FundId = L.FundId
			) LEFT JOIN
		[OMAMPROD01].[VIVALDI].dbo.vw_RelativeVaRReports AS B ON (
			V.VaRDate = B.ReportDate
			AND V.FundId = B.FundId
			)
WHERE L.PrevDate IS NOT NULL

----------------------------------------------------------------------
--== PERIOD VALUES SIG ==--
SELECT	V.FundName
		, 'HVaR 99%, 1d, 1y Lookback' AS VaRModel
		, COUNT(V.[Portfolio VaR]) AS VaRObs
		, MIN(V.[Portfolio VaR])/100 AS PortVaRMin
		, MAX(V.[Portfolio VaR])/100 AS PortVaRMax
		, AVG(V.[Portfolio VaR])/100 AS PortVaRAvg
		, StDev(V.[Portfolio VaR])/100 AS PortVaRStD
		, MIN(V.[Benchmark VaR])/100 AS BenVaRMin
		, MAX(V.[Benchmark VaR])/100 AS BenVaRMax
		, AVG(V.[Benchmark VaR])/100 AS BenVaRAvg
		, StDev(V.[Benchmark VaR])/100 AS BenVaRStD
		, SUM(CASE WHEN -V.[Benchmark VaR] > 
					V.[Portfolio Gross Return] THEN 1 
					ELSE 0 END) AS VaREventsNeg
		, SUM(CASE WHEN V.[Benchmark VaR] < 
					V.[Portfolio Gross Return] THEN 1 
					ELSE 0 END) AS VaREventsPos
INTO	#PerSIG
FROM	[OMAMPROD01].[Product].dbo.vew_FSR_FacstetDailyRisk AS V
WHERE		V.NaVDate <= @RefDate
			AND V.NaVDate > @FirstDate
GROUP BY	V.FundName


----------------------------------------------------------------------
--== PERIOD VALUES OMAM ==--
SELECT	V.FundId
		, V.VaRModel + ' ' + 
				CAST(CAST(V.VaRConfidence*100 AS INTEGER) AS NVARCHAR(3)) + 
				'%, ' +	V.VaRHorizon + ', 1y Lookback' AS VaRModel
		, COUNT(V.VaRDate) AS VaRObs
		, MIN(V.PercentVaR) AS PortVaRMin
		, MAX(V.PercentVaR) AS PortVaRMax
		, AVG(V.PercentVaR) AS PortVaRAvg
		, StDev(V.PercentVaR) AS PortVaRStD
		, MIN(B.VaRbench/PL.CostNaV) AS BenVaRMin
		, MAX(B.VaRbench/PL.CostNaV) AS BenVaRMax
		, AVG(B.VaRbench/PL.CostNaV) AS BenVaRAvg
		, StDev(B.VaRbench/PL.CostNaV) AS BenVaRStD
		, SUM(CASE WHEN -V.PercentVaR > 
					PL.TotalPl/PL.CostNaV THEN 1 
					ELSE 0 END) AS VaREventsNeg
		, SUM(CASE WHEN V.PercentVaR < 
					PL.TotalPl/PL.CostNaV THEN 1 
					ELSE 0 END) AS VaREventsPos
INTO	#PerOMAM
FROM	[OMAMPROD01].[Vivaldi].dbo.vw_TotalVaRByFundByDate AS V LEFT JOIN
		[OMAMPROD01].[Vivaldi].dbo.vw_RelativeVaRReports AS B ON (
			V.VaRDate = B.ReportDate
			AND V.FundId = B.FundId
			) LEFT JOIN 
		[OMAMPROD01].[Vivaldi].dbo.tbl_FundsNaVsAndPLs AS PL ON (
			V.VaRDate = PL.NaVPLDate
			AND V.FundId = PL.FundId
			)
WHERE		V.VARDate <= @RefDate
			AND V.VaRDate > @FirstDate
GROUP BY	V.FundID
			, V.VaRModel
			, V.VaRConfidence
			, V.VaRHorizon

			
----------------------------------------------------------------------
--== CLEAN UP == --
DROP TABLE #LDatesSIG
DROP TABLE #PDatesSIG
DROP TABLE #LDatesOMAM
DROP TABLE #PDatesOMAM
DROP TABLE #LastVaRSIG
DROP TABLE #PrevVaRSIG
DROP TABLE #LastVaROMAM
DROP TABLE #PrevVaROMAM
DROP TABLE #PerSIG
DROP TABLE #PerOMAM
