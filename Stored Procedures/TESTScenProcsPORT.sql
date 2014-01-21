Use Vivaldi;

--PAST
--EXEC spS_GetScenarioOutcomesAbs '2013 May 1', 5
--EXEC spS_GetScenarioOutcomesRel '2013 May 1', 5
--EXEC spS_GetScenarioOutcomesRelMonths '2013 May 1', 5, 3
--EXEC spS_GetScenarioOutcomesAbsMonths '2013 May 1', 5, 3
--EXEC spS_GetScenOutcomesRelLbck '2013 May 1', 5, 3
--EXEC spS_GetScenOutcomesAbsLbck '2013 May 1', 5, 3
--EXEC spS_Worst3Scenarios '2013 APR 12'
--EXEC spS_Worst3ScenariosRel '2013 APR 12'
--EXEC spS_GetScenariosByFundByDate '2013 May 1', 41
	
--NEW
--EXEC spS_GetScenarioOutcomesAbs '2013 May 9', 5
--EXEC spS_GetScenarioOutcomesRel '2013 May 9', 5
--EXEC spS_GetScenarioOutcomesRelMonths '2013 May 9', 5, 3
--EXEC spS_GetScenarioOutcomesAbsMonths '2013 May 9', 5, 3
--EXEC spS_GetScenOutcomesRelLbck '2013 May 9', 5, 3
--EXEC spS_GetScenOutcomesAbsLbck '2013 May 9', 5, 3
--EXEC spS_Worst3Scenarios '2013 May 9'
--EXEC spS_Worst3ScenariosRel '2013 May 9' 
--EXEC spS_GetScenariosByFundByDate '2013 May 9', 41

--EXEC spS_UCITSScenarioQData '2013 May 9'
--EXEC spS_GetScenariosByIdByDate '2013 May 9', 27
--EXEC spS_GetScenCountComp '2013 May 10'
EXEC spS_GetDashboardRiskRep '2014 Jan 9', 3, 0, 0, 1 

--SELECT FundId, ReportId FROM tbl_ScenReports
--WHERE ReportDate = '2013 May 9' AND FUNDid in (14, 23, 60)
--GROUP by FundId
