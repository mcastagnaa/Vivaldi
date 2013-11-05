USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetFundsPerformances]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetFundsPerformances]
GO

CREATE PROCEDURE [dbo].[spS_GetFundsPerformances] 
	@RefDate datetime
AS

SET NOCOUNT ON;


SELECT 	MIN(BMKs.PriceDate) AS FirstBenchDate
	, BMKs.ID AS BenchId
INTO 	#FirstDates
FROM 	tbl_BenchmData BMKs
GROUP BY	BMKs.Id



SELECT	Funds.FundId
	, Funds.FundCode
	, Funds.FundClass
	, Funds.BaseCCY
	, SUM(PLs.TotalPl/PLs.CostNaV) AS AbsPl
	, Funds.BenchLong AS Benchmark
	, Funds.BenchmarkId AS BenchId
	, SUM(Benchs.Perf) AS BenchPl
	, SUM(PLs.TotalPl/PLs.CostNaV) - SUM(Benchs.Perf) AS RelPl
	, dateadd(day, -(day(@refdate)-1),@refdate) AS FirstPeriodDate
	

INTO	#MtD

FROM	vw_FundsTypology AS Funds RIGHT JOIN
	tbl_FundsNavsAndPLs AS PLs ON
		(Funds.FundId = PLs.FundId) LEFT JOIN
	tbl_BenchmData AS Benchs ON
		(Funds.BenchmarkId = Benchs.Id
		AND PLs.NavPlDate = Benchs.PriceDate)

WHERE 	PLs.NavPlDate <= @RefDate
	AND PLs.NavPlDate >= dateadd(day, -(day(@refdate)-1),@refdate)
	AND Funds.IsAlive = '1'
	AND FUnds.IsSkip = '0'

GROUP BY	Funds.FundId
		, Funds.FundCode
		, Funds.FundClass
		, Funds.BaseCCY
		, Funds.Benchlong
		, Funds.BenchmarkId

------------------------------------------------------------------------------------------


SELECT	Funds.FundId
	, Funds.FundCode
	, Funds.FundClass
	, SUM(PLs.TotalPl/PLs.CostNaV) AS AbsPl
	, Funds.Benchmark
	, SUM(Benchs.Perf) AS BenchPl
	, SUM(PLs.TotalPl/PLs.CostNaV) - SUM(Benchs.Perf) AS RelPl
	, dbo.fn_GetPrevSunday(@RefDate) AS FirstPeriodDate


INTO	#WtD

FROM	vw_FundsTypology AS Funds RIGHT JOIN
	tbl_FundsNavsAndPLs AS PLs ON
		(Funds.FundId = PLs.FundId) LEFT JOIN
	tbl_BenchmData AS Benchs ON
		(Funds.BenchmarkId = Benchs.Id
		AND PLs.NavPlDate = Benchs.PriceDate)

WHERE 	PLs.NavPlDate <= @RefDate
	AND PLs.NavPlDate >= dbo.fn_GetPrevSunday(@RefDate)
	AND Funds.IsAlive = '1'
	AND FUnds.IsSkip = '0'

GROUP BY	Funds.FundId
		, Funds.FundCode
		, Funds.FundClass
		, Funds.Benchmark


------------------------------------------------------------------------------------------


SELECT	Funds.FundId
	, Funds.FundCode
	, Funds.FundClass
	, SUM(PLs.TotalPl/PLs.CostNaV) AS AbsPl
	, Funds.Benchmark
	, SUM(Benchs.Perf) AS BenchPl
	, SUM(PLs.TotalPl/PLs.CostNaV) - SUM(Benchs.Perf) AS RelPl
	, dateAdd(month, -1, @RefDate) AS FirstPeriodDate

INTO	#OneMonth

FROM	vw_FundsTypology AS Funds RIGHT JOIN
	tbl_FundsNavsAndPLs AS PLs ON
		(Funds.FundId = PLs.FundId) LEFT JOIN
	tbl_BenchmData AS Benchs ON
		(Funds.BenchmarkId = Benchs.Id
		AND PLs.NavPlDate = Benchs.PriceDate)

WHERE 	PLs.NavPlDate <= @RefDate
	AND PLs.NavPlDate > dateAdd(month, -1, @RefDate)
	AND Funds.IsAlive = '1'
	AND FUnds.IsSkip = '0'

GROUP BY	Funds.FundId
		, Funds.FundCode
		, Funds.FundClass
		, Funds.Benchmark


------------------------------------------------------------------------------------------


SELECT	Funds.FundId
	, Funds.FundCode
	, Funds.FundClass
	, SUM(PLs.TotalPl/PLs.CostNaV) AS AbsPl
	, Funds.Benchmark
	, SUM(Benchs.Perf) AS BenchPl
	, SUM(PLs.TotalPl/PLs.CostNaV) - SUM(Benchs.Perf) AS RelPl
	, dateAdd(day, -7, @RefDate) AS FirstPeriodDate	

INTO	#FiveDays

FROM	vw_FundsTypology AS Funds RIGHT JOIN
	tbl_FundsNavsAndPLs AS PLs ON
		(Funds.FundId = PLs.FundId) LEFT JOIN
	tbl_BenchmData AS Benchs ON
		(Funds.BenchmarkId = Benchs.Id
		AND PLs.NavPlDate = Benchs.PriceDate)

WHERE 	PLs.NavPlDate <= @RefDate
	AND PLs.NavPlDate > dateAdd(day, -7, @RefDate)
	AND Funds.IsAlive = '1'
	AND FUnds.IsSkip = '0'

GROUP BY	Funds.FundId
		, Funds.FundCode
		, Funds.FundClass
		, Funds.Benchmark
------------------------------------------------------------------------------------------

SELECT	MtD.FundId
	, MtD.FundCode
	, MtD.FundClass
	, MtD.BaseCCY
	, MtD.Benchmark AS BenchMark
	, WtD.AbsPl AS WtDAbsPl
	, (CASE WHEN FirstBD.FirstBenchDate < WtD.FirstPeriodDate THEN WtD.BenchPl ELSE NULL END) AS WtDBenchPl
	, (CASE WHEN FirstBD.FirstBenchDate < WtD.FirstPeriodDate THEN WtD.RelPl ELSE NULL END) AS WtDRelPl
	, MtD.AbsPl AS MtDAbsPl
	, (CASE WHEN FirstBD.FirstBenchDate < MtD.FirstPeriodDate THEN MtD.BenchPl ELSE NULL END) AS MtDBenchPl
	, (CASE WHEN FirstBD.FirstBenchDate < MtD.FirstPeriodDate THEN MtD.RelPl ELSE NULL END) AS MtDRelPl
	, FDs.AbsPl AS FdsAbsPl
	, (CASE WHEN FirstBD.FirstBenchDate < FDs.FirstPeriodDate THEN FDs.BenchPl ELSE NULL END) AS FDsBenchPl
	, (CASE WHEN FirstBD.FirstBenchDate < FDs.FirstPeriodDate THEN FDs.RelPl ELSE NULL END) AS FDsRelPl
	, OMn.AbsPl AS OmnAbsPl
	, (CASE WHEN FirstBD.FirstBenchDate < OMn.FirstPeriodDate THEN OMn.BenchPl ELSE NULL END) AS OMnBenchPl
	, (CASE WHEN FirstBD.FirstBenchDate < OMn.FirstPeriodDate THEN OMn.RelPl ELSE NULL END) AS OMnRelPl

FROM	#MtD AS MtD LEFT JOIN
	#WtD AS WtD ON 
		(MtD.FundId = WtD.FundID) LEFT JOIN
	#FiveDays As FDs ON
		(MtD.FundId = FDs.FundID) LEFT JOIN
	#OneMonth AS OMn ON
		(MtD.FundId = OMn.FundID) LEFT JOIN
	#FirstDates AS FirstBD ON
		(MtD.BenchId = FirstBD.BenchId)

ORDER BY	MtD.FundClass,
		MtD.FundCode

------------------------------------------------------------------------------------------
DROP TABLE #WtD
DROP TABLE #MtD
DROP TABLE #FiveDays
DROP TABLE #OneMonth
DROP TABLE #FirstDates
------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spS_GetFundsPerformances TO [OMAM\StephaneD], [OMAM\MargaretA] 

