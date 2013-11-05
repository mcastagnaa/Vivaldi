USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetNaVPLExpData_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetNaVPLExpData_V2
GO

CREATE PROCEDURE dbo.spS_GetNaVPLExpData_V2
	@RefDate datetime
	, @FundId int
AS

SET NOCOUNT ON;

----------------------------------------------------------------------------------
SELECT * INTO #CubeData FROM dbo.fn_GetCubeDataTable(@RefDate, @FundId)
----------------------------------------------------------------------------------

SELECT	CubeData.FundCode
	, CubeData.FundId
	, CubeData.PositionDate
	, ISNULL(ManualNaVs.NaV, SUM(CubeData.BaseCCYCostValue)) AS CostNaV
	, SUM(CubeData.BaseCCYMarketValue) AS MktNaVPricesOnly
	, SUM(CubeData.BaseCCYCostValue * (1 + CubeData.AssetReturn) * 
			(1 + CubeData.FxReturn)) AS MktNaV
	, SUM(BaseCCYCostValue * CubeData.AssetReturn) AS AssetPL
	, SUM(BaseCCYCostValue * CubeData.FxReturn) AS FxPL
	, SUM(BaseCCYCostValue * (CubeData.AssetReturn + CubeData.FxReturn)) AS TotalPL

INTO	#NaVs

FROM	#CubeData AS CubeData LEFT JOIN
	tbl_NotionalNaVs AS ManualNaVs ON (CubeData.FundId = ManualNaVs.FundId)

WHERE	FundIsAlive = 1

GROUP BY	CubeData.FundCode
		, CubeData.FundId
		, CubeData.PositionDate
		, ManualNaVs.NaV

----------------------------------------------------------------------------------

SELECT	CubeData.FundId
	, CubeData.PositionDate
	, COUNT(DISTINCT CubeData.BMISCode) AS PositionsCount

INTO	#TickerCounts

FROM	#CubeData AS CubeData

WHERE	CubeData.FundIsAlive = 1
	AND LongShort <> 'CashBaseCCY'
	AND CountMeExp = 1

GROUP BY	CubeData.FundId
		, CubeData.PositionDate

----------------------------------------------------------------------------------

SELECT	CubeData.FundId
	, CubeData.PositionDate
	, SUM(CubeData.BaseCCYExposure) AS NetExposure

INTO	#ExposuresTmp

FROM	#CubeData AS CubeData

WHERE	CubeData.FundIsAlive = 1
	AND LongShort <> 'CashBaseCCY'
	AND CountMeExp = 1

GROUP BY	CubeData.FundId
		, CubeData.PositionDate
		, CubeData.UnderlyingCTD

----------------------------------------------------------------------------------

SELECT	FundId
	, PositionDate
	, SUM(NetExposure) AS NetExposure
	, SUM(ABS(NetExposure)) AS GrossExposure

INTO	#Exposures

FROM	#ExposuresTmp AS ExpTmp

GROUP BY	FundId
		, PositionDate

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

SELECT	CubeData.FundId
	, CubeData.PositionDate
	, CubeData.AssetCCY
	, SUM(CubeData.BaseCCYExposure * IsCCYExp) AS CCYExp

INTO	#CCYExposuresTMP

FROM	#CubeData AS CubeData

WHERE	CubeData.AssetCCY <> CubeData.FundBaseCCYCode
-- 	AND CubeData.SecurityType NOT IN ('FutOft')
	AND CubeData.IsDerivative = 0
--	AND CubeData.IsFuture = 0

GROUP BY	FundId
		, PositionDate
		, AssetCCY
----------------------------------------------------------------------------------
SELECT	CCYExpT.FundId
	, CCYExpT.PositionDate
	, SUM(ABS(CCYExpT.CCYExp)) AS CCYExp

INTO	#CCYExposures

FROM	#CCYExposuresTMP AS CCYExpT

GROUP BY	CCYExpT.FundId
		, CCYExpT.PositionDate

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

SELECT	NaVs.*
	, TickerCounts.PositionsCount
	, Exposures.NetExposure/NaVs.CostNaV AS NetExposure
	, Exposures.GrossExposure/NaVs.CostNaV AS GrossExposure
	, CCYExposures.CCYExp/NaVs.CostNaV AS CCYExp

FROM	#NaVs AS NaVs 
	LEFT JOIN #TickerCounts AS TickerCounts ON
		(NaVs.FundId = TickerCounts.FundId
		AND NaVs.PositionDate = TickerCounts.PositionDate)
	LEFT JOIN #Exposures AS Exposures ON
		(NaVs.FundId = Exposures.FundId
		AND NaVs.PositionDate = Exposures.PositionDate)
	LEFT JOIN #CCYExposures AS CCYExposures ON
		(NaVs.FundId = CCYExposures.FundId
		AND NaVs.PositionDate = CCYExposures.PositionDate)

----------------------------------------------------------------------------------

DROP TABLE #CubeData
DROP TABLE #TickerCounts
DROP TABLE #CCYExposuresTMP
DROP TABLE #CCYExposures
DROP TABLE #ExposuresTmp
DROP TABLE #Exposures
DROP TABLE #NaVs

GO

GRANT EXECUTE ON dbo.spS_GetNaVPLExpData_V2 TO [OMAM\StephaneD], [OMAM\MargaretA] 
