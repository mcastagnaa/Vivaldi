USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetFundsDetailsByDate_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetFundsDetailsByDate_V2
GO

CREATE PROCEDURE dbo.spS_GetFundsDetailsByDate_V2
	@RefDate datetime
	, @FundId int
	, @PercDayVol float
AS

SET NOCOUNT ON;

----------------------------------------------------------------------------------
SELECT * INTO #CubeData FROM fn_GetCubeDataTable(@RefDate, @FundId)
----------------------------------------------------------------------------------

SELECT	CubeData.FundCode
	, CubeData.FundId
	, CubeData.SecurityGroup
	, CubeData.SecurityType
	, CubeData.IsDerivative
	, CubeData.BMISCode
	, CubeData.BBGTicker
	, CubeData.UnderlyingCTD AS Underlying
	, CubeData.BaseCCYCostValue AS CostMarketVal
	, CubeData.BaseCCYCostValue / NaVs.CostNaV AS Weight
	, CubeData.BaseCCYExposure AS CostExposureVal
	, CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp AS ExpWeight
	, CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta AS ExpWeightBetaAdj
	, CubeData.AssetCCY
	, CubeData.PositionSize
	, CubeData.StartPrice
	, CubeData.MarketPrice
	, CubeData.AssetReturn AS AssetChange
	, CubeData.FxReturn AS FxChange
--BaseCCY PL
	, CubeData.AssetReturn * 
		(CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) AS AssetPL
	, CubeData.FXReturn * (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) FxPL
	, (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) AS TotalPL
--PL in Bps of CostNaV
	, CubeData.AssetReturn * (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) / NaVs.CostNaV AS AssetPLOnNaV
	, CubeData.FXReturn * (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) / NaVs.CostNaV AS FXPLOnNaV
	, (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1)/ NaVs.CostNaV
		 AS PLOnNaV
--PL over TotalPL
	, CubeData.AssetReturn * (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END)/NULLIF(NaVs.TotalPL, 0) AS AssetPLonTotalPL
	, CubeData.FXReturn * (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END)/NULLIF(NaVs.TotalPL, 0) AS FxPLonTotalPL
	, (CASE Asset.PLOnCost WHEN 1 THEN CubeData.BaseCCYCostValue
							ELSE CubeData.BaseCCYExposure END) * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) / NULLIF(NaVs.TotalPL, 0)
		 AS PLOnTotalPL

	, CubeData.CountryISO
	, CubeData.CountryName
	, CubeData.CountryRegionName AS CountryRegion
	, CubeData.IndustrySector
	, CubeData.IndustryGroup
	, CubeData.SPCleanRating
	, CubeData.SPRatingRank
	, CubeData.BondYearsToMaturity AS YearsToMat
	, CubeData.EquityMarketStatus AS EquityMktStatus
	, CubeData.LongShort
	, DaysToLiquidate = 
		NULLIF(
			ABS(CubeData.PositionSize) / 
			(CubeData.ADV * ISNULL(@PercDayVol, CubeData.PercDayVolume))
		, CubeData.ADV)
	, CubeData.Beta
	, CubeData.Size
	, CubeData.Value
	, CubeData.IsManualPrice
	, CubeData.ROE
	, CubeData.EPSGrowth
	, CubeData.SalesGrowth
	, CubeData.BtP
	, CubeData.DivYield
	, CubeData.EarnYield
	, CubeData.StP
	, CubeData.EbitdaTP
	, CubeData.MktCapLocal
	, CubeData.MktCapUSD
	, CubeData.KRD3m
	, CubeData.KRD6m
	, CubeData.KRD1y
	, CubeData.KRD2y
	, CubeData.KRD3y
	, CubeData.KRD4y
	, CubeData.KRD5y
	, CubeData.KRD6y
	, CubeData.KRD7y
	, CubeData.KRD8y
	, CubeData.KRD9y
	, CubeData.KRD10y
	, CubeData.KRD15y
	, CubeData.KRD20y
	, CubeData.KRD25y
	, CubeData.KRD30y
	, CubeData.EffDur
	, CubeData.InflDur
	, CubeData.RealDur
	, CubeData.SpreadDur
	, CubeData.OAS
	, CubeData.CnvYield
	, CubeData.CoupType
	, CubeData.Bullet AS IsBullet
	, CubeData.SecType
	, CubeData.CollType
	, CubeData.MktSector
	, CubeData.ShortMom
	, CubeData.CDSPayFreq
	, CubeData.CDSMaturityDate
	, CubeData.CDSRecRate
	, CubeData.CDSNotionalSpread
	, CubeData.CDSMktSpread
	, CubeData.CDSMktPremium
	, CubeData.CDSAccrued
	, CubeData.CDSModel
	, CubeData.CDSPrevPremium
	, UpDown = CASE	WHEN CubeData.ShortMom > 0 THEN 'Up' 
			WHEN CubeData.ShortMom < 0 THEN 'Down' 
			ELSE NULL 
		END
	, OptDelta
	, OptGamma
	, OptVega
	, OptDaysToExp
	, ABS(CubeData.PositionSize) * CubeData.FutInitialMargin AS MarginLocal

/*		, CubeData.AssetCCYQuote
		, CubeData.AssetCCYIsInverse
		, CubeData.BaseCCYQuote
		, CubeData.FundBaseCCYIsInverse
		, CubeData.SecurityType*/

	, CASE WHEN CubeData.FutInitialMargin <> 0 THEN
		dbo.fn_GetBaseCCYPrice(ABS(CubeData.PositionSize) * CubeData.FutInitialMargin
			, CubeData.AssetCCYQuote
			, CubeData.AssetCCYIsInverse
			, CubeData.BaseCCYQuote
			, CubeData.FundBaseCCYIsInverse
			, CubeData.SecurityType
			, 0) 
		ELSE 0 END
		AS MarginBase
	, CASE WHEN CubeData.FutInitialMargin <> 0 THEN
		dbo.fn_GetBaseCCYPrice(ABS(CubeData.PositionSize) * CubeData.FutInitialMargin
			, CubeData.AssetCCYQuote
			, CubeData.AssetCCYIsInverse
			, CubeData.BaseCCYQuote
			, CubeData.FundBaseCCYIsInverse
			, CubeData.SecurityType
			, 0) / NaVs.CostNaV 
		ELSE 0 END
		AS MarginBaseOnNaV
	, BBGId
	, AllExpWeights = CASE  WHEN CubeData.LongShort <> 'CashBaseCCY'
				THEN CubeData.BaseCCYExposure / NaVs.CostNaV
				ELSE 0
				END
	, CubeData.FundClass
	, CubeData.FundIsAlive
	, CubeData.FundIsSkip
	, CubeData.FundBaseCCYCode AS FundBaseCCY
	, CubeData.IsCCYExp
	, Countries.ISLxEM AS IsEM
	, CAST((CASE 	WHEN CubeData.SPRatingRank <= 11 THEN 0
			WHEN (CubeData.SPRatingRank > 11 AND CubeData.SPCleanRating IS NOT NULL) THEN 1
		 	ELSE NULL END) AS Bit) AS IsHY
	, CubeData.PositionDate

								
FROM	#CubeData AS CubeData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(CubeData.FundId = NaVs.FundId
		AND CubeData.PositionDate = NaVs.NaVPLDate) LEFT JOIN
	tbl_CountryCodes AS Countries ON
		(CubeData.CountryISO = Countries.ISOCode) LEFT JOIN
	tbl_BMISAssets AS Asset ON
		(CubeData.SecurityType = Asset.AssetName)

	
ORDER BY	FundId
		, SecurityGroup
		, AssetCCY
		, Underlying


----------------------------------------------------------------------------------
DROP TABLE #CubeData
GO
----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetFundsDetailsByDate_V2 TO 
		[OMAM\StephaneD], [OMAM\ShaunF]
		, [OMAM\OMAM UK OpsTAsupport] 
