USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_PreTradeData]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_PreTradeData]
GO

CREATE PROCEDURE [dbo].[spS_PreTradeData] 
	@RefDate datetime
	, @AbsRepId int
	, @RelRepId int
AS

SET NOCOUNT ON;



SELECT	TOP 100 VaRDate
	, PercentVaR
	, (SELECT TOP 1 PercentVaR
		FROM vw_TotalVaRByFundByDate AS SubVaRTable 
		WHERE	VaRDate < MainVaRsTable.VaRDate
			AND ReportId = @AbsRepId
		ORDER BY VaRDate DESC ) AS PrevVaR

INTO	#PortfVaRs

FROM	vw_TotalVaRByFundByDate AS MainVaRsTable
WHERE	ReportId = @AbsRepId
	AND VaRDate <= @RefDate
GROUP BY	VaRDate
		, percentVaR
ORDER BY 	VaRDate DESC

---------------------------------------------------------------

SELECT	VaRs.ReportDate
	, VaRs.VarBench/NaVs.CostNaV AS BenchVaR
INTO	#BenchVaRs
FROM	tbl_VaRReports AS VaRs LEFT JOIN
	tbl_FundsNaVsAndPls AS NaVs ON 
		(VaRs.FundId = NaVs.FundId
		AND VaRs.ReportDate = NaVs.NaVPLDate)
WHERE	ReportId = @RelRepId
	AND ReportDate <= @RefDate
	AND SecTicker = 'Totals'

---------------------------------------------------------------


SELECT	PortfVaRs.VaRDate
	, PortfVaRs.PercentVaR
	, PortfVaRs.PrevVaR
	, PortfVaRs.PercentVaR - PortfVaRs.PrevVaR AS VaRChanges
	, (CASE
		WHEN PortfVaRs.PercentVaR > PortfVaRs.PrevVaR 
			THEN PortfVaRs.PercentVaR - PortfVaRs.PrevVaR
		ELSE 0
	END) AS PositiveVaRChanges
	, BenchVaRs.BenchVaR

FROM	#PortfVaRs AS PortfVaRs LEFT JOIN
	#BenchVaRs AS BenchVaRs ON
		(PortfVaRs.VaRDate = BenchVaRs.ReportDate)
ORDER BY VaRDate ASC

---------------------------------------------------------------

DROP TABLE #PortfVaRs
DROP TABLE #BenchVaRs
GO

GRANT EXECUTE ON spS_PreTradeData TO [OMAM\StephaneD], [OMAM\MargaretA] 