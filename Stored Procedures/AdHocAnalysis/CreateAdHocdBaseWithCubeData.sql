USE Vivaldi
GO

DECLARE @PercDayVol float
		, @StartDate datetime
		, @EndDate datetime
		, @FundId integer
		, @DataDate datetime

SET @PercDayVol = 0.1
SET @FundId = 14 -- 115 is ARBEA, 14 is GEAR
SET @EndDate = '2014 Sep 30'
SET @StartDate = '2010 May 1' --DateAdd(yy,-5,@EndDate)

-------------------------------------------------------------------
TRUNCATE TABLE GEARdata --only if you need to start from scratch (comment over if append)

DECLARE Dates_Cursor CURSOR FOR
SELECT	PositionDate
FROM	tbl_Positions
WHERE	FundShortName = (SELECT FundCode FROM tbl_Funds WHERE ID = @FundId)
		AND PositionDate >= @StartDate
		AND PositionDate <= @EndDate
GROUP BY PositionDate
ORDER BY PositionDate

OPEN Dates_Cursor
FETCH NEXT FROM Dates_Cursor
INTO @DataDate

WHILE @@FETCH_STATUS = 0
BEGIN
------------------------------------------------------------------------

SELECT * INTO #CubeData FROM fn_GetCubeDataTable(@DataDate, @FundId)

INSERT INTO GEARdata
SELECT	CubeData.PositionDate
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
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue AS AssetPL
	, CubeData.FXReturn * CubeData.BaseCCYCostValue AS FxPL
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1) AS TotalPL
--PL in Bps of CostNaV
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue / NaVs.CostNaV AS AssetPLOnNaV
	, CubeData.FXReturn * CubeData.BaseCCYCostValue / NaVs.CostNaV AS FXPLOnNaV
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
		* (1 + CubeData.AssetReturn) - 1)/ NaVs.CostNaV
		 AS PLOnNaV
--PL over TotalPL
	, CubeData.AssetReturn * CubeData.BaseCCYCostValue/NULLIF(NaVs.TotalPL, 0) AS AssetPLonTotalPL
	, CubeData.FXReturn * CubeData.BaseCCYCostValue/NULLIF(NaVs.TotalPL, 0) AS FxPLonTotalPL
	, CubeData.BaseCCYCostValue * ((1 + CubeData.FXReturn) 
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
	, (CASE WHEN (CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta) >= 0 THEN 'LongBAdj'
		ELSE 'ShortBAdj' END) AS LongShortBAdj
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
	, CubeData.SecType
	, CubeData.CollType
	, CubeData.MktSector
	, CubeData.ShortMom
	, UpDown = CASE	WHEN CubeData.ShortMom > 0 THEN 'Up' 
			WHEN CubeData.ShortMom < 0 THEN 'Down' 
			ELSE NULL 
		END
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
	, ABS(CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp * Beta) AS ExpWeightBetaAdjAbs
	, ABS(CubeData.BaseCCYExposure / NaVs.CostNaV * CountMeExp) AS ExpWeightAbs
	, DATEPART(yyyy, PositionDate) AS DateYear
	, DATEPART(mm, PositionDate) AS DateMonth
	, null AS QuantCountry
	, null AS QuantRegion

FROM	#CubeData AS CubeData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(CubeData.FundId = NaVs.FundId
		AND CubeData.PositionDate = NaVs.NaVPLDate) LEFT JOIN
	tbl_CountryCodes AS Countries ON
		(CubeData.CountryISO = Countries.ISOCode)

DROP TABLE #CubeData


------------------------------------------------------------------------
--	SELECT @DataDate
	FETCH NEXT FROM Dates_Cursor
	INTO @DataDate
END

CLOSE Dates_Cursor
DEALLOCATE Dates_Cursor
