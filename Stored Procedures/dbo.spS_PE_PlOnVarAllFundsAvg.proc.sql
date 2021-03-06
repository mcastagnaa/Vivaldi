USE [Vivaldi]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_PE_PlOnVarAllFundsAvg]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_PE_PlOnVarAllFundsAvg]
GO

CREATE PROCEDURE [dbo].[spS_PE_PlOnVarAllFundsAvg] 
	@StartDate datetime,
	@EndDate datetime
AS

SET NOCOUNT ON;

SELECT	VaRs.FundShortName AS FundCode
	, Funds.VehicleName AS Vehicle
	, Funds.VehicleStrategyName AS Strategy
	, Funds.StyleName AS Style
	, Funds.BenchLong AS Benchmark
	, HoD.Name + ' ' + HoD.Surname AS HeadOfDesk
	, SUM(VaRs.PL)/SUM(VaRs.DollarVaR/ZScores.ZScore) AS AvgPLonRisk
	, AVG(VaRs.PercentVaR/ZScores.ZScore) AS AvgRisk
	, (SELECT MIN(ReportDate) FROM tbl_varReports WHERE FundId = Funds.FundId 
		AND ReportDate > @StartDate GROUP BY FundId) AS FirstSampleDate
	, (SELECT MAX(ReportDate) FROM tbl_varReports WHERE FundId = Funds.FundId 
		AND ReportDate <= @EndDate GROUP BY FundId) AS EndSampleDate
	, COUNT(VaRs.PercentVaR) AS Obs

FROM	Vw_TotalVaRByFundByDate AS VaRs LEFT JOIN
	tbl_ZScores AS ZScores ON (
		VaRs.VaRConfidence = ZScores.Probability
	) LEFT JOIN vw_FundsTypology AS Funds ON (
		VaRs.FundId = Funds.FundId
	) LEFT JOIN vw_FundsPeopleRoles AS HoD ON (
		VaRs.FundId = HoD.FundId
	)

WHERE	VaRs.VaRDate > @StartDate
	AND VaRs.VaRDate <= @EndDate
	AND HoD.RoleId = 1
	AND Funds.IsAlive = 1
	AND Funds.IsSkip = 0
	AND Funds.FundCode NOT IN ('UGEF', 'UPUF', 'GSAFLX', 'GSAFLF', 'GSAFMN', 
								'SMFO', 'U7', 'TEWK', 'SKANMC', 'VGDEOMUK', 'EBIOM')

GROUP BY	VaRs.FundShortName
		, Funds.VehicleName
		, Funds.VehicleStrategyName
		, Funds.StyleName
		, Funds.BenchLong
		, Funds.FundId
		, HoD.Name 
		, HoD.Surname


ORDER BY SUM(VaRs.PL)/SUM(VaRs.DollarVaR/ZScores.ZScore) DESC

-------------------------------------------------------------------------------------------------

