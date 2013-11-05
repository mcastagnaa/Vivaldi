USE [VIVALDI]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spU_AddVaRExcpReport]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spU_AddVaRExcpReport]
GO
CREATE PROCEDURE [dbo].[spU_AddVaRExcpReport] 
AS

SET NOCOUNT ON;

DECLARE @RepDate datetime
		, @FundId integer


SET @RepDate = (SELECT Max(ReportDate) FROM tbl_VaRRepExceptStIn) 
SET @FundId = (SELECT Max(FundId) FROM tbl_VaRRepExceptStIn) 

------------------------------------------------------------------------------------------
--== Take the reference from the VaR table ==--
UPDATE	tbl_VaRRepExceptStIn 
SET		BBGInstrId = VaR.BBGInstrId
FROM	tbl_VaRRepExceptStIn AS Expt LEFT JOIN 
		tbl_VaRReports AS VaR ON (
			Expt.SecTicker = VaR.SecTicker
			AND Expt.ReportDate = VaR.ReportDate
			AND	Expt.FundId = VaR.FundId
			)

--== Take what you can from AssetPrices (1) when there is no match in the VaR table ==--
UPDATE	tbl_VaRRepExceptStIn 
SET		BBGInstrId = AP.IDBloomberg
FROM	tbl_VaRRepExceptStIn AS Expt LEFT JOIN
		tbl_AssetPrices AS AP ON (
			AP.PriceDate = Expt.ReportDate
			AND AP.Description = Expt.SecTicker
			)
WHERE Expt.BBGInstrId IS NULL


--== Take what you can from AssetPrices (2) when there is no match in the VaR table ==--
UPDATE	tbl_VaRRepExceptStIn 
SET		BBGInstrId = AP.IDBloomberg
FROM	tbl_VaRRepExceptStIn AS Expt LEFT JOIN
		tbl_AssetPrices AS AP ON (
			AP.PriceDate = Expt.ReportDate
			AND AP.IDBloomberg = 
				'CO' + LEFT(Expt.BBGTicker, CHARINDEX(' ', Expt.BBGTicker)-1) + '9'
			)
WHERE Expt.BBGInstrId IS NULL

--== Take what you can from AssetPrices (3) when there is no match in the VaR table ==--
UPDATE	tbl_VaRRepExceptStIn 
SET		BBGInstrId = LEFT(BBGTicker, CHARINDEX(' ', BBGTicker)-1)
WHERE	BBGInstrId IS NULL


--== Match and upload positions ==--
UPDATE	tbl_VaRRepExceptStIN
SET		Position = ISNULL(Pos.Units,0)
FROM	tbl_VaRRepExceptStIn AS Expt LEFT JOIN
		tbl_AssetPrices AS AP ON (
			Expt.ReportDate = AP.PriceDate
			AND Expt.BBGInstrId = AP.IDBloomberg
			) LEFT JOIN
		tbl_Positions AS Pos ON (
			AP.SecurityId = Pos.PositionId
			AND AP.PriceDate = Pos.PositionDate
			AND AP.SecurityType = Pos.SecurityType
			)
WHERE	Expt.BBGInstrId IS NOT NULL

--== Deprecated after BBG changed report 13/5/2013 ==--
/*;WITH CTE
     AS (SELECT BBGInstrId, ROW_NUMBER() 
		OVER (PARTITION BY BBGInstrId 
					ORDER BY ( SELECT 0)) AS RN
         FROM   tbl_VaRRepExceptStIn)
DELETE 
FROM	CTE
WHERE	RN > 1 
		OR BBGInstrId IS NULL*/


/*INSERT INTO tbl_VaRRepExceptionsPORT 
SELECT	ReportDate
		, FundId
		, ReportId
		, SecTicker
		, BBGInstrId
		, ReasonFail
		, Position
FROM	tbl_VaRRepExceptStIn
WHERE	Position IS NOT NULL*/

--== Copy into VaRRepExceptions table new ones ==--

DELETE
FROM	tbl_VaRRepExceptions
WHERE	ReportDate = @RepDate
		AND FundId = @FundId
--		AND FundId IN (104, 105, 106, 35, 39)

INSERT INTO tbl_VaRRepExceptions
SELECT	ReportDate
		, FundId
		, ReportId
		, SecTicker
		, BBGInstrId
		, ReasonFail
		, Position
FROM	tbl_VaRRepExceptStIn
WHERE	Position IS NOT NULL
--		AND FundId IN (104, 105, 106, 35, 39)

TRUNCATE TABLE tbl_VaRRepExceptStIn
------------------------------------------------------------------------------------------
GO
GRANT EXECUTE ON spU_AddVaRExcpReport TO [OMAM\StephaneD]
