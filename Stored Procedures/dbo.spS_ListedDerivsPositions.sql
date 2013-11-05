USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_ListedDerivsPositions]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_ListedDerivsPositions]
GO

CREATE PROCEDURE [dbo].[spS_ListedDerivsPositions] 
	@RefDate datetime

AS

SET NOCOUNT ON;

----------------------------------

SELECT 	PositionId
FROM	tbl_Positions AS Pos LEFT JOIN
	tbl_BMISAssets AS Ass ON (
		Pos.SecurityType = Ass.AssetName
		)
WHERE	Ass.IsDerivative = 1
	AND Pos.PositionDate = @RefDate
	AND Ass.AssetName NOT IN(
				'FutOft'
				,'Derivatives'
				,'CDS'
				,'CDSIndex'
				,'CDSiO'
				)

GROUP BY PositionId



GO
---------------------------------

GRANT EXECUTE ON spS_ListedDerivsPositions TO [OMAM\StephaneD]