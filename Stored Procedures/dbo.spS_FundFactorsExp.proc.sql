USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_FundFactorsExp]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_FundFactorsExp]
GO

CREATE PROCEDURE [dbo].[spS_FundFactorsExp] 
	@RefDate datetime
	, @FundId int 		-- 20
	, @LiqPerc float	-- 0.1
AS

SET NOCOUNT ON;


CREATE TABLE #RawData (
	SecurityGroup		nvarchar(30)
	, PostionValue		float 
	, FundBaseCCYCode 	nvarchar(3)
	, BMISCode             	nvarchar(30)
	, BBGTicker		nvarchar(30)  
	, AssetCCY		nvarchar(3)
	, PositionSize		float                           
	, StartPrice		float                           
	, MarketPrice		float                           
	, AssetEffect		float                           
	, FxEffect		float                           
	, PortfolioShare	float                           
	, AssetPL		float                           
	, FxPL			float                           
	, PositionPL		float                           
	, BpPositionPL		float                           
	, MargVaRPerc		float                     
	, CountryISO		nvarchar(10)
	, CountryName		nvarchar(100)                                                                   
	, CountryRegionName	nvarchar(100)                                                                   
	, IndustrySector	nvarchar(40)       
	, IndustryGroup		nvarchar(40)       
	, SPCleanRating		nvarchar(30)      
	, SPRatingRank		int
	, BondYearsToMaturity	float                      
	, EquityMarketStatus	nvarchar(10)
	, LongShort		nvarchar(20)
	, DaysToLiquidate	float                           
	, RiskOnPtflSh		float                           
	, PlOnRisk		float                           
	, Beta			float                    
	, Size			nvarchar(30)
	, Value			nvarchar(30)
	, IsManualPrice		bit
	, ROE			float
	, EPSGrowth		float
	, SalesGrowth		float
	, BtP			float
	, DivYield		float
	, EarnYield		float
	, StP			float
	, EbitdaTP		float
	, MktCapLocal		float
	, MktCapUSD		float
	, KRD3m			float
	, KRD6m			float
	, KRD1y			float
	, KRD2y			float
	, KRD3y			float
	, KRD4y			float
	, KRD5y			float
	, KRD6y			float
	, KRD7y			float
	, KRD8y			float
	, KRD9y			float
	, KRD10y		float
	, KRD15y		float
	, KRD20y		float
	, KRD25y		float
	, KRD30y		float
	, EffDur		float
	, InflDur		float
	, RealDur		float
	, SpreadDur		float
	, CoupType		nvarchar(30)
	, Bullet		bit
	, SecType		nvarchar(30)
	, CollType		nvarchar(30)
	, MktSector		nvarchar(20)
	, ShortMom		float
	, UpDown		nvarchar(5)
	, AssetPlBps		float
	, FxPlBps		float
	, Delta			float
	, Underlying		nvarchar(30)
	, UnderSize		float
	, UnderNotional		float
	)	

------------------------------------------------------------------------------------------
INSERT INTO #RawData
EXEC spS_GenerateFundDetailsByDate @RefDate, @FundID, @LiqPerc
------------------------------------------------------------------------------------------


SELECT	*
INTO #SMBExp
FROM (	SELECT	PortfolioShare, LongShort, Size 
	FROM #RawData
	WHERE len(Size)>0 ) o
PIVOT (SUM(PortfolioShare) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #HMLExp
FROM (	SELECT	PortfolioShare, LongShort, Value 
	FROM #RawData
	WHERE len(Value)>0) o
PIVOT (SUM(PortfolioShare) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #UMDExp
FROM (	SELECT	PortfolioShare, LongShort, UpDown 
	FROM #RawData
	WHERE UpDown is not null) o
PIVOT (SUM(PortfolioShare) FOR LongShort IN(	[Long]
					, [Short]
					)) p

SELECT	*
INTO #BetaExp
FROM (	SELECT	PortfolioShare, LongShort, 
	BetaType = CASE WHEN Beta >= 1 THEN 'HiBeta' 
			WHEN Beta < 1 THEN 'LowBeta'
	END
	FROM #RawData
	WHERE Beta is not null
		AND BETA <> 0) o
PIVOT (SUM(PortfolioShare) FOR LongShort IN(	[Long]
					, [Short]
					)) p


------------------------------------------------------------------------------------------

SELECT 	'CompanySize' AS FactorType
	, Size As FactorName
	, ISNULL(Long, 0) AS Long
	, ISNULL(-Short,0) AS Short
	, ISNULL(Long, 0) + ISNULL(Short,0) as Net
FROM #SMBExp

UNION
SELECT 	'ValueType' AS FactorType
	, Value
	, ISNULL(Long, 0)
	, ISNULL(-Short,0)
	, ISNULL(Long, 0) + ISNULL(Short,0)
FROM #HMLExp

UNION
SELECT 	'ShortMom' AS FactorType
	, UpDown
	, ISNULL(Long, 0)
	, ISNULL(-Short,0)
	, ISNULL(Long, 0) + ISNULL(Short,0)
FROM #UMDExp

UNION
SELECT 	'Beta' AS FactorType
	, BetaType
	, ISNULL(Long, 0)
	, ISNULL(-Short,0)
	, ISNULL(Long, 0) + ISNULL(Short,0)
FROM #BetaExp


------------------------------------------------------------------------------------------
DROP TABLE #RawData
DROP TABLE #HMLExp
DROP TABLE #SMBExp
DROP TABLE #UMDExp
DROP TABLE #BetaExp

------------------------------------------------------------------------------------------
GO

GRANT EXECUTE ON spS_FundFactorsExp TO [OMAM\StephaneD], [OMAM\MargaretA]