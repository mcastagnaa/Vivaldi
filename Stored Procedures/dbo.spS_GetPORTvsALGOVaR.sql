USE Vivaldi;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetPORTvsALGOVaR') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetPORTvsALGOVaR
GO

CREATE PROCEDURE dbo.spS_GetPORTvsALGOVaR
AS

SET NOCOUNT ON;
-----------------------------------------------------------------------
/* 
TO-DO LIST
*/


SELECT 'PORTVaR' AS Source
		, PORT.* 
		, -PORT.PL/PORT.DollarVAR AS AbsPLtoVARRatio
		, DETS.SumPortWeights AS TotWeight
		, DETS.SumMarg
		, DETS.SumMarg * 100/PORT.DollarVaR AS MargTotalRatio
		, DETS.ExceptionsCount AS Exptns
INTO	#TEMPAbsVaR
FROM	vw_TotalVaRByFundByDatePORT AS PORT  LEFT JOIN
		vw_VaRByFundByDatePORTDets AS DETS ON (
			PORT.ReportId = DETS.ReportId
			AND PORT.VaRDate = DETS.ReportDate
			)
UNION 
SELECT 'ALGOVaR'
		, ALGO.*
		, -ALGO.PL/ALGO.DollarVAR AS AbsPLtoVARRatio
		, null
		, null
		, null
		, null
FROM vw_TotalVaRByFundByDatePORT AS PORT LEFT JOIN
	vw_TotalVaRByFundByDate AS ALGO ON (
		PORT.FundId = ALGO.FundId
		AND PORT.ReportId = ALGO.ReportId
		AND PORT.VaRdate = ALGO.VaRdate
		)
WHERE	PORT.FundId IS NOT NULL 

SELECT * FROM #TEMPAbsVaR AS TEMP
WHERE	TEMP.FundId > 0 
ORDER BY	TEMP.FundId, TEMP.VaRDate, TEMP.Source


DROP TABLE #TEMPAbsVaR
-----------------------------------------------------------------------

GO

GRANT EXECUTE ON dbo.spS_GetPORTvsALGOVaR TO [OMAM\Compliance]