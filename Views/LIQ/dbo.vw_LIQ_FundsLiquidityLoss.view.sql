USE VIVALDI
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_LIQ_FundsLiquidityLoss]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_LIQ_FundsLiquidityLoss]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_LIQ_FundsLiquidityLoss]
AS

SELECT 	Factors.RefDate
	, Factors.FundId
	, Factors.FundCode
	, NaVs.CostNaV
	, Factors.AgeOfBond
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 1) AS AgeOfBondW
	, Factors.BidAsk
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 2) AS BidAskW
	, Factors.TimeToMaturity
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 3) AS TimeToMaturityW
	, Factors.IssuedAmount
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 4) AS IssuedAmountW
	, Factors.BadPrice
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 5) AS BadPriceW
	, Factors.YieldVol
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 6) AS YieldVolW
	, Factors.PositionSize  
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 7) AS PositionSizeW
	, AgeOfBond * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 1) + 
		BidAsk * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 2) + 
		TimeToMaturity * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 3) + 
		IssuedAmount * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 4) + 
		BadPrice * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 5) + 
		YieldVol * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 6) +
		PositionSize * (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 7)
			AS TotLiqRisk
	, Vol.VIX
	, Vol.MOVE
	, (Vol.VixHc + Vol.MoveHc)/2 AS MktVolHc


FROM 	tbl_LIQ_FundsLiqRiskFactors AS Factors LEFT JOIN
	tbl_FundsNaVsAndPLs AS NAVs ON 
		(Factors.RefDate = NaVs.NaVPLDate
		AND Factors.FundId = NaVs.FundId) LEFT JOIN
	tbl_LIQ_MktVolHc AS Vol ON 
		(Factors.RefDate = Vol.RefDate)

WHERE	Factors.RefDate >= '31/Oct/2011'

