USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_AddVaRReportPORT]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_AddVaRReportPORT]
GO

CREATE PROCEDURE [dbo].[spU_AddVaRReportPORT] 
AS

SET NOCOUNT ON;

------------------------------------------------------------------------------------------

UPDATE tbl_VaRReport_StInPORT
SET CondVaR = 0
WHERE CondVaR IS NULL

------------------------------------------------------------------------------------------
--== Eliminate EconomicCash '_EC' lines after adjusting MVaR values
------------------------------------------------------------------------------------------

SELECT	*
		, LEFT(BBGInstrId, LEN(BBGInstrId)-3) AS NewId
INTO	#FutsEC
FROM	tbl_VaRReport_StInPORT
WHERE	RIGHT(BBGInstrId, 3) = '_EC'

----------------------------------------------------------

UPDATE	tbl_VaRReport_StInPORT
SET		VaRPerc = M.VaRPerc + ISNULL(EC.VaRPerc,0)
		, MargVaR = M.MargVaR + ISNULL(EC.MargVaR,0)

FROM	tbl_VaRReport_StInPORT AS M JOIN
		#FutsEC AS EC ON (
			M.ReportId = EC.ReportId
			AND M.BBGInstrId = EC.NewId
			)

DELETE
FROM	tbl_VaRReport_StInPORT
WHERE	RIGHT(BBGInstrId, 3) = '_EC'

----------------------------------------------------------

DROP Table #FutsEC

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

DECLARE @RefDate datetime
DECLARE @FundId integer

SET @RefDate = (SELECT MAX(ReportDate) FROM tbl_VaRReport_StInPORT)
SET @FundId = (SELECT MAX(FundId) FROM tbl_VaRReport_StInPORT)

DELETE
FROM	tbl_VaRReports
WHERE	FundId = @FundId
		AND ReportDate = @RefDate

INSERT INTO tbl_VaRReports SELECT * FROM tbl_VaRReport_StInPORT

------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spU_AddVaRReportPORT TO [OMAM\StephaneD]

