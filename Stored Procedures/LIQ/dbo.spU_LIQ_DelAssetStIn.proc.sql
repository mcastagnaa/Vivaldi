USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_LIQ_DelAssetStIn]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_LIQ_DelAssetStIn]
GO

CREATE PROCEDURE [dbo].[spU_LIQ_DelAssetStIn] 
AS

SET NOCOUNT ON;


------------------------------------------------------------------------------------------

TRUNCATE TABLE tbl_LIQ_AssetsLiquidity_StIn

------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spU_LIQ_DelAssetStIn TO [OMAM\StephaneD], [OMAM\MargaretA] 

