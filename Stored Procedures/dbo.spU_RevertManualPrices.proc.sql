USE RM_PTFL
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_RevertManualPrices]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spU_RevertManualPrices]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spU_RevertManualPrices] 

AS
SET NOCOUNT ON;

DECLARE @RefDate AS Datetime
SET @RefDate = (SELECT MAX(PriceDate) FROM tbl_AssetPrices)

UPDATE	tbl_RevertMktPriceToCost
SET 	MktPrice = Prices.PXLast
FROM	tbl_RevertMktPriceToCost AS Checks LEFT JOIN
	tbl_AssetPrices AS Prices ON (
		Checks.SecurityId = Prices.SecurityId
		)
WHERE	Checks.RevertToCost = 1
	AND Prices.PriceDate = @RefDate
--GO
-----------------------------------------------------------------------------

--DECLARE @RefDate AS Datetime
--SET @RefDate = (SELECT MAX(PriceDate) FROM tbl_AssetPrices)

UPDATE	tbl_AssetPrices
SET 	PxLast = Positions.StartPrice
	, IsManualPrice = 1

FROM	tbl_Positions AS Positions LEFT JOIN
	tbl_AssetPrices AS Prices ON (
		Positions.PositionId = Prices.SecurityId
		AND Positions.PositionDate = Prices.PriceDate
		AND Positions.SecurityType = Prices.SecurityType
			) LEFT JOIN
	tbl_RevertMktPriceToCost AS Checks ON (
		Positions.PositionId = Checks.SecurityId
			)
WHERE	Prices.PriceDate = @RefDate
	AND Checks.RevertToCost = 1

GO

GRANT EXECUTE ON spU_RevertManualPrices TO [OMAM\StephaneD], [OMAM\MargaretA]