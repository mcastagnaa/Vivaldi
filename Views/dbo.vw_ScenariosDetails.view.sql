USE Vivaldi
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_ScenariosDetails]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_ScenariosDetails]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_ScenariosDetails]
AS

SELECT	FileDets.ID
		, FileDets.FileName
		, FileDets.ScenId
		, Scens.AlgoLetter AS ScenLetter
		, Scens.ScenLabel
		, FileDets.FundId
		, Funds.FundCode
		, FileDets.IsRelative
		, FileDets.LastUpdate
FROM	tbl_EnumScenFiles AS FileDets LEFT JOIN
		tbl_EnumScen AS Scens ON (
			FileDets.ScenId = Scens.ID
			) LEFT JOIN
		tbl_funds AS Funds ON (
			FileDets.FundId = Funds.Id
			)