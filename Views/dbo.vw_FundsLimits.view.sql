USE VIVALDI
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_FundsLimits]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_FundsLimits]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FundsLimits]
AS

SELECT	EnumLimits.ShortName AS LimitCode
	, Limits.LimitId
	, EnumLimits.LongName As LimitName
	, Limits.FundId
	, Funds.FundCode AS FundCode
	, Funds.FundName As FundName
	, Vehicles.ShortName As FundVehicle
	, Limits.LowerBound
	, Limits.UpperBound
	, Funds.Alive AS FundIsAlive
	, Funds.Skip AS FundIsSkip


FROM	tbl_Limits AS Limits LEFT JOIN
	tbl_EnumLimits AS EnumLimits ON (
		Limits.LimitId = EnumLimits.ID
		) LEFT JOIN
	tbl_Funds AS Funds ON (
		Limits.FundId = Funds.Id
		) LEFT JOIN
	tbl_Vehicles AS Vehicles ON (
		Funds.VehicleId = Vehicles.ID
		)
