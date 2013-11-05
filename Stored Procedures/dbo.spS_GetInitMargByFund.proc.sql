USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetInitMargByFund]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_GetInitMargByFund]
GO

CREATE PROCEDURE [dbo].[spS_GetInitMargByFund] 
	@RefDate datetime,
	@FundId int 
AS

SET NOCOUNT ON;

SELECT	FutPos.PositionDate
	, FutPos.SecurityGroup
	, SUM(FutPos.MarginBase/NaVs.mktNaVprices) AS TMarginBase

INTO	#RawData

FROM	vw_FuturesPositions AS FutPos LEFT JOIN
	tbl_FundsNaVsAndPLs AS NaVs ON
		(FutPos.FundId = NaVs.FundId
		AND FutPos.PositionDate = NaVs.NaVPLDate)

WHERE	FutPos.FundId = @FundId
	AND FutPos.PositionDate > DATEADD(month,-3,@RefDate)
	AND FutPos.PositionDate <= @RefDate

GROUP BY	FutPos.FundCode
		, FutPos.Positiondate
		, FutPos.SecurityGroup


--------------------------------------------------------------------------------

SELECT	*

FROM 	(SELECT	PositionDate, SecurityGroup, TMarginBase
	FROM	#RawData) o
PIVOT	(SUM(TMarginBase) 
	FOR SecurityGroup IN(	
			Comdty
			, Equities
			, FixedIn
			)
	) p
--------------------------------------------------------------------------------

DROP Table #RawData

GO

GRANT EXECUTE ON spS_GetInitMargByFund TO [OMAM\StephaneD], [OMAM\MargaretA]