Use vivaldi
go

declare @Nodays integer
		, @refDate datetime

SET @RefDate = '2010 Jan 1'

SELECT	DISTINCT positiondate 
INTO	#PosDates
FROM	tbl_positions
WHERE	PositionDate >= @RefDate
		AND SecurityType NOT IN ('cash', 'fx')
		AND FundShortName ='EQIO'


SET @Nodays = (SELECT count(positiondate) FROM  #PosDates)

--SELECT @noDays

drop table #PosDates


SELECT	P.PositionId AS AssetId
		, AP.Description AS AssetName
		, P.securitytype
		, count(P.positionDate) AS NoOfDays
		, cast(count(P.positiondate) as float)/@nodays*100 AS DaysPercInPeriod

FROM tbl_positions  AS P LEFT JOIN
		tbl_AssetPrices AS AP  ON (
			P.PositionId = AP.SecurityId
			AND P.SecurityType = AP.SecurityType
			AND P.PositionDate = AP.PriceDate
		)

WHERE P.PositionDate >= @refDate
		ANd P.SecurityType not in ('cash', 'fx')
		And P.FundShortName ='EQIO'

GROUP by P.PositionId, P.securitytype, AP.Description

ORDER BY count(P.positionDate) DESC

SELECT	PositionDate
		, Count(PositionId)
FROM tbl_positions
WHERE PositionDate >= @RefDate
		ANd SecurityType not in ('cash', 'fx')
		And FundShortName ='EQIO'

GROUP by PositionDate
ORDER BY positiondaTE

