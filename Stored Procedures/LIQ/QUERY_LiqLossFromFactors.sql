USE [VIVALDI]
GO


----------------------------------------------------------------------------------

SELECT	Positions.SecurityType
	, Positions.FundId
	, Positions.BMIScode
--	, Positions.BBGTicker
--	, Positions.AssetCCY
--	, Positions.PositionSize/1000000 AS LocalCCYPos
--	, FXrates.LastQuote AS AssetFXQuote
	, (Positions.PositionSize/1000000) / 
		POWER(FXrates.LastQuote, (CASE FXrates.IsInverse WHEN 1 THEN -1 ELSE 1 END)) /
		@GBPrate AS PositionGBPmn

INTO	#GBPPositionsSize

FROM	#Positions AS Positions JOIN
	vw_FxQuotes AS FXrates ON
		(Positions.AssetCCY = FXRates.ISO
		AND FXRates.FXQuoteDate = @RefDate)

WHERE 	Positions.SecurityGroup = 'FixedIn'


----------------------------------------------------------------------------------

SELECT 	Factors.RefDate
	, Factors.FundId
	, ISNULL(LiqFact.AgeOfBond, 0) AS AgeOfBond
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 1) AS AgeOfBondW
	, ISNULL(LiqFact.BidAsk, 0) AS BidAsk
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 2) AS BidAskW
	, ISNULL(LiqFact.TimeToMaturity, 0) AS TimeToMaturity
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 3) AS TimeToMaturityW
	, ISNULL(LiqFact.IssuedAmount, 0) AS IssuedAmount
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 4) AS IssuedAmountW
	, ISNULL(LiqFact.BadPrice, 0) AS BadPrice
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 5) AS BadPriceW
	, ISNULL(LiqFact.YieldVol, 0) AS YieldVol
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 6) AS YieldVolW
	, PositionSize = (CASE 
		WHEN GBPSize.PositionGBPMn <= 
			(SELECT HigherBound FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 1) THEN
			(SELECT Haircut FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 1)
		WHEN GBPSize.PositionGBPMn > 
			(SELECT HigherBound FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 1)
			AND  GBPSize.PositionGBPMn <= 
			(SELECT HigherBound FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 2) THEN
			(SELECT Haircut FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 2)
		WHEN GBPSize.PositionGBPMn > 
			(SELECT HigherBound FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 2) 
			AND GBPSize.PositionGBPMn <= 
			(SELECT HigherBound FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 3)THEN
			(SELECT Haircut FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 3)
		ELSE
			(SELECT Haircut FROM tbl_LIQ_PositionSizes AS PS WHERE PS.Id = 4)
	END) 
--	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 7) AS PositionSizeW
	, Funds.FundCode

INTO	#FactorsW

FROM 	#Positions AS Positions JOIN 
	tbl_Funds AS Funds ON 
		(Positions.FundId = Funds.Id) LEFT JOIN
	tbl_LIQ_AssetsLiquidity AS LiqFact ON
		(Positions.BMISCode = LiqFact.BMISTicker
		AND Positions.SecurityType = LiqFact.SecType
		AND LiqFact.Date = @RefDate) LEFT JOIN
	#GBPPositionsSize AS GBPSize ON
		(GBPSize.SecurityType = Positions.SecurityType
		AND GBPSize.BMIScode = Positions.BMISCode
		AND Positions.FundId = GBPSize.FundId)

WHERE 	Funds.FundClassId = 2
	AND Funds.Alive = 1
	AND Funds.Skip = 0
	AND Positions.SecurityGroup = 'FixedIn'
--	AND Positions.IsDerivative = 0
--	AND Funds.Id = 5

----------------------------------------------------------------------------------

SELECT 	Factors.RefDate
	, Factors.FundId
	, SUM(AgeOfBond) AS AgeOfBond
	, SUM(BidAsk) AS BidAsk
	, SUM(TimeToMaturity) AS TimeToMaturity
	, SUM(IssuedAmount) AS IssuedAmount
	, SUM(BadPrice) AS BadPrice
	, SUM(YieldVol) AS YieldVol
	, SUM(PositionSize) AS PositionSize
	, Factors.FundCode
	, NaVs.CostNaV

FROM	#FactorsW AS Factors LEFT JOIN
	tbl_FundsNaVsAndPLs AS NAVs ON 
		(NaVs.NAVPLDate = Factors.RefDate
		AND NaVS.FundId = Factors.FundId)

GROUP BY	Factors.RefDate
		, Factors.FundId
		, Factors.FundCode
		, Navs.CostNav

----------------------------------------------------------------------------------

DROP TABLE #Positions
DROP TABLE #GBPPositionsSize
DROP TABLE #FactorsW
GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_LIQ_CalcBFundsFactorsLoss TO [OMAM\StephaneD], [OMAM\MargaretA]