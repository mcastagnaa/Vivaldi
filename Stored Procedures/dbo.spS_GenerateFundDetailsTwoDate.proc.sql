USE Vivaldi
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GenerateFundDetailsTwoDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_GenerateFundDetailsTwoDate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_GenerateFundDetailsTwoDate] 
	@RefDate1 datetime, 
	@RefDate2 datetime, 
	@FundId Int
AS
SET NOCOUNT ON;

/*DECLARE @RefDate1 datetime
DECLARE	@RefDate2 datetime
DECLARE	@FundId Int

SET @RefDate1 = '2009-9-17'
SET @RefDate2 = '2009-9-16'
SET @FundId = 18*/

SELECT 	Positions.PositionDate AS PositionDate,
	Positions.PositionId AS PositionId,
	Funds.Id AS FundId,
	Positions.FundShortName AS FundCode,
	FundsCCY.ISO3 AS FundBaseCCYCode,
	Positions.SecurityType AS SecurityType,
	Assets.SecurityGroup AS SecurityGroup,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGName,
	Assets.ShortName AS BondIssuer,
	Positions.Units AS PositionSize,
	Positions.StartPrice AS StartPrice,
	Assets.CCYIso AS AssetCCY,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Regions.RegionName As CountryRegionName,
	Assets.IndustrySector AS IndustrySector,
	Assets.IndustryGroup AS IndustryGroup,
	Ratings.CleanRating AS SPCleanRating,
	Assets.YearsToMaturity AS BondYearsToMaturity,
	Assets.MarketStatus AS EquityMarketStatus

INTO	#RawData1

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_CcyDetails AS FundsCCY ON (
		Funds.BaseCCYId = FundsCCY.Id
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_CountryCodes AS Country ON (
		Assets.CountryISO = Country.ISOCode
		) LEFT JOIN
	tbl_RegionsCodes AS Regions ON (
		Country.RegionId = Regions.ID
		) LEFT JOIN
	tbl_SPRatingsCodes AS Ratings ON (
		Assets.SPRating = Ratings.RatingSPBB
		) 
	
WHERE 	Assets.PriceDate = @RefDate1 AND
	Funds.Id = @FundId AND
	Assets.CCYIso <> '---'

----------------------------------------------------------------------------------

SELECT 	Positions.PositionDate AS PositionDate,
	Positions.PositionId AS PositionId,
	Funds.Id AS FundId,
	Positions.FundShortName AS FundCode,
	FundsCCY.ISO3 AS FundBaseCCYCode,
	Positions.SecurityType AS SecurityType,
	Assets.SecurityGroup AS SecurityGroup,
	Positions.PositionId AS BMISCode,
	Assets.IDBloomberg AS BBGId,
	Assets.Description AS BBGName,
	Assets.ShortName AS BondIssuer,
	Positions.Units AS PositionSize,
	Positions.StartPrice AS StartPrice,
	Assets.CCYIso AS AssetCCY,
	Assets.CountryISO AS CountryISO,
	Country.CountryName AS CountryName,
	Regions.RegionName As CountryRegionName,
	Assets.IndustrySector AS IndustrySector,
	Assets.IndustryGroup AS IndustryGroup,
	Ratings.CleanRating AS SPCleanRating,
	Assets.YearsToMaturity AS BondYearsToMaturity,
	Assets.MarketStatus AS EquityMarketStatus

INTO	#RawData2

FROM 	tbl_Positions AS Positions LEFT JOIN
	tbl_Funds AS Funds ON (
		Positions.FundShortName = Funds.FundCode
		) LEFT JOIN
	tbl_CcyDetails AS FundsCCY ON (
		Funds.BaseCCYId = FundsCCY.Id
		) LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionId = Assets.SecurityId AND
		Positions.PositionDate = Assets.PriceDate AND
		Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_CountryCodes AS Country ON (
		Assets.CountryISO = Country.ISOCode
		) LEFT JOIN
	tbl_RegionsCodes AS Regions ON (
		Country.RegionId = Regions.ID
		) LEFT JOIN
	tbl_SPRatingsCodes AS Ratings ON (
		Assets.SPRating = Ratings.RatingSPBB
		) 
	
WHERE 	Assets.PriceDate = @RefDate2 AND
	Funds.Id = @FundId AND
	Assets.CCYIso <> '---'


----------------------------------------------------------------------------------

SELECT	ALL Set1.FundCode,
	Set1.BMISCode,
	Set1.BBGName,
	Set1.StartPrice,
	Set1.SecurityType,
	Set1.AssetCCY,
	Set1.PositionSize AS Date1Position,
	Set2.PositionSize AS Date2Position,
	ISNULL(Set1.PositionSize,0) - ISNULL(Set2.PositionSize,0) AS PositionDifference,
	PositionPercDiff = 
		CASE
			WHEN Set2.PositionSize IS NOT NULL AND Set2.PositionSize <> 0 THEN
				ISNULL(Set1.PositionSize,0)/Set2.PositionSize - 1
			ELSE
				NULL
		END,
	Set1.CountryName,
	Set1.CountryRegionName,
	Set1.IndustrySector,
	Set1.IndustryGroup,
	Set1.SPCleanRating,
	Set1.BondYearsToMaturity,
	Set1.EquityMarketStatus

FROM	#RawData1 AS Set1 LEFT JOIN
	#RawData2 AS Set2 ON (
		Set1.BMIScode=Set2.BMISCode
		AND Set1.SecurityType = Set2.SecurityType
		)
WHERE	(Set1.PositionSize - Set2.PositionSize) <> 0 OR
		Set2.PositionSize IS NULL

UNION

SELECT	ALL Set2.FundCode,
	Set2.BMISCode,
	Set2.BBGName,
	Set2.StartPrice,
	Set2.SecurityType,
	Set2.AssetCCY,
	Set1.PositionSize AS Date1Position,
	Set2.PositionSize AS Date2Position,
	ISNULL(Set1.PositionSize,0) - ISNULL(Set2.PositionSize,0) AS PositionDifference,
	PositionPercDiff = 
		CASE
			WHEN Set2.PositionSize IS NOT NULL AND Set2.PositionSize <> 0 THEN
				ISNULL(Set1.PositionSize,0)/Set2.PositionSize - 1
			ELSE
				NULL
		END,
	Set2.CountryName,
	Set2.CountryRegionName,
	Set2.IndustrySector,
	Set2.IndustryGroup,
	Set2.SPCleanRating,
	Set2.BondYearsToMaturity,
	Set2.EquityMarketStatus

FROM	#RawData2 AS Set2 LEFT JOIN
	#RawData1 AS Set1 ON (
		Set2.BMIScode=Set1.BMISCode
		AND Set2.SecurityType = Set1.SecurityType
		)
WHERE	Set1.PositionSize IS NULL


----------------------------------------------------------------------------------

DROP Table #RawData1
DROP Table #RawData2

GO

GRANT EXECUTE ON spS_GenerateFundDetailsTwoDate TO [OMAM\StephaneD], [OMAM\MargaretA]