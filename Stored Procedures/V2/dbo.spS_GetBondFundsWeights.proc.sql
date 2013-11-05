USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetBondFundsWeights') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetBondFundsWeights
GO

CREATE PROCEDURE dbo.spS_GetBondFundsWeights
	@RefDate datetime
AS

SET NOCOUNT ON;
----------------------------------------------------------------------------------

SELECT	Positions.PositionDate
	, Positions.SecurityType
	, Positions.PositionId AS BMISCode
	, Assets.Description

FROM	tbl_Positions AS Positions LEFT JOIN tbl_AssetPrices AS Assets ON
		(Positions.PositionId = Assets.SecurityId
		AND Positions.PositionDate = Assets.PriceDate
		AND Positions.SecurityType = Assets.SecurityType)
	LEFT JOIN tbl_BMISAssets AS Types ON
		(Assets.SecurityType = Types.AssetName)
	LEFT JOIN tbl_Funds AS Funds ON
		(Positions.FundShortName = Funds.FundCode)

WHERE 	Funds.FundclassId = 2
	AND Funds.Skip = 0
	AND Funds.Alive = 1
	AND Types.SecGroup = 'FixedIn'
	AND Positions.PositionDate = @refDate

GROUP BY	Positions.PositionDate
		, Positions.SecurityType
		, Positions.PositionId
		, Assets.Description

ORDER BY	Positions.SecurityType	
		, Assets.Description

 
----------------------------------------------------------------------------------
DROP TABLE #CubeData
DROP TABLE #TempData
GO
----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetBondFundsWeights TO [OMAM\StephaneD], [OMAM\MargaretA] 
