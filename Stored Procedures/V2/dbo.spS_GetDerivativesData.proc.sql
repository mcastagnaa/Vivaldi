USE Vivaldi
GO

---------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetDerivativesData') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetDerivativesData
GO

CREATE PROCEDURE dbo.spS_GetDerivativesData
	@RefDate datetime
	, @FundId integer
AS

SET NOCOUNT ON;

---------------------------------------------------------------------------------------

SELECT	*
INTO	#DerivDets
FROM 	dbo.fn_GetCubeDataTable(@RefDate, @FundId)
WHERE 	IsDerivative = 1
	AND SecurityType <> 'FutOft'
ORDER BY	FundCode

---------------------------------------------------------------------------------------

SELECT 	DDets.PositionDate
	, DDets.FundId
	, DDets.FundCode
	, Funds.FundName
	, DDets.FundClass
	, DDets.FundBaseCCYCode
	, DDets.SecurityGroup
	, DDets.SecurityType
	, DDets.BMISCode AS Code
	, DDets.BBGTicker AS Description
	, DDets.AssetCCY
	, DDets.UnderlyingCTD AS Underlying
	, DDets.PositionSize AS Position
	, DDets.FutContractSize
	, (CASE WHEN 	DDets.SecurityType LIKE 'CDS%' 
			AND DDets.IndustrySector = 'NotApplicable' 
			THEN 'Index'
		ELSE DDets.IndustrySector END) AS Sector
	, DDets.MarketPrice
	, DDets.BaseCCYExposure 
	, DDets.BaseCCYExposure/NaVs.CostNaV AS ExpWeight
	, (CASE DDets.SecurityGroup 
		WHEN ('FixedIn') THEN 
			CASE 	WHEN DDets.SecurityType LIKE 'CDS%' THEN DDets.SpreadDur
				ELSE DDets.EffDur
			END
		ELSE DDets.Beta 
	END) AS Sensitivity
	, DDets.MktSector
 	, (CASE WHEN DDets.SecurityType LIKE 'CDS%' THEN DDets.CDSMktSpread
		WHEN DDets.IsFuture = 1 THEN DDets.FutContractSize
		ELSE DDets.OptDelta END) AS OptionDelta
	, DDets.OptGamma AS OptionGamma
	, DDets.OptVega AS OptionVega
	, dbo.fn_GetBaseCCYPrice(DDets.OptVega * DDets.FutPointValue * DDets.PositionSize * DDets.OptPxScale
		, AssetFxData.LastQuote
		, AssetFxData.IsInverse
		, FundFxData.LastQuote
		, FundFxData.IsInverse
		, DDets.SecurityType
		, 0) / NaVs.CostNaV AS VegaBpValue
	, DDets.OptDaysToExp AS DaysToExpiry
	, DDets.OptPxScale
	, DDets.FutCategory
	, ABS(DDets.PositionSize) * DDets.FutInitialMargin AS LocalMarginPaid
	, dbo.fn_GetBaseCCYPrice(ABS(DDets.PositionSize) * DDets.FutInitialMargin
		, AssetFxData.LastQuote
		, AssetFxData.IsInverse
		, FundFxData.LastQuote
		, FundFxData.IsInverse
		, DDets.SecurityType
		, 0) AS BaseCCYMarginPaid
	, dbo.fn_GetBaseCCYPrice(ABS(DDets.PositionSize) * DDets.FutInitialMargin
		, AssetFxData.LastQuote
		, AssetFxData.IsInverse
		, FundFxData.LastQuote
		, FundFxData.IsInverse
		, DDets.SecurityType
		, 0) / NaVs.CostNaV AS MarginOnEquity

	, (CASE	WHEN SecurityType LIKE 'CDS%' THEN 'Credit derivatives'
		WHEN DDets.IsFuture = 1 THEN 'Futures'
		WHEN DDets.IsFuture = 0 THEN 'Options' 
		END) AS Classifier

	, VaRs.MargVaR * 100/ NaVs.CostNaV AS MVaROnNaV
	, VaRs.MargVaR * 100/ TotalVaRs.DollarVaR AS MVaROnVaR
	, VaRs.MargVaR * 100 AS MVaR
	, NaVs.CostNaV
	


FROM	#DerivDets AS DDets LEFT JOIN
	tbl_VaRReports AS VaRs ON (
		DDets.PositionDate = VaRs.ReportDate
		AND DDets.FundId = VaRs.FundId
		AND DDets.BBGId = VaRs.BBGInstrId
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		DDets.PositionDate = NaVs.NaVPLDate
		AND DDets.FundId = NaVs.FundID
		) LEFT JOIN
	vw_TotalVaRByFundByDate AS TotalVaRs ON (
		DDets.PositionDate = TotalVaRs.VaRDate
		AND DDets.FundId = TotalVaRs.FundId
		) LEFT JOIN
	vw_FxQuotes AS AssetFXData ON (
		DDets.PositionDate = AssetFXData.FxQuoteDate
		AND DDets.AssetCCY = AssetFXData.ISO
		) LEFT JOIN
	vw_FxQuotes As FundFxData ON (
		DDets.FundBaseCcyCode = FundFxData.ISO
		AND FundFxData.FxQuoteDate = AssetFxData.FxQuoteDate
		) JOIN
	tbl_Funds AS Funds ON (
		DDets.FundId = Funds.Id
		) LEFT JOIN
	tbl_EnumVaRReports AS VaRReports ON (
		VaRs.ReportId = VaRReports.Id
		)
		

WHERE 	VaRReports.IsRelative = 0 Or VaRreports.IsRelative IS NULL

ORDER BY 	FundCode

---------------------------------------------------------------------------------------

DROP TABLE	#DerivDets
GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetDerivativesData TO [OMAM\StephaneD]