USE RM_PTFL
GO

IF  EXISTS (
SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[vw_PositionsByDate]') AND OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_PositionsByDate]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_PositionsByDate]
AS
SELECT 	Positions.PositionId AS SecurityId,
	Positions.SecurityType As SecurityType,
	Positions.PositionDate AS PositionDate/*,
	Positions.StartPrice AS BMISPrice*/
FROM 	tbl_Positions AS Positions
GROUP BY Positions.PositionId, Positions.PositionDate, Positions.SecurityType /*, Positions.StartPrice*/
