USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetFundsDetailsAndRiskByDate_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetFundsDetailsAndRiskByDate_V2
GO

CREATE PROCEDURE dbo.spS_GetFundsDetailsAndRiskByDate_V2
	@RefDate datetime
	, @FundId int
	, @PercDayVol float

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
EXEC spS_GetFundsDetailsByDate_V2 @RefDate, @FundId, @PercDayVol
----------------------------------------------------------------------------------

SELECT	VaRReports.FundId
	, VaRReports.ReportDate	
	, AVG(VaRReports.MargVaR) AS AvgMVaR
	, COUNT(VaRreports.MargVaR) AS CountOfRisky
	, ZScores.ZScore AS Sigma

INTO	#MVarStats

FROM 	tbl_VaRReports AS VaRReports LEFT JOIN
	tbl_EnumVaRReports AS EnumVaRReports ON (
		VaRReports.ReportId = EnumVaRReports.Id
		) LEFT JOIN
	tbl_Funds AS Funds ON (
		VaRReports.FundId = Funds.Id
		) LEFT JOIN
	tbl_ZScores AS ZScores ON (
		Funds.ConfidenceInt = ZScores.Probability
	)
	
WHERE	((EnumVaRReports.IsRelative = 0) OR
	(EnumVaRReports.IsRelative IS NULL))
	AND VaRReports.ReportDate =  @RefDate
	AND ABS(VaRReports.VaR) > 0 
	AND VaRreports.MargVaR is not null
	AND VaRReports.SecTicker <> 'Totals'

GROUP BY 	VaRReports.FundId
		, VaRReports.ReportDate
		, ZScores.ZScore

----------------------------------------------------------------------------------

SELECT	Pos.FundCode
	, Pos.FundId
	, MAX(Pos.SecurityGroup) AS SecurityGroup
	, MAX(Pos.BMISCode) AS BMISCode
	, MAX(Pos.BBGTicker) AS BBGTicker
	, MAX(Pos.Underlying) AS Underlying
	, SUM(Pos.CostMarketVal) AS CostMarketVal
	, SUM(Pos.Weight) AS Weight
	, Sum(Pos.CostExposureVal) AS CostExposureVal
	, SUM(Pos.ExpWeight) AS ExpWeight
	, SUM(Pos.ExpWeightBetaAdj) AS ExpWeightBetaAdj
	, MAX(Pos.AssetCCY) AS AssetCCY
	, SUM(Pos.PositionSize) AS PositionSize
	, MAX(Pos.StartPrice) AS StartPrice
	, MAX(Pos.MarketPrice) AS MarketPrice
	, MAX(Pos.AssetChange) AS AssetChange
	, MAX(Pos.FxChange) AS FXChange
	, SUM(Pos.AssetPL) AS AssetPL
	, SUM(Pos.FxPL) AS FXPL
	, SUM(Pos.TotalPL) AS TotalPL
	, SUM(Pos.AssetPLOnNaV) AS AssetPLOnNaV
	, SUM(Pos.FXPLOnNaV) AS FxPLOnNaV
	, SUM(Pos.PLOnNaV) AS PLOnNaV
	, SUM(Pos.AssetPLonTotalPL) AS AssetPLonTotalPL
	, SUM(Pos.FxPLonTotalPL) AS FXPLonTotalPL
	, SUM(Pos.PLOnTotalPL) AS PLOnTotalPL
	, MAX(Pos.CountryISO) AS CountryISO
	, MAX(Pos.CountryName) AS CountryName
	, MAX(Pos.CountryRegion) AS CountryRegion
	, MAX(Pos.IndustrySector) AS IndustrySector
	, MAX(Pos.IndustryGroup) AS IndustryGroup
	, MAX(Pos.SPCleanRating) AS SPCleanRating
	, MAX(Pos.SPRatingRank) AS SPRatingRank
	, MAX(Pos.YearsToMat) AS YearsToMat
	, MAX(Pos.EquityMktStatus) AS EquityMktStatus
	, MAX(Pos.LongShort) AS LongShort
	, MAX(Pos.DaysToLiquidate) AS DaysToLiquidate
	, MAX(Pos.Beta) AS Beta
	, MAX(Pos.Size) AS Size
	, MAX(Pos.Value) AS Value
	, MAX(Pos.ROE) AS ROE
	, MAX(Pos.EPSGrowth) AS EPSGrowth
	, MAX(Pos.SalesGrowth) AS SalesGrowth
	, MAX(Pos.BtP) AS BtP
	, MAX(Pos.DivYield) AS DivYield
	, MAX(Pos.EarnYield) AS EarnYield
	, MAX(Pos.StP) AS StP
	, MAX(Pos.EbitdaTP) AS EbitdaTP
	, MAX(Pos.MktCapLocal) AS MktCapLocal
	, MAX(Pos.MktCapUSD) AS MktCapUSD
	, MAX(Pos.KRD3m) AS KRD3m
	, MAX(Pos.KRD6m) AS KRD6m
	, MAX(Pos.KRD1y) AS KRD1y
	, MAX(Pos.KRD2y) AS KRD2y
	, MAX(Pos.KRD3y) AS KRD3y
	, MAX(Pos.KRD4y) AS KRD4y
	, MAX(Pos.KRD5y) AS KRD5y
	, MAX(Pos.KRD6y) AS KRD6y
	, MAX(Pos.KRD7y) AS KRD7y
	, MAX(Pos.KRD8y) AS KRD8y
	, MAX(Pos.KRD9y) AS KRD9y
	, MAX(Pos.KRD10y) AS KRD10y
	, MAX(Pos.KRD15y) AS KRD15y
	, MAX(Pos.KRD20y) AS KRD20y
	, MAX(Pos.KRD25y) AS KRD25y
	, MAX(Pos.KRD30y) AS KRD30y
	, MAX(Pos.EffDur) AS EffDur
	, MAX(Pos.InflDur) AS InflDur
	, MAX(Pos.RealDur) AS RealDur
	, MAX(Pos.SpreadDur) AS SpreadDur
	, MAX(Pos.OAS) AS OAS
	, MAX(Pos.CnvYield) AS CnvYield
	, MAX(Pos.CoupType) AS CoupType
	, MAX(Pos.SecType) AS SecType
	, MAX(Pos.CollType) AS CollType
	, MAX(Pos.MktSector) AS MktSector
	, MAX(Pos.ShortMom) AS ShortMom
	, MAX(Pos.UpDown) AS UpDown
	, MAX(Pos.OptDelta) AS OptDelta
	, MAX(Pos.OptGamma) AS OptGamma
	, MAX(Pos.OptVega) AS OptVega
	, MAX(Pos.OptDaysToExp) AS OptDaysToExp
	, SUM(Pos.MarginLocal) AS MarginLocal
	, SUM(Pos.MarginBase) AS MarginBase
	, SUM(POs.MarginBaseOnNaV) AS MarginBaseOnNaV
	, Pos.BBGId
	, MAX(Pos.FundBaseCCY) AS FundBaseCCY
-----------------------------------------------------------------------------------------------------
	, MAX(TotalVaR.DollarVaR) AS FundVaR
	, ISNULL(MAX(VaRReports.MargVAR) * 100, 0) AS MVAR
	, ISNULL(MAX(VaRReports.MargVAR) * 100, 0) / MAX(MVaRStats.Sigma) AS MVARAdj

	, ISNULL(MAX(VaRReports.MargVaR)*100,0) 
			/ MAX(TotalVaR.DollarVaR) AS MVaRonVaR

	, ISNULL(MAX(VaRReports.MargVaR)*100,0) 
			/ MAX(NaVs.CostNaV) AS MVaRonNaV

	, ISNULL(MAX(VaRReports.CondVaR)*100,0) 
			/ MAX(NaVs.CostNaV) AS CVaRonNaV

	, ISNULL(MAX(VaRReports.MargVAR)*100/MAX(MVaRStats.Sigma),0)
			/ MAX(NaVs.CostNaV) AS MVaRAdjOnNaV

	, ISNULL(SUM(Pos.TotalPL), 0)
		/ NULLIF(MAX(VaRReports.MargVaR)*100/MAX(MVaRStats.Sigma),0) AS PLOnMVaRAdj

	, SUM(Pos.AllExpWeights) AS NaVWeightForRisk
	, SUM(Pos.AllExpWeights * Pos.IsCCYExp) AS CCYExpForRisk

	, ROUND(ABS(MAX(VaRReports.MargVAR))/MAX(MVaRStats.AvgMVaR),3) AS RiskPlMultiplier
--	, MAX(MVaRStats.CountOfRisky) AS CountOfRisky
--	, MAX(MVaRStats.AvgMVaR)*100 AS AvgMVaR

-----------------------------------------------------------------------------------------------------

INTO	#StartData

FROM	#PositionDets AS Pos LEFT JOIN
	tbl_VaRReports AS VaRReports ON (
		Pos.FundId = VaRReports.FundId AND
		Pos.BBGId = VaRReports.BBGInstrId AND
		@RefDate = VaRReports.ReportDate
		) LEFT JOIN
	tbl_EnumVaRReports AS EnumVaRReports ON (
		VaRReports.ReportId = EnumVaRReports.Id
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		Pos.FundId = NaVs.FundId AND
		@RefDate = NaVs.NaVPLDate
		) LEFT JOIN
	vw_TotalVaRByFundByDate AS TotalVaR ON (
		Pos.FundId = TotalVaR.FundId AND
		@RefDate = TotalVaR.VaRDate
		) LEFT JOIN
	#MVarStats AS MVaRStats ON (
		Pos.FundId = MVaRStats.FundId
	)
	
WHERE	((EnumVaRReports.IsRelative = 0) OR
	(EnumVaRReports.IsRelative IS NULL))
	

GROUP BY	Pos.FundId
		, Pos.FundCode
		, Pos.BBGId

---------------------------------------------------------------------------------

SELECT FundCode
, FundId
, SecurityGroup
, BMISCode
, BBGTicker
, Underlying
, CostMarketVal
, Weight
, CostExposureVal
, ExpWeight
, ExpWeightBetaAdj
, AssetCCY
, PositionSize
, StartPrice
, MarketPrice
, AssetChange
, FXChange
, AssetPL
, FXPL
, TotalPL
, AssetPLOnNaV
, FxPLOnNaV
, PLOnNaV
, AssetPLonTotalPL
, FXPLonTotalPL
, PLOnTotalPL
, CountryISO
, CountryName
, CountryRegion
, IndustrySector
, IndustryGroup
, SPCleanRating
, SPRatingRank
, YearsToMat
, EquityMktStatus
, LongShort
, DaysToLiquidate
, Beta
, Size
, Value
, ROE
, EPSGrowth
, SalesGrowth
, BtP
, DivYield
, EarnYield
, StP
, EbitdaTP
, MktCapLocal
, MktCapUSD
, KRD3m
, KRD6m
, KRD1y
, KRD2y
, KRD3y
, KRD4y
, KRD5y
, KRD6y
, KRD7y
, KRD8y
, KRD9y
, KRD10y
, KRD15y
, KRD20y
, KRD25y
, KRD30y
, EffDur
, InflDur
, RealDur
, SpreadDur
, OAS
, CnvYield
, CoupType
, SecType
, CollType
, MktSector
, ShortMom
, UpDown
, OptDelta
, OptGamma
, OptVega
, OptDaysToExp
, BBGId
, MarginLocal
, MarginBase
, MarginBaseOnNaV
, MVaR
, MVaRAdj
, MVaRonVaR
, MVaRonNaV
, MVaRAdjonNaV
, NaVWeightForRisk
, RiskOnPtflShare = MVaRonNaV/NULLIF(NaVWeightForRisk, 0)
, PLOnMVaRAdj = SIGN(TotalPL)*Abs(PLOnMVaRAdj)
, RiskPlMultiplier
, RiskAdjPl = TotalPL/NULLIF(RiskPlMultiplier, 0)
, RiskAdjPlOnNaV = PLOnNaV/NULLIF(RiskPlMultiplier, 0) 
--, MVaRAdjOnPL * NULLIF(RiskPlMultiplier, 0) AS MVaRAdjOnPlAdj
--, FundVaR
--, AvgMVaR
, @RefDate AS DetsDate
, FundBaseCCY
, CCYExpForRisk
, CVaROnNaV
	
FROM #StartData

ORDER BY	FundId
		, SecurityGroup
		, AssetCCY
		, Underlying

---------------------------------------------------------------------------------

DROP TABLE #PositionDets
DROP TABLE #StartData
DROP TABLE #MVaRStats
GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetFundsDetailsAndRiskByDate_V2 TO [OMAM\StephaneD]