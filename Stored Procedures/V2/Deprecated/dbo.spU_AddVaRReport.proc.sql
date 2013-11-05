USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_AddVaRReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_AddVaRReport]
GO

CREATE PROCEDURE [dbo].[spU_AddVaRReport] 
AS

SET NOCOUNT ON;


------------------------------------------------------------------------------------------

INSERT INTO tbl_VaRReports SELECT * FROM tbl_VaRReport_StIn

------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spU_AddVaRReport TO [OMAM\StephaneD], [OMAM\MargaretA] 

