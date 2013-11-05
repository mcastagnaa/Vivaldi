USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetDashboardRiskRep') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetDashboardRiskRep
GO

CREATE PROCEDURE dbo.spS_GetDashboardRiskRep
	@RefDate datetime
	, @Lookback integer
	, @Offshore bit
	, @Select bit
AS

SET NOCOUNT ON;

DECLARE @FirstDate datetime
SET @FirstDate = Dateadd(mm, - @LookBack, @RefDate)

/* 
	TO-DO LIST
*/

----------------------------------------------------------------------
--== THE DATES BIT SIG ==--
SELECT	V.FundCode
		, MAX(NAVDate) AS LastDate
INTO	#LDatesSIG
FROM	[OMAMPROD01].[Product].dbo.vew_FSR_FacstetDailyRisk AS V 
WHERE		V.NaVDate <= @RefDate
GROUP BY	V.FundCode

SELECT	V.FundCode
		, MAX(NAVDate) AS PrevDate
INTO	#PDatesSIG
FROM	[OMAMPROD01].[Product].dbo.vew_FSR_FacstetDailyRisk AS V FULL JOIN
		#LDatesSIG AS L ON (
			V.FundCode = L.FundCode
		)
WHERE		V.NaVDate < L.LastDate
GROUP BY	V.FundCode

--== THE DATES BIT OMAM ==--
SELECT	V.FundId
		, MAX(V.VaRDate) AS LastDate
INTO	#LDatesOMAM
FROM	vw_TotalVaRByFundByDate AS V 
WHERE		V.VaRDate <= @RefDate
GROUP BY	V.FundId

SELECT	V.FundId
		, MAX(V.VaRDate) AS PrevDate
INTO	#PDatesOMAM
FROM	vw_TotalVaRByFundByDate AS V FULL JOIN
		#LDatesOMAM AS L ON (
			V.FundId = L.FundId
		)
WHERE		V.VaRDate < L.LastDate
GROUP BY	V.FundId	

----------------------------------------------------------------------
--== LAST VALUES SIG ==--

SELECT	V.FundCode
		, V.[PortFolio VaR]/100 AS PortVaR
		, V.[Benchmark VaR]/100 AS BenchVaR
		, V.[Gross Weight]/100 AS GrossExp
		, V.[Net Weight]/100 AS NetExp
		, L.LastDate
INTO	#LastVaRSIG
FROM	[PRODUCT].dbo.vew_FSR_FacstetDailyRisk AS V FULL JOIN
		#LDatesSIG AS L ON (
			V.NaVDate = L.LastDate
			AND V.FundCode = L.FundCode
		)
WHERE L.LastDate IS NOT NULL

--== PREV VALUES SIG ==--
SELECT	V.FundCode
		, V.[PortFolio VaR]/100 AS PortVaR
		, V.[Benchmark VaR]/100 AS BenchVaR
		, V.[Gross Weight]/100 AS GrossExp
		, V.[Net Weight]/100 AS NetExp
		, L.PrevDate
INTO	#PrevVaRSIG
FROM	[PRODUCT].dbo.vew_FSR_FacstetDailyRisk AS V FULL JOIN
		#PDatesSIG AS L ON (
			V.NaVDate = L.PrevDate
			AND V.FundCode = L.FundCode
		)
WHERE L.PrevDate IS NOT NULL

--== LAST VALUES OMAM ==--
SELECT	V.FundId
		, V.PercentVaR AS PortVaR
		, B.VaRbench/E.CostNaV AS BenchVaR
		, E.GrossExposure AS GrossExp
		, E.NetExposure AS NetExp
		, L.LastDate
INTO	#LastVaROMAM
FROM	vw_TotalVaRByFundByDate AS V FULL JOIN
		#LDatesOMAM AS L ON (
			V.VaRDate = L.LastDate
			AND V.FundId = L.FundId
			) LEFT JOIN
		vw_RelativeVaRReports AS B ON (
			V.VaRDate = B.ReportDate
			AND V.FundId = B.FundId 
			) LEFT JOIN
		tbl_FundsNaVsAndPLs AS E ON (
			V.VaRDate = E.NaVPLDate
			AND V.FundID = E.FundId
			)
WHERE L.LastDate IS NOT NULL
/*	AND B.VaRBench/E.CostNaV < 7
	AND E.GrossExposure < 600
 not tested!*/

--== PREV VALUES OMAM ==--
SELECT	V.FundId
		, V.PercentVaR AS PortVaR
		, B.VaRbench/E.CostNaV AS BenchVaR
		, E.GrossExposure AS GrossExp
		, E.NetExposure AS NetExp
		, L.PrevDate
INTO	#PrevVaROMAM
FROM	vw_TotalVaRByFundByDate AS V FULL JOIN
		#PDatesOMAM AS L ON (
			V.VaRDate = L.PrevDate
			AND V.FundId = L.FundId
			) LEFT JOIN
		vw_RelativeVaRReports AS B ON (
			V.VaRDate = B.ReportDate
			AND V.FundId = B.FundId
			) LEFT JOIN
		tbl_FundsNaVsAndPLs AS E ON (
			V.VaRDate = E.NaVPLDate
			AND V.FundID = E.FundId
			)
WHERE L.PrevDate IS NOT NULL

----------------------------------------------------------------------
--== PERIOD VALUES SIG ==--
SELECT	V.FundCode
		, 'FCST/MCVaR 99%, 1d, 1y Lbck' AS VaRModel
		, COUNT(V.[Portfolio VaR]) AS VaRObs
		, MIN(V.[Portfolio VaR])/100 AS PortVaRMin
		, MAX(V.[Portfolio VaR])/100 AS PortVaRMax
		, AVG(V.[Portfolio VaR])/100 AS PortVaRAvg
		, StDev(V.[Portfolio VaR])/100 AS PortVaRStD
		, MIN(V.[Benchmark VaR])/100 AS BenVaRMin
		, MAX(V.[Benchmark VaR])/100 AS BenVaRMax
		, AVG(V.[Benchmark VaR])/100 AS BenVaRAvg
		, StDev(V.[Benchmark VaR])/100 AS BenVaRStD
		, MIN(V.[Gross Weight])/100 AS GrossExpMin
		, MAX(V.[Gross Weight])/100 AS GrossExpMax
		, AVG(V.[Gross Weight])/100 AS GrossExpAvg
		, StDev(V.[Gross Weight])/100 AS GrossExpStD
		, MIN(V.[Net Weight])/100 AS NetExpMin
		, MAX(V.[Net Weight])/100 AS NetExpMax
		, AVG(V.[Net Weight])/100 AS NetExpAvg
		, StDev(V.[Net Weight])/100 AS NetExpStD
		, COUNT(V.[Portfolio VaR]) * (1-0.99) AS ExpectedVaREvents
		, SUM(CASE WHEN -V.[Portfolio VaR] > 
					V.[Portfolio Gross Return] THEN 1 
					ELSE 0 END) AS VaREventsNeg
		/*, SUM(CASE WHEN V.[Benchmark VaR] < 
					V.[Portfolio Gross Return] THEN 1 
					ELSE 0 END) AS VaREventsPos*/
INTO	#PerSIG
FROM	[Product].dbo.vew_FSR_FacstetDailyRisk AS V
WHERE		V.NaVDate <= @RefDate
			AND V.NaVDate > @FirstDate
GROUP BY	V.FundCode

UPDATE #PerSig
SET		FundCode = 'SKUKOPP'
WHERE	FundCode = 'UKOPP'

UPDATE #LastVaRSIG
SET		FundCode = 'SKUKOPP'
WHERE	FundCode = 'UKOPP'

UPDATE #PrevVaRSIG
SET		FundCode = 'SKUKOPP'
WHERE	FundCode = 'UKOPP'

--SELECT * FROM #PerSIG

----------------------------------------------------------------------
--== PERIOD VALUES OMAM ==--
SELECT	V.FundId
		, 'BBG/' + V.VaRModel + ' ' + 
				CAST(CAST(V.VaRConfidence*100 AS INTEGER) AS NVARCHAR(3)) + 
				'%, ' +	V.VaRHorizon + ', 1y Lbck' AS VaRModel
		, COUNT(V.VaRDate) AS VaRObs
		, MIN(V.PercentVaR) AS PortVaRMin
		, MAX(V.PercentVaR) AS PortVaRMax
		, AVG(V.PercentVaR) AS PortVaRAvg
		, StDev(V.PercentVaR) AS PortVaRStD
		, MIN(B.VaRbench/PL.CostNaV) AS BenVaRMin
		, MAX(B.VaRbench/PL.CostNaV) AS BenVaRMax
		, AVG(B.VaRbench/PL.CostNaV) AS BenVaRAvg
		, StDev(B.VaRbench/PL.CostNaV) AS BenVaRStD
		, MIN(PL.GrossExposure) AS GrossExpMin
		, MAX(PL.GrossExposure) AS GrossExpMax
		, AVG(PL.GrossExposure) AS GrossExpAvg
		, StDev(PL.GrossExposure) AS GrossExpStD
		, MIN(PL.NetExposure) AS NetExpMin
		, MAX(PL.NetExposure) AS NetExpMax
		, AVG(PL.NetExposure) AS NetExpAvg
		, StDev(PL.NetExposure) AS NetExpStD
		, COUNT(V.VaRDate) * (1-V.VarConfidence) AS ExpectedVaREvents
		, SUM(CASE WHEN -V.PercentVaR > 
					PL.TotalPl/PL.CostNaV THEN 1 
					ELSE 0 END) AS VaREventsNeg
		/*, SUM(CASE WHEN V.PercentVaR < 
					PL.TotalPl/PL.CostNaV THEN 1 
					ELSE 0 END) AS VaREventsPos*/
INTO	#PerOMAM
FROM	vw_TotalVaRByFundByDate AS V LEFT JOIN
		vw_RelativeVaRReports AS B ON (
			V.VaRDate = B.ReportDate
			AND V.FundId = B.FundId
			) LEFT JOIN 
		tbl_FundsNaVsAndPLs AS PL ON (
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
--== BRINGING IT ALL TOGETHER ==--

SELECT	PerOMAM.VaRModel
		, PerOMAM.VaRObs
		, PerOMAM.PortVaRMin
		, PerOMAM.PortVaRMax
		, PerOMAM.PortVaRAvg
		, PerOMAM.PortVaRStD
		, PerOMAM.BenVaRMin
		, PerOMAM.BenVaRMax
		, PerOMAM.BenVaRAvg
		, PerOMAM.BenVaRStD
		, PerOMAM.ExpectedVaREvents
		, PerOMAM.VaREventsNeg
		, LOMAM.LastDate
		, POMAM.PrevDate
		, LOMAM.PortVaR AS LastVaR
		, POMAM.PortVaR AS PrevVaR
		, LOMAM.PortVaR-POMAM.PortVaR AS VaRDiff
		, (LOMAM.PortVaR - PerOMAM.PortVaRMin)/
			NULLIF(PerOMAM.PortVaRMax - PerOMAM.PortVaRMin,0) AS LastVaROnRange
		, LOMAM.BenchVaR AS LastBenVaR
		, POMAM.BenchVaR AS PrevBenVaR
		, LOMAM.BenchVaR-POMAM.BenchVaR AS BenVaRDiff
		, LOMAM.PortVaR/LOMAM.BenchVaR AS LastPortBenVaRRatio
		, PerOMAM.GrossExpMin
		, PerOMAM.GrossExpMax
		, PerOMAM.GrossExpAvg
		, PerOMAM.GrossExpStD
		, LOMAM.GrossExp AS LastGrossExp
		, POMAM.GrossExp AS PrevGrossExp
		, LOMAM.GrossExp-POMAM.GrossExp AS GrossExpDiff
		, (LOMAM.GrossExp - PerOMAM.GrossExpMin)/
			NULLIF(PerOMAM.GrossExpMax - PerOMAM.GrossExpMin,0) AS LastGExpOnRange
		, PerOMAM.NetExpMin
		, PerOMAM.NetExpMax
		, PerOMAM.NetExpAvg
		, PerOMAM.NetExpStD
		, LOMAM.NetExp AS LastNetExp
		, POMAM.NetExp AS PrevNetExp
		, LOMAM.NetExp-POMAM.NetExp AS NetExpDiff
		, (LOMAM.NetExp - PerOMAM.NetExpMin)/
			NULLIF(PerOMAM.NetExpMax - PerOMAM.NetExpMin,0) AS LastNExpOnRange
		, F.FundCode
		, F.ConfidenceInt
INTO	#FullSet
FROM	#PerOMAM AS PerOMAM LEFT JOIN
		#LastVaROMAM AS LOMAM ON (
			PerOMAM.FundId = LOMAM.FundId
			) LEFT JOIN
		#PrevVaROMAM AS POMAM ON (
			PerOMAM.FundID = POMAM.FundId
			) LEFT JOIN
		tbl_Funds AS F ON (
			PerOMAM.FundId = F.Id
			)

UNION
SELECT	PerSIG.VaRModel
		, PerSIG.VaRObs
		, PerSIG.PortVaRMin
		, PerSIG.PortVaRMax
		, PerSIG.PortVaRAvg
		, PerSIG.PortVaRStD
		, PerSIG.BenVaRMin
		, PerSIG.BenVaRMax
		, PerSIG.BenVaRAvg
		, PerSIG.BenVaRStD
		, PerSIG.ExpectedVaREvents
		, PerSIG.VaREventsNeg
		, LSIG.LastDate
		, PSIG.PrevDate
		, LSIG.PortVaR AS LastVaR
		, PSIG.PortVaR AS PrevVaR
		, LSIG.PortVaR-PSIG.PortVaR AS VaRDiff
		, (LSIG.PortVaR - PerSIG.PortVaRMin)/
			NULLIF(PerSIG.PortVaRMax - PerSIG.PortVaRMin,0) AS LastVaROnRange
		, LSIG.BenchVaR AS LastBenVaR
		, PSIG.BenchVaR AS PrevBenVaR
		, LSIG.BenchVaR-PSIG.BenchVaR AS BenVaRDiff
		, LSIG.PortVaR/LSIG.BenchVaR AS LastPortBenVaRRatio
		, PerSIG.GrossExpMin
		, PerSIG.GrossExpMax
		, PerSIG.GrossExpAvg
		, PerSIG.GrossExpStD
		, LSIG.GrossExp AS LastGrossExp
		, PSIG.GrossExp AS PrevGrossExp
		, LSIG.GrossExp-PSIG.GrossExp AS GrossExpDiff
		, (LSIG.GrossExp - PerSIG.GrossExpMin)/
			NULLIF(PerSIG.GrossExpMax - PerSIG.GrossExpMin,0) AS LastGExpOnRange
		, PerSIG.NetExpMin
		, PerSIG.NetExpMax
		, PerSIG.NetExpAvg
		, PerSIG.NetExpStD
		, LSIG.NetExp AS LastNetExp
		, PSIG.NetExp AS PrevNetExp
		, LSIG.NetExp-PSIG.NetExp AS NetExpDiff
		, (LSIG.NetExp - PerSIG.NetExpMin)/
			NULLIF(PerSIG.NetExpMax - PerSIG.NetExpMin, 0) AS LastNExpOnRange
		, PerSig.FundCode
		, 0.99

--INTO	#FullSet
FROM	#PerSIG AS PerSIG LEFT JOIN
		#LastVaRSIG AS LSIG ON (
			PerSIG.FundCode = LSIG.FundCode
			) LEFT JOIN
		#PrevVaRSIG AS PSIG ON (
			PerSIG.FundCode = PSIG.FundCode
			)
WHERE PerSIG.FundCode NOT IN ('SKGBLBND', 'SKEUREQ', 'SKJPNEQ', 'SKGEQ', 
			'SKUKCONST')

----------------------------------------------------------------------
--== ADDING FUND DETAILS ==--
SELECT	Prod.ShortCode AS FundCode
		, Prod.FundName
		, Prod.Company
		, Prod.SoldAs
		, Vehic.LongName AS Vehicle
		, Prod.OurTeam AS DeskShort
		, Desk.LongName As Desk
		, Prod.OurPM AS PM
		, Prod.IsSelect
		, Prod.InvManager AS IM
		, Bench.Code AS BenchCode
		, Bench.LongName AS BenchName
		, Bench.IsCash AS IsBenchCash
		, '<b><i>' + Prod.ShortCode + ' - ' + Prod.FundName + '</i></b>, Inv.Manager: <b>' 
				+ Prod.InvManager +	'</b>, Responsible: <b>' + 
				Prod.OurPM + '</b>' AS FundDets
		, (CASE WHEN Bench.Code IS NOT NULL AND Bench.IsCash = 0 THEN
				'Benchmark: <i>' + Bench.LongName + '</i>'
				ELSE NULL END) AS BenchDets
		, 'VaR model: <b>' + FS.VaRMODEL + '</b> - Last risk data: <b>' + 
				CONVERT(VARCHAR(8), FS.LastDate , 3) + '</b>, observations: <b>' +
				CONVERT(NVARCHAR(3), FS.VaRObs) + '</b>' AS ObsDets
		, FS.LastDate
		, (CASE WHEN FS.LastDate IS NULL THEN '*'
				WHEN DATEDIFF(dd, FS.LastDate, @RefDate) > 4 THEN '*' 
				ELSE '' END) AS MissingData
		, FS.VarMODEL
		, FS.VaRObs
		, FS.LastVaR
		, FS.VaRDiff
		, '<b>' + CAST(ROUND(FS.LastVaR, 4) * 100 AS NVARCHAR(7)) + '%</b> (' +
			'<font color="' + (CASE WHEN FS.VaRDiff > 0 THEN 'green' ELSE 'red' END) +  
			'">' + CAST(ROUND(FS.VaRDiff,4) * 10000 AS NVARCHAR(7)) + 'b</font>)' AS VaRLabel
		, FS.LastBenVaR
		, FS.LastVaR/LastBenVaR AS VaRatio
		, FS.PortVaRAvg
		, FS.PortVaRMin
		, FS.PortVaRMax
		, CAST(ROUND(FS.PortVaRAvg, 4) * 100 AS NVARCHAR(7)) + '% (<font color="gray">' +  
				+ CAST(ROUND(FS.PortVaRMin,4) * 100 AS NVARCHAR(7)) + '/' +
				+ CAST(ROUND(FS.PortVaRMax,4) * 100 AS NVARCHAR(7)) + 
				'</font>)' AS VaRRange
		, FS.BenVaRAvg
		, FS.PortVaRAvg/FS.BenVaRAvg AS VaRAvgRatio
		, FS.ExpectedVaREvents
		, FS.VaREventsNeg AS VaREvents
		, (CASE WHEN Prod.RiskLimitName = 'Exposure' THEN NULL 
				ELSE CAST(FS.VaREventsNeg AS nvarchar(3)) + ' (' +
					CAST(ROUND(FS.ExpectedVaREvents,1) AS nvarchar(5)) + ')'
				END) AS BckTstLabel	
		, (CASE WHEN (FS.ConfidenceInt = 0.99 
						AND FS.VaREventsNeg > 4
						AND ISNULL(Prod.RiskLimitName, '') <> 'Exposure') 
				THEN '*' ELSE '' END) AS BckTestFail
		, FS.LastGrossExp
		, FS.GrossExpAvg
		, FS.GrossExpMin
		, FS.GrossExpMax
		, CAST(ROUND(FS.GrossExpAvg, 2) * 100 AS NVARCHAR(5)) + '% (<font color="gray">' +  
				+ CAST(ROUND(FS.GrossExpMin,2) * 100 AS NVARCHAR(5)) + '/' +
				+ CAST(ROUND(FS.GrossExpMax,2) * 100 AS NVARCHAR(5)) + 
				'</font>)' AS GrossExpRange
		, FS.LastNetExp
		, FS.NetExpAvg
		, FS.NetExpMin
		, FS.NetExpMax
		, CAST(ROUND(FS.NetExpAvg, 2) * 100 AS NVARCHAR(5)) + '% (<font color="gray">' +  
				+ CAST(ROUND(FS.NetExpMin,2) * 100 AS NVARCHAR(5)) + '/' +
				+ CAST(ROUND(FS.NetExpMax,2) * 100 AS NVARCHAR(5)) + 
				'</font>)' AS NetExpRange
		, Prod.RiskLimitName AS LimitType
		, Prod.RiskLimitValue AS Limit
		, (CASE Prod.RiskLimitName 
				WHEN 'Absolute' THEN
					((CASE FS.ConfidenceInt WHEN 0.95 THEN 1.414319 ELSE 1 END) * FS.LastVaR) 
				WHEN 'Relative' THEN
					FS.LastVaR/LastBenVaR 
				WHEN 'Exposure' THEN
					FS.LastGrossExp 
				ELSE null
			END) AS IsBreach

FROM	[OMAMPROD01].[PerfRep].dbo.tbl_Products AS Prod LEFT JOIN
		#FullSet As FS ON (
			Prod.ShortCode = FS.FundCode
		)	LEFT JOIN
		[OMAMPROD01].[PerfRep].dbo.tbl_benchmarks AS Bench ON (
			Prod.BenchmarkId = Bench.Id
		) LEFT JOIN
		tbl_Vehicles AS Vehic ON (Vehic.ShortName = Prod.SoldAS)
			LEFT JOIN
		[OMAMPROD01].[PerfRep].dbo.tbl_Desks AS Desk ON
			(Desk.Code = Prod.OurTeam)
WHERE	Prod.InceptionDate < @RefDate
		AND ISNULL(Prod.CloseDate,GetDate()) > @RefDate
--		AND NOT (Prod.OurTeam = 'ExtSStrat' AND Prod.IsSelect = 1)
		AND (@Offshore = 0 OR Prod.SoldAs = 'UCITS4')
		AND (@Select = 0 OR (Prod.IsSelect = 1))
		AND	Prod.ShortCode NOT IN ('OMTSY')

ORDER BY	Prod.OurTeam
			, Prod.OurPM
			, Prod.SoldAs

----------------------------------------------------------------------
--== TESTS ==--
--SELECT * FROM #LDatesOMAM
--SELECT * FROM #PDatesOMAM
--SELECT * FROM #LastVaRSIG ORDER BY FundCode DESC
--SELECT * FROM #PrevVaRSIG ORDER BY FundCode DESC
--SELECT * FROM #LastVaROMAM
--SELECT * FROM #PrevVaROMAM
--SELECT * FROM #PerSIG ORDER BY FundCode DESC
--SELECT * FROM #PerOMAM ORDER BY FundId DESC
--SELECT * FROM #FullSet ORDER BY FundCode DESC


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
--DROP TABLE #FullSet

-----------------------------------------------------------------

GO

GRANT EXECUTE ON dbo.spS_GetDashboardRiskRep TO [OMAM\Compliance]