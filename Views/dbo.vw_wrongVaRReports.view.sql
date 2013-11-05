USE VIVALDI
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_wrongVaRReports]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_wrongVaRReports]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_wrongVaRReports]
AS

SELECT 	VaRs.FundId As FundId
	, VaRs.FundShortName AS FundName
	, VaRs.VaRDate AS ReportDate
	, SUM(VaRReports.MargVaR) * 100 AS SumOfMargVaR
	, VaRs.DollarVaR AS TotalVaR
	, ROUND((SUM(VaRReports.MargVaR) * 100 - VaRs.DollarVaR),2) AS VarDiff

FROM	tbl_VaRReports AS VaRReports 
	JOIN	vw_TotalVaRByFundByDate AS VaRs ON (
			VarReports.FundId = VaRs.FundId
			AND VaRReports.ReportDate = VaRs.VaRDate
			)
	JOIN	tbl_EnumVaRReports AS ReportsList ON (
			VaRReports.ReportId = Reportslist.Id
			)

WHERE	ReportsList.IsRelative = 0

GROUP BY	VaRs.DollarVaR
		, VaRs.VaRDate
		, VaRs.FundShortName
		, VaRs.FundId

--HAVING ROUND((SUM(VaRReports.MargVaR) * 100 - VaRs.DollarVaR),2) <> 0 
HAVING ROUND((SUM(VaRReports.MargVaR) * 100 / VaRs.DollarVaR),2) NOT BETWEEN 0.98 AND 1.02 