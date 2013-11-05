USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CashReportAllFunds]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CashReportAllFunds]
GO


CREATE PROCEDURE [dbo].[spS_CashReportAllFunds] 
	@RefDate datetime
AS

SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate,
	Funds.Id AS FundId,
	Positions.FundShortName AS FundCode,
	Funds.FundName AS FundName,
	FundsCCY.ID AS FundBaseCCYId,
	FundsCCY.ISO3 AS FundBaseCCYCode,
	FundsCCY.IsInverse AS FundBaseCCYIsInverse,
	BaseCCYquotes.LastQuote AS BaseCCYQuote,
	BaseCCYquotes.PreviousQuote AS BaseCCYPrevQuote,
	Positions.SecurityType AS SecurityType,
	BMISAssets.PriceDivider AS PriceDivider,
	Assets.Multiplier AS FuturesMultiplier,
	Positions.Units AS PositionSize,
	Positions.StartPrice AS StartPrice,
	AssetsCCY.IsInverse AS AssetCCYIsInverse,
	AssetsCCYQuotes.LastQuote AS AssetCCYQuote,
	AssetsCCYQuotes.PreviousQuote AS AssetCCYPrevQuote,
	PenceQuotesDivider =
	CASE
		WHEN Assets.DivBy100 = 1 THEN 100
		ELSE 1
	END
INTO #RawData

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_CcyDetails AS FundsCCY ON (
		Funds.BaseCCYId = FundsCCY.Id
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_FxQuotes AS BaseCCYQuotes ON (
		Positions.PositionDate = BaseCCYQuotes.LastQuoteDate AND
		FundsCCY.ISO3 = BaseCCYQuotes.ISO
		) LEFT JOIN
	tbl_CcyDetails AS AssetsCCY ON (
		Assets.CCYIso = AssetsCCY.ISO3
		) LEFT JOIN
	tbl_FxQuotes AS AssetsCCYQuotes ON (
		Positions.PositionDate = AssetsCCYQuotes.LastQuoteDate AND
		AssetsCCY.ISO3 = AssetsCCYQuotes.ISO
		)  LEFT JOIN
	tbl_BMISAssets AS BMISAssets ON (
		Positions.SecurityType = BMISAssets.AssetName
		)
	
WHERE 	Assets.PriceDate = @RefDate AND
	Assets.CCYIso <> '---' AND
	Positions.SecurityType in ('Cash', 'MMFunds', 'TBills', 'CD')

----------------------------------------------------------------------------------

SELECT	RawData.FundId,
	RawData.FundCode,
	RawData.FundName,
	RawData.FundBaseCCYCode,
	dbo.fn_GetBaseCCYPrice(RawData.StartPrice,
		RawData.AssetCCYPrevQuote,
		RawData.AssetCCYIsInverse,
		RawData.BaseCCYPrevQuote,
		RawData.FundBaseCCYIsInverse,
		RawData.SecurityType,
		1) * RawData.PositionSize * 
			RawData.FuturesMultiplier/
			RawData.PriceDivider/
			RawData.PenceQuotesDivider AS BaseCCYCostValue,
	NaVs.CostNaV AS NaV

INTO #Interim

FROM	#RawData AS RawData LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		RawData.FundId = NaVs.FundId AND
		RawData.PositionDate = NaVs.NaVPLDate
		)


-----------------------------------------------------------------------

SELECT	Interim.FundId,
	Interim.FundCode,
	Interim.FundName,
	Interim.FundBaseCCYCode,
	Sum(Interim.BaseCCYCostValue) AS PositionValue,
	PortfolioShare = 
		CASE 
			WHEN Interim.NaV IS NULL THEN NULL
			ELSE Sum(Interim.BaseCCYCostValue)/Interim.NaV
		END

FROM	#Interim as Interim

GROUP BY	Interim.FundId,
		Interim.FundCode,
		Interim.FundName,
		Interim.FundBaseCCYCode,
		Interim.NaV

ORDER BY	Interim.FundCode ASC

DROP Table #RawData
DROP Table #Interim
GO


GRANT EXECUTE ON spS_CashReportAllFunds TO [OMAM\StephaneD], [OMAM\MargaretA]

