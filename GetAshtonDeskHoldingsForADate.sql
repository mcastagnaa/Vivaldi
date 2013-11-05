USE VIVALDI

SELECT PositionId, PositionDate 
INTO #UKDEFOS
FROM tbl_Positions

WHERE	FundShortName = 'UKDEFOS'
	AND PositionDate = '31 Dec 2010'
	AND SecurityType IN ('Equities', 'CFD')

GROUP BY 	PositionID
		, PositionDate

---------------------------------------------------

SELECT	DEF.PositionId
	, Allf.SecurityType
	, Asset.Description
	, Allf.FundShortName
	, Allf.Units
--	, People.RoleCode
--	, People.PeopleCOde

FROM	#UKDEFOS AS DEF LEFT JOIN
	tbl_positions AS Allf ON
		(DEF.PositionId = Allf.PositionId AND
		DEF.PositionDate = Allf.PositionDate)
	JOIN tbl_AssetPrices AS Asset ON
		(Allf.PositionId = Asset.SecurityId
		AND Allf.PositionDate = Asset.PriceDate
		AND Allf.SecurityType = Asset.SecurityType)
	JOIN vw_FundsPeopleRoles AS People ON
		(Allf.FundShortName = People.FundCode)

WHERE	People.PeopleCode = 'ACB'
	AND People.RoleCode = 'HD'
	AND Allf.FundShortName NOT IN ('EIFO', 'ASFO', 'UKSEO', 'EQIO')

ORDER BY Asset.Description
	
---------------------------------------------------

--SELECT * FROM #UKDEFOS

DROP TABLE #UKDEFOS
