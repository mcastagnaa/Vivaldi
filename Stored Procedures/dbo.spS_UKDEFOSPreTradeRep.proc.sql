USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_UKDEFOSPreTradeRep]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_UKDEFOSPreTradeRep]
GO

CREATE PROCEDURE [dbo].[spS_UKDEFOSPreTradeRep] 
	@RefDate datetime
	, @AbsRepId int
	, @RelRepId int
AS

SET NOCOUNT ON;



SELECT	TOP 100 VaRDate
	, PercentVaR
	, BenchLong
	, (SELECT TOP 1 PercentVaR
		FROM vw_TotalVaRByFundByDate AS SubVaRTable 
		WHERE	VaRDate < MainVaRTable.VaRDate
			AND ReportId = @AbsRepId
		ORDER BY VaRDate DESC ) AS PrevVaR

INTO	#VaRList

FROM	vw_TotalVaRByFundByDate AS MainVaRTable
WHERE	ReportId = @AbsRepId
	AND VaRDate <= @RefDate
GROUP BY	VaRDate
		, percentVaR
		, BenchLong

ORDER BY 	VaRDate DESC

---------------------------------------------------------------

SELECT	ReportDate
	, 2 * VarBench/(MarketValThousands*1000) AS TwoBenchVaR
	, [VaR]/(MarketValThousands*1000) AS PortfVaR
INTO	#LastBenchVaR
FROM	tbl_VaRReports
WHERE	ReportId = @RelRepId
	AND ReportDate = @RefDate
	AND SecTicker = 'Totals'

---------------------------------------------------------------

SELECT	VaRDate as MaxChangeDate
	, PercentVaR AS VaR1
	, PrevVaR AS VaR2
	, PercentVaR-PrevVaR AS VaRChange
	, BenchLong
INTO	#MaxVaRChange
FROM	#VARList
WHERE	PercentVaR-PrevVaR = (SELECT MAX(PercentVaR-PrevVaR) AS MaxVaRChange FROM #VaRList)

---------------------------------------------------------------

SELECT	MIN(VaRDate) as FirstRepDate
INTO	#FirstDate
FROM	#VARList

---------------------------------------------------------------


SELECT	LastBench.*
	, MaxVaR.*
	, FirstDate.*
	, LastBench.TwoBenchVaR - 2 * MaxVaR.VaRChange AS Threshold
	, LastBench.TwoBenchVaR - 2 * MaxVaR.VaRChange - LastBench.PortfVaR AS TEST
	, (CASE 
		WHEN (LastBench.TwoBenchVaR - 2 * MaxVaR.VaRChange - LastBench.PortfVaR) > 0 
			THEN 0 --'No pre-trade VaR needed'
		WHEN (LastBench.TwoBenchVaR - 2 * MaxVaR.VaRChange - LastBench.PortfVaR) <= 0 
			THEN 1 --'Pre-trade VaR needed' 
	END) AS TestResult

FROM	#LastBenchVaR AS LastBench
	, #MaxVarChange As MaxVar
	, #FirstDate AS FirstDate

---------------------------------------------------------------

DROP TABLE #VaRList
DROP TABLE #LastBenchVaR
DROP TABLE #MaxVaRChange
DROP TABLE #FirstDate
GO

GRANT EXECUTE ON spS_UKDEFOSPreTradeRep TO [OMAM\StephaneD], [OMAM\MargaretA] 