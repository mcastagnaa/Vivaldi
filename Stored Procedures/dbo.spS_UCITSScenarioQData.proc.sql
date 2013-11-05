USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_UCITSScenarioQData]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_UCITSScenarioQData]
GO

CREATE PROCEDURE [dbo].[spS_UCITSScenarioQData] 
	@RefDate datetime

AS

SET NOCOUNT ON;


SELECT	Funds.FundCode
		, ScenReps.ReportDate
		, ScenDets.ScenLabel
		, FundNaVs.CostNaV AS NaV
		, ScenReps.PortPerf*ScenReps.MktVal/FundNaVs.CostNaV AS PortfolioPerf
		, ScenReps.BenchPerf AS BenchmarkPerf
		, (CASE ScenReps.BenchPerf 
			WHEN NULL THEN NULL
			ELSE ScenReps.PortPerf*ScenReps.MktVal/FundNaVs.CostNaV -
				ScenReps.BenchPerf
			END) AS RelativePerf


FROM	tbl_ScenReports AS ScenReps LEFT JOIN
		tbl_EnumScen AS ScenDets ON (
			ScenDets.ID = ScenReps.ReportId
			) JOIN
		tbl_FundsNavsAndPls AS FundNaVs ON (
			ScenReps.FundId = FundNaVs.FundId
			AND ScenReps.ReportDate = FundNaVs.NAVPLDate) JOIN
		tbl_Funds AS Funds ON
			(Funds.Id = ScenReps.FundId)

WHERE	Funds.VehicleId = 2
		AND ScenReps.ReportDate > DATEADD(m, -3, @RefDate)
		AND ScenReps.ReportDate <= @refDate
ORDER BY	Funds.FundCode, ScenReps.ReportDate ASC

GO

GRANT EXECUTE ON spS_UCITSScenarioQData TO [OMAM\StephaneD]