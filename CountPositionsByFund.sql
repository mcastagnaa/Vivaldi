USE VIVALDI
GO

SELECT 	Fund.FundCode
	, Fund.FundName
	, Fund.VehicleName
	, Fund.StyleName
	, Fund.FundClass
	, MAX(Stat.PositionsCount) AS MaxPositions
	, MIN(Stat.PositionsCount) AS MinPositions
	, AVG(Stat.PositionsCount) AS AvgPositions
	, STDEV(Stat.PositionsCount) AS StDevPositions


FROM	vw_FundsTypology AS Fund LEFT JOIN 
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
		) LEFT JOIN
	tbl_FundsNaVsAndPLs AS Stat ON (
		Pos.PositionDate = Stat.NaVPLDate
		AND Stat.FundId = Fund.FundId
		)

WHERE	--Fund.FundCode = 'UKMCO'
	Pos.PositionDate >= '1 Jan 2012'
	AND Pos.PositionDate <= '28 Nov 2012'
	AND Fund.VehicleId NOT IN (4, 6, 7)
--	AND AssetTypes.SecGroup <> 'CashFX'

GROUP BY	Fund.FundCode
	, Fund.FundName
	, Fund.VehicleName
	, Fund.FundClass
	, Fund.StyleName
ORDER BY	Fund.FundCode

