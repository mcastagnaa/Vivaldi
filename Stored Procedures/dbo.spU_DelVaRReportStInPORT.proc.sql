USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_DelVaRReportStInPORT]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_DelVaRReportStInPORT]
GO

CREATE PROCEDURE [dbo].[spU_DelVaRReportStInPORT] 
AS

SET NOCOUNT ON;


------------------------------------------------------------------------------------------

TRUNCATE TABLE tbl_VaRReport_StInPORT

------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spU_DelVaRReportStInPORT TO [OMAM\StephaneD]

