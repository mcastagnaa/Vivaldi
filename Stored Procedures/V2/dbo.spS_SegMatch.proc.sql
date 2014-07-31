USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_SegMatch]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_SegMatch]
GO

CREATE PROCEDURE [dbo].[spS_SegMatch] 
	@RefDate datetime
AS

DECLARE @PercDayVol float
DECLARE @SegFund integer
DECLARE @RefFund integer

SET @PercDayVol = 0.1

SET NOCOUNT ON;

-------------------------------------------------------------------
SELECT * INTO #CubeData FROM fn_GetCubeDataTable(@RefDate, null)
-------------------------------------------------------------------

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
	, CubeData.FundId

INTO	#FullData						
FROM	#CubeData AS CubeData LEFT JOIN
		tbl_FundsNaVsAndPLs AS NaVs ON
			(CubeData.FundId = NaVs.FundId
			AND CubeData.PositionDate = NaVs.NaVPLDate) LEFT JOIN
		tbl_CountryCodes AS Countries ON
			(CubeData.CountryISO = Countries.ISOCode)

--------------------------------------------------------------------
DROP TABLE #CubeData
--------------------------------------------------------------------

--BUILD THE DATASET
TRUNCATE TABLE tbl_MandateChecks

DECLARE Seg_Cursor CURSOR FOR
SELECT	Id
FROM	tbl_Funds
WHERE	Skip = 0
		AND Alive = 1
		AND RefFund IS NOT NULL

OPEN Seg_Cursor
FETCH NEXT FROM Seg_Cursor
INTO @SegFund

WHILE @@FETCH_STATUS = 0
BEGIN
	--SET @SegFund = 143
	SET @RefFund = (SELECT RefFund FROM tbl_Funds WHERE Id = @SegFund)
	EXEC spS_SegMatchSubProc @RefDate, @SegFund, @RefFund

	FETCH NEXT FROM Seg_Cursor
	INTO @SegFund
END

CLOSE Seg_Cursor
DEALLOCATE Seg_Cursor

--------------------------------------------------------------

-- USE THE DATASET
SELECT	RefDate
		, SegId 
		, RefId
		, AssetCCY 
		, SUM(SegW - RefW) AS ActiveCCY
INTO	#CCYexp
FROM	tbl_MandateChecks
WHERE	IsCCYExp = 1
GROUP BY	RefDate, SegId, RefId, AssetCCY

SELECT RefDate
		, SegId
		, RefId
		, BBGTicker
		, SUM(SegW) AS SegW
		, SUM(RefW) AS RefW
INTO	#TickerWeights
FROM	tbl_MandateChecks
WHERE	SecurityGroup <> 'CashFX'
GROUP BY RefDate, SegId, RefId, BBGTicker

SELECT	RefDate
		, SegId
		, RefId
		, BBGTicker
		, SegW-RefW As ActiveWeight
		, RANK() OVER (PARTITION BY SegId ORDER BY ABS(SegW-RefW) DESC) AS RankNo
INTO	#RankedSc
FROM	#TickerWeights
--WHERE	SecurityGroup <> 'CashFX'


SELECT	RefDate
		, 'Asset exposure' AS Item
		, null AS Ticker
		, null AS Ranking
		, SegId AS MandateId
		, RefId AS ReferenceId
		, SUM(SegW - RefW) AS AssetActiveNet
		, SUM(ABS(SegW - RefW)) AS AssetActiveGross
INTO	#FinalSet
FROM	#TickerWeights
--WHERE	SecurityGroup <> 'CashFx'
GROUP BY	RefDate, SegId, RefId
--ORDER BY	RefId, SegId

UNION SELECT ALL
		RefDate
		, 'CCY exposure' 
		, null AS Ticker
		, null AS Ranking
		, SegId 
		, RefId 
		, SUM(ActiveCCY)
		, SUM(ABS(ActiveCCY))
FROM	#CCYexp
GROUP BY	RefDate, SegId, RefId

UNION SELECT ALL
		RefDate
		, 'Top 5 active exposures' 
		, BBGTicker
		, RankNo
		, SegId 
		, RefId 
		, Activeweight
		, null
FROM	#RankedSc
WHERE	RankNo <= 5

SELECT	D.* 
		, S.FundCode AS SegCode
		, S.FundName AS SegName
		, R.FundCode AS RefCode
		, R.FundName AS RefName
		, P.Name + ' ' + P.Surname AS HeadOfDesk
FROM	#FinalSet AS D LEFT JOIN
		tbl_Funds AS S ON (S.Id = D.MandateId) LEFT JOIN
		tbl_Funds AS R ON (R.Id = D.ReferenceId) LEFT JOIN
		vw_FundsPeopleRoles AS P ON (P.FundId = D.MandateId)
WHERE	P.RoleId = 1
ORDER BY	P.Name + ' ' + P.Surname
			, D.ReferenceId
			, D.MandateId
			, D.Ranking

DROP TABLE #CCYExp, #RankedSc, #FinalSet, #TickerWeights
DROP TABLE #FullData
GO
--------------------------------------------------------------

GRANT EXECUTE ON spS_SegMatch TO [OMAM\StephaneD]

		