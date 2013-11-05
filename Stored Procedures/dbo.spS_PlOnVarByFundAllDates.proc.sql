USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_PlOnVarByFundAllDates]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_PlOnVarByFundAllDates]
GO

CREATE PROCEDURE [dbo].[spS_PlOnVarByFundAllDates] 
	@StartDate datetime,
	@EndDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;

SELECT	AVG(VaRs.PL / (VaRs.DollarVaR/ZScores.ZScore)) AS AvgPLonRisk

INTO #AvgStat

FROM	Vw_TotalVaRByFundByDate AS VaRs LEFT JOIN
	tbl_ZScores AS ZScores ON
		(VaRs.VaRConfidence = ZScores.Probability)

WHERE	VaRs.FundId = @FundId
	AND VaRs.VaRDate >= @StartDate
	AND VaRs.VaRDate <= @EndDate

-------------------------------------------------------------------------------------------------


SELECT	VaRs.VarDate	
	, Vars.FundShortName
	, VaRs.DollarVaR/NaV AS VaRPerc
	, Vars.DollarVaR/ZScores.ZScore AS OneSigmaDollarVaR
	, (Vars.DollarVaR/ZScores.Zscore) / NaV AS OneSigmaVaRPerc
	, VaRs.PL
	, VaRs.PL / (VaRs.DollarVaR/ZScores.ZScore) AS PLonRisk
	, AvgPlonRisk

FROM	Vw_TotalVaRByFundByDate AS VaRs LEFT JOIN
	tbl_ZScores AS ZScores ON
		(VaRs.VaRConfidence = ZScores.Probability)
	, #AvgStat

WHERE	VaRs.FundId = @FundId
	AND VaRs.VaRDate >= @StartDate
	AND VaRs.VaRDate <= @EndDate

DROP TABLE #AvgStat

GO

GRANT EXECUTE ON spS_PlOnVarByFundAllDates TO [OMAM\StephaneD], [OMAM\MargaretA]