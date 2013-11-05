USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_ManualPrices]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_ManualPrices]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_ManualPrices]
AS

SELECT	Prices.PriceDate
	, Prices.SecurityId
	, Prices.Description
	, Prices.ShortName
	, Prices.securityType
	, Prices.PxLast AS BMISPrice
	, Manual.MktPrice
FROM	tbl_RevertMktPriceToCost AS Manual LEFT JOIN
	tbl_AssetPrices As Prices ON (
		Manual.SecurityId = Prices.SecurityId
		)

WHERE	Manual.RevertToCost = 1
	AND Prices.PriceDate = (SELECT MAX(Pricedate) FROM tbl_AssetPrices)
	
	