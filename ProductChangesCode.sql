USE Vivaldi;

--TESTED

------------------------------------
--== Type 1: Name change ==--
DECLARE @TodayDate datetime
SET @TodayDate = datediff(day,0,getdate())

SELECT	* 
INTO	#Changes
FROM	tbl_ProductsChanges
WHERE	ChangeDate = @TodayDate
		AND EventCode = 1

SELECT	FundName
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode)

UPDATE	tbl_Funds
SET		FundName = C.FundNameNew
FROM	#Changes AS C LEFT JOIN 
		tbl_Funds AS F ON (
			C.FundCode = F.FundCode)

SELECT	FundName
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode)

DROP TABLE #Changes
GO

------------------------------------
--== Type 2: Merge/CloseOut ==--
DECLARE @TodayDate datetime
SET @TodayDate = datediff(day,0,getdate())

SELECT	* 
INTO	#Changes
FROM	tbl_ProductsChanges
WHERE	ChangeDate = @TodayDate
		AND EventCode = 2

SELECT	FundName, Alive
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode)

UPDATE	tbl_Funds
SET		Alive = 0
FROM	#Changes AS C LEFT JOIN 
		tbl_Funds AS F ON (
			C.FundCode = F.FundCode)

SELECT	FundName, Alive
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode)

DROP TABLE #Changes
GO

------------------------------------
--== Type 4: SoldAs ==--

DECLARE @TodayDate datetime
SET @TodayDate = datediff(day,0,getdate())

SELECT	* 
INTO	#Changes
FROM	tbl_ProductsChanges
WHERE	ChangeDate = @TodayDate
		AND EventCode = 4

SELECT	F.FundName, F.VehicleId, V.ShortName AS VehicleCode
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode
			) LEFT JOIN
		tbl_Vehicles AS V ON (
			F.VehicleId = V.Id
			)

UPDATE	tbl_Funds
SET		VehicleId = (CASE C.SoldAsNew 
				WHEN 'UCITS4' THEN 2
				WHEN 'OEIC' THEN 1
				WHEN 'HF' THEN 3
				WHEN 'NURS' THEN 8
				WHEN 'Mandate' THEN 4
			END) 
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode
			) 

SELECT	F.FundName, F.VehicleId, V.ShortName AS VehicleCode
FROM	tbl_Funds AS F RIGHT JOIN 
		#Changes AS C ON (
			C.FundCode = F.FundCode
			) LEFT JOIN
		tbl_Vehicles AS V ON (
			F.VehicleId = V.Id
			)

DROP TABLE #Changes
GO

