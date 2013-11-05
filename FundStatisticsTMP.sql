USE RM_PTFL
GO



DECLARE @RefDate datetime
DECLARE	@FundId Int
DECLARE	@LiqPerc float

SET @RefDate = '2009-9-21'
SET @FundId = 5
SET @LiqPerc = 0.1


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
	)	

------------------------------------------------------------------------------------------

INSERT INTO #RawData
EXEC spS_GenerateFundDetailsByDate @RefDate, @FundID, @LiqPerc

------------------------------------------------------------------------------------------

SELECT	@FundId AS FundId
	, @RefDate AS StatsDates

	-- EQUITIES STATISTICS --
-------------------------------------------------
--- BETAs
	, SUM(Beta * PortfolioShare) AS PortfBeta
	, SUM(Beta * PortfolioShare) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS PortfBetaEqOnly
	, SUM(Beta * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfBetaLong
	, SUM(Beta * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfBetaShort

	, SUM(CASE WHEN MktSector = 'Equity' THEN DaysToLiquidate * ABS(PortfolioShare) 
			ELSE 0 END) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ABS(PortfolioShare)
			ELSE 0 END),0)
		AS AvgDaysToLiquidate
--- ROEs
	, SUM(ROE * PortfolioShare) AS RoE
	, SUM(ROE * PortfolioShare) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END) ,0)
		AS RoEEqOnly
	, SUM(ROE * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfRoELong
	, SUM(ROE * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfRoEShort
--- EPSs
	, SUM(EpsGrowth * PortfolioShare) AS EPSGrowth
	, SUM(EPSGrowth * PortfolioShare)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare 
			ELSE 0 END),0)
		AS EPSGrowthEqOnly
	, SUM(EpsGrowth * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfEPSLong
	, SUM(EpsGrowth * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfEPSShort

--- SalesGrowths
	, SUM(SalesGrowth * PortfolioShare) AS SalesGrowth
	, SUM(SalesGrowth * PortfolioShare)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS SalesGrowthEqOnly
	, SUM(SalesGrowth * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfSalesLong
	, SUM(SalesGrowth * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfSalesShort

--- BtPs
	, SUM(BtP * PortfolioShare) AS BookToPrice
	, SUM(BtP * PortfolioShare) /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS BookToPriceEqOnly
	, SUM(BtP * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfBtPLong
	, SUM(Btp * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfBtPShort

--- DivYields
	, SUM(DivYield * PortfolioShare)  AS DivYield
	, SUM(DivYield * PortfolioShare)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS DivYieldEqOnly
	, SUM(DivYield * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfDYLong
	, SUM(DivYield * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfDYShort


--- EarnYields
	, SUM(EarnYield * PortfolioShare) AS EarnYield
	, SUM(EarnYield * PortfolioShare)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS EarnYieldEqOnly
	, SUM(EarnYield * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfEarnLong
	, SUM(EarnYield * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfEarnShort

--- SalesToPrices
	, SUM(StP * PortfolioShare)  AS SalesToP
	, SUM(StP * PortfolioShare)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS SalesToPEqOnly
	, SUM(StP * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS PortfStPLong
	, SUM(StP * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS PortfStPShort

--- EbitdaToPrices
	, SUM(EbitdaTP * PortfolioShare)  AS EbitdaToP
	, SUM(EbitdaTP * PortfolioShare)  /
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		AS EbitdaToPEqOnly
	, SUM(EbitdaTP * (CASE WHEN PortfolioShare > 0 THEN PortfolioShare ELSE 0 END)) 
		AS EbitdaToPLong
	, SUM(EbitdaTP * (CASE WHEN PortfolioShare < 0 THEN PortfolioShare ELSE 0 END))
		AS EbitdaToPShort


--- MarketSizes
	, SUM(CASE WHEN MktSector = 'Equity' THEN MktCapUSD * ABS(PortfolioShare) 
			ELSE 0 END)
			/
		NULLIF(SUM(CASE WHEN MktSector = 'Equity' THEN ABS(PortfolioShare) 
			ELSE 0 END),0)
		AS MarketCapUSDMn
	, SUM(MktCapUSD * (CASE WHEN (MktSector = 'Equity' AND PortfolioShare > 0) THEN PortfolioShare ELSE 0 END)) 
		AS MktCapUSDLong
	, SUM(MktCapUSD * (CASE WHEN (MktSector = 'Equity' AND PortfolioShare < 0) THEN PortfolioShare ELSE 0 END))
		AS MktCapUSDShort

	-- FINCOME STATISTICS --
-------------------------------------------------
	, SUM(BondYearsToMaturity * PortfolioShare) /
		NULLIF(SUM(CASE WHEN MktSector <> 'Equity' THEN PortfolioShare
			ELSE 0 END),0)
		 AS YearsToMaturity
	, SUM(CAST(IsManualPrice AS INT)) AS ManualPrices

	, SUM(KRD3m * PortfolioShare) AS KRD3m
	, SUM(KRD6m * PortfolioShare) AS KRD6m
	, SUM(KRD1y * PortfolioShare) AS KRD1y
	, SUM(KRD2y * PortfolioShare) AS KRD2y
	, SUM(KRD3y * PortfolioShare) AS KRD3y
	, SUM(KRD4y * PortfolioShare) AS KRD4y
	, SUM(KRD5y * PortfolioShare) AS KRD5y
	, SUM(KRD6y * PortfolioShare) AS KRD6y
	, SUM(KRD7y * PortfolioShare) AS KRD7y
	, SUM(KRD8y * PortfolioShare) AS KRD8y
	, SUM(KRD9y * PortfolioShare) AS KRD9y
	, SUM(KRD10y * PortfolioShare) AS KRD10y
	, SUM(KRD15y * PortfolioShare) AS KRD15y
	, SUM(KRD20y * PortfolioShare) AS KRD20y
	, SUM(KRD25y * PortfolioShare) AS KRD25y
	, SUM(KRD30y * PortfolioShare) AS KRD30y
	, SUM(EffDur * PortfolioShare) AS EffDur
	, SUM(InflDur * PortfolioShare) AS InflDur
	, SUM(RealDur * PortfolioShare) AS RealDur
	, SUM(CASE WHEN SPRatingRank <= 10 THEN PortfolioShare ELSE 0 END) AS InvGrade
	, SUM(CASE WHEN (SPRatingRank > 10 AND SPRatingRank <= 21) THEN PortfolioShare ELSE 0 END) AS HiYield
	, SUM(CASE WHEN (SPRatingRank > 21 AND MktSector NOT IN ('Equity', 'Currency')) THEN PortfolioShare ELSE 0 END) AS NotRated
	, SUM(CASE WHEN InflDur > 0 THEN PortfolioShare ELSE 0 END) AS InflationBonds
	, SUM(CASE WHEN MktSector = 'Government' THEN PortfolioShare ELSE 0 END) AS GovernmentBonds
	, SUM(CASE WHEN MktSector = 'Corporate' THEN PortfolioShare ELSE 0 END) AS Corporate
	, SUM(CASE WHEN MktSector = 'Mortgage' THEN PortfolioShare ELSE 0 END) AS Mortgage
	, SUM(CASE WHEN MktSector = 'Preferred' THEN PortfolioShare ELSE 0 END) AS Preferred
	, SUM(CASE WHEN MktSector = 'Municipals' THEN PortfolioShare ELSE 0 END) AS Municipals

	
FROM #RawData
------------------------------------------------------------------------------------------
DROP TABLE #RawData
