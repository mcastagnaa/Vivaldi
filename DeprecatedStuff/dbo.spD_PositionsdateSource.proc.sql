USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spD_PositionsDateSource]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spD_PositionsDateSource]
GO

CREATE PROCEDURE [dbo].[spD_PositionsDateSource] 
	@RefDate datetime, 
	@RefSource nvarchar(10)

AS

SET NOCOUNT ON;

DELETE	
FROM	tbl_Positions 
WHERE	PositionDate = @RefDate AND
	BOShortName = @RefSource


