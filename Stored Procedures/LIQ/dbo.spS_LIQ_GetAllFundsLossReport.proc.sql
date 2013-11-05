USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_LIQ_GetAllFundsLossReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_LIQ_GetAllFundsLossReport]
GO

CREATE PROCEDURE [dbo].[spS_LIQ_GetAllFundsLossReport] 
	@RefDate datetime
AS

SET NOCOUNT ON;

----------------------------------------------------------------------------------

SELECT 	Factors.RefDate
	, (SELECT MAX(RefDate) FROM tbl_LIQ_FundsLiqRiskFactors WHERE RefDate < Factors.RefDate) AS PrevDate
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
	, Vol.VIX
	, Vol.MOVE
	, (Vol.VixHc + Vol.MoveHc)/2 AS MktVolHc


INTO	#FactorsW

FROM 	tbl_LIQ_FundsLiqRiskFactors AS Factors LEFT JOIN
	tbl_FundsNaVsAndPLs AS NAVs ON 
		(Factors.RefDate = NaVs.NaVPLDate
		AND Factors.FundId = NaVs.FundId) LEFT JOIN
	tbl_LIQ_MktVolHc AS Vol ON 
		(Factors.RefDate = Vol.RefDate)

WHERE	Factors.RefDate <= @RefDate
	AND Factors.RefDate >= (SELECT MAX(RefDate) FROM tbl_LIQ_FundsLiqRiskFactors WHERE RefDate < @RefDate)

----------------------------------------------------------------------------------

SELECT	RefDate
	, PrevDate
	, Fundid
	, FundCode
	, AgeOfBond
	, AgeOfBondW
	, BidAsk
	, BidAskW
	, TimeToMaturity
	, TimeToMaturityW
	, IssuedAmount
	, IssuedAmountW
	, BadPrice
	, BadPriceW
	, YieldVol
	, YieldVolW
	, PositionSize
	, PositionSizeW
	, AgeOfBond * AgeOfBondW + 
		BidAsk * BidAskW + 
		TimeToMaturity * TimeToMaturityW + 
		IssuedAmount * IssuedAmountW + 
		BadPrice * BadPriceW + 
		YieldVol * YieldVolW +
		PositionSize * PositionSizeW
			AS TotLiqRisk
	, Vix AS EquityVol
	, Move AS FIncomeVol
	, MktVolHc

INTO	#CurrentMeasures	

FROM	#FactorsW

----------------------------------------------------------------------------------

SELECT	CM.RefDate
	, CM.FundId
	, CM.FundCode

	, CM.AgeOfBond
	, PM.AgeOfBond AS PrevAgeOfBond
	, CM.AgeOfBond - PM.AgeOfBond AS AgeOfBondCh
	, CM.AgeOfBondW

	, CM.BidAsk
	, PM.BidAsk AS PrevBidAsk
	, CM.BidAsk - PM.BidAsk AS BidAskCh
	, CM.BidAskW

	, CM.TimeToMaturity
	, PM.TimeToMaturity AS PrevTimeToMaturity
	, CM.TimeToMaturity - PM.TimeToMaturity AS TimeToMaturityCh
	, CM.TimeToMaturityW

	, CM.IssuedAmount
	, PM.IssuedAmount AS PrevIssuedAmount
	, CM.IssuedAmount - PM.IssuedAmount AS IssuedAmountCh
	, CM.IssuedAmountW

	, CM.BadPrice
	, PM.BadPrice AS PrevBadPrice
	, CM.BadPrice - PM.BadPrice AS BadPriceCh
	, CM.BadPriceW

	, CM.YieldVol
	, PM.YieldVol AS PrevYieldVol
	, CM.YieldVol - PM.YieldVol AS YieldVolCh
	, CM.YieldVolW

	, CM.PositionSize
	, PM.PositionSize AS PrevPositionSize
	, CM.PositionSize - PM.PositionSize AS PositionSizeCh
	, CM.PositionSizeW

	, CM.TotLiqRisk
	, PM.TotLiqRisk AS PrevTotLiqRisk
	, CM.TotLiqRisk - PM.TotLiqRisk AS TotLiqRiskCh

	, CM.EquityVol
	, PM.EquityVol AS PrevEquityVol
	, CM.EquityVol - PM.EquityVol AS EquityVolCh

	, CM.FIncomeVol
	, PM.FIncomeVol AS PrevFIncomeVol
	, CM.FIncomeVol - PM.FIncomeVol AS FIncomeVolCh

	, CM.MktVolHc
	, PM.MktVolHc AS PrevMktVolHc
	, CM.MktVolHc - PM.MktVolHc AS MktVolHcCh


FROM	#CurrentMeasures AS CM LEFT JOIN
	#CurrentMeasures AS PM ON 
		(PM.RefDate = CM.PrevDate
		AND CM.FundId  = PM.FundId)


WHERE 	CM.RefDate = @RefDate

----------------------------------------------------------------------------------

DROP TABLE #FactorsW
DROP TABLE #CurrentMeasures

GO

----------------------------------------------------------------------------------

GRANT EXECUTE ON dbo.spS_LIQ_GetAllFundsLossReport TO [OMAM\StephaneD], [OMAM\MargaretA]