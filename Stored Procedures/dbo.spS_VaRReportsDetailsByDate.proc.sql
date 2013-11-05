USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_VaRReportsDetailsByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_VaRReportsDetailsByDate]
GO

CREATE PROCEDURE [dbo].[spS_VaRReportsDetailsByDate] 
	@RefDate datetime
	, @Months integer
AS

SET NOCOUNT ON;

SELECT 	Positions.PositionDate AS PositionDate
	, Funds.Id AS FundId
	, Funds.ConfidenceInt
	, Positions.FundShortName AS FundCode
	, MAX(Assets.Description) AS AssetDescription
	, MAX(Assets.ShortName) AS AssetShortName
	, MAX(Assets.IDBloomberg) AS BBGUniqueId
	, BMISAssets.SecGroup AS SecurityGroup
	, Veh.ShortName AS Vehicle

INTO	#RawData

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_BMISAssets AS BMISAssets ON (
		Positions.SecurityType = BMISAssets.AssetName
		) LEFT JOIN
	tbl_Vehicles AS Veh ON (
		Funds.VehicleId = Veh.Id
		)
	
WHERE 	Assets.PriceDate = @RefDate AND
	Assets.CCYIso <> '---'
	AND Funds.Alive = 1
	AND Funds.Skip = 0

GROUP BY	Positions.PositionDate
		, Funds.Id
		, Funds.Alive
		, Funds.Skip
		, Positions.FundShortName
		, Assets.IDBloomberg
		, Assets.Description
		, Assets.ShortName
		, Assets.Accrual1dBond
		, BMISAssets.SecGroup
		, Funds.ConfidenceInt
		, Veh.ShortName

-------------------------------------------------------------

SELECT	VaRReports.MargVaR as MVaR
	, RawData.*

INTO	#MainTable

FROM	tbl_VaRReports AS VaRReports RIGHT JOIN
	#RawData AS RawData
	 ON (
		VaRReports.FundId = RawData.FundId
		AND VaRReports.BBGInstrId = RawData.BBGUniqueId 
		AND VaRReports.ReportDate = RawData.PositionDate
		) LEFT JOIN
	tbl_EnumVaRReports AS EnumVaRReports ON (
		VaRReports.ReportId = EnumVaRReports.Id
		)
	
WHERE	EnumVaRReports.IsRelative = 0
	AND VaRReports.SecTicker <> 'Totals'

-------------------------------------------------------------

SELECT	COUNT(Exceptions.ID) AS ExceptionsNo
	, Funds.Id AS FundID

INTO	#Exceptions

FROM	tbl_VaRRepExceptions AS Exceptions LEFT JOIN
	tbl_Funds AS Funds ON (
		Exceptions.FundId = Funds.Id
		) LEFT JOIN
	tbl_EnumVaRReports AS EnumVaR ON (
		Exceptions.ReportId = EnumVaR.Id
		)

WHERE	Exceptions.ReportDate = @RefDate
	AND EnumVaR.IsRelative = 0

GROUP BY	Funds.Id

-------------------------------------------------------------

SELECT	COUNT(VaRReports.VaRDate) AS ObservationsCount
	, VaRReports.FundId AS FundID

INTO	#VaRReportsCount

FROM	vw_TotalVaRByFundByDate AS VaRReports

WHERE	VaRReports.VaRDate >= dateadd(month, -@Months, @RefDate)
	AND VaRReports.VaRDate <= @RefDate
	
GROUP BY	VaRReports.FundId


-------------------------------------------------------------

SELECT	COUNT(VaRReports.VaRDate) AS AbsVaREventsCount
	, VaRReports.FundId AS FundID

INTO	#AbsVaREventsCounts

FROM	vw_TotalVaRByFundByDate AS VaRReports

WHERE	ABS(VaRReports.PL) > DollarVaR
	AND VaRReports.VaRDate >= dateadd(month, -@Months, @RefDate)
	AND VaRReports.VaRDate <= @RefDate
	
GROUP BY	VaRReports.FundId


-------------------------------------------------------------

SELECT	COUNT(VaRReports.VaRDate) AS VaREventsCount
	, VaRReports.FundId AS FundID

INTO	#VaREventsCounts

FROM	vw_TotalVaRByFundByDate AS VaRReports

WHERE	VaRReports.PL < -DollarVaR
	AND VaRReports.VaRDate >= dateadd(month, -@Months, @RefDate)
	AND VaRReports.VaRDate <= @RefDate

GROUP BY	VaRReports.FundId


-------------------------------------------------------------

SELECT	STDEV(
		(VarReports.PL * ZScores.ZScore) / VaRReports.DollarVaR
		) AS ChiTest
	, VaRReports.FundId AS FundID

INTO	#ChiTestValues

FROM	vw_TotalVaRByFundByDate AS VaRReports LEFT JOIN
	tbl_ZScores AS ZScores ON (
		VarReports.VaRConfidence = ZScores.Probability
		)

WHERE	VaRReports.VaRDate >= dateadd(month, -@Months, @RefDate)
	AND VaRReports.VaRDate <= @RefDate

GROUP BY	VaRReports.FundId


-------------------------------------------------------------


SELECT	 MainTable.FundCode AS FundCode
	, MainTable.ConfidenceInt
	, COUNT(MainTable.BBGUniqueId) AS RiskPositionsCount
	, MainVaRReports.DollarVaR AS TotalVaR
	, MainVaRReports.NAV
	, MainVaRReports.DollarVaR/MainVaRReports.NAV AS VaRPerc
	, Exceptions.ExceptionsNo AS Exceptions
	, VaRReportsCount.ObservationsCount AS Observations
	, SUM(MainTable.MVaR) * 100 AS TotalMargVaR
	, GoodMargVaRReport = 
		CASE
		WHEN	(ROUND(SUM(MainTable.MVaR) * 100,0) / 
				ROUND(MainVaRReports.DollarVaR,0)) BETWEEN 0.98 AND 1.02 THEN 1
		ELSE 0
		END
	, AbsVaREventsCounts.AbsVaREventsCount AS ABSVaREvents
	, VaREventsCounts.VaREventsCount AS VaREvents
	, FLOOR(VaRReportsCount.ObservationsCount * (1 - MainTable.ConfidenceInt)) AS Expected
	, ChiTestValues.ChiTest AS ChiTestStat
	, (1 - ChiTestValues.ChiTest) AS OverUnderEstimate
	, MainTable.FundId AS FundID
	--, AS ChiTestLowBound
	--, AS ChiTestHiBound
	--, AS VaRModelPass
	, MainTable.Vehicle

FROM	#MainTable AS MainTable LEFT JOIN
	vw_TotalVaRByFundByDate AS MainVaRReports ON (
		MainTable.FundID = MainVaRReports.FundId
		AND MainTable.PositionDate = MainVaRReports.VaRDate
		) LEFT JOIN
	#Exceptions AS Exceptions ON (
		MainTable.FundID = Exceptions.FundID
		) LEFT JOIN
	#VaRReportsCount AS VaRReportsCount ON (
		MainTable.FundID = VaRReportsCount.FundId
		) LEFT JOIN
	#AbsVaREventsCounts AS AbsVarEventsCounts ON (
		MainTable.FundID = AbsVarEventsCounts.FundId
		) LEFT JOIN
	#VaREventsCounts AS VarEventsCounts ON (
		MainTable.FundID = VarEventsCounts.FundId
		) LEFT JOIN
	#ChiTestValues AS ChiTestValues ON (
		MainTable.FundID = ChiTestValues.FundId
		)

GROUP BY	MainTable.FundId
		, MainTable.FundCode
		, MainVaRReports.DollarVaR
		, MainVaRReports.NAV
		, Exceptions.ExceptionsNo
		, VaRReportsCount.ObservationsCount
		, MainTable.ConfidenceInt
		, AbsVaREventsCounts.AbsVaREventsCount
		, VaREventsCounts.VaREventsCount
		, ChiTestValues.ChiTest
		, MainTable.Vehicle

----------------------------------------------------------------------------------------------------------

DROP Table #RawData
DROP Table #MainTable
DROP Table #Exceptions
DROP Table #VaRReportsCount
DROP Table #AbsVaREventsCounts
DROP Table #VaREventsCounts
DROP Table #ChiTestValues
----------------------------------------------------------------------------------------------------------

GO

GRANT EXECUTE ON spS_VaRReportsDetailsByDate TO [OMAM\StephaneD]

