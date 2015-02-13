USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_OffsetCheck') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_OffsetCheck
GO

CREATE PROCEDURE dbo.spS_OffsetCheck
	@RefDate datetime

AS

DECLARE @PercDayVol float
		, @COL AS NVARCHAR(MAX)
		, @QRY AS NVARCHAR(MAX)
		, @Tolerance AS float

SET @PercDayVol = 0.1
SET @Tolerance = 0.005

SET NOCOUNT ON;

------------------------------------------------

SELECT * INTO #CubeData FROM fn_GetCubeDataTable(@RefDate, null)

SELECT CubeData.FundId
	, CubeData.FundCode	
	, CubeData.PositionDate
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


INTO #TMPdata
FROM	#CubeData AS CubeData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(CubeData.FundId = NaVs.FundId
		AND CubeData.PositionDate = NaVs.NaVPLDate) LEFT JOIN
	tbl_CountryCodes AS Countries ON
		(CubeData.CountryISO = Countries.ISOCode)

WHERE	CubeData.IsCCYExp = 0
		AND CubeData.SecurityType NOT IN ('CDSIndex', 'CDS', 'IndexOpt', 'EqOpt', 'BondFutOpt')
		AND FundCode NOT LIKE 'FOUND%'
------------------------------------------------------------------------

SELECT	FundId
		, FundCode
		, AssetCCY
		, SUM(Weight) AS SumWeight
		, (CASE 
			WHEN ABS(SUM(Weight)) < @tolerance THEN 0
			ELSE 1
			END) AS TEST
		
INTO	#SumWeight
FROM	#TMPdata
GROUP BY	FundId, FundCode, AssetCCY

------------------------------------------------------------------------

SET @COL =	STUFF((SELECT distinct ',' + QUOTENAME(dS.SecurityType)
			FROM #TMPdata AS dS
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')


SET @QRY =	'SELECT FundId, FundCode, AssetCCY, ' + @COL + ', SumWeight, TEST ' +
			'FROM (SELECT T.FundId, T.FundCode, T.SecurityType, T.AssetCCY, T.Weight, W.SumWeight, 
					W.TEST FROM #TMPdata AS T LEFT JOIN #SumWeight AS W ON 
					(T.FundId = W.FundId AND T.AssetCCY = W.AssetCCY)
				) X
			PIVOT
				(SUM(Weight) FOR SecurityType in (' + @COL + ')
				) P ORDER BY FundId, FundCode'

--SELECT @QRY
EXECUTE(@QRY)


------------------------------------------------------------------------

--SELECT * FROM #SumWeight
--SELECT * FROM ##SecTypes

------------------------------------------------------------------------
DROP TABLE #CubeData
DROP TABLE #TMPdata
DROP TABLE #SumWeight
--DROP TABLE ##SecTypes

GRANT EXECUTE ON spS_OffsetCheck TO [OMAM\StephaneD], [OMAM\ShaunF]