USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_OthersReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_OthersReport]
GO

CREATE PROCEDURE [dbo].[spS_OthersReport] 
	@RefDate datetime
AS

SET NOCOUNT ON;


SELECT	Funds.Id AS FundID
	, Funds.FundCode AS FundCode
	, Positions.Units AS Position
	, Assets.SecurityId AS AssetCode
	, Assets.Description AS AssetName
	, Assets.ShortName AS Issuer
	, Assets.PxLast As LastPrice

FROM	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId
		AND Positions.PositionDate = Assets.PriceDate
		)

WHERE	Assets.SecurityType = 'Others'
	AND Positions.PositionDate = @RefDate

GO

GRANT EXECUTE ON spS_OthersReport TO [OMAM\StephaneD], [OMAM\MargaretA]