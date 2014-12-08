USE VIVALDI
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_WhosHoldingBigChanges]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_WhosHoldingBigChanges]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_WhosHoldingBigChanges] 
	@RefDate datetime,
	@FItolerance float,
	@EQtolerance float

AS

SET NOCOUNT ON;
SELECT 	Positions.FundShortName AS FundCode
		, NaVs.CostNaV
		, Funds.ID AS FundId
		, Funds.BaseCCYId AS FundBaseCCYid
		, Positions.PositionDate AS PositionDate
		, Positions.Units AS Units
		, Assets.SecurityGroup AS SecurityGroup
		, (CASE Assets.SecurityGroup 
				WHEN 'FixedIn'	THEN @FItolerance
				--WHEN 'Equities'	THEN @EQtolerance END) AS Tolerance,
				ELSE @EQtolerance 
			END) AS Tolerance
		, Assets.SecurityType AS SecurityType
		, BMISAssets.PriceDivider AS PriceDivider
		, Assets.Multiplier AS FuturesMultiplier
		, Positions.PositionId AS BMISCode
		, Assets.IDBloomberg AS BBGId
		, Assets.Description AS BBGTicker
		, Assets.ShortName AS BondIssuer
		, Positions.StartPrice AS StartPrice
		, ISNULL(Assets.PxLast, Positions.StartPrice) AS MarketPrice
		, PriceChange = 
			CASE
				WHEN Positions.StartPrice = 0 THEN NULL
				ELSE (ISNULL(Assets.PxLast, Positions.StartPrice)/Positions.StartPrice - 1)
			END
		, Assets.CCYIso AS AssetCCY
		, AssetsCCY.IsInverse AS AssetCCYIsInverse
		, AssetsCCYQuotes.LastQuote AS AssetCCYQuote
		, AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote
		
		, FundCCY.IsInverse AS FundCCYIsInverse
		, FundCCYQuotes.LastQuote AS FundCCYQuote
		, FundCCYQuotes.PreviousQuote AS FundCCYPrevQuote
		, Assets.Accrual AS BondAccrual
		, PenceQuotesDivider =
			CASE WHEN Assets.DivBy100 = 1 THEN 100
				ELSE 1
			END
		, Assets.CountryISO AS CountryISO
		, (CASE Assets.SecurityType 
			WHEN 'Bonds' THEN
				dbo.fn_GetBondTR(Assets.PxLast	
					, Positions.StartPrice
					, Assets.Accrual
					, Assets.Accrual1dBond)
			ELSE	Assets.TotalReturnEq
			END) AS AssetTR

INTO	#RawData

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_CcyDetails AS AssetsCCY ON (
		Assets.CCYIso = AssetsCCY.ISO3
		) LEFT JOIN
	tbl_FxQuotes AS AssetsCCYQuotes ON (
		Positions.PositionDate = AssetsCCYQuotes.LastQuoteDate AND
		AssetsCCY.ISO3 = AssetsCCYQuotes.ISO
		) LEFT JOIN
	tbl_BMISAssets AS BMISAssets ON (
		Positions.SecurityType = BMISAssets.AssetName
		) LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_CcyDetails AS FundCCY ON (
		Funds.BaseCCYId = FundCCY.id
		) LEFT JOIN
	tbl_FxQuotes AS FundCCYQuotes ON (
		Positions.PositionDate = FundCCYQuotes.LastQuoteDate AND
		FundCCY.ISO3 = FundCCYQuotes.ISO) LEFT JOIN
	tbl_FundsNavsAndPLs AS NAVs ON (
		Funds.Id = Navs.FundId
		AND Navs.NaVPLDate = Positions.PositionDate)
	
WHERE 	Assets.PriceDate = @RefDate AND
	BMISAssets.PricePercChangeMethod = 1


--SELECT * FROM #RawData

----------------------------------------------------------------------------------

SELECT	RawData.BMISCode
	, RawData.SecurityType
	, RawData.BBGTicker
	, RawData.StartPrice
	, RawData.MarketPrice
	, round(RawData.PriceChange*100,2) AS PriceChangePerc
	, round(RawData.AssetTR*100,2) AS TotalReturnPerc
	, RawData.FundCode
	, RawData.Units AS PositionSize
	, round((dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual,
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.FundCCYPrevQuote, 
		RawData.FundCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.Units * 
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider)/RawData.CostNaV*100,2) AS PtflWeightPerc
	, round((dbo.fn_GetBaseCCYPrice(RawData.StartPrice + RawData.BondAccrual,
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.FundCCYPrevQuote, 
		RawData.FundCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.Units * 
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider)/RawData.CostNaV *
		RawData.AssetTR * 10000,0) AS BPSEffect

FROM	#RawData AS RawData 
--LEFT JOIN
--	tbl_Positions AS Positions ON (
--		RawData.BMISCode = Positions.PositionId
--		AND RawData.SecurityType = Positions.SecurityType
--		AND RawData.PositionDate = Positions.PositionDate
--		) LEFT JOIN
--	tbl_CCYDetails AS BaseCCY ON (
--		RawData.FundBaseCCYId = BaseCCY.Id
--		) LEFT JOIN
--	tbl_FxQuotes AS BaseCCYData ON (
--		BaseCCY.ISO3 = BaseCCYData.ISO
--		AND BaseCCYData.LastQuoteDate = RawData.PositionDate
--		)

WHERE ABS(RawData.PriceChange) > RawData.Tolerance

ORDER BY RawData.FundCode

----------------------------------------------------------------------------------

DROP Table #RawData
--DROP Table #BigChanges

GO

GRANT EXECUTE ON spS_WhosHoldingBigChanges TO [OMAM\StephaneD], [OMAM\ShaunF]