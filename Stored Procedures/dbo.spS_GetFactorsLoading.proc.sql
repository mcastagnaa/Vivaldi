USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetFactorsLoading]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetFactorsLoading]
GO

CREATE PROCEDURE [dbo].[spS_GetFactorsLoading] 
	@RefDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;


SELECT	StatDate
	, FactorType AS Factor
	, Sum(Abs(Net)) AS GrossFactorExposure
INTO	#FactorsLoads
FROM	tbl_FundsFactorsLoads
WHERE	FundId = @FundId
	AND StatDate > DATEADD(month,-3,@RefDate)
GROUP BY	StatDate
		, FactorType
ORDER BY	StatDate


--------------------------------------------------------

SELECT	Factor
	, AVG(GrossFactorExposure) AS FactorAvg
INTO	#FactorAvgs
FROM	#FactorsLoads
GROUP BY	Factor


--------------------------------------------------------

SELECT	*
INTO	#PivotData
FROM 	(SELECT	StatDate, Factor, GrossFactorExposure
	FROM	#FactorsLoads) o
PIVOT	(SUM(GrossFactorExposure) 
	FOR Factor IN(	
			Beta
			, CompanySize
			, ShortMom
			, ValueType
			)
	) p

--------------------------------------------------------

SELECT	StatDate
	, Beta
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'Beta') AS BetaAvg
	, CompanySize AS Size
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'CompanySize') AS SizeAvg
	, ValueType AS Value
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'ValueType') AS ValueAvg
	, ShortMom AS Reversal
	, (SELECT FactorAvg FROM #FactorAvgs WHERE Factor = 'ShortMom') AS ReversalAvg

FROM	#PivotData

DROP Table #PivotData
DROP Table #FactorsLoads
DROP Table #FactorAvgs

GO

GRANT EXECUTE ON spS_GetFactorsLoading TO [OMAM\StephaneD], [OMAM\MargaretA]