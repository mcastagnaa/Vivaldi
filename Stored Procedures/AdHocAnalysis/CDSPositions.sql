
SELECT Pos.* 
		, Asset.Description
		, Asset.PxLast AS MarketPrice
		, Asset.Shortname
		, Asset.SpreadDur
		, CDS.BuySell
		, CDS.PayFreq
		, CDS.RecRate
		, CDS.NotionalSpread
		, CDS.FlatSpread
FROM tbl_Positions AS Pos LEFT JOIN
		tbl_AssetPrices AS Asset ON (
			Asset.PriceDate = Pos.PositionDate
			AND Asset.SecurityId = Pos.PositionId
			) LEFT JOIN
		tbl_CDSData AS CDS ON (
			CDS.PositionId = Pos.PositionId
			AND Pos.PositionDate = CDS.DataDate
			)
WHERE Pos.PositionDate = '2015 Feb 5'
AND Pos.SecurityType LIKE 'CDS%'