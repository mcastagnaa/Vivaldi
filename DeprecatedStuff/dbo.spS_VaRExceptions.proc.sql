USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_VaRExceptions]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_VaRExceptions]
GO

CREATE PROCEDURE [dbo].[spS_VaRExceptions] 
	@ReportDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;

SELECT	Excepts.SecTicker AS Ticker,
	Excepts.ReasonFail AS Reason,
	Assets.CCYIso AS CCY,
	Excepts.Position AS Position,
	Assets.PxLast AS MarketPrice
	
FROM	tbl_VaRRepExceptions AS Excepts LEFT JOIN
	tbl_EnumVaRReports AS Reports ON (
		Excepts.ReportId = Reports.Id
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Excepts.BBGInstrId = Assets.IDBloomberg AND
		Excepts.ReportDate = Assets.PriceDate
		)

WHERE	Excepts.ReportDate = @ReportDate AND
	Excepts.FundId = @FundId AND
	Reports.IsRelative = 0
	
	
ORDER BY	Assets.CCYIso ASC,	
		Excepts.SecTicker	

GO

GRANT EXECUTE ON spS_VaRExceptions TO [OMAM\StephaneD], [OMAM\MargaretA]