USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_RelativePerformance]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_RelativePerformance]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_RelativePerformance]
AS


SELECT	Funds.Id AS FundId
	, PLs.NaVPLDate AS PLDate
	, PLs.TotalPL/CostNaV AS AbsPL
	, Funds.BenchmarkId AS BenchmarkId
--	, EnumBenchms.IsAvailable AS HasBenchmsData
	, EnumBenchms.ShortName AS BenchmarkName
	, Benchms.Perf As BenchPl
	, PLs.TotalPL/CostNaV - Benchms.Perf AS RelPL
FROM 	tbl_Funds AS Funds LEFT JOIN 
	tbl_Benchmarks AS EnumBenchms ON (
		Funds.BenchmarkId = EnumBenchms.id
		) LEFT JOIN
	tbl_BenchmData AS Benchms ON (
		Funds.BenchmarkId = Benchms.Id
		AND EnumBenchms.Id = Benchms.Id
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS PLs ON (
		Benchms.PriceDate = PLs.NaVPLDate
		AND Funds.Id = PLs.FundId
		)
	
WHERE		EnumBenchms.IsAvailable = 1
