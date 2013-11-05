USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_KRDByFundByDate]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_KRDByFundByDate]
GO

CREATE PROCEDURE [dbo].[spS_KRDByFundByDate] 
	@RefDate datetime
	, @FundId int

AS

SET NOCOUNT ON;

DECLARE	@RefDate1w datetime
DECLARE	@RefDate1m datetime


SET @RefDate1w = (SELECT MAX(StatsDate)
			FROM tbl_FundsStatistics
			WHERE StatsDate <= DATEADD(week, -1, @RefDate)
		)

SET @RefDate1m = ISNULL((SELECT MAX(StatsDate)
			FROM tbl_FundsStatistics
			WHERE StatsDate <= DATEADD(month, -1, @RefDate))
		, (SELECT MIN(StatsDate)
			FROM tbl_FundsStatistics
			WHERE StatsDate >= '2009-9-18')
		)

----------------------------------

SELECT	'Date1' AS DateTag
	, @RefDate AS KRDDate
	, KRD3m
	, KRD6m
	, KRD1y
	, KRD2y
	, KRD3y
	, KRD4y
	, KRD5y
	, KRD6y
	, KRD7y
	, KRD8y
	, KRD9y
	, KRD10y
	, KRD15y
	, KRD20y
	, KRD25y
	, KRD30y

FROM	tbl_FundsStatistics
WHERE	StatsDate = @RefDate
	AND FundId = @FundId

UNION 
SELECT	'Date2'
	, @RefDate1w
	, KRD3m
	, KRD6m
	, KRD1y
	, KRD2y
	, KRD3y
	, KRD4y
	, KRD5y
	, KRD6y
	, KRD7y
	, KRD8y
	, KRD9y
	, KRD10y
	, KRD15y
	, KRD20y
	, KRD25y
	, KRD30y

FROM	tbl_FundsStatistics
WHERE	StatsDate = @RefDate1w
	AND FundId = @FundId

UNION
SELECT	'Date3'
	,@RefDate1m
	, KRD3m
	, KRD6m
	, KRD1y
	, KRD2y
	, KRD3y
	, KRD4y
	, KRD5y
	, KRD6y
	, KRD7y
	, KRD8y
	, KRD9y
	, KRD10y
	, KRD15y
	, KRD20y
	, KRD25y
	, KRD30y

FROM	tbl_FundsStatistics
WHERE	StatsDate = @RefDate1m
	AND FundId = @FundId

GO
---------------------------------

GRANT EXECUTE ON spS_KRDByFundByDate TO [OMAM\StephaneD], [OMAM\MargaretA]