USE VIVALDI
GO

SELECT 	Fund.FundCode
	, Pos.PositionId AS Ticker
	, Pos.SecurityType
	, Asset.Description AS Name
	, Count(Pos.PositionDate) AS CountOfDates


FROM	tbl_Funds AS Fund LEFT JOIN 
	tbl_Positions AS Pos ON (
		Fund.FundCode = Pos.FundShortName
		) LEFT JOIN
	tbl_AssetPrices AS Asset ON (
		Pos.PositionId = Asset.SecurityId
		AND Pos.PositionDate = Asset.PriceDate
		AND Pos.SecurityType = Asset.SecurityType
		) LEFT JOIN
	tbl_BMISAssets AS AssetTypes ON (
		Pos.SecurityType = AssetTypes.AssetName
		)

WHERE	Fund.FundCode = 'UKMCO'
	AND Pos.PositionDate >= '1 Jan 2012'
	AND Pos.PositionDate <= '22 Nov 2012'
	AND AssetTypes.SecGroup <> 'CashFX'

GROUP BY	Fund.FundCode
		, Pos.PositionId
		, Asset.Description
		, Pos.SecurityType

ORDER BY	COUNT(Pos.PositionDate) DESC