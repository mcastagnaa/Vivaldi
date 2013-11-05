SELECT 	Prices.SecurityId AS Sedol
	, Prices.PxLast AS MktPrice
	, Prices.IDBloomberg AS BBGCode
	, RevertToManual.RevertToCost AS IsManualPrice
	, Positions.StartPrice AS CostPrice
FROM	tbl_AssetPrices As Prices LEFT JOIN
	tbl_RevertMktPriceToCost AS RevertToManual ON (
		Prices.SecurityId = RevertToManual.SecurityId
		) LEFT JOIN
	tbl_Positions AS Positions ON (
		Prices.SecurityId = Positions.PositionId
		AND Prices.PriceDate = Positions.PositionDate
		AND Prices.SecurityType = Positions.SecurityType
		)
WHERE	Prices.SecurityType = 'Bonds'
	AND Prices.PriceDate = '2009-10-8'

GROUP BY Prices.SecurityId
	, Prices.PxLast
	, Prices.IDBloomberg
	, RevertToManual.RevertToCost
	, Positions.StartPrice