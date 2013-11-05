USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_KRDByFundByDateFinal]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_KRDByFundByDateFinal]
GO

CREATE PROCEDURE [dbo].[spS_KRDByFundByDateFinal] 
	@RefDate datetime
	, @FundId int

AS

CREATE TABLE #KRDData (
	DateTag		nvarchar(10)
	, KRDDate	datetime
	, KRD3m		float
	, KRD6m		float
	, KRD1y		float
	, KRD2y		float
	, KRD3y		float
	, KRD4y		float
	, KRD5y		float
	, KRD6y		float
	, KRD7y		float
	, KRD8y		float
	, KRD9y		float
	, KRD10y	float
	, KRD15y	float
	, KRD20y	float
	, KRD25y	float
	, KRD30y	float
)	

INSERT INTO #KRDData
EXEC spS_KRDByFundByDate @RefDate, @FundId

-------------------------------------------------------------------------

SELECT	*
INTO #KRD3m
FROM (	SELECT	DateTag, KRD3m FROM #KRDData) o
PIVOT (AVG(KRD3m) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD6m
FROM (	SELECT	DateTag, KRD6m FROM #KRDData) o
PIVOT (AVG(KRD6m) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD1y
FROM (	SELECT	DateTag, KRD1y FROM #KRDData) o
PIVOT (AVG(KRD1y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD2y
FROM (	SELECT	DateTag, KRD2y FROM #KRDData) o
PIVOT (AVG(KRD2y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD3y
FROM (	SELECT	DateTag, KRD3y FROM #KRDData) o
PIVOT (AVG(KRD3y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD4y
FROM (	SELECT	DateTag, KRD4y FROM #KRDData) o
PIVOT (AVG(KRD4y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD5y
FROM (	SELECT	DateTag, KRD5y FROM #KRDData) o
PIVOT (AVG(KRD5y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD6y
FROM (	SELECT	DateTag, KRD6y FROM #KRDData) o
PIVOT (AVG(KRD6y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD7y
FROM (	SELECT	DateTag, KRD7y FROM #KRDData) o
PIVOT (AVG(KRD7y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD8y
FROM (	SELECT	DateTag, KRD8y FROM #KRDData) o
PIVOT (AVG(KRD8y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD9y
FROM (	SELECT	DateTag, KRD9y FROM #KRDData) o
PIVOT (AVG(KRD9y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD10y
FROM (	SELECT	DateTag, KRD10y FROM #KRDData) o
PIVOT (AVG(KRD10y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD15y
FROM (	SELECT	DateTag, KRD15y FROM #KRDData) o
PIVOT (AVG(KRD15y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD20y
FROM (	SELECT	DateTag, KRD20y FROM #KRDData) o
PIVOT (AVG(KRD20y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD25y
FROM (	SELECT	DateTag, KRD25y FROM #KRDData) o
PIVOT (AVG(KRD25y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

SELECT	*
INTO #KRD30y
FROM (	SELECT	DateTag, KRD30y FROM #KRDData) o
PIVOT (AVG(KRD30y) FOR DateTag IN(	[Date1]
					, [Date2]
					, [Date3]
					)) p

-------------------------------------------------------------------------

SELECT	1 AS CatOrder
	,'KRD3m' AS KRD
	, Date1 AS ValueLast
	, Date2 AS Value1w
	, Date3 AS Value1m
FROM #KRD3m

UNION
SELECT	2
	,'KRD6m'
	, Date1
	, Date2
	, Date3
FROM #KRD6m

UNION
SELECT	3
	,'KRD1y'
	, Date1
	, Date2
	, Date3
FROM #KRD1y

UNION
SELECT	4
	,'KRD2y'
	, Date1
	, Date2
	, Date3
FROM #KRD2y

UNION
SELECT	5
	,'KRD3y'
	, Date1
	, Date2
	, Date3
FROM #KRD3y

UNION
SELECT	6
	,'KRD4y'
	, Date1
	, Date2
	, Date3
FROM #KRD4y

UNION
SELECT	7
	,'KRD5y'
	, Date1
	, Date2
	, Date3
FROM #KRD5y

UNION
SELECT	8
	,'KRD6y'
	, Date1
	, Date2
	, Date3
FROM #KRD6y

UNION
SELECT	9
	,'KRD7y'
	, Date1
	, Date2
	, Date3
FROM #KRD7y

UNION
SELECT	10
	,'KRD8y'
	, Date1
	, Date2
	, Date3
FROM #KRD8y

UNION
SELECT	11
	,'KRD9y'
	, Date1
	, Date2
	, Date3
FROM #KRD9y

UNION
SELECT	12
	,'KRD10y'
	, Date1
	, Date2
	, Date3
FROM #KRD10y

UNION
SELECT	13
	,'KRD15y'
	, Date1
	, Date2
	, Date3
FROM #KRD15y

UNION
SELECT	14
	,'KRD20y'
	, Date1
	, Date2
	, Date3
FROM #KRD20y

UNION
SELECT	15
	,'KRD25y'
	, Date1
	, Date2
	, Date3
FROM #KRD25y

UNION
SELECT	16
	,'KRD30y'
	, Date1
	, Date2
	, Date3
FROM #KRD30y

-------------------------------------------------------------------------

DROP TABLE #KRDData
DROP TABLE #KRD3m
DROP TABLE #KRD6m
DROP TABLE #KRD1y
DROP TABLE #KRD2y
DROP TABLE #KRD3y
DROP TABLE #KRD4y
DROP TABLE #KRD5y
DROP TABLE #KRD6y
DROP TABLE #KRD7y
DROP TABLE #KRD8y
DROP TABLE #KRD9y
DROP TABLE #KRD10y
DROP TABLE #KRD15y
DROP TABLE #KRD20y
DROP TABLE #KRD25y
DROP TABLE #KRD30y

GO

GRANT EXECUTE ON spS_KRDByFundByDateFinal TO [OMAM\StephaneD], [OMAM\MargaretA]