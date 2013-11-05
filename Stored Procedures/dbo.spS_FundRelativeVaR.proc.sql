USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_FundRelativeVaR]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_FundRelativeVaR]
GO


CREATE PROCEDURE [dbo].[spS_FundRelativeVaR] 
	@RefDate datetime
	, @FundId int

AS

DECLARE @SumOfActiveVaROnNaV float

SET NOCOUNT ON;


SELECT	VarReports.SecTicker AS Ticker
	, VarReports.BBGInstrId AS BBGId
	, VarReports.SecName
	, VarReports.PortShare/100 AS PortfWeight
	, VarReports.BenchPerc/100 AS BenchWeight
	, VarReports.ActivePerc/100 AS ActiveWeight
	, ABS(VarReports.ActivePerc) AS AbsActiveWeight
	, VarReports.VaRActive
	, NaVs.CostNaV AS NaV
	, (VarReports.VaRActive/NaVs.CostNaV) AS ActiveVaROnNaV

INTO	#LineData

FROM 	tbl_VaRReports AS VaRReports LEFT JOIN
	tbl_EnumVaRReports AS Reports ON (
		VarReports.ReportId = Reports.ID		
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		VaRReports.FundId = NaVs.FundId
		AND VaRReports.ReportDate = NaVs.NaVPLDate
		)

WHERE	VaRReports.FundId = @FundId
	AND VaRReports.ReportDate = @RefDate
	AND VaRReports.SecTicker <> 'Totals'
	AND Reports.IsRelative = 1

ORDER BY VarReports.VaRActive DESC

----------------------------------------------------------------------------------


/*SELECT	VarReports.SecTicker AS Ticker
	, VarReports.BBGInstrId AS BBGId
	, VarReports.SecName
	, VarReports.PortShare/100 AS PortfWeight
	, VarReports.BenchPerc/100 AS BechWeight
	, VarReports.ActivePerc/100 AS ActiveWeight
	, ABS(VarReports.ActivePerc) AS AbsActiveWeight
	, VarReports.VaRActive
	, NaVs.CostNaV AS NaV
	, (VarReports.VaRActive/NaVs.CostNaV) AS ActiveVaROnNaV

INTO	#FundData

FROM 	tbl_VaRReports AS VaRReports LEFT JOIN
	tbl_EnumVaRReports AS Reports ON (
		VarReports.ReportId = Reports.ID		
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		VaRReports.FundId = NaVs.FundId
		AND VaRReports.ReportDate = NaVs.NaVPLDate
		)

WHERE	VaRReports.FundId = @FundId
	AND VaRReports.ReportDate = @RefDate
	AND VaRReports.SecTicker = 'Totals'
	AND Reports.IsRelative = 1*/

SET @SumOfActiveVaROnNaV = (SELECT SUM(ActiveVaROnNaV) FROM #LineData)


----------------------------------------------------------------------------------

SELECT	Line.Ticker
	, Line.BBGId
	, Line.SecName
	, Line.PortfWeight AS PortfWeight
	, Line.BenchWeight AS BenchWeight
	, Line.ActiveWeight AS ActiveWeight
	, Line.AbsActiveWeight AS AbsActiveWeight
	, Line.VaRActive AS VaRActive
	, Line.NaV AS NaV
	, Line.ActiveVaROnNaV AS ActiveVaROnNaV
	, Line.ActiveVaROnNaV/@SumOfActiveVaROnNaV AS ActiveOnSumActive


FROM 	#LineData AS Line--, #FundData AS Fund

ORDER BY ABS(Line.ActiveVaROnNaV/@SumOfActiveVaROnNaV) DESC


----------------------------------------------------------------------------------

--SELECT * FROM #LineData
--SELECT * FROM #FundData

----------------------------------------------------------------------------------

DROP TABLE #LineData
--DROP TABLE #FundData

----------------------------------------------------------------------------------

GO


GRANT EXECUTE ON spS_FundRelativeVaR TO [OMAM\StephaneD], [OMAM\MargaretA] 