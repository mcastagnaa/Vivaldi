USE RM_PTFL
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_MissingRatingsClassification]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_MissingRatingsClassification]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_MissingRatingsClassification]
AS


SELECT	Assets.SPRating AS BBGRating
	, Ratings.CleanRating AS MyRating

FROM	tbl_AssetPrices AS Assets LEFT JOIN 
	tbl_SPRatingsCodes AS Ratings ON (
		Assets.SPRating = Ratings.RatingSPBB
		)

WHERE	Ratings.CleanRating IS NULL
	