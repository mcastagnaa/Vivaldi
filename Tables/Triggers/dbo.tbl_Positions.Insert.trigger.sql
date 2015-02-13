USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * 
		FROM dbo.sysobjects 
		WHERE id = OBJECT_ID(N'dbo.tbl_Positions$Insert') 
			AND OBJECTPROPERTY(id, N'IsTrigger') = 1)

DROP TRIGGER dbo.tbl_Positions$Insert
GO

CREATE TRIGGER dbo.tbl_Positions$Insert
   ON dbo.tbl_Positions AFTER INSERT
AS
SET NOCOUNT ON
BEGIN
	DELETE P
	FROM tbl_Positions AS P JOIN INSERTED AS I ON
		(P.PositionDate = I.PositionDate
			AND P.FundShortName = I.FundShortName
			AND P.SecurityType = I.SecurityType
			AND P.PositionId = I.PositionId)
	WHERE P.Units = 0
	
END
GO








