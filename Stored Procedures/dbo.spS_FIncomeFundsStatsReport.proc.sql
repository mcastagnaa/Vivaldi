USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_FIncomeFundsStatsReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_FIncomeFundsStatsReport]
GO

CREATE PROCEDURE [dbo].[spS_FIncomeFundsStatsReport] 
	@RefDate datetime
AS

SET NOCOUNT ON;


SELECT	Funds.FundCode
	, Stats.YearsToMaturity
	, Stats.ManualPrices
	, Stats.KRD3m
	, Stats.KRD6m
	, Stats.KRD1y
	, Stats.KRD2y
	, Stats.KRD3y
	, Stats.KRD4y
	, Stats.KRD5y
	, Stats.KRD6y
	, Stats.KRD7y
	, Stats.KRD8y
	, Stats.KRD9y
	, Stats.KRD10y
	, Stats.KRD15y
	, Stats.KRD20y
	, Stats.KRD25y
	, Stats.KRD30y
	, Stats.EffDur
	, Stats.SpreadDur
	, Stats.InflDur
	, Stats.InvGrade
	, Stats.HiYield
	, Stats.NotRated
	, Stats.CleanRating AS AvgRating
	, Stats.BulletBonds
	, Stats.InflationBonds
	, Stats.GovernmentBonds
	, Stats.Corporate AS CorpBonds
	, Stats.Mortgage AS MtgBonds
	, Stats.Preferred AS PrefShares
	, Stats.PLPositives AS PositivePLOverLast5
	, stats.PlAverage AS AveragePLOverLast5

FROM 	tbl_FundsStatistics AS Stats LEFT JOIN
	tbl_Funds AS Funds ON (
		Stats.FundId = Funds.Id
		)
WHERE	Funds.FundClassId IN (2, 3, 4, 5)
	AND Stats.StatsDate = @RefDate

ORDER BY Funds.FundCode

GO

GRANT EXECUTE ON spS_FIncomeFundsStatsReport TO [OMAM\StephaneD], [OMAM\MargaretA]		