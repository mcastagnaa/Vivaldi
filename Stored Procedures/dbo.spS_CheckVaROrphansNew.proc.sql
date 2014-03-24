USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_CheckVaROrphansNew]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_CheckVaROrphansNew]
GO

CREATE PROCEDURE [dbo].[spS_CheckVaROrphansNew] 
	@RefDate datetime
AS

SET NOCOUNT ON;


SELECT	Funds.Id AS FundId
	, Funds.FundCode
	, Positions.SecurityType
	, Positions.PositionDate
	, Positions.PositionId
	, Prices.IDBloomberg AS BBGId

INTO	#Test1

FROM 	tbl_Positions AS Positions 
		JOIN 
	tbl_Funds AS Funds ON (
	Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_AssetPrices AS Prices ON (
	Positions.PositionId = Prices.SecurityId
	AND Positions.PositionDate = Prices.PriceDate
	AND Positions.SecurityType = Prices.SecurityType
		) 


WHERE	Positions.PositionDate = @RefDate
		AND Funds.Skip = 0
		AND Funds.Alive = 1

-----------------------------------------------------------------------------------

SELECT	VARs.MargVaR
	, VARs.FundId
	, VARS.ReportDate
	, VARS.ReportId
	, VARS.BBGInstrId AS BBGid
	, VARS.SecTicker
	, VARReports.IsRelative

INTO	#VARs


FROM	tbl_VaRReports AS VARs JOIN
	tbl_enumVaRReports AS VARReports ON (
	VARReports.Id = VARs.ReportId
	)

WHERE	VARS.ReportDate = @RefDate
	AND VARReports.IsRelative = 0



-----------------------------------------------------------------------------------


SELECT	Test1.FundId
	, Test1.FundCode
	, Test1.PositionId
	, Test1.SecurityType
	, Test1.PositionDate
	, Test1.BBGId
	, VaRs.MargVaR
	, VARs.ReportId

INTO	#FailsPositionsIntoVaR

FROM	#Test1 AS Test1 LEFT JOIN
	#VARS AS VARs ON (
	Test1.BBGId = VARs.BBGId
	AND Test1.FundId = VARS.FundId
	AND Test1.PositionDate = VaRS.ReportDate
	)

WHERE	VaRs.MargVAR is null
	AND Test1.FundId not in (2, 46, 17, 92, 65, 66, 67, 78, 137
			, 138, 139, 141, 142, 143, 144, 145)
		-- AS5, AS17, GEMPLUS, OMTSY, UTIMCOs
	AND Test1.PositionId not in ('6339162', 'B08K3V3', '9110427', '9190935',
			'B7HKGH0', 'B4558J2', 'B8KLKR5', 'B46J6L1', 'B8Y2Q10', 
			'6268716', '6455886', '6627663')
		-- All excluded from the BBG portfolio upload

ORDER BY Test1.FundId
-----------------------------------------------------------------


SELECT	VaRs.FundId
	, VARS.ReportId
	, VARS.BBGid
	, VARs.SecTicker
	, VaRs.MargVaR


INTO	#FailsVaRIntoPositions

FROM	#Test1 AS Test1 RIGHT JOIN
	#VARS AS VARs ON (
	Test1.BBGId = VARs.BBGId
	AND Test1.FundId = VARS.FundId
	AND Test1.PositionDate = VaRS.ReportDate
	)

WHERE	Test1.PositionId is null
	AND VARS.BBGid <> 'VaRTotal'


-----------------------------------------------------------------

SELECT	FailsA.FundId
	, FailsA.FundCode
	, FailsA.PositionId
	, FailsA.BBGId
	, FailsA.SecurityType
	, FailsA.ReportId
	, 'MissingVaRData' AS TestType

FROM	#FailsPositionsIntoVaR AS FailsA LEFT JOIN
	tbl_VaRRepExceptions AS Exceptions ON
	(FailsA.Positiondate = Exceptions.ReportDate
	AND FailsA.BBGid = Exceptions.BBGInstrId
	AND FailsA.FundId = Exceptions.FundId)

WHERE	EXCEPTIONS.ReasonFail is null


UNION SELECT	FailsB.FundId
	, ''
	, FailsB.SecTicker
	, FailsB.BBGId
	, ''
	, FailsB.ReportId
	, 'MissingPositionData' AS TestType

FROM 	#FailsVaRIntoPositions AS FailsB
WHERE	RIGHT(FailsB.BBGId, 3) <> '_EC'

ORDER BY	TestType, PositionId, FundId

-----------------------------------------------------------------


DROP Table #Test1
DROP Table #VARS
DROP Table #FailsPositionsIntoVaR
DROP Table #FailsVaRIntoPositions


GO

GRANT EXECUTE ON spS_CheckVaROrphansNew TO [OMAM\StephaneD] 