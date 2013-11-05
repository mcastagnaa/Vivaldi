USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_InvalidAssets]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_InvalidAssets]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_InvalidAssets]
AS


SELECT	Funds.Id AS FundId
	, Funds.FundCode AS FundCode
	, Positions.PositionId
	, Positions.PositionDate AS ReportDate
	, Positions.SecurityType
	, Positions.Units AS Size
	, Positions.StartPrice As BMISPrice
	, Positions.BOShortName AS BackOffice

FROM	tbl_Funds AS Funds LEFT JOIN
	tbl_Positions AS Positions ON (
		Funds.FundCode = Positions.FundShortName
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionDate = Assets.PriceDate
		AND Positions.PositionId = Assets.SecurityId
		AND Positions.SecurityType = Assets.SecurityType
		)

WHERE	Positions.PositionDate = (SELECT MAX(PositionDate)
					FROM tbl_Positions)
	AND Assets.CCYIso = '---'