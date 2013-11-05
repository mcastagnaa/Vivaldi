USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_EquityFundsStatsReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_EquityFundsStatsReport]
GO

CREATE PROCEDURE [dbo].[spS_EquityFundsStatsReport] 
	@RefDate datetime
AS

SET NOCOUNT ON;


SELECT	Funds.FundCode
	, Stats.PortfBeta AS PortfBeta
	, Stats.PortfBetaLong
	, Stats.PortfBetaShort
	, RoE = CASE Funds.FundClassId
			WHEN 4 THEN Stats.RoEEqOnly
			ELSE Stats.RoE
		END
	, EPSGrowth = CASE Funds.FundClassId
			WHEN 4 THEN Stats.EPSGrowthEqOnly
			ELSE Stats.EPSGrowth
		END
	, SalesGrowth = CASE Funds.FundClassId
			WHEN 4 THEN Stats.SalesGrowthEqOnly
			ELSE Stats.SalesGrowth
		END
	, BookToPrice = CASE Funds.FundClassId
			WHEN 4 THEN Stats.BookToPriceEqOnly
			ELSE Stats.BookToPrice
		END
	, Stats.PortfBtPLong
	, Stats.PortfBtPShort
	, DividendYield = CASE Funds.FundClassId
			WHEN 4 THEN Stats.DivYieldEqOnly
			ELSE Stats.DivYield
		END
	, Stats.PortfDYLong
	, Stats.PortfDYShort
	, EarningsYield = CASE Funds.FundClassId
			WHEN 4 THEN Stats.EarnYieldEqOnly
			ELSE Stats.EarnYield
		END
	, SalesToPrice = CASE Funds.FundClassId
			WHEN 4 THEN Stats.SalesToPEqOnly
			ELSE Stats.SalesToP
		END
	, EbitdaToPrice = CASE Funds.FundClassId
			WHEN 4 THEN Stats.EbitdaToPEqOnly
			ELSE Stats.EbitdaToP
		END
	, Stats.MarketCapUSDMn AS AvgMktCapUSDmn
	, Stats.MktCapUSDLong
	, Stats.MktCapUSDShort AS MktCapUSDShort
	, Stats.AvgDaysToLiquidate
	, Stats.PLPositives AS PositivePLOverLast5
	, stats.PlAverage AS AveragePLOverLast5

FROM 	tbl_FundsStatistics AS Stats LEFT JOIN
	tbl_Funds AS Funds ON (
		Stats.FundId = Funds.Id
		)
WHERE	Funds.FundClassId IN (1, 4)
	AND Stats.StatsDate = @RefDate

ORDER BY Funds.FundCode

GO

GRANT EXECUTE ON spS_EquityFundsStatsReport TO [OMAM\StephaneD], [OMAM\MargaretA]

		
		



		