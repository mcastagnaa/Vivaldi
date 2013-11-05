USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetUKDeskExpStats]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetUKDeskExpStats]
GO

CREATE PROCEDURE [dbo].[spS_GetUKDeskExpStats] 
	@RefDate datetime

AS
SET NOCOUNT ON;


SELECT	Funds.FundCode AS FundCode
	, MAX(Funds.BenchmarkId) AS BcmkId
	, MAX(FM.PeopleCode) AS FManager
	, MAX(People.PeopleCode) AS HoD

INTO	#FundPeopleList

FROM	tbl_Funds AS Funds JOIN
	vw_FundsPeopleRoles AS People ON (
		People.FundId = Funds.ID
		) JOIN
	vw_FundsPeopleRoles AS FM ON (
		FM.FundId = Funds.ID
		)	

WHERE	/*People.PeopleCode = 'ACB'
	AND*/ People.RoleId = 1
	AND FM.RoleId = 2
	AND Funds.Alive = 1
	AND Funds.Skip = 0
	AND Funds.FundCode not in ('SMFO')

GROUP BY FUnds.FundCode

----------------------------------------------------------

SELECT	Funds.FundCode AS FundCode
	, MAX(AbsVaR.ExpVol1y) AS ExpFundVol
	, MAX(VaRs.ExpBenchVol1y) AS ExpBenchVol
	, MAX(VaRs.ExpTE1y) AS ExpTE
	, (CASE WHEN MAX(Funds.FundClassId) = 2 OR MAX(Funds.FundClassId) = 7 
		THEN MAX(Sts.EffDur) ELSE MAX(Sts.PortfBeta) END) AS PtflBeta

INTO	#Last

FROM	vw_TotalVaRByFundByDate AS AbsVaR JOIN
	tbl_Funds AS Funds ON (
		AbsVaR.FundId = Funds.Id
		) LEFT JOIN
	vw_RelativeVaRReports AS VaRs ON (
		AbsVaR.FundId = VaRs.FundId
		AND AbsVaR.VaRDate = VaRs.ReportDate
		) LEFT JOIN
	tbl_FundsStatistics AS Sts ON (
		AbsVaR.VaRDate = Sts.StatsDate
		AND Sts.FundId = Funds.Id
		) 

WHERE	AbsVaR.VaRDate = @RefDate


GROUP BY Funds.FundCode

----------------------------------------------------------

SELECT	Funds.FundCode
	, AbsVaR.ExpVol1y AS ExpFundVol
	, VaRs.ExpBenchVol1y AS ExpBenchVol
	, VaRs.ExpTE1y AS ExpTE
	, (CASE WHEN Funds.FundClassId = 2 OR Funds.FundClassId = 7 
		THEN Sts.EffDur ELSE Sts.PortfBeta END) AS PtflBeta

INTO	#1w

FROM	vw_TotalVaRByFundByDate AS AbsVaR JOIN
	tbl_Funds AS Funds ON (
		AbsVaR.FundId = Funds.Id
		) LEFT JOIN
	vw_RelativeVaRReports AS VaRs ON (
		AbsVaR.FundId = VaRs.FundId
		AND AbsVaR.VaRDate = VaRs.ReportDate
		) LEFT JOIN
	tbl_FundsStatistics AS Sts ON (
		AbsVaR.VaRDate = Sts.StatsDate
		AND Sts.FundId = Funds.Id
		) /*JOIN
	vw_FundsPeopleRoles AS People ON (
		People.FundId = Funds.ID
		) */

WHERE	/*People.PeopleCode = 'ACB'
	AND People.RoleId = 1
	AND */ AbsVaR.VaRDate = (	SELECT MAX(VaRDate) 
				FROM vw_TotalVaRByFundByDate
				WHERE VaRDate <= DATEADD(w, -1, @RefDate)
				)




----------------------------------------------------------

SELECT	Funds.FundCode
	, AbsVaR.ExpVol1y AS ExpFundVol
	, VaRs.ExpBenchVol1y AS ExpBenchVol
	, VaRs.ExpTE1y AS ExpTE
	, (CASE WHEN Funds.FundClassId = 2 OR Funds.FundClassId = 7 
		THEN Sts.EffDur ELSE Sts.PortfBeta END) AS PtflBeta

INTO	#1m

FROM	vw_TotalVaRByFundByDate AS AbsVaR JOIN
	tbl_Funds AS Funds ON (
		AbsVaR.FundId = Funds.Id
		) LEFT JOIN
	vw_RelativeVaRReports AS VaRs ON (
		AbsVaR.FundId = VaRs.FundId
		AND AbsVaR.VaRDate = VaRs.ReportDate
		) LEFT JOIN
	tbl_FundsStatistics AS Sts ON (
		AbsVaR.VaRDate = Sts.StatsDate
		AND Sts.FundId = Funds.Id
		) /*JOIN
	vw_FundsPeopleRoles AS People ON (
		People.FundId = Funds.ID
		) */

WHERE	/*People.PeopleCode = 'ACB'
	AND People.RoleId = 1
	AND*/ AbsVaR.VaRDate = (	SELECT MAX(VaRDate) 
				FROM vw_TotalVaRByFundByDate
				WHERE VaRDate <= DATEADD(m, -1, @RefDate)
				)

----------------------------------------------------------

SELECT	@RefDate as RefDate
	, Funds.FundCode
	, Funds.BcmkId
	, #Last.ExpFundVol AS LExpFundVol
	, #1w.ExpFundVol AS WExpFundVol
	, #1m.ExpFundVol AS MExpFundVol
	, #Last.ExpBenchVol AS LExpBenchVol
	, #1w.ExpBenchVol AS WExpBenchVol
	, #1m.ExpBenchVol AS MExpBenchVol
	, #Last.ExpTE AS LExpTE
	, #1w.ExpTE AS WExpTE
	, #1m.ExpTE AS MExpTE
	, #Last.PtflBeta AS LPtflBeta
	, #1w.PtflBeta AS WPtflBeta
	, #1m.PtflBeta AS MPtflBeta
	, Funds.FManager
	, Funds.HoD

FROM	#FundPeopleList As Funds LEFT JOIN
		#Last ON ( 
		Funds.FundCode = #Last.FundCode
			) LEFT JOIN #1w ON (
		Funds.FundCode = #1w.FundCode
			) LEFT JOIN #1m ON (
		Funds.FundCode = #1m.FundCode
			)

ORDER BY HoD, FManager, Funds.FundCode


--SELECT * FROM #Last
--SELECT * FROM #1w
--SELECT * FROM #1m

----------------------------------------------------------

DROP TABLE #FundPeopleList
DROP TABLE #Last
DROP TABLE #1w
DROP TABLE #1m

GO

GRANT EXECUTE ON spS_GetUKDeskExpStats TO [OMAM\StephaneD], [OMAM\MargaretA]		