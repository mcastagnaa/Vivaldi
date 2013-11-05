USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_MissingCountryRegionClassification]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_MissingCountryRegionClassification]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_MissingCountryRegionClassification]
AS


SELECT	Assets.CountryISO AS Country
	, Countries.CountryName AS Name
	, Countries.RegionId AS Region

FROM	tbl_AssetPrices AS Assets LEFT JOIN 
	tbl_CountryCodes AS Countries ON (
		Assets.CountryISO = Countries.ISOCode
		)

WHERE	Countries.RegionId IS NULL
	