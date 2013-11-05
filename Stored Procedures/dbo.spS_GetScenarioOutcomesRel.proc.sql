USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetScenarioOutcomesRel]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetScenarioOutcomesRel]
GO

CREATE PROCEDURE [dbo].[spS_GetScenarioOutcomesRel] 
	@RefDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;


SELECT	Scen.ReportDate
	, Scen.FundId
	, MIN(Scen.PortPerf*Scen.MktVal/Navs.CostNav - ISNULL(Scen.BenchPerf,0)) AS WrstRelScenario
	, Navs.CostNaV

INTO	#Wrst

FROM 	tbl_ScenReports AS Scen LEFT JOIN
		tbl_FundsNavsAndPLs AS NaVs ON (
		Scen.FundId = NaVs.FundId
		AND Scen.ReportDate = NaVs.NaVPLDate
		)

WHERE	Scen.FundId = @FundId
	AND Scen.ReportDate > DATEADD(month,-3, @RefDate)

GROUP BY	Scen.ReportDate
		, Scen.FundId
		, NaVs.CostNaV

------------------------------------------------------------------------------

SELECT	Reports.ReportId
	, Descr.Id AS ScenarioId
	, Descr.ScenLabel AS Scenario
--	, Count(ReportId) AS TotalCount
--	, Wrst.ReportDate
	, Wrst.WrstRelScenario AS WrstScenario

INTO	#WhichIsWrst
FROM	#Wrst AS Wrst JOIN
	tbl_ScenReports AS Reports ON
		(Wrst.WrstRelScenario = (Reports.PortPerf*Reports.MktVal/Wrst.CostNav 
						- ISNULL(Reports.BenchPerf,0))
		AND Wrst.ReportDate = Reports.ReportDate
		AND Wrst.FundId = Reports.FundId) JOIN
	tbl_EnumScen AS Descr ON
		(Reports.ReportId = Descr.Id)


------------------------------------------------------------------------------

SELECT	ScenarioId
	, Scenario + ' (avg: ' + CAST(ROUND(AVG(WrstScenario),2) AS VARCHAR(6)) + '%)' AS Scenario
	, Count(ReportId) AS Outcomes
	, (SELECT Count(*) FROM #WhichIsWrst)  AS TotalScens
	, CAST(Count(ReportId) AS FLOAT)/CAST((SELECT Count(*) FROM #WhichIsWrst) AS FLOAT) AS Outcome
FROM	#WhichIsWrst
GROUP BY	ScenarioId
		, Scenario
		, ReportId

------------------------------------------------------------------------------
DROP TABLE #Wrst
DROP TABLE #WhichIsWrst

GO

GRANT EXECUTE ON spS_GetScenarioOutcomesRel TO [OMAM\StephaneD]