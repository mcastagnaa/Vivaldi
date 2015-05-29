USE VIVALDI;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetFoFTypeLoading1Y]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetFoFTypeLoading1Y]
GO

CREATE PROCEDURE [dbo].[spS_GetFoFTypeLoading1Y] 
	@RefDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;

SELECT	DetsDate
	, SecurityGroup
	, IndustrySector AS Asset
	, IndustryGroup AS FundType
	, SUM(CASE SecurityGroup WHEN 'CashFx' THEN Weight ELSE ExpWeight END) AS NetExp
	, SUM(ABS(ExpWeight)) AS GrossExp
	, SUM(MVaRonVaR) AS RiskShare
INTO	#Base
FROM	TmpFundRiskDetails
WHERE	FundId = @FundId
	AND DetsDate > DATEADD(month,-12,@RefDate)
GROUP BY	DetsDate
		, SecurityGroup
		, IndustrySector
		, IndustryGroup
ORDER BY	DetsDate


UPDATE	#Base
SET	SecurityGroup = 'Funds'
WHERE	Asset = 'Funds'

UPDATE	#Base
SET	FundType = 'Others'
WHERE	FundType NOT IN ('Equity Fund', 'Debt Fund', 'Real Estate Fund')
		AND Asset = 'Funds'

INSERT INTO #Base
	SELECT	@RefDate, 'Funds', 'Funds', 'Real Estate Fund', 0,0,0 
	UNION ALL SELECT @RefDate, 'Funds', 'Funds', 'Equity Fund', 0,0,0
	UNION ALL SELECT @RefDate, 'Funds', 'Funds', 'Debt Fund', 0,0,0
	UNION ALL SELECT @RefDate, 'Funds', 'Funds', 'Others', 0,0,0
	UNION ALL SELECT @RefDate, 'Funds', 'Funds', 'Others', 0,0,0
	UNION ALL SELECT @RefDate, 'CashFx', '', '', 0,0,0
	UNION ALL SELECT @RefDate, 'Equities', '', '', 0,0,0
	UNION ALL SELECT @RefDate, 'FixedIn', '', '', 0,0,0


SELECT	DetsDate
		, 'BySecGroup' AS Class
		, SecurityGroup AS Typ
		, 'NetExp' AS Calc
		, SUM(NetExp) AS Val
FROM	#Base
GROUP BY	DetsDate
			, SecurityGroup
UNION
SELECT	DetsDate
		, 'BySecGroup' 
		, SecurityGroup 
		, 'GrossExp' 
		, SUM(ABS(NetExp)) AS Val
FROM	#Base
GROUP BY	DetsDate
			, SecurityGroup
UNION
SELECT	DetsDate
		, 'BySecGroup'
		, SecurityGroup 
		, 'RiskShare' 
		, SUM(RiskShare) AS Val
FROM	#Base
GROUP BY	DetsDate
			, SecurityGroup
--
UNION 
SELECT	DetsDate
		, 'ByFundType'
		, FundType
		, 'NetExp'
		, SUM(NetExp) AS Val
FROM	#Base
WHERE	Asset = 'Funds'
GROUP BY	DetsDate
			, FundType
UNION 
SELECT	DetsDate
		, 'ByFundType'
		, FundType
		, 'GrossExp'
		, SUM(ABS(NetExp)) AS Val
FROM	#Base
WHERE	Asset = 'Funds'
GROUP BY	DetsDate
			, FundType
UNION 
SELECT	DetsDate
		, 'ByFundType'
		, FundType
		, 'RiskShare'
		, SUM(RiskShare) AS Val
FROM	#Base
WHERE	Asset = 'Funds'
GROUP BY	DetsDate
			, FundType		 
--SELECT * FROM #Base

DROP Table #Base
GO

GRANT EXECUTE ON spS_GetFoFTypeLoading1Y TO [OMAM\StephaneD]