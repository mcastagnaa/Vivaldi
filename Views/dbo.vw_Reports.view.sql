USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_Reports]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_Reports]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Reports]
AS

SELECT	Reports.Id AS ReportId
	, Reports.ShortName AS ShortName
	, Reports.LongName AS Description
	, Reports.ReportType AS TypeID
	, RepTypes.ShortName AS Type
	, RepTypes.LongName As TypeDescription
	, Reports.FileName AS FileName
	, Reports.EMailAddresses AS EMailDef
	, Reports.LastFileFolder AS LastFileFolder
	, Reports.HistFileFolder AS HistFileFolder
	, Reports.IsAvailable AS IsAvailable
	, Reports.SourceName AS SourceName
	
FROM	tbl_Reports AS Reports LEFT JOIN
	tbl_ReportTypes AS RepTypes ON
		(Reports.ReportType = RepTypes.ID)