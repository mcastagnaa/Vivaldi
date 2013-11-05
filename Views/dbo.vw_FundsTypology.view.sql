USE Vivaldi
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_FundsTypology]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_FundsTypology]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FundsTypology]
AS

SELECT 	Funds.Id AS FundId
	, Funds.Alive AS IsAlive
	, Funds.Skip AS IsSkip
	, Funds.FundCode AS FundCode
	, Funds.FUndName AS FundName
	, CCYs.ISO3 AS BaseCCY
	, VaRModels.ShortName + ' ' + 
		CAST(Funds.ConfidenceInt AS nvarchar(10)) + ' ' +
		Funds.Horizon AS VaRModelDetails
	, Funds.ConfidenceInt
	, ZScores.ZScore
	, FundClasses.ShortName AS FundClass
	, Benchm.ShortName AS Benchmark
	, Vehicles.ShortName AS VehicleCode
	, Vehicles.LongName AS VehicleName
	, VehicleStrategies.ShortName AS VehicleStrategyCode
	, VehicleStrategies.LongName AS VehicleStrategyName
	, RefFunds.FundCode AS ReferenceFund
	, Styles.ShortName AS StyleCode
	, Styles.LongName AS StyleName
	, Benchm.LongName AS BenchLong
	, Benchm.ID AS BenchId
	, BackOffices.ShortName AS BackOffice
	, Funds.BaseCCYId
	, Funds.VaRModelId
	, Funds.FundClassId
	, Funds.BenchmarkId
	, BenchmSources.Id AS BchmSourceId
	, BenchmSources.ShortName AS BchmSourceName
	, Funds.VehicleId
	, Funds.VehStrategyId
	, Funds.RefFund AS RefFundId
	, Funds.BackOfficeId
	, Funds.StyleId
	, Funds.ReportInUse AS ReportId
	, Funds.PercDayVol
	, Funds.AdvField
	, Funds.SectorsDef
	, Reports.ReportName AS ReportName
	, Reports.Description AS ReportDescription
	, People.Name + ' ' + People.Surname AS HoDLongName
	, People.ShortCode AS HoDCode

	
FROM 	tbl_funds AS Funds LEFT JOIN
	tbl_CcyDetails AS CCYs ON (
		Funds.BaseCCYId = CCYs.ID
		) LEFT JOIN
	tbl_VaRModels AS VaRModels ON (
		Funds.VaRModelId = VaRModels.Id
		) LEFT JOIN
	tbl_FundClasses AS FundClasses ON (
		Funds.FundClassId = FundClasses.ID
		) LEFT JOIN
	tbl_Vehicles AS Vehicles ON (
		Funds.VehicleId = Vehicles.ID
		) LEFT JOIN
	tbl_VehicleStrategies AS VehicleStrategies ON (
		Funds.VehStrategyId = VehicleStrategies.ID
		) LEFT JOIN
	tbl_Funds AS RefFunds ON (
		Funds.RefFund = RefFunds.ID
		) LEFT JOIN 
	tbl_BackOffices As BackOffices ON (
		Funds.BackOfficeId = BackOffices.ID
		) LEFT JOIN
	tbl_FundStyles AS Styles ON (
		Funds.StyleId = Styles.ID
		) LEFT JOIN
	tbl_Benchmarks AS Benchm ON (
		Funds.BenchmarkId = Benchm.Id
		) LEFT JOIN
	tbl_EnumSingleFundReports AS Reports ON (
		Funds.ReportInUse = Reports.Id
		) LEFT JOIN
	tbl_ZScores AS ZScores ON (
		Funds.ConfidenceInt = ZScores.Probability
		) LEFT JOIN
	tbl_BenchmarksSources AS BenchmSources ON (
		BenchmSources.ID = Benchm.SourceId
		) LEFT JOIN
	tbl_FundsPeopleRoles AS Roles ON (
		Funds.Id = Roles.FundId
		) LEFT JOIN
	tbl_People AS People ON (
		People.ID = Roles.peopleId
		)
	

WHERE (Roles.RoleId = 1 OR Roles.RoleId is null)
	AND Funds.FundCode not like '%TEST%'
	
-- Funds.Alive = 1
--	AND Funds.Skip = 0


