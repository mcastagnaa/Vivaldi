SELECT tbl_positions.* 
	, tbl_AssetPrices.IDBloomberg
FROM tbl_positions LEFT JOIN tbl_assetPrices ON
	(tbl_positions.PositionId = tbl_AssetPrices.SecurityId
	AND tbl_positions.Positiondate = tbl_AssetPrices.Pricedate
	AND tbl_positions.securityType = tbl_AssetPrices.securitytype
)
WHERE tbl_positions.positionDate = '2009-9-18' and tbl_positions.FundShortName = 'FRGEF'
	