USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_VaRExceptions_V2]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_VaRExceptions_V2]
GO

CREATE PROCEDURE [dbo].[spS_VaRExceptions_V2] 
	@RefDate datetime
	, @FundId int
AS

SET NOCOUNT ON;

------------------------------------------------------------------------------------------
SELECT * INTO #RawData FROM fn_GetCubeDataTable(@RefDate, @FundId)
------------------------------------------------------------------------------------------

SELECT	RawData.FundId AS FundId
	, RawData.PositionDate AS ReportDate
	, Exceptions.SecTicker As Ticker
	, Exceptions.ReasonFail AS Reason
	, Exceptions.Position AS Position
	, RawData.StartPrice AS StartPrice
	, RawData.BaseCCYExposure/NaVs.CostNAV AS PtflWeight
	, RawData.MarketPrice AS MarketPrice
	, RawData.AssetCCY AS CCY
	, RawData.SPCleanRating AS SPRating

FROM	tbl_VaRRepExceptions AS Exceptions LEFT JOIN
	#RawData AS RawData ON
		(Exceptions.SecTicker = RawData.BBGTicker
		AND Exceptions.ReportDate = RawData.PositionDate) LEFT JOIN
	tbl_EnumVaRReports AS VaRReports ON
		(Exceptions.ReportId = VaRReports.ID) LEFT JOIN
	tbl_FundsNaVsAndPls AS NaVs ON (
		Exceptions.ReportDate = NaVs.NaVPLDate
		AND RawData.FundId = NaVs.FundId
		)

WHERE	Exceptions.ReportDate = @RefDate
	AND VaRReports.IsRelative = 0
	AND ((@FundId Is NULL) OR (Exceptions.FundId = @FundId))

-------------------------------------------------------------------------------------------
DROP TABLE #RawData
GO
-------------------------------------------------------------------------------------------

GRANT EXECUTE ON spS_VaRExceptions_V2 TO [OMAM\StephaneD], [OMAM\MargaretA]