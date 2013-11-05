USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetFactorsTilt]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetFactorsTilt]
GO

CREATE PROCEDURE [dbo].[spS_GetFactorsTilt] 
	@RefDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;


SELECT 	StatDate
	, (CASE FactorName 
		WHEN 'Hi' THEN 'HiVal'
		WHEN 'Low' THEN 'LowVal'
		WHEN 'Mid' THEN CASE FactorType
					WHEN 'ValueType' THEN 'MidVal'
					ELSE 'Mid'
				END
		ELSE FactorName
	END) AS NewFactorName
	, Net
INTO	#NewFactorsLoads
FROM	tbl_FundsFactorsLoads
WHERE	FundId = @FundID
	AND StatDate > DATEADD(month,-3,@RefDate)
	AND StatDate <= @RefDate

----------------------------------------------------------------------------

SELECT	*
INTO	#PivotData
FROM 	#NewFactorsLoads
PIVOT	(SUM(Net) 
	FOR NewFactorName IN(	
			HiBeta
			, LowBeta
			, Big
			, Mid
			, Small
			, Up
			, Down
			, HiVal
			, MidVal
			, LowVal
			)
	) p


----------------------------------------------------------------------------

SELECT	StatDate
	, ISNULL(HiBeta,0)-ISNULL(LowBeta,0) AS HiBetaTilt
	, ISNULL(Big,0)-ISNULL(Mid,0)-ISNULL(Small,0) AS BmMSTilt
	, ISNULL(Up,0)-ISNULL(Down,0) AS UmDTilt
	, ISNULL(HiVal,0)-ISNULL(LowVal,0) AS HMLTilt
INTO #FactorsTilt
FROM #PivotData 

----------------------------------------------------------------------------

SELECT	AVG(HiBetaTilt) AS AvgHBetaTlt
	, AVG(BmMSTilt) AS AvgBmMSTlt
	, AVG(UmDTilt) AS AvgUmDTlt
	, AVG(HMLTilt) AS AvgHMLTlt
INTO #FactorsTiltAvgs
FROM #FactorsTilt

----------------------------------------------------------------------------

SELECT 	StatDate
	, HiBetaTilt
	, AvgHBetaTlt
	, BmMSTilt
	, AvgBmMSTlt
	, UmDTilt
	, AvgUmDTlt
	, HMLTilt
	, AvgHMLTlt

FROM #FactorsTilt, #FactorsTiltAvgs

ORDER BY StatDate


----------------------------------------------------------------------------
DROP Table #NewFactorsLoads
DROP Table #PivotData
DROP Table #FactorsTilt
DROP Table #FactorsTiltAvgs

GO

GRANT EXECUTE ON spS_GetFactorsTilt TO [OMAM\StephaneD], [OMAM\MargaretA]