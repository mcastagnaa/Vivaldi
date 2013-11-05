USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_Benchmarks]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_Benchmarks]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Benchmarks]
AS

SELECT	Benchmarks.ID
	, Benchmarks.ShortName
	, Benchmarks.LongName
	, Benchmarks.IsPortfolio
	, Benchmarks.SourceId
	, BenchmarksSources.ShortName AS SourceShortName
	, BenchmarksSources.LongName AS SourceLongName
	, Benchmarks.UpdateFreqDays AS FrequencyOfUpdate
	, Benchmarks.FileName AS PortfolioFileName
	, Benchmarks.CCY
	, Benchmarks.IsAvailable
FROM	tbl_Benchmarks AS Benchmarks LEFT JOIN
	tbl_BenchmarksSources AS BenchmarksSources ON
		(Benchmarks.SourceID = BenchmarksSources.ID)