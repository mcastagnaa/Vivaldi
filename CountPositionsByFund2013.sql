USE Vivaldi;

SELECT F.FundCode
		, F.FundName
		, F.VehicleName
		, F.StyleName
		, F.FundClass
		, MAX(Stat.PositionsCount) AS MaxPositions
		, AVG(Stat.PositionsCount) AS AvgPositions
		, MIN(Stat.PositionsCount) AS MinPositions
		, STDEV(Stat.PositionsCount) AS StDevPositions
		, COUNT(F.FundCode) AS Obs

FROM tbl_FundsNavsAndPLs AS Stat LEFT JOIN
		vw_FundsTypology AS F On (
			Stat.FundId = F.FundId
		)
WHERE	NaVPLDate > '2012 Dec 31' 
		AND NaVPLDate <= '2013 Dec 31' 

GROUP BY F.FundCode
		, F.FundName
		, F.VehicleName
		, F.StyleName
		, F.FundClass