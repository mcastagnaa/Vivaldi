USE Vivaldi
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_CleanFundamentals]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spU_CleanFundamentals]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spU_CleanFundamentals] 

AS
SET NOCOUNT ON;

DECLARE @RefDate AS Datetime
SET @RefDate = (SELECT MAX(PriceDate) FROM tbl_AssetPrices)

UPDATE	tbl_AssetPrices
SET 	Beta = Null
	, ROE = Null
	, EPSGrowth = Null
	, SalesGrowth = Null
	, BtP = Null
--	, DivYield = Null
--	, EarnYield = Null
	, StP = Null
	, EbitdaTP = Null
	, MktCapLocal = Null
	, [Size] = Null
	, [Value] = Null
	, MktCapUSD = Null
WHERE	SecurityGroup<>'Equities'
	AND PriceDate = @RefDate


UPDATE	tbl_AssetPrices
SET 	CountryISO = 'FR'
WHERE	SecurityType='BondFut'
	AND SecurityId like 'OAT%'
	AND PriceDate = @RefDate	

UPDATE tbl_AssetPrices
SET Size = 'Mid'
WHERE SecurityId = 'MCIX'

UPDATE tbl_AssetPrices
SET Size = 'Big'
WHERE SecurityType IN ('IndexFut', 'IndexOpt')

GO

GRANT EXECUTE ON spU_CleanFundamentals TO [OMAM\StephaneD]
