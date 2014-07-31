USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_SegMatchSubProc]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_SegMatchSubProc]
GO

CREATE PROCEDURE [dbo].[spS_SegMatchSubProc] 
	@RefDate datetime,
	@SegFund int,
	@RefFund int 
AS

SET NOCOUNT ON;

SELECT	*
INTO	#SegAcc
FROM	#FullData  
WHERE	FundId = @SegFund

SELECT	*
INTO	#RefAcc
FROM	#FullData 
WHERE	FundId = @RefFund

INSERT INTO	tbl_MandateChecks
SELECT	@RefDate AS RefDate
		, @SegFund AS SegId
		, @RefFund AS RefId
		, ISNULL(S.SecurityGroup, F.SecurityGroup) AS SecurityGroup
		, ISNULL(S.BMISCode, F.BMISCode) AS BMISCode
		, ISNULL(S.BBGTicker, F.BBGTicker) AS BBGTicker
		, SUM(ISNULL(S.AllExpWeights,0)) AS SegW
		, SUM(ISNULL(F.AllExpWeights,0)) AS RefW
		, ISNULL(S.AssetCCY, F.AssetCCY) AS AssetCCY
		, ISNULL(S.IsCCYExp, F.IsCCYExp) AS IsCCYExp

FROM	#SegAcc AS S FULL JOIN
		#RefAcc AS F ON (
			S.BMISCode = F.BMISCode
			AND S.SecurityType = F.SecurityType
			)
GROUP BY	ISNULL(S.SecurityGroup, F.SecurityGroup)
			, ISNULL(S.BMISCode, F.BMISCode)
			, ISNULL(S.BBGTicker, F.BBGTicker)
			, ISNULL(S.AssetCCY, F.AssetCCY)
			, ISNULL(S.IsCCYExp, F.IsCCYExp)
HAVING		SUM(ISNULL(S.AllExpWeights,0)) <> 0
			OR SUM(ISNULL(F.AllExpWeights,0)) <> 0

ORDER BY	ISNULL(S.SecurityGroup, F.SecurityGroup)
			, ISNULL(S.BMISCode, F.BMISCode)

DROP TABLE #SegAcc
		, #RefAcc	

GO

GRANT EXECUTE ON spS_SegMatchSubProc TO [OMAM\StephaneD]
