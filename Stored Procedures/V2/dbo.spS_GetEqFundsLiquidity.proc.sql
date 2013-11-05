USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetEqFundsLiquidity') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetEqFundsLiquidity
GO

CREATE PROCEDURE dbo.spS_GetEqFundsLiquidity
	@RefDate datetime
	, @PercDayVol float
AS

SET NOCOUNT ON;


/* Get last date, 1w before and 1m before */

----------------------------------------------------------------------------------
SELECT * INTO #RefD FROM fn_GetCubeDataTable(@RefDate, null)
----------------------------------------------------------------------------------

SELECT	CubeData.FundCode
	, CubeData.FundId
	, COUNT(CubeData.FundId) AS PositionNumber
	, DaysToLiquidate = 
		AVG(NULLIF(
			ABS(CubeData.PositionSize) / 
			(CubeData.ADV * ISNULL(@PercDayVol, CubeData.PercDayVolume))
		, CubeData.ADV))
	, Funds.ADVField
	, ISNULL(@PercDayVol, CubeData.PercDayVolume) AS PercDayVol
	, @RefDate AS RelevantDate

--INTO	
								
FROM	#RefD AS CubeData LEFT JOIN
	tbl_Funds AS Funds ON (
		Funds.Id = CubeData.FundId
		)

WHERE	CubeData.SecurityGroup = 'Equities'
	AND CubeData.IsDerivative = 0
	AND CubeData.ADV is not null
	AND CubeData.PositionSize is not null

GROUP BY CubeData.FundCode
	, CubeData.FundId
	, Funds.ADVField
	, CubeData.PercDayVolume


----------------------------------------------------------------------------------
DROP TABLE #RefD
GO
----------------------------------------------------------------------------------
GRANT EXECUTE ON dbo.spS_GetEqFundsLiquidity TO [OMAM\StephaneD]
