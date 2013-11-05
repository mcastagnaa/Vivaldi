USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_HedgeFundsLimitsCheck]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_HedgeFundsLimitsCheck]
GO

CREATE PROCEDURE [dbo].[spS_HedgeFundsLimitsCheck] 
	@RefDate datetime
AS

SET NOCOUNT ON;


CREATE TABLE #RawData (
	FundCode		nvarchar(15)
        , PositionsCount	int
	, GrossExposure		float
	, NetExposure		float
	, LMV			float
	, SMV			float
	, TopTicker		nvarchar(30)
	, TopSecPerc		float
	, BotTicker		nvarchar(30)
	, BotSecPerc		float
	, TopIndSec		nvarchar(40)
	, TopIndSecNetExp	float
	, TopIndSecLong		float
	, TopIndSecShort	float
	, BotIndSec		nvarchar(40)
	, BotIndSecNetExp	float
	, BotIndSecLong		float
	, BotIndSecShort	float
	, TopCountry		nvarchar(100)
	, TopCountryNetExp	float
	, TopCountryLong	float
	, TopCountryShort	float
	, BotCountry		nvarchar(100)
	, BotCountryNetExp	float
	, BotCountryLong	float
	, BotCountryShort	float
	)	

------------------------------------------------------------------------------------------

INSERT INTO #RawData
EXEC spS_HedgeFundsReportByDate @RefDate

------------------------------------------------------------------------------------------
SELECT	RawData.FundCode
	, AVG(RawData.GrossExposure) AS GrossExposure
	, AVG(RawData.NetExposure) AS NetExposure
	, AVG(RawData.PositionsCount) AS PositionCount
	, MAX(RawData.TopSecPerc) AS MaxNameExp
	, MIN(RawData.BotSecPerc) AS MinNameExp
	, MAX(RawData.TopIndSecNetExp) AS MaxSecExp
	, MIN(RawData.BotIndSecNetExp) AS MinSecExp
	, MAX(RawData.TopCountryNetExp) AS MaxCtryExp
	, MIN(RawData.BotCountryNetExp) AS MinCtryExp 

INTO	#FundsData

FROM	#RawData AS RawData
GROUP BY	RawData.FundCode

------------------------------------------------------------------------------------------

SELECT 	FundsData.FundCode
	, GrossExpLowBound = (	SELECT	LowerBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'GrossExposure')
	, GrossExpHiBound = (	SELECT	UpperBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'GrossExposure')
	, NetExpLowBound = (	SELECT	LowerBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'NetExposure')
	, NetExpHiBound = (	SELECT	UpperBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'NetExposure')
	, PositionCountLowBound = (	SELECT	LowerBound
					FROM	vw_FundSLimits AS FundsLimits
					WHERE	FundsLimits.FundCode = FundsData.FundCode
						AND FundsLimits.LimitCode = 'PositionsCount')
	, PositionCountHiBound = (	SELECT	UpperBound
					FROM	vw_FundSLimits AS FundsLimits
					WHERE	FundsLimits.FundCode = FundsData.FundCode
						AND FundsLimits.LimitCode = 'PositionsCount')
	, NameWarnLowBound = (	SELECT	LowerBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'NameExpW')
	, NameWarnHiBound = (	SELECT	UpperBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'NameExpW')
	, NameLowBound = (	SELECT	LowerBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'NameExp')
	, NameHiBound = (	SELECT	UpperBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'NameExp')
	, SecLowBound = (	SELECT	LowerBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'SectExp')
	, SecHiBound = (	SELECT	UpperBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'SectExp')
	, CtryLowBound = (	SELECT	LowerBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'CtryExp')
	, CtryHiBound = (	SELECT	UpperBound
				FROM	vw_FundSLimits AS FundsLimits
				WHERE	FundsLimits.FundCode = FundsData.FundCode
					AND FundsLimits.LimitCode = 'CtryExp')

INTO #FundsLimits

FROM #FundsData As FundsData
------------------------------------------------------------------------------------------

SELECT	Limits.FundCode
	, Limits.PositionCountLowBound
	, FundsData.PositionCount
	, Limits.PositionCountHiBound
	, (CASE WHEN FundsData.PositionCount > Limits.PositionCountHiBound THEN 1 ELSE 0 END) AS PosCntHiBoundBreach
	, (CASE WHEN FundsData.PositionCount < Limits.PositionCountLowBound THEN 1 ELSE 0 END) AS PosCntLowBoundBreach

	, Limits.GrossExpLowBound
	, FundsData.GrossExposure
	, Limits.GrossExpHiBound
	, (CASE WHEN FundsData.GrossExposure > Limits.GrossExpHiBound THEN 1 ELSE 0 END) AS GrossExpHiBoundBreach
	, (CASE WHEN FundsData.GrossExposure < Limits.GrossExpLowBound THEN 1 ELSE 0 END) AS GrossExpLowBoundBreach

	, Limits.NetExpLowBound
	, FundsData.NetExposure
	, Limits.NetExpHiBound
	, (CASE WHEN FundsData.NetExposure > Limits.NetExpHiBound THEN 1 ELSE 0 END) AS NetExpHiBoundBreach
	, (CASE WHEN FundsData.NetExposure < Limits.NetExpLowBound THEN 1 ELSE 0 END) AS NetExpLowBoundBreach

	, Limits.NameLowBound
	, Limits.NameWarnLowBound
	, FundsData.MinNameExp
	, FundsData.MaxNameExp
	, Limits.NameWarnHiBound
	, Limits.NameHiBound
	, (CASE WHEN FundsData.MaxNameExp > Limits.NameWarnHiBound THEN 1 ELSE 0 END) AS NameWarnHiBoundBreach
	, (CASE WHEN FundsData.MinNameExp < Limits.NameWarnLowBound THEN 1 ELSE 0 END) AS NameWarnLowBoundBreach
	, (CASE WHEN FundsData.MaxNameExp > Limits.NameHiBound THEN 1 ELSE 0 END) AS NameHiBoundBreach
	, (CASE WHEN FundsData.MinNameExp < Limits.NameLowBound THEN 1 ELSE 0 END) AS NameLowBoundBreach

	, Limits.SecLowBound
	, FundsData.MinSecExp
	, FundsData.MaxSecExp
	, Limits.SecHiBound
	, (CASE WHEN FundsData.MaxSecExp > Limits.SecHiBound THEN 1 ELSE 0 END) AS SecHiBoundBreach
	, (CASE WHEN FundsData.MinSecExp < Limits.SecLowBound THEN 1 ELSE 0 END) AS SecLowBoundBreach

	, Limits.CtryLowBound
	, FundsData.MinCtryExp
	, FundsData.MaxCtryExp
	, Limits.CtryHiBound
	, (CASE WHEN FundsData.MaxCtryExp > Limits.CtryHiBound THEN 1 ELSE 0 END) AS CtryHiBoundBreach
	, (CASE WHEN FundsData.MinCtryExp < Limits.CtryLowBound THEN 1 ELSE 0 END) AS CtryLowBoundBreach


INTO	#Breaches

FROM	#FundsLimits AS Limits LEFT JOIN
	#FundsData AS FundsData ON (
		Limits.FundCode = FundsData.FundCode
	)

------------------------------------------------------------------------------------------
SELECT	* 
FROM 	#Breaches 
WHERE	PosCntHiBoundBreach = 1
	OR PosCntLowBoundBreach = 1
	OR GrossExpHiBoundBreach = 1
	OR GrossExpLowBoundBreach = 1
	OR NetExpHiBoundBreach = 1
	OR NetExpLowBoundBreach = 1
	OR CtryHiBoundBreach = 1
	OR CtryLowBoundBreach = 1
	OR SecHiBoundBreach = 1
	OR SecLowBoundBreach = 1
	OR NameWarnHiBoundBreach = 1
	OR NameWarnLowBoundBreach = 1
	OR NameHiBoundBreach = 1
	OR NameLowBoundBreach = 1


------------------------------------------------------------------------------------------

DROP TABLE #RawData
DROP TABLE #FundsData
DROP TABLE #FundsLimits
DROP TABLE #Breaches

GO
------------------------------------------------------------------------------------------

GRANT EXECUTE ON spS_HedgeFundsLimitsCheck TO [OMAM\StephaneD], [OMAM\MargaretA]