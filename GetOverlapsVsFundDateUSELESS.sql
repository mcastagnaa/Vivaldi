USE VIVALDI
GO

DECLARE @Funds VARCHAR(2000)  
DECLARE @query VARCHAR(4000)  
DECLARE @RefDate datetime

SET @RefDate = '2012 Oct 22'

SELECT	* 
INTO	#GSAF
FROM 	tbl_Positions
WHERE 	FundShortName = 'GSAF'
	AND PositionDate = '2012 Oct 22'

-------------------------------------------------------------------------------


/*SET @Funds = STUFF(( 	SELECT DISTINCT CHAR(39) + ','+ CHAR(39) + FundShortName
			FROM    tbl_Positions  
			WHERE	PositionDate = @RefDate
			ORDER BY CHAR(39) + ','+ CHAR(39) + FundShortName
				FOR XML PATH('')  
			), 1, 2, '') + CHAR(39)

SELECT @Funds

SELECT * FROM
(
	SELECT 	PositionId, SecurityType, Units, FundShortName
	FROM 	tbl_Positions
	WHERE	PositionDate = @RefDate
) t
PIVOT (SUM(Units) FOR FundShortName IN (@Funds)) AS pvt*/


SELECT  @Funds = STUFF((	SELECT DISTINCT '],[' + FundShortName
				FROM    tbl_Positions  
				WHERE	PositionDate = @RefDate
				ORDER BY '],[' + FundShortName
				FOR XML PATH('')  
				), 1, 2, '') + ']'


SET @Query = 'SELECT * 
INTO tbl_TMPDELETEME
FROM
(
	SELECT 	PositionId, SecurityType, Units, FundShortName
	FROM 	tbl_Positions
	WHERE	PositionDate = ' + CHAR(39) + CONVERT(VARCHAR(10), @RefDate, 20) + CHAR(39) + '
) T

PIVOT (SUM(Units) FOR FundShortName IN ('+ @Funds +')) AS PVT'

EXEC (@query)


SELECT 	AllF.* 
--INTO	#AllSet
FROM 	tbl_TMPDELETEME AS AllF JOIN
	#GSAF AS GSAF ON (GSAF.PositionId = AllF.PositionId)
WHERE	AllF.SecurityType IN ('Equities', 'CFD')




/*SELECT SUM(CASE WHEN AS4 IS NULL THEN 0 ELSE 1 END) AS AS4

FROM #AllSet*/






-------------------------------------------------------------------------------
DROP TABLE #GSAF
--DROP TABLE #AllSet
DROP TABLE tbl_TMPDELETEME