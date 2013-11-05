USE Vivaldi
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_VaRByFundByDatePORTDets]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_VaRByFundByDatePORTDets]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_VaRByFundByDatePORTDets]
AS



SELECT	VAR.ReportDate
		, Funds.FundCode
		, VAR.FundId
		, VAR.ReportId
		, Reps.IsRelative
		, SUM(VAR.NumSec) AS SecNumber
		, SUM(VAR.PortShare) AS SumPortWeights
		, SUM(VAR.BenchPerc) AS SumBenchWeights
		, SUM(VAR.MargVAR) AS SumMarg
		, COUNT(Expt.ID) AS ExceptionsCount

FROM	tbl_VaRReportsPORT AS VAR LEFT JOIN
		tbl_VaRRepExceptionsPORT AS Expt ON (
			VAR.ReportDate = Expt.ReportDate
			AND VAR.ReportId = Expt.ReportId
			AND VAR.BBGInstrId = Expt.BBGInstrId
			) LEFT JOIN
		tbl_EnumVaRReports AS Reps ON (
			VaR.ReportId = Reps.ID
			) LEFT JOIN
		tbl_Funds AS Funds ON (
			VaR.FundId = Funds.Id
			)

WHERE	VAR.SecTicker <> 'Totals' 


GROUP BY	VAR.ReportDate
			, VAR.FundId
			, VAR.ReportId
			, Funds.FundCode
			, Reps.IsRelative

--ORDER BY	VAR.FundId, Reps.IsRelative, VAR.ReportDate

