USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CheckVaROrphans]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CheckVaROrphans]
GO

CREATE PROCEDURE [dbo].[spS_CheckVaROrphans] 
	@RefDate datetime 
AS

SET NOCOUNT ON;


SELECT	VAR.FundId
	, Funds.FundCode
	, VAR.SecTicker
	, VAR.BBGInstrId
	, VAR.SecName
	, Assets.IDBloomberg
	, Assets.SecurityType


FROM	tbl_VaRReports AS VAR LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		VAR.BBGInstrId = Assets.IDBloomberg
		AND VAR.ReportDate = Assets.PriceDate
		) LEFT JOIN 
	tbl_EnumVarReports AS VaRReports ON (
		VAR.ReportId = VaRReports.ID
		) LEFT JOIN
	tbl_Funds AS Funds ON (
		VAR.FundId = Funds.Id
		)

WHERE	VAR.ReportDate = @RefDate
	AND VAR.SecTicker <> 'Totals'
	AND VaRReports.IsRelative = 0
	AND Assets.IDBloomberg IS NULL
--	AND Assets.SecurityType = 'Derivatives'


GO

GRANT EXECUTE ON spS_CheckVaROrphans TO [OMAM\StephaneD]
					, [OMAM\MargaretA]
