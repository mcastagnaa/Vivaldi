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
	, FundCCY		nvarchar(3)
        , PositionsCount	int
	, GrossExposure		float
	, NetExposure		float
	, LMV			float
	, SMV			float
	, TopTicker		nvarchar(40)
	, TopSecPerc		float
	, BotTicker		nvarchar(40)
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
	, CCYExp		float
	, LxEMGrossExp		float
	, LxEMNetExp		float
	, LxIlliquid		float
	, LxVeryIlliquid	float
	, LxNotAllowed		float
	, NaV			float
	)	

INSERT INTO #RawData
EXEC spS_HedgeFundsReportByDate @RefDate


------------------------------------------------------------------------------------------


SELECT	FundCode
	, AVG(GrossExposure) AS GrossExposure
	, AVG(NetExposure) AS NetExposure
	, AVG(PositionsCount) AS PositionsCount
	, AVG(CCYExp) AS CCYExp
	, AVG(LxEMGrossExp) AS LxEMGrossExp
	, AVG(LxEMNetExp) AS LxEMNetExp
	, AVG(LxIlliquid) AS LxIlliquid
	, AVG(LxVeryIlliquid) AS LxVeryIlliquid
	, AVG(LxNotAllowed) AS LxNotAllowed
	, CASE
		WHEN MAX(TopSecPerc) > MAX(ABS(BotSecPerc)) 
			THEN MAX(TopSecPerc) 
		ELSE MAX(ABS(BotSecPerc)) 
		END
	AS NameExp
	, CASE
		WHEN MAX(TopIndSecNetExp) > MAX(ABS(BotIndSecNetExp)) 
			THEN MAX(TopIndSecNetExp) 
		ELSE MAX(ABS(BotIndSecNetExp)) 
		END
	AS SectExp
	, CASE
		WHEN MAX(TopCountryNetExp) > MAX(ABS(BotCountryNetExp)) 
			THEN MAX(TopCountryNetExp) 
		ELSE MAX(ABS(BotCountryNetExp)) 
		END
	AS CtryExp
	, AVG(LMV) AS LMV
	, AVG(SMV) AS SMV

INTO	#FundsData

FROM 	#RawData
GROUP BY	FundCode

------------------------------------------------------------------------------------------

SELECT	*
INTO	#LowBounds

FROM (	SELECT	LimitCode, FundCode, LowerBound 
		FROM	vw_FundsLimits) o

PIVOT (AVG(LowerBound) FOR LimitCode IN(	
					[NetExposure]
					, [GrossExposure]
					, [SectExp]
					, [CtryExp]
					, [NameExpW]
					, [NameExp]
					, [PositionsCount]
					, [LxEMGrossExp]
					, [LxEMNetExp]
					, [CCYExp]
					, [LxIlliquid]
					, [LxVeryIlliquid]
					, [LxNotAllowed]
					, [LMV]
					, [SMV]
					)
	) p

------------------------------------------------------------------------------------------

SELECT	*
INTO	#UppBounds

FROM (	SELECT	LimitCode, FundCode, UpperBound 
		FROM	vw_FundsLimits) o

PIVOT (AVG(UpperBound) FOR LimitCode IN(	
					[NetExposure]
					, [GrossExposure]
					, [SectExp]
					, [CtryExp]
					, [NameExpW]
					, [NameExp]
					, [PositionsCount]
					, [LxEMGrossExp]
					, [LxEMNetExp]
					, [CCYExp]
					, [LxIlliquid]
					, [LxVeryIlliquid]
					, [LxNotAllowed]
					, [LMV]
					, [SMV]
					)
	) p


------------------------------------------------------------------------------------------

SELECT	UppBounds.FundCode
	, 'PositionCount' AS LimitName
	, LowBounds.PositionsCount AS LowBound
	, FundsData.PositionsCount AS Portfolio
	, UppBounds.PositionsCount AS UpperBound
	, (CASE 
		WHEN 	FundsData.PositionSCount > UppBounds.PositionsCount
			OR 
			FundsData.PositionSCount < LowBounds.PositionsCount
		THEN 1 ELSE 0 END) AS IsBreach
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.PositionsCount IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'GrossExposure'
	, LowBounds.GrossExposure
	, FundsData.GrossExposure
	, UppBounds.GrossExposure
	, (CASE 
		WHEN 	FundsData.GrossExposure > UppBounds.GrossExposure
			OR 
			FundsData.GrossExposure < LowBounds.GrossExposure
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.GrossExposure IS NOT NULL


UNION ALL
SELECT	UppBounds.FundCode
	, 'LMV'
	, LowBounds.LMV
	, FundsData.LMV
	, UppBounds.LMV
	, (CASE 
		WHEN 	FundsData.LMV > UppBounds.LMV
			OR 
			FundsData.LMV < LowBounds.LMV
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.LMV IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'SMV'
	, LowBounds.SMV
	, FundsData.SMV
	, UppBounds.SMV
	, (CASE 
		WHEN 	FundsData.SMV > UppBounds.SMV
			OR 
			FundsData.SMV < LowBounds.SMV
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.SMV IS NOT NULL



UNION ALL
SELECT	UppBounds.FundCode
	, 'NetExposure'
	, LowBounds.NetExposure
	, FundsData.NetExposure
	, UppBounds.NetExposure
	, (CASE 
		WHEN 	FundsData.NetExposure > UppBounds.NetExposure
			OR 
			FundsData.NetExposure < LowBounds.NetExposure
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.NetExposure IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'NameExposureWarning'
	, LowBounds.NameExpW
	, FundsData.NameExp
	, UppBounds.NameExpW
	, (CASE 
		WHEN 	FundsData.NameExp > UppBounds.NameExpW
			OR 
			FundsData.NameExp < LowBounds.NameExpW
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.NameExpW IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'NameExposure'
	, LowBounds.NameExp
	, FundsData.NameExp
	, UppBounds.NameExp
	, (CASE 
		WHEN 	FundsData.NameExp > UppBounds.NameExp
			OR 
			FundsData.NameExp < LowBounds.NameExp
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.NameExp IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'SectorExposure'
	, LowBounds.SectExp
	, FundsData.SectExp
	, UppBounds.SectExp
	, (CASE 
		WHEN 	FundsData.SectExp > UppBounds.SectExp
			OR 
			FundsData.SectExp < LowBounds.SectExp
		THEN 1 ELSE 0 END)
FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.SectExp IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'CountryExposure'
	, LowBounds.CtryExp 
	, FundsData.CtryExp
	, UppBounds.CtryExp
	, (CASE 
		WHEN 	FundsData.CtryExp > UppBounds.CtryExp
			OR 
			FundsData.CtryExp < LowBounds.CtryExp
		THEN 1 ELSE 0 END) AS CtryExpBreach

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.CtryExp IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'CCYGrossExposure'
	, LowBounds.CCYExp
	, FundsData.CCYExp
	, UppBounds.CCYExp
	, (CASE 
		WHEN 	FundsData.CCYExp > UppBounds.CCYExp
			OR 
			FundsData.CCYExp < LowBounds.CCYExp
		THEN 1 ELSE 0 END)

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.CCYExp IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'LxEMGrossExposure'
	, LowBounds.LxEMGrossExp
	, FundsData.LxEMGrossExp
	, UppBounds.LxEMGrossExp
	, (CASE 
		WHEN 	FundsData.LxEMGrossExp > UppBounds.LXEMGrossExp
			OR 
			FundsData.LxEMGrossExp < LowBounds.LXEMGrossExp
		THEN 1 ELSE 0 END)

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.LxEMGrossExp IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'LxEMNetExposure'
	, LowBounds.LxEMNetExp
	, FundsData.LxEMNetExp
	, UppBounds.LxEMNetExp
	, (CASE 
		WHEN 	FundsData.LxEMNetExp > UppBounds.LXEMNetExp
			OR 
			FundsData.LxEMNetExp < LowBounds.LXEMNetExp
		THEN 1 ELSE 0 END)

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.LxEMNetExp IS NOT NULL


UNION ALL
SELECT	UppBounds.FundCode
	, 'LxIlliquid'
	, LowBounds.LxIlliquid
	, FundsData.LxIlliquid
	, UppBounds.LxIlliquid
	, (CASE 
		WHEN 	FundsData.LxIlliquid > UppBounds.LXIlliquid
		THEN 1 ELSE 0 END)

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.LxIlliquid IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'LxVeryIlliquid'
	, LowBounds.LxVeryIlliquid
	, FundsData.LxVeryIlliquid
	, UppBounds.LxVeryIlliquid
	, (CASE 
		WHEN 	FundsData.LxVeryIlliquid > UppBounds.LXVeryIlliquid
		THEN 1 ELSE 0 END)

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.LxVeryIlliquid IS NOT NULL

UNION ALL
SELECT	UppBounds.FundCode
	, 'LxNotAllowed'
	, LowBounds.LxNotAllowed
	, FundsData.LxNotAllowed
	, UppBounds.LxNotAllowed
	, (CASE 
		WHEN 	FundsData.LxNotAllowed > UppBounds.LxNotAllowed
		THEN 1 ELSE 0 END)

FROM	#UppBounds AS UppBounds LEFT JOIN
	#LowBounds AS LowBounds ON
		(UppBounds.FundCode = LowBounds.FundCode) LEFT JOIN
	#FundsData AS FundsData ON (
		UppBounds.FundCode = FundsData.FundCode
		AND LowBounds.FundCode = FundsData.FundCode
	)
WHERE	UppBounds.LxNotAllowed IS NOT NULL

ORDER BY	UppBounds.FundCode



------------------------------------------------------------------------------------------

DROP TABLE #RawData
DROP TABLE #FundsData
DROP TABLE #LowBounds
DROP TABLE #UppBounds

GO
------------------------------------------------------------------------------------------

GRANT EXECUTE ON spS_HedgeFundsLimitsCheck TO [OMAM\StephaneD], [OMAM\MargaretA]