USE VIVALDI
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_FuturesPositions]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_FuturesPositions]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FuturesPositions]
AS


SELECT 	Funds.Id AS FundId
	, Funds.FundCode
	, Positions.PositionDate
	, Positions.PositionId
	, Positions.Units AS Lots
	, Positions.Units * Prices.Multiplier AS NotionalLocal
	, dbo.fn_GetBaseCCYPrice(Positions.Units * Prices.Multiplier
		, AssetFxData.LastQuote
		, AssetFxData.IsInverse
		, FundFxData.LastQuote
		, FundFxData.IsInverse
		, Positions.SecurityType
		, 0) AS NotionalBase
	, Positions.Units * Prices.PxLast * FuturesData.PointValue AS PointsValueLocal
	, dbo.fn_GetBaseCCYPrice(Positions.Units * Prices.PxLast * FuturesData.PointValue
		, AssetFxData.LastQuote
		, AssetFxData.IsInverse
		, FundFxData.LastQuote
		, FundFxData.IsInverse
		, Positions.SecurityType
		, 0) AS PointsValueBase
	, FuturesData.Category
	, Prices.SecurityType
	, AssetTypes.SecGroup AS SecurityGroup
	, ABS(Positions.Units) * FuturesData.InitialMargin AS MarginLocal
	, dbo.fn_GetBaseCCYPrice(ABS(Positions.Units) * FuturesData.InitialMargin
		, AssetFxData.LastQuote
		, AssetFxData.IsInverse
		, FundFxData.LastQuote
		, FundFxData.IsInverse
		, Positions.SecurityType
		, 0) AS MarginBase



FROM	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON
		(Funds.FundCode = Positions.FundShortName) LEFT JOIN
	tbl_AssetPrices AS Prices ON
		(Positions.PositionDate = Prices.PriceDate
		AND Positions.SecurityType = Prices.SecurityType
		AND Positions.PositionId = Prices.SecurityId) LEFT JOIN
	vw_FxQuotes AS AssetFXData ON
		(Prices.PriceDate = AssetFXData.FxQuoteDate
		AND Prices.CCYIso = AssetFXData.ISO) LEFT JOIN
	vw_FxQuotes As FundFxData ON
		(Funds.BaseCcyId = FundFxData.Id
		AND FundFxData.FxQuoteDate = AssetFxData.FxQuoteDate) LEFT JOIN
	tbl_FuturesData AS FuturesData ON
		(Positions.PositionId = FuturesData.FuturesId
		AND Positions.PositionDate = FuturesData.PriceDate) LEFT JOIN
	tbl_BMISAssets AS AssetTypes ON
		(Positions.SecurityType = AssetTypes.AssetName)

WHERE	FuturesData.FuturesId IS NOT NULL