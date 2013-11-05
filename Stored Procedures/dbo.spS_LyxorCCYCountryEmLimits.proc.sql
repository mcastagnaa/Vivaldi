USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_LyxorCCYCountryEmLimits]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_LyxorCCYCountryEmLimits]
GO

CREATE PROCEDURE [dbo].[spS_LyxorCCYCountryEmLimits] 
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
	)	

------------------------------------------------------------------------------------------

INSERT INTO #RawData
EXEC spS_GenerateFundDetailsByDate @RefDate, @FundID, @LiqPerc

------------------------------------------------------------------------------------------

SELECT	RawD.AssetCCY
	, Funds.FundCode
	, SUM(RawD.PortfolioShare) AS NetExposure

INTO	#CCYExp

FROM	#RawData AS RawD, tbl_Funds AS Funds

GROUP BY	RaWD.AssetCCY
		, RawD.FundBaseCCYCode
		, Funds.FundCode
		, Funds.Id

HAVING	AssetCCY <> FundBaseCCYCode
	AND Funds.Id = @FundID

------------------------------------------------------------------------------------------

SELECT	RawData.CountryISO
	, Funds.FundCode
	, SUM(PortfolioShare) AS NetExposure

INTO	#EMExposure
FROM	#RawData AS RawData LEFT JOIN
	tbl_CountryCodes AS EnumCtries ON (
		RawData.CountryISO = EnumCtries.ISOCode
	)
	, tbl_Funds AS Funds 

GROUP BY	RawData.CountryISO
		, EnumCtries.IsLxEm
		, Funds.FundCode
		, Funds.Id

HAVING	EnumCtries.IsLxEm = 1
	AND Funds.Id = @FundId

------------------------------------------------------------------------------------------

SELECT	SUM(NetExposure) AS Exposure
	, FundCode
	, 'LxEMNetExp' AS LimitCode
	, 11 AS LimitId
FROM	#EMExposure
GROUP BY FundCode

UNION
SELECT	SUM(ABS(NetExposure))
	, FundCode
	, 'LxEMGrossExp'
	, 10
FROM	#EMExposure
GROUP BY FundCode

UNION
SELECT 	SUM(ABS(NetExposure))
	, FundCode
	, 'LxCCYRisk'
	, 12
FROM	#CCYExp
GROUP BY FundCode



------------------------------------------------------------------------------------------
DROP TABLE #RawData
DROP TABLE #CCYExp
DROP TABLE #EMExposure
------------------------------------------------------------------------------------------
GO

GRANT EXECUTE ON spS_LyxorCCYCountryEmLimits TO [OMAM\StephaneD], [OMAM\MargaretA]