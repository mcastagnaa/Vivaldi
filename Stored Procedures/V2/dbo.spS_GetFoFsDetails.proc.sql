USE Vivaldi
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetFoFsDetails') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetFoFsDetails
GO

CREATE PROCEDURE dbo.spS_GetFoFsDetails
	@RefDate datetime
AS

SET NOCOUNT ON;
----------------------------------------------------------------------------------
SELECT	D.*
INTO	#FoFDetsTmp
FROM 	dbo.fn_GetCubeDataTable(@RefDate, null) AS D JOIN
		tbl_Funds AS F ON (D.FundId = F.Id)
WHERE 	F.StyleId IN (6,7)
----------------------------------------------------------------------------------

SELECT	FundId
		, FundCode
		, SecurityGroup
		, IndustryGroup
		, IndustrySector
		, BBGId
		, SUM(BaseCCYCostValue) AS BaseCCYCostValue
		, SUM(BaseCCYExposure) AS BaseCCYExposure
INTO	#FoFDets
FROM	#FoFDetsTmp
GROUP BY	FundId
			, FundCode
			, SecurityGroup
			, IndustryGroup
			, IndustrySector
			, BBGId

----------------------------------------------------------------------------------
SELECT	DDets.FundCode
		, Funds.FundName
		, Funds.HoDLongName
		, Funds.StyleName
		, (CASE DDets.IndustrySector 
				WHEN 'Funds' THEN 'Funds' 
				ELSE DDets.SecurityGroup END) AS SecurityGroup
--		, DDets.BMISCode AS Code
--		, DDets.BBGTicker AS Description
		, (CASE DDets.SecurityGroup 
				WHEN 'CashFx' THEN 'CashFx' 
				ELSE DDets.IndustrySector END) AS Asset
		, DDets.IndustryGroup AS FundType
		, SUM(CASE DDets.SecurityGroup 
			WHEN 'CashFX' THEN DDets.BaseCCYCostValue
			ELSE DDets.BaseCCYExposure END)/NaVs.CostNaV AS NetExp
		, ABS(SUM(CASE DDets.SecurityGroup 
			WHEN 'CashFX' THEN DDets.BaseCCYCostValue
			ELSE DDets.BaseCCYExposure END))/NaVs.CostNaV AS GrossExp
		, SUM(VaRs.MargVaR) * 100/ NaVs.CostNaV AS MVaROnNaV
		, SUM(VaRs.MargVaR) * 100/ TotalVaRs.DollarVaR AS MVaROnVaR

INTO #Base

FROM	#FoFDets AS DDets LEFT JOIN
	tbl_VaRReports AS VaRs ON (
		DDets.FundId = VaRs.FundId
		AND DDets.BBGId = VaRs.BBGInstrId
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON (
		DDets.FundId = NaVs.FundID
		) LEFT JOIN
	vw_TotalVaRByFundByDate AS TotalVaRs ON (
		DDets.FundId = TotalVaRs.FundId
		) LEFT JOIN
	vw_FundsTypology AS Funds ON (
		DDets.FundId = Funds.FundId
		) 
WHERE	VaRs.ReportDate = @RefDate
		AND NaVs.NaVPLDate = @RefDate
		AND TotalVaRs.VaRDate = @RefDate

GROUP BY	Funds.HoDLongName
			, Funds.StyleName
			, DDets.FundCode
			, Funds.FundName
			, DDets.SecurityGroup
			, DDets.IndustrySector
			, DDets.IndustryGroup
			, NaVs.CostNaV
			, TotalVaRs.DollarVaR

--ORDER BY 	FundCode

UPDATE	#Base
SET	FundType = Asset
WHERE	FundType = 'NotApplicable'

UPDATE	#Base
SET	Asset = 'Overlay'
WHERE	Asset NOT IN ('Funds', 'CashFx')


/*UPDATE	#Base
SET	FundType = 'Equity'
WHERE	Asset = 'CashFx'
*/
SELECT * FROM #Base
----------------------------------------------------------------------------------

DROP TABLE #FoFDets
DROP TABLE #Base

----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetFoFsDetails TO [OMAM\StephaneD]