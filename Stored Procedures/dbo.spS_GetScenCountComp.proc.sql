USE Vivaldi;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetScenCountComp]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetScenCountComp]
GO

CREATE PROCEDURE [dbo].[spS_GetScenCountComp] 
	@RefDate datetime 
AS

SET NOCOUNT ON;

DECLARE @PrevDate datetime
SET @PrevDate = (SELECT	MAX(ReportDate) 
				FROM	tbl_ScenReports
				WHERE	ReportDate < @RefDate)

SELECT	'Totals' AS ItemLabel
		, null AS FundId
		, null AS FundCode
		, COUNT(ReportDate) AS RefDateCount
		, (SELECT COUNT(ReportDate) 
			FROM tbl_ScenReports
			WHERE ReportDate = @PrevDate) AS PrevDateCount
FROM	tbl_ScenReports
WHERE	ReportDate = @RefDate

UNION
SELECT	'Funds' AS ItemLabel
		, R.FundId
		, F.FundCode
		, COUNT(R.ReportDate) AS RefDateCount
		, (SELECT	COUNT(ReportDate) 
			FROM	tbl_ScenReports AS P
			WHERE	P.ReportDate = @PrevDate
					AND P.FundId = R.FundId) AS PrevDateCount
FROM	tbl_ScenReports AS R LEFT JOIN
		tbl_Funds AS F ON (
			R.FundId = F.Id
			)
WHERE	ReportDate = @RefDate
GROUP BY R.FundId, F.FundCode

GRANT EXECUTE ON spS_GetScenCountComp TO [OMAM\StephaneD]