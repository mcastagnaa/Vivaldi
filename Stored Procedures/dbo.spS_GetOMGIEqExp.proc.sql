USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetOMGIEqExp') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetOMGIEqExp
GO

CREATE PROCEDURE dbo.spS_GetOMGIEqExp
	@RefDate datetime
	, @AssetId nvarchar(25)
AS

SET NOCOUNT ON;

SELECT	P.SecurityType AS Instrument
		, P.PositionId
		, SUM(P.Units) AS TotalDeskPosition
		, AVG(P.StartPrice) AS StartPrice
		, P.PositionDate
		, F.ShortCode AS FundCode
		, F.OurTeam AS Desk

INTO	#Positions
FROM	tbl_Positions AS P LEFT JOIN
		PerfRep.dbo.tbl_Products AS F On (P.FundShortName = F.ShortCode)
WHERE	(@refDate IS NULL OR P.PositionDate = @RefDate)
		AND (@AssetId IS NULL OR P.positionId = @AssetId)
		/*AND P.FundShortName IN ('EQIO', 'UKSEF', 'UKSEO', 'UKMCO', 'SKAN',
			'SMID', 'UKDEFOS', 'UKSSO', 'TEWK', 'SKANMC', 'EBIOM',
			'UKOPP', 'SKUKCONST', 'OMUKALPHA')
		P.FundShortName IN ('UKMCO', 'SKAN', 'UKSEF', 
			'SMID', 'UKDEFOS', 'UKSSO', 'TEWK', 'SKANMC', 'EBIOM'
			)*/
		AND P.SecurityType IN ('CFD', 'Equities')
		AND F.Id NOT IN (321)
GROUP BY	P.SecurityType, P.PositionId, P.StartPrice, P.PositionDate,
			F.ShortCode, F.OurTeam
ORDER BY P.PositionId, P.StartPrice


SELECT	P.Instrument
		, P.Desk
		, P.PositionDate
		, P.FundCode
		, P.PositionId
		, P.TotalDeskPosition
		, A.DivBy100 AS Divider
		, A.Description
		, A.CcyIso AS CCY
		, A.PxLast AS MktPrice
		, P.StartPrice
		, A.VolumeAvg3m AS ADV3m
		, A.VolumeAvg20d AS ADV1m
		, A.MktCapLocal AS LocalMarketCap
		, A.MktCapUSD AS USDMktCapMn

INTO	#Intermediate

FROM #Positions AS P LEFT JOIN
		tbl_AssetPrices AS A ON (
			P.PositionDate = A.PriceDate
			AND P.Instrument = A.SecurityType
			AND P.PositionId = A.SecurityId
			)
--WHERE A.DivBy100 <> 0


--SELECT * FROM #Intermediate

SELECT	I.PositionDate
		, I.PositionId
		, I.Description
		, I.Instrument
		, I.Desk
		, I.FundCode
		, (CASE WHEN SUM(I.TotalDeskPosition) > 0 THEN 'Long' ELSE 'Short' END) AS Side
		, ABS(SUM(I.TotalDeskPosition)) AS TotalShares
		, ABS(SUM(I.TotalDeskPosition)) * AVG(I.StartPrice)/100 AS TotalValue
		, ABS((SUM(I.TotalDeskPosition)) * AVG(I.StartPrice)/100) /
			AVG(I.LocalMarketCap) AS PercMarketCap
		, ABS(SUM(I.TotalDeskPosition)) / NULLIF(AVG(I.ADV3m),0) AS PercADV3m
		, ABS(SUM(I.TotalDeskPosition)) / NULLIF(AVG(I.ADV1m),0) AS PercADV1m
		, AVG(I.USDMktCapMn) AS MktCapUSDmn
FROM	#Intermediate AS I


GROUP BY	I.PositionDate
			, I.PositionId
			, I.Description
			, I.Desk
			, I.FundCode
			, I.Instrument


DROP TABLE #Positions
DROP TABLE #Intermediate

GO
--------------------------------------------------------------------------------------

GRANT EXECUTE ON spS_GetOMGIEqExp TO [OMAM\StephaneD], [OMAM\PaulE]