USE Vivaldi
GO

---------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetDerivativesCashData') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetDerivativesCashData
GO

CREATE PROCEDURE dbo.spS_GetDerivativesCashData
	@RefDate datetime
	, @FundId integer
AS

SET NOCOUNT ON;


---------------------------------------------------------------------------------------

CREATE TABLE #PlainCash (
FundId 			integer
,FundCode 		nvarchar(25)
,FundName 		nvarchar(150)
,FundBaseCCYCode	nvarchar(3)
,PositionValue		float
,PortfolioShare		float
)

INSERT INTO #PlainCash
EXEC spS_CashReportAllFunds @RefDate

---------------------------------------------------------------------------------------

SELECT	*
INTO	#ShortBonds
FROM 	dbo.fn_GetCubeDataTable(@RefDate, @FundId)
WHERE 	IsDerivative = 0
	AND SecurityType = 'Bonds'
	AND BondYearsToMaturity < 2
ORDER BY	FundCode


---------------------------------------------------------------------------------------

SELECT	*
INTO	#DerivDets
FROM 	dbo.fn_GetCubeDataTable(@RefDate, @FundId)
WHERE 	IsDerivative = 1
	AND SecurityType <> 'FutOft'
ORDER BY	FundCode

---------------------------------------------------------------------------------------

SELECT 	DerivDets.FundId
	, COUNT(DerivDets.BMISCode) AS DerivsNo
INTO	#DFunds
FROM	#DerivDets AS DerivDets
--WHERE	COUNT(DerivDets.BMISCode) > 0
GROUP BY DerivDets.FundId
---------------------------------------------------------------------------------------

SELECT 	'Derivatives' AS MainGroup
	, DDets.PositionDate
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


UNION SELECT
 	'Liquidity' AS MainGroup
	, @RefDate AS PositionDate
	, PCash.FundId
	, PCash.FundCode
	, PCash.FundName
	, null AS FundClass
	, PCash.FundBaseCCYCode
	, 'Cash' AS SecurityGroup
	, 'Cash' AS SecurityGroup
	, null AS Code
	, 'Cash balances' AS Description
	, null AS AssetCCY
	, null AS Underlying
	, PCash.PositionValue As Position
	, 0 AS FutContractSize
	, null AS Sector
	, 1 As MarketPrice
	, PCash.PositionValue AS BaseCCYExposure
	, PCash.PortfolioShare AS ExpWeight
	, 0 AS Sensitivity
	, null AS MktSector
 	, null AS OptionDelta
	, null AS OptionGamma
	, null AS OptionVega
	, null AS VegaBpValue
	, null AS DaysToExpiry
	, null AS OptPxScale
	, null AS FutCategory
	, null AS LocalMarginPaid
	, null AS BaseCCYMarginPaid
	, null AS MarginOnEquity
	, 'Cash Balances' AS Classifier
	, null AS MVaROnNaV
	, null AS MVaROnVaR
	, null AS MVaR
	, null AS CostNaV


FROM	#PlainCash AS PCash JOIN
	#DFunds AS DFunds ON (
		PCash.FundId = DFunds.FundId
		)

WHERE	((@FundId Is NULL) OR (DFunds.FundId = @FundId))


UNION SELECT
 	'Liquidity' AS MainGroup
	, SBonds.PositionDate
	, SBonds.FundId
	, SBonds.FundCode
	, Null AS FundName
	, SBonds.FundClass
	, SBonds.FundBaseCCYCode
	, SBonds.SecurityGroup
	, SBonds.SecurityType
	, SBonds.BMISCode AS Code
	, SBonds.BBGTicker AS Description
	, SBonds.AssetCCY
	, SBonds.UnderlyingCTD AS Underlying
	, SBonds.PositionSize AS Position
	, SBonds.FutContractSize
	, NULLIF(SBonds.IndustrySector, 'NotApplicable') AS Sector
	, SBonds.MarketPrice
	, SBonds.BaseCCYExposure 
	, SBonds.BaseCCYExposure/NaVs.CostNaV AS ExpWeight
	, SBonds.EffDur AS Sensitivity
	, SBonds.MktSector
 	, null AS OptionDelta
	, SBonds.OptGamma AS OptionGamma
	, SBonds.OptVega AS OptionVega
	, null AS VegaBpValue
	, SBonds.OptDaysToExp AS DaysToExpiry
	, SBonds.OptPxScale
	, SBonds.FutCategory
	, null AS LocalMarginPaid
	, null AS BaseCCYMarginPaid
	, null AS MarginOnEquity
	, 'Short bonds' AS Classifier
	, null AS MVaROnNaV
	, null AS MVaROnVaR
	, null AS MVaR
	, null AS CostNaV


FROM	#ShortBonds AS SBonds LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		SBonds.PositionDate = NaVs.NaVPLDate
		AND Sbonds.FundId = NaVs.FundID
		) JOIN
	#DFunds AS DFunds ON (
		SBonds.FundId = DFunds.FundId
		)



ORDER BY 	FundCode

---------------------------------------------------------------------------------------

DROP TABLE	#DerivDets
DROP TABLE	#PlainCash
DROP TABLE	#ShortBonds
DROP TABLE	#DFunds
GO

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetDerivativesCashData TO [OMAM\StephaneD]