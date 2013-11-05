USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_AssetFXPlAttribution]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_AssetFXPlAttribution]
GO

CREATE PROCEDURE [dbo].[spS_AssetFXPlAttribution] 
	@RefDate datetime
	, @FundId int
AS

SET NOCOUNT ON;


SELECT	NaVPlDate
	, AssetPL/CostNaV AS AssetPLBps
	, FxPL/CostNaV AS FXPlBps
	, TotalPL/CostNaV AS TotalPLBps
	, FxPL/TotalPl As FxPlPerc
	, CCYExposure AS CCYExp
FROM	tbl_FundsNavsAndPls AS DataSet
WHERE	FundId = @FundId
	AND NAVPlDate > DATEADD(m, -3, @RefDate)
	AND NAVPlDate <= @refDate
ORDER BY	NaVPlDate

GO

GRANT EXECUTE ON spS_AssetFXPlAttribution TO [OMAM\StephaneD], [OMAM\MargaretA] 