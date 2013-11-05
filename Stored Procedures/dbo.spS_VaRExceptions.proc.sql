USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_VaRExceptions]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_VaRExceptions]
GO

CREATE PROCEDURE [dbo].[spS_VaRExceptions] 
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


SELECT	@FundId AS FundId
	, @RefDate AS ReportDate
	, Exceptions.SecTicker As Ticker
	, Exceptions.ReasonFail AS Reason
	, Exceptions.Position AS Position
	, RawData.StartPrice AS StartPrice
	, RawData.PortfolioShare AS PtflWeight
	, RawData.MarketPrice AS MarketPrice
	, RawData.AssetCCY AS CCY
	, RawData.SPCleanRating AS SPRating

FROM	tbl_VaRRepExceptions AS Exceptions LEFT JOIN
	#RawData AS RawData ON
		(Exceptions.SecTicker = RawData.BBGTicker) LEFT JOIN
	tbl_EnumVaRReports AS VaRReports ON
		(Exceptions.ReportId = VaRReports.ID)

WHERE	Exceptions.ReportDate = @RefDate
	AND Exceptions.FundId = @FundId
	AND VaRReports.IsRelative = 0

-------------------------------------------------------------------------------------------
DROP TABLE #RawData
GO
-------------------------------------------------------------------------------------------

GRANT EXECUTE ON spS_VaRExceptions TO [OMAM\StephaneD], [OMAM\MargaretA]