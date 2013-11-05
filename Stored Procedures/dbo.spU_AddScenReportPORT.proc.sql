USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_AddScenReportPORT]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_AddScenReportPORT]
GO

CREATE PROCEDURE [dbo].[spU_AddScenReportPORT] 
AS

SET NOCOUNT ON;

------------------------------------------------------------------------------------------

DECLARE @RefDate datetime
DECLARE @FundId integer

SET @RefDate = (SELECT MAX(ReportDate) FROM tbl_ScenReportsStInPORT)
SET @FundId = (SELECT MAX(FundId) FROM tbl_ScenReportsStInPORT)

DELETE	tbl_ScenReports
FROM	tbl_ScenReports AS Rep 
		INNER JOIN
		tbl_ScenReportsStInPORT AS Sti ON (
			Rep.ReportDate = Sti.ReportDate
			AND Rep.FundId = Sti.FundId
			AND Rep.ReportId = Sti.ReportId)
WHERE	Sti.ReportId IS NOT NULL

UPDATE tbl_ScenReportsStInPORT
SET PortPerf = NULLIF(PortPerf,0), BenchPerf = NULLIF(BenchPerf,0)


INSERT INTO tbl_ScenReports SELECT * FROM tbl_ScenReportsStInPORT

TRUNCATE TABLE tbl_ScenReportsStInPORT

------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spU_AddScenReportPORT TO [OMAM\StephaneD]

