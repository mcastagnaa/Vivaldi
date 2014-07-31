USE Vivaldi;
DECLARE @refDate as datetime

SET @refDate = '2014 JAN 15'

SELECT	P.SecurityType AS Instrument
		, P.PositionId
		, SUM(P.Units) AS TotalDeskPosition
		, AVG(P.StartPrice) AS StartPrice
		, P.PositionDate

INTO	#Positions
FROM	tbl_Positions AS P
WHERE	/*P.FundShortName IN ('EQIO', 'UKSEF', 'UKSEO', 'UKMCO', 'SKAN',
			'SMID', 'UKDEFOS', 'UKSSO', 'TEWK', 'SKANMC', 'EBIOM',
			'UKOPP', 'SKUKCONST', 'OMUKALPHA')*/
		P.FundShortName IN ('UKMCO', 'SKAN', 'UKSEF', 
			'SMID', 'UKDEFOS', 'UKSSO', 'TEWK', 'SKANMC', 'EBIOM'
			)
		AND P.PositionDate = @RefDate
		AND P.SecurityType IN ('CFD', 'Equities')

GROUP BY P.SecurityType, P.PositionId, P.StartPrice, P.PositionDate
ORDER BY P.PositionId, P.StartPrice


SELECT	P.Instrument
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
WHERE A.DivBy100 <> 0


SELECT	I.PositionId
		, I.Description
		, (CASE WHEN SUM(I.TotalDeskPosition) > 0 THEN 'Long' ELSE 'Short' END) AS Side
		, ABS(SUM(I.TotalDeskPosition)) AS TotalShares
		, ABS(SUM(I.TotalDeskPosition)) * AVG(I.StartPrice)/100 AS TotalValue
		, ABS((SUM(I.TotalDeskPosition)) * AVG(I.StartPrice)/100) /
			AVG(I.LocalMarketCap) AS PercMarketCap
		, ABS(SUM(I.TotalDeskPosition)) / NULLIF(AVG(I.ADV3m),0) AS PercADV3m
		, ABS(SUM(I.TotalDeskPosition)) / NULLIF(AVG(I.ADV1m),0) AS PercADV1m
FROM	#Intermediate AS I


GROUP BY I.PositionId, I.Description


DROP TABLE #Positions
DROP TABLE #Intermediate