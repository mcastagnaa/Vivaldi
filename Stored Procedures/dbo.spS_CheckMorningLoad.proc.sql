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

SELECT 	'SUMMARY' AS Item
	, Last.BO AS BackOffice
	, '' AS FundCode
	, Last.LastDate
	, Prev.PrevDate
	, Last.LastCount
	, Prev.PrevCount
	, (Last.LastCount-Prev.PrevCount) AS Diff

INTO #Summary

FROM	#LastSUM AS Last LEFT JOIN #PrevSUM AS Prev ON
	(Last.BO = Prev.BO)

--------------------------------------------------------------------
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

SELECT 	ISNULL(Last.SecType, Prev.SecType) AS Item
	, '' AS BackOffice
	, '' AS FundCode
	, ISNULL(Last.LastDate, Prev.PrevDate) AS LastDate
	, ISNULL(Prev.PrevDate, Last.LastDate) AS PrevDate
	, ISNULL(Last.LastCount,0) As LastCount
	, ISNULL(Prev.PrevCount,0) As PrevCount
	, (ISNULL(Last.LastCount,0)-ISNULL(Prev.PrevCount,0)) AS Diff

INTO #TypeDets

FROM	#LastType AS Last FULL JOIN #PrevType AS Prev ON
	(Last.SecType = Prev.SecType)

--------------------------------------------------------------------
--------------------------------------------------------------------

SELECT  Pos.PositionDate AS LastDate
	, Count(Pos.PositionId) AS LastCount
	, Pos.FundShortName AS FundCode
INTO	#LASTFUND
FROM tbl_Positions AS Pos
WHERE	Pos.PositionDate = @RefDate
GROUP BY	Pos.PositionDate
		, Pos.FundShortName

--------------------------------------------------------------------

SELECT  Pos.PositionDate AS PrevDate
	, Count(Pos.PositionId) AS PrevCount
	, Pos.FundShortName AS FundCOde
INTO	#PREVFUND
FROM tbl_Positions AS Pos
WHERE	Pos.PositionDate = (SELECT MAX(PositionDate) FROM tbl_Positions WHERE PositionDate < @RefDate)
GROUP BY	Pos.PositionDate
		, Pos.FundShortName

--------------------------------------------------------------------

SELECT 	'' AS Item 
	, '' AS BackOffice
	, Last.FundCode 
	, Last.LastDate
	, Prev.PrevDate
	, Last.LastCount
	, Prev.PrevCount
	, (Last.LastCount-Prev.PrevCount) AS Diff

INTO #FUNDDETS

FROM	#LastFund AS Last FULL JOIN #PrevFund AS Prev ON
	(Last.FundCode = Prev.FundCode)

--------------------------------------------------------------------
--------------------------------------------------------------------

SELECT DISTINCT Pos.PositionDate AS LastDate
	, Pos.SecurityType
	, Pos.PositionId

INTO	#LASTAssetCountA
FROM 	tbl_Positions AS Pos
WHERE	Pos.PositionDate = @RefDate

GROUP BY	Pos.PositionId
		, Pos.SecurityType
		, Pos.PositionDate

--------------------------------------------------------------------

SELECT	Pos.LastDate
	, COUNT(Pos.PositionId) AS Counter
INTO	#LastAssetCount
FROM	#LastAssetCountA AS Pos
GROUP By	Pos.LastDate

--------------------------------------------------------------------

SELECT  DISTINCT Pos.PositionDate AS PrevDate
	, Pos.SecurityType
	, Pos.PositionId

INTO	#PREVAssetCountA
FROM 	tbl_Positions AS Pos
WHERE	Pos.PositionDate = (SELECT MAX(PositionDate) FROM tbl_Positions WHERE PositionDate < @RefDate)
GROUP BY	Pos.PositionId
		, Pos.SecurityType
		, Pos.PositionDate

--------------------------------------------------------------------

SELECT	Pos.PrevDate
	, COUNT(Pos.PositionId) AS Counter
INTO	#PrevAssetCount
FROM	#PrevAssetCountA AS Pos
GROUP By	Pos.PrevDate

--------------------------------------------------------------------

SELECT		'SUMMARY' AS Item
		, 'BeastLines' AS BackOffice
		, '' AS FundCode
		, Last.LastDate
		, Prev.PrevDate
		, Last.Counter AS LastCount
		, Prev.Counter AS PrevCount
		, Last.COunter-Prev.Counter AS Diff


INTO #ASSETCOUNT

FROM	#LastAssetCount AS Last, #PrevAssetCount AS PREV

--------------------------------------------------------------------
--------------------------------------------------------------------

SELECT * FROM #SUMMARY
UNION
SELECT * FROM #TYPEDETS
UNION
SELECT * FROM #FUNDDETS
UNION
SELECT * FROM #AssetCount
ORDER BY BackOffice , FundCode

--------------------------------------------------------------------
DROP TABLE #LASTSUM
DROP TABLE #PREVSUM
DROP TABLE #LASTTYPE
DROP TABLE #PREVTYPE
DROP TABLE #SUMMARY
DROP TABLE #TYPEDETS
DROP TABLE #LASTFUND
DROP TABLE #PREVFUND
DROP TABLE #FUNDDETS
DROP Table #PrevAssetCount
DROP Table #LastAssetCount
DROP Table #PrevAssetCountA
DROP Table #LastAssetCountA
DROP Table #ASSETCOUNT

GO
--------------------------------------------------------------------

GRANT EXECUTE ON spS_CheckMorningLoad TO [OMAM\StephaneD], [OMAM\MargaretA] 
