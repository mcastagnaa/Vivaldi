SELECT 	Funds.FundCode
	, NaVs.NaVPLDate AS RefDate
	, NaVs.TotalPL/NaVs.CostNaV AS PL
	, BenchList.ShortName
	, Bench.Perf AS BenchPL 
	, Stts.PortfBeta AS Beta

FROM	tbl_FundsNaVsAndPLs AS NaVs LEFT JOIN
	tbl_Funds AS Funds ON (
		Funds.Id = NaVs.FundId
		) LEFT JOIN 
	tbl_FundsStatistics AS Stts ON (
		Stts.StatsDate = NaVs.NaVPLDate
		AND Stts.FundId = NaVs.FundId
		AND Funds.Id = Stts.FundId
		) LEFT JOIN
	tbl_BenchmData AS Bench ON (
		NaVs.NaVPLDate = Bench.PriceDate
		AND Stts.StatsDate = Bench.PriceDate
		) JOIN
	tbl_Benchmarks AS BenchList ON (
		Bench.Id = BenchList.Id	
		AND Funds.BenchmarkId = BenchList.Id
		AND Bench.Id = Funds.BenchmarkId
		)

WHERE Funds.FundCode = 'UKSEO'

ORDER BY RefDate
