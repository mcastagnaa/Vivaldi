USE Vivaldi
GO

DECLARE @StartDate datetime
		, @EndDate datetime
		, @DataDate datetime

SET @StartDate = '2014 Nov 3'
SET @EndDate = '2015 Jan 26'

-------------------------------------------------------------------

DECLARE Dates_Cursor CURSOR FOR
SELECT	PositionDate
FROM	tbl_Positions
WHERE	PositionDate >= @StartDate
		AND PositionDate <= @EndDate
GROUP BY PositionDate
ORDER BY PositionDate

OPEN Dates_Cursor
FETCH NEXT FROM Dates_Cursor
INTO @DataDate

WHILE @@FETCH_STATUS = 0
BEGIN
------------------------------------------------------------------------

SELECT	FundShortName
INTO	#FundIds
FROM	tbl_positions
WHERE	positionDate = @DataDate
GROUP BY FundShortName

INSERT INTO MissingVaRData
SELECT	@DataDate AS VaRDate
		, Pos.FundShortName As FundCode
		, Funds.Id AS FundId
		, Funds.FundName
		, VaR.PercentVaR
FROM	#FundIds AS Pos LEFT JOIN
		tbl_Funds AS Funds ON (Pos.FundShortName = Funds.FundCode) LEFT JOIN
		vw_TotalVaRByFundByDate AS VAR ON (Funds.Id = VaR.FundId)
WHERE	VaR.VaRDate = @DataDate
		AND VaR.PercentVaR IS NULL

DROP TABLE #FundIds
------------------------------------------------------------------------
--	SELECT @DataDate
	FETCH NEXT FROM Dates_Cursor
	INTO @DataDate
END

CLOSE Dates_Cursor
DEALLOCATE Dates_Cursor

SELECT * FROM MissingVaRData

--TRUNCATE TABLE MissingVaRData