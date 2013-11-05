USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_LIQ_AddAssetFactors]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_LIQ_AddAssetFactors]
GO

CREATE PROCEDURE [dbo].[spU_LIQ_AddAssetFactors] 
AS

SET NOCOUNT ON;


------------------------------------------------------------------------------------------

INSERT INTO tbl_LIQ_AssetsLiquidity SELECT * FROM tbl_LIQ_AssetsLiquidity_StIn

------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spU_LIQ_AddAssetFactors TO [OMAM\StephaneD], [OMAM\MargaretA] 

