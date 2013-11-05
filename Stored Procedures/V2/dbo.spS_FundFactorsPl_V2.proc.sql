USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_FundFactorsPl_V2') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_FundFactorsPl_V2
GO

CREATE PROCEDURE dbo.spS_FundFactorsPl_V2
	@RefDate datetime
	, @FundId int
AS

SET NOCOUNT ON;


SELECT	*
INTO #SMBExp
FROM (	SELECT	PLOnNaV, LongShort, Size 
	FROM 	TmpFundRiskDetails
	WHERE 	LEN(Size)>0 
		AND FundId = @FundId
		AND DetsDate = @RefDate) o
PIVOT (SUM(PLOnNaV) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #HMLExp
FROM (	SELECT	PLOnNaV, LongShort, Value 
	FROM 	TmpFundRiskDetails
	WHERE 	LEN(Value)>0
		AND FundId = @FundId
		AND DetsDate = @RefDate) o
PIVOT (SUM(PLOnNaV) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #UMDExp
FROM (	SELECT	PLOnNaV, LongShort, UpDown 
	FROM 	TmpFundRiskDetails
	WHERE 	UpDown is not null
		AND FundId = @FundId
		AND DetsDate = @RefDate) o
PIVOT (SUM(PLOnNaV) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #BetaExp
FROM (	SELECT	PLOnNaV, LongShort, 
	BetaType = CASE WHEN Beta >= 1 THEN 'HiBeta' 
			WHEN Beta < 1 THEN 'LowBeta'
	END
	FROM 	TmpFundRiskDetails
	WHERE 	Beta IS not null
		AND BETA <> 0
		AND FundId = @FundId
		AND DetsDate = @RefDate) o
PIVOT (SUM(PLOnNaV) FOR LongShort IN(	[Long]
					, [Short]
					)) p


------------------------------------------------------------------------------------------

SELECT 	'CompanySize' AS FactorType
	, Size As FactorName
	, ISNULL(Long,0) AS Long
	, ISNULL(-Short,0) AS Short
	, ISNULL(Long,0) + ISNULL(Short,0) as Net
FROM #SMBExp

UNION
SELECT 	'ValueType' AS FactorType
	, Value
	, ISNULL(Long,0)
	, ISNULL(-Short,0)
	, ISNULL(Long,0) + ISNULL(Short,0)
FROM #HMLExp

UNION
SELECT 	'ShortMom' AS FactorType
	, UpDown
	, ISNULL(Long,0)
	, ISNULL(-Short,0)
	, ISNULL(Long,0) + ISNULL(Short,0)
FROM #UMDExp

UNION
SELECT 	'Beta' AS FactorType
	, BetaType
	, ISNULL(Long,0)
	, ISNULL(-Short,0)
	, ISNULL(Long,0) + ISNULL(Short,0)
FROM #BetaExp


------------------------------------------------------------------------------------------

DROP TABLE #HMLExp
DROP TABLE #SMBExp
DROP TABLE #UMDExp
DROP TABLE #BetaExp

------------------------------------------------------------------------------------------
GO

GRANT EXECUTE ON dbo.spS_FundFactorsPl_V2 TO [OMAM\StephaneD], [OMAM\MargaretA]