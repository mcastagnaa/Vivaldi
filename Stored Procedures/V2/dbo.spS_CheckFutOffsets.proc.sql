USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_CheckFutOffsets') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_CheckFutOffsets
GO

CREATE PROCEDURE dbo.spS_CheckFutOffsets
	@RefDate datetime
AS

SET NOCOUNT ON;


CREATE TABLE #PositionDets (
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
INSERT INTO #PositionDets
EXEC spS_GetFundsDetailsByDate_V2 @RefDate, null, null
----------------------------------------------------------------------------------

SELECT	FundId
		, AssetCCY
		, BMISCode
		, CostMarketVal AS CurrentOffSet
		, CostMarketVal/PositionSize AS FXRate
INTO	#OffsetsDets
FROM	#PositionDets
WHERE	SecurityType IN ('FutOft') AND CostMarketVal <> 0
		

SELECT	A.FundCode
		, A.AssetCCY
		, O.BMISCode
		, N.CostNaV
		, SUM(A.CostMarketVal) AS NetValueBase
		, SUM(A.CostMarketVal)/N.CostNaV AS NetValOnNaV
		, O.FXRate
		, O.CurrentOffset/O.FXRate AS CurrentOffsetLocal
		, -SUM(A.CostMarketVal)/O.FxRate AS CorrectionLocal
		, (O.CurrentOffset - SUM(A.CostMarketVal))/O.FxRate AS NewOffsetLocal
		, 'Amended' AS Status
		, 'FutOft' AS SecurityType

INTO	#Amendments
		
FROM	#PositionDets AS A LEFT JOIN
		tbl_FundsNavsAndPLs AS N ON (
			A.FundId = N.FundId
			AND A.PositionDate = N.NaVPLDate
			) LEFT JOIN
		#OffsetsDets AS O ON (
			A.FundId = O.FundId
			AND A.AssetCCY = O.AssetCCY
			)
WHERE	IsDerivative = 1
		AND SecurityType IN ('FutOft', 'IndexFut', 'BondFut', 'IntRateFut', 
							'AgsCmdtFut', 'EngyCmdtFut', 'BMtlCmdtFut', 
							'PMtlCmdtFut')
GROUP BY	A.FundCode, A.AssetCCY, N.CostNaV, O.FxRate, O.CurrentOffset, O.BMISCode
HAVING		ABS(SUM(A.CostMarketVal)/N.CostNaV) > 0.0005


UPDATE P
SET P.Units = A.NewOffsetLocal
FROM	tbl_positions AS P JOIN
		#Amendments AS A ON (
			A.SecurityType = P.SecurityType
			AND P.FundShortName = A.FundCode
			AND P.PositionId = A.BMISCode
			AND P.PositionDate = @RefDate
			)

SELECT * FROM #Amendments

---------------------------------------------------------------------------------

DROP TABLE #PositionDets
DROP TABLE #OffsetsDets
DROP TABLE #Amendments

GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_CheckFutOffsets TO [OMAM\StephaneD]