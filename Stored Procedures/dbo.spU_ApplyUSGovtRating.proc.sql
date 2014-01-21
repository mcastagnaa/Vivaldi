USE Vivaldi
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_ApplyUSGovtRating]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spU_ApplyUSGovtRating]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spU_ApplyUSGovtRating] 
	@RefDate datetime

AS
SET NOCOUNT ON;

UPDATE tbl_AssetPrices
SET CountryISO = 'IT'
WHERE	SecurityId LIKE 'IK__ Comdty'
		AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AA+', CollType = 'BONDS'
WHERE	CountryISO = 'US'
	AND IndustrySector = 'Government'
	AND SecType = 'US GOVERNMENT'
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AA+'
WHERE	CountryISO in ('FR')
	AND SecurityType IN ('BondFut', 'BondFutOpt')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AA+'
WHERE	CountryISO in ('FR')
	AND SecurityType IN ('Bonds')
	AND IndustrySector IN ('Government')
	AND	IndustryGroup IN  ('Sovereign')
	AND SPRating IN ('NR', '#N/A N/A')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AAA'
WHERE	CountryISO in ('DE')
	AND SecurityType IN ('BondFut', 'BondFutOpt')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AA+'
WHERE	CountryISO in ('US')
	AND SecurityType IN ('BondFut', 'BondFutOpt')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AA-'
WHERE	CountryISO in ('JP')
	AND SecurityType IN ('BondFut', 'BondFutOpt')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AA-'
WHERE	CountryISO in ('JP')
	AND SecurityType IN ('Bonds')
	AND IndustrySector IN ('Government')
	AND IndustryGroup IN  ('Sovereign')
	AND SPRating IN ('NR', '#N/A N/A')
	AND PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'BBB+'
WHERE	CountryISO in ('IT')
	AND SecurityType IN ('BondFut', 'BondFutOpt')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AAA'
WHERE	CountryISO in ('GB')
	AND (SecurityType IN ('TBills') OR (SecurityGroup = 'FixedIn' AND Description like 'UKT%'))
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AAA'
WHERE	CountryISO in ('GB')
	AND SecurityType IN ('BondFut', 'BondFutOpt')
	AND  PriceDate = @RefDate

UPDATE	tbl_AssetPrices
SET 	SPRating = 'AAA'
WHERE	CountryISO in ('DE', 'NL')
	AND SecurityType IN ('Bonds')
	AND IndustrySector IN ('Government')
	AND	IndustryGroup IN  ('Sovereign')
	AND SPRating IN ('NR', '#N/A N/A')
	AND  PriceDate = @RefDate

GO

GRANT EXECUTE ON spU_ApplyUSGovtRating TO [OMAM\StephaneD]