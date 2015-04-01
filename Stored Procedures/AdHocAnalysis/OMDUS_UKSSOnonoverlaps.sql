USE Vivaldi;

DROP TABLE #OMDUS, #UKSSO

SELECT * 
INTO #OMDUS
FROM tbl_Positions 
WHERE FundShortName = 'OMDUS'

SELECT * 
INTO #UKSSO
FROM tbl_Positions 
WHERE FundShortName = 'UKSSO'


SELECT	ALL 'OMDUSnotinUKSSO' AS Item,
		O.PositionDate,
		O.SecurityType,
		O.PositionId,
		N.Description AS SecName,
		O.Units AS OMDUSUnits,
		ISNULL(S.Units, 0) AS UKSSOUnits
FROM	#OMDUS AS O LEFT JOIN
		#UKSSO AS S ON (
			O.PositionId = S.PositionId
			AND O.PositionDate = S.PositionDate
			AND O.SecurityType = S.SecurityType
				) LEFT JOIN
		tbl_AssetPrices AS N ON (
			O.PositionId = N.SecurityId
			AND O.SecurityType = N.SecurityType
				)
WHERE	N.SecurityType NOT IN ('Cash') 
		AND S.Units IS NULL
		AND O.PositionDate > '2013 Dec 31'

UNION 
SELECT	'UKSSOnotinOMDUS' AS Item,
		S.PositionDate,
		S.SecurityType,
		S.PositionId,
		N.Description AS SecName,
		S.Units AS UKSSOUnits,
		ISNULL(O.Units,0) AS OMDUSUnits
FROM	#UKSSO AS S LEFT JOIN
		 #OMDUS AS O ON (
			O.PositionId = S.PositionId
			AND O.PositionDate = S.PositionDate
			AND O.SecurityType = S.SecurityType
				) LEFT JOIN
		tbl_AssetPrices AS N ON (
			S.PositionId = N.SecurityId
			AND S.SecurityType = N.SecurityType
				)
WHERE	N.SecurityType NOT IN ('Cash')
		AND O.Units IS NULL
		AND S.PositionDate > '2013 Dec 31'

ORDER BY Item, PositionDate
		