DECLARE @StatHeaders NVARCHAR(4000)
DECLARE @UnpivotTableSQL NVARCHAR(4000)
DECLARE @FundCode NVARCHAR(10)
DECLARE @RelDate Datetime 

SELECT @FundCode = 'GSBO'
SELECT @RelDate = '2011/Sep/15'
-------------------------------------------------------------------

SELECT Name 
INTO #ColumnNames
FROM sys.columns 
WHERE object_id = object_id(N'tbl_FundsStatistics') 
	AND Name <> 'CleanRating'
	AND Name <> 'StatsDate'
	

--SELECT * FROM #ColumnNames


-------------------------------------------------------------------
SELECT 	Stats.*

INTO 	##FundsStats

FROM 	tbl_FundsStatistics AS Stats LEFT JOIN
	tbl_Funds AS Funds 
		on (Funds.Id = Stats.FundId)

WHERE	Funds.FundCode =  @FundCode   
	AND Stats.StatsDate = @RelDate 

-------------------------------------------------------------------


SELECT @StatHeaders = 
COALESCE(@StatHeaders + ',[' + Name + ']', '['+ Name + ']')

FROM 	#ColumnNames

--SELECT @StatHeaders

/*SELECT 	Stats.*
FROM 	tbl_FundsStatistics Stats LEFT JOIN
	tbl_Funds Funds 
		on (Funds.Id = Stats.FundId)
WHERE	Funds.FundCode = ' + CHAR(39) + @FundCode + CHAR(39) +
	' AND Stats.StatsDate = ' + CHAR(39) + CAST(@RelDate AS NVARCHAR(20)) + CHAR(39) + '*/

-------------------------------------------------------------------

SELECT @UnpivotTableSQL = N'
SELECT convert(varChar(30), StatName) StatName,  StatValue
FROM ##FundsStats AS P
UNPIVOT
(StatValue FOR StatName IN (' + @StatHeaders + 
')) AS UNPVT
'

EXECUTE(@UnpivotTableSQL)

-------------------------------------------------------------------


DROP TABLE #ColumnNames
DROP TABLE ##FundsStats



