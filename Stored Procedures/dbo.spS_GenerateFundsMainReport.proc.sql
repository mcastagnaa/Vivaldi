USE Vivaldi
GO

IF  EXISTS (
	SELECT * 
	FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GenerateFundsMainReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_GenerateFundsMainReport]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_GenerateFundsMainReport] 
	@RefDate datetime

AS
SET NOCOUNT ON;


SELECT	MAX(NaVs.NAVPLDate) AS FundRefDate
	, NaVs.FundId AS FundID

INTO	#PrevDates

FROM 	tbl_FundsNavsAndPls AS NaVs

WHERE	NaVs.NaVPLDate <= (
		SELECT 	MAX(NaVPLDATE)
		FROM	tbl_FundsNaVsAndPls
		WHERE	NaVPLDate < @RefDate
		)

GROUP BY	NaVs.FundId

-----------------------	


SELECT 	PrvDates.FundRefDate
	, NaVs.FundId AS FundID
	, NaVs.CostNaV AS CostNaV
	, VaRs.DollarVaR AS VaR
	, NAVs.PositionsCount AS PositionsCount

INTO	#PrevNumbers

FROM 	tbl_FundsNavsAndPls AS NaVs LEFT JOIN
	vw_TotalVaRByFundByDate  AS VaRs ON (
		NaVs.FundId = VaRs.FundID AND
		NaVs.NaVPLDate = VaRs.VaRDate
	) LEFT JOIN #PrevDates AS PrvDates ON (
		PrvDates.FundRefDate = NaVs.NaVPLDate
		AND Prvdates.FundId = NaVs.FundId
	)

WHERE PrvDates.FundRefDate is not null

-----------------------	

SELECT	Funds.FundCode AS FundCode,
	Funds.FundName AS FundName,
	CCYs.ISO3 AS BaseCCY,
	FundsClass.ShortName AS FundClass,
	NAVPLReports.CostNaV AS CostNaV,
	PrevNumbers.CostNaV AS PrevNaV,
	NAVPLReports.CostNaV/PrevNumbers.CostNaV -1 AS NaVChange,
	NaVPLReports.TotalPL AS DollarPL,
	NaVPLReports.TotalPL/NAVPLReports.CostNaV AS PercentPL,
	NaVPLReports.TotalPL/NAVPLReports.CostNaV - 
		(CASE BenchmEnum.IsAvailable WHEN 1 THEN Benchm.Perf WHEN 0 THEN NULL END) AS RelPerf,
	VaRReports.VaRModel + ' ' +
		CAST(VaRReports.VaRConfidence AS nvarchar(10)) + ' ' +
		VaRReports.VaRHorizon AS VaRModel,
	VaRReports.DollarVaR AS DollarVaR,
	VaRReports.DollarVaR/NAVPLReports.CostNaV AS PercentVaR,
	PrevNumbers.VaR/PrevNumbers.CostNaV AS PrevPercentVaR,
	VaRReports.DollarVaR/NAVPLReports.CostNaV - 
			PrevNumbers.VaR/PrevNumbers.CostNaV AS VaRChange,
	VaRReports.TailVaR AS DollarTailVaR,
	VaRReports.TailVaR/NAVPLReports.CostNaV AS TailPercentVaR,
	RelVaRReports.ExAnteTE1D AS TrackError,
	(NaVPLReports.TotalPL/NAVPLReports.CostNaV) /
		(VaRReports.DollarVaR/NAVPLReports.CostNaV) AS PLonVaR,
	NaVPLReports.TotalPL/NAVPLReports.CostNaV /
		((VaRReports.DollarVaR/NAVPLReports.CostNaV) /
		ZScores.ZScore) AS ExPostExAnte,
	NaVPLReports.PositionsCount AS PositionsNo,
	PrevNumbers.PositionsCount AS PrevPosNo,
	NaVPLReports.PositionsCount - PrevNumbers.PositionsCount AS PosCountDiff,
	Funds.ID AS FundId,
	NavPLReports.AssetPL AS AssetPL,
	NavPLReports.FxPl AS CcyPL,
	Stats.PLPositives AS PosOn5d,
	Stats.PLAverage AS AvgPLOn5d,
	Benchm.Perf AS BenchmarkPerf,
	BenchmEnum.LongName AS BenchmarkName,
	Styles.ShortName AS Style,
	(VaRReports.DollarVaR/NAVPLReports.CostNaV) / 
			(PrevNumbers.VaR/PrevNumbers.CostNaV) - 1 AS VaRPercChange,
	People.PeopleCode AS HoD
	, dbo.fn_GetBaseCCYPrice(
		NAVPLReports.CostNaV
		, FxQuotes.LastQuote
		, FxQuotes.IsInverse
		, (SELECT LastQuote FROM vw_FxQuotes WHERE ISO = 'GBP' AND FxQuoteDate = @RefDate)
		, 1
		, 'Equities'
		, 1) AS GBPNaV
	
	
FROM 	tbl_FundsNaVsAndPLs AS NAVPLReports LEFT JOIN
	tbl_Funds AS Funds ON (
		NAVPLReports.FundId = Funds.ID
		) LEFT JOIN
	vw_TotalVaRByFundByDate AS VaRReports ON (
		NAVPLReports.FundId = VaRReports.FundId AND
		NAVPLReports.NaVPLDate = VaRReports.VaRDate
		) LEFT JOIN
	vw_relativeVaRReports AS RelVaRReports ON (
		NAVPLReports.FundId = RelVaRReports.FundId AND
		NAVPLReports.NaVPLDate = RelVaRReports.ReportDate
		) LEFT JOIN
	tbl_CcyDetails AS CCYs ON (
		Funds.BaseCCYId = CCYs.ID
		) LEFT JOIN
	tbl_FundClasses AS FundsClass ON (
		Funds.FundClassId = FundsClass.Id
		) LEFT JOIN
	#PrevNumbers AS PrevNumbers ON (
		NaVPLReports.FundID = PrevNumbers.FundID
		) LEFT JOIN
	tbl_ZScores AS ZScores ON (
		VaRReports.VaRConfidence = ZScores.Probability
		) LEFT JOIN
	tbl_FundsStatistics AS Stats ON (
		Funds.ID = Stats.FundID
		AND NAVPLReports.NAVPLDate = Stats.StatsDate
		) LEFT JOIN
	tbl_BenchmData AS Benchm ON (
		Funds.BenchmarkId = Benchm.ID
		AND NAVPLReports.NAVPLDate = Benchm.PriceDate
		) LEFT JOIN
	tbl_Benchmarks AS BenchmEnum ON (
		Benchm.ID = BenchmEnum.ID
		) LEFT JOIN
	tbl_FundStyles AS Styles ON (
		Funds.StyleId = Styles.ID
		) LEFT JOIN
	vw_FundsPeopleRoles AS People ON (
		Funds.Id = People.FundId
		) LEFT JOIN	
	vw_FxQuotes AS FxQuotes ON (
		Funds.BaseCCyId = FxQuotes.Id
		AND NAVPLReports.NAVPLDate = FxQuotes.FxQuoteDate)


WHERE 	NaVPLReports.NaVPLDate = @RefDate AND
	Funds.Alive = 1 AND
	Funds.Skip = 0
	AND People.RoleId = 1

ORDER BY 	FundsClass.ShortName ASC,
		Funds.FundCode ASC

DROP TABLE	#PrevDates
DROP TABLE	#PrevNumbers
GO

GRANT EXECUTE ON spS_GenerateFundsMainReport TO [OMAM\StephaneD], [OMAM\MargaretA], [OMAM\ChrisP], [OMAM\HarvarshS]