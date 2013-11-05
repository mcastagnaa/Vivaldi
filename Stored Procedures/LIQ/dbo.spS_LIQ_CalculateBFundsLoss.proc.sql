USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_LIQ_CalculateBFundsLoss]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_LIQ_CalculateBFundsLoss]
GO

CREATE PROCEDURE [dbo].[spS_LIQ_CalculateBFundsLoss] 
	@RefDate datetime
	, @FundId int

AS

DECLARE	@GBPrate float

SET NOCOUNT ON;


CREATE TABLE #Positions (
FundCode 		nvarchar(25)
,FundId 		integer
,SecurityGroup 		nvarchar(30)
,SecurityType 		nvarchar(30)
,IsDerivative 		bit
,BMISCode 		nvarchar(30)
,BBGTicker		nvarchar(40)
,Underlying 		nvarchar(40)
,CostMarketVal 		float
,Weight 		float
,CostExposureVal 	float
,ExpWeight 		float
,ExpWeightBetaAdj 	float
,AssetCCY 		nvarchar(3)
,PositionSize 		float
,StartPrice 		float
,MarketPrice 		float
,AssetChange 		float
,FxChange 		float
,AssetPL 		float
,FxPL 			float
,TotalPL 		float
,AssetPLOnNaV 		float
,FXPLOnNaV 		float
,PLOnNaV 		float
,AssetPLonTotalPL 	float
,FxPLonTotalPL 		float
,PLOnTotalPL 		float
,CountryISO 		nvarchar(10)
,CountryName		nvarchar(100)
,CountryRegion 		nvarchar(100)
,IndustrySector 	nvarchar(40)
,IndustryGroup 		nvarchar(40)
,SPCleanRating 		nvarchar(30)
,SPRatingRank 		integer
,YearsToMat 		float
,EquityMktStatus 	nvarchar(10)
,LongShort 		nvarchar(20)
,DaysToLiquidate 	float
,Beta 			float
,Size 			nvarchar(10)
,Value 			nvarchar(10)
,IsManualPrice 		bit
,ROE 			float
,EPSGrowth 		float
,SalesGrowth 		float
,BtP 			float
,DivYield 		float
,EarnYield 		float
,StP 			float
,EbitdaTP 		float
,MktCapLocal 		float
,MktCapUSD 		float
,KRD3m 			float
,KRD6m 			float
,KRD1y 			float
,KRD2y 			float
,KRD3y 			float
,KRD4y 			float
,KRD5y 			float
,KRD6y 			float
,KRD7y 			float
,KRD8y 			float
,KRD9y 			float
,KRD10y 		float
,KRD15y 		float
,KRD20y 		float
,KRD25y 		float
,KRD30y 		float
,EffDur 		float
,InflDur 		float
,RealDur 		float
,SpreadDur 		float
,OAS 			float
,CnvYield 		float
,CoupType 		nvarchar(30)
,IsBullet 		bit
,SecType 		nvarchar(30)
,CollType 		nvarchar(30)
,MktSector 		nvarchar(20)
,ShortMom 		float
,CDSPayFreq		nvarchar(1)
,CDSMaturityDate	datetime
,CDSRecRate		float
,CDSNotionalSpread	float
,CDSMktSpread		float
,CDSMktPremium		float
,CDSAccrued 		float
,CDSModel		nvarchar(1)
,CDSPrevPremium 	float
,UpDown 		nvarchar(4)
,OptDelta 		float
,OptGamma 		float
,OptVega 		float
,OptDaysToExp 		integer
,MarginLocal		float
,MarginBase		float
,MarginBaseOnNaV	float
,BBGId			nvarchar(30)
,AllExpWeights		float
,FundClass		nvarchar(30)
,FundIsAlive		bit
,FundIsSkip		bit
,FundBaseCCY		nvarchar(3)
,IsCCYExp		bit
,IsEM			bit
,IsHY			bit
,PositionDate		datetime
)
----------------------------------------------------------------------------------
INSERT INTO #Positions
EXEC spS_GetFundsDetailsByDate_V2 @RefDate, @FundId, null
----------------------------------------------------------------------------------

SET @GBPRate = (SELECT LastQuote FROM tbl_FXQuotes WHERE ISO = 'GBP' AND LastQuoteDate = @RefDate)

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

SELECT 	@RefDate AS RefDate
	, Positions.FundId
	, Positions.SecurityGroup
	, Positions.IsDerivative
	, Positions.SecurityType
	, Positions.BMISCode 
	, Positions.BBGTicker
	, Positions.ExpWeight
	, ISNULL(LiqFact.AgeOfBond, 0) AS AgeOfBond
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 1) AS AgeOfBondW
	, ISNULL(LiqFact.BidAsk, 0) AS BidAsk
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 2) AS BidAskW
	, ISNULL(LiqFact.TimeToMaturity, 0) AS TimeToMaturity
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 3) AS TimeToMaturityW
	, ISNULL(LiqFact.IssuedAmount, 0) AS IssuedAmount
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 4) AS IssuedAmountW
	, ISNULL(LiqFact.BadPrice, 0) AS BadPrice
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 5) AS BadPriceW
	, ISNULL(LiqFact.YieldVol, 0) AS YieldVol
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 6) AS YieldVolW
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
	, (SELECT FactorWeight FROM tbl_LIQ_FactorsWeights WHERE Id = 7) AS PositionSizeW
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
	AND Positions.IsDerivative = 0
--	AND Funds.Id = 5

----------------------------------------------------------------------------------

SELECT 	Factors.RefDate
	, Factors.FundId
	, LiqRisk = SUM(
		ExpWeight * (
			AgeOfBond * AgeOfBondW + 
			BidAsk * BidAskW +
			TimeToMaturity * TImeToMaturityW + 
			IssuedAmount * IssuedAmountW +
			BadPrice * BadPriceW +
			YieldVol * YieldVolW +
			PositionSize * PositionSizeW
			)
		)
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
GRANT EXECUTE ON dbo.spS_LIQ_CalculateBFundsLoss TO [OMAM\StephaneD]