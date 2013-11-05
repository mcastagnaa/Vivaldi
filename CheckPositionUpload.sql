USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CheckMorningLoad]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CheckMorningLoad]
GO

CREATE PROCEDURE [dbo].[spS_CheckMorningLoad] 
	@RefDate datetime
AS

SET NOCOUNT ON;


SELECT  Pos.PositionDate AS LastDate
	, Count(Pos.PositionId) AS LastCount
	, Pos.BOShortName AS BO
INTO	#LASTSUM
FROM tbl_Positions AS Pos
WHERE	Pos.PositionDate = @RefDate
GROUP BY	Pos.PositionDate
		, Pos.BOShortName

--------------------------------------------------------------------

SELECT  Pos.PositionDate AS PrevDate
	, Count(Pos.PositionId) AS PrevCount
	, Pos.BOShortName AS BO
INTO	#PREVSUM
FROM tbl_Positions AS Pos
WHERE	Pos.PositionDate = (SELECT MAX(PositionDate) FROM tbl_Positions WHERE PositionDate < @RefDate)
GROUP BY	Pos.PositionDate
		, Pos.BOShortName

--------------------------------------------------------------------

SELECT 	'BOSUMMARY' AS Item
	, Last.BO AS BackOffice
	, Last.LastDate
	, Prev.PrevDate
	, Last.LastCount
	, Prev.PrevCount
	, (Last.LastCount-Prev.PrevCount) AS Diff

INTO #Summary

FROM	#LastSUM AS Last LEFT JOIN #PrevSUM AS Prev ON
	(Last.BO = Prev.BO)

--------------------------------------------------------------------

SELECT  Pos.PositionDate AS LastDate
	, Count(Pos.PositionId) AS LastCount
	, Pos.SecurityType As SecType
INTO	#LASTTYPE
FROM tbl_Positions AS Pos
WHERE	Pos.PositionDate = @RefDate
GROUP BY	Pos.PositionDate
		, Pos.SecurityType

--------------------------------------------------------------------

SELECT  Pos.PositionDate AS PrevDate
	, Count(Pos.PositionId) AS PrevCount
	, Pos.SecurityType AS SecType
INTO	#PREVTYPE
FROM tbl_Positions AS Pos
WHERE	Pos.PositionDate = (SELECT MAX(PositionDate) FROM tbl_Positions WHERE PositionDate < @RefDate)
GROUP BY	Pos.PositionDate
		, Pos.SecurityType

--------------------------------------------------------------------

SELECT 	Last.SecType AS Item
	, '' AS BackOffice
	, Last.LastDate
	, Prev.PrevDate
	, Last.LastCount
	, Prev.PrevCount
	, (Last.LastCount-Prev.PrevCount) AS Diff

INTO #TypeDets

FROM	#LastType AS Last FULL JOIN #PrevType AS Prev ON
	(Last.SecType = Prev.SecType)

--------------------------------------------------------------------
SELECT * FROM #SUMMARY
UNION
SELECT * FROM #TYPEDETS
ORDER BY BackOffice 

--------------------------------------------------------------------
DROP TABLE #LASTSUM
DROP TABLE #PREVSUM
DROP TABLE #LASTTYPE
DROP TABLE #PREVTYPE
DROP TABLE #SUMMARY
DROP TABLE #TYPEDETS



GO
--------------------------------------------------------------------

GRANT EXECUTE ON spS_CheckMorningLoad TO [OMAM\StephaneD], [OMAM\MargaretA] 
