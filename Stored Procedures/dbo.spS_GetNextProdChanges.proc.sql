Use Vivaldi;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'dbo.spS_GetNextProdChanges') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE dbo.spS_GetNextProdChanges
GO

CREATE PROCEDURE dbo.spS_GetNextProdChanges
	@RefDate datetime
AS

SET NOCOUNT ON;

/* 
	TO-DO LIST
*/

----------------------------------------------------------------------

SELECT C.PerfId
		, C.FundCode
		, P2.FundName AS CurrentFundName
		, C.FundNameNew AS NewFundName
		, C.InvManagerNew AS NewInvManager
		, C.OurTeamNew	AS NewOMGITeam
		, C.OurPMNew AS NewOMGIPM
		, C.BenchNew AS NewBenchmark
		, (CASE C.SoldAsNew 
				WHEN 'OEIC' THEN 'Onshore' 
				WHEN 'UCITS4' THEN 'Offshore'
				ELSE '' END) AS Umbrella
		, E.FullName AS Event
		, C.EventCode
		, C.ChangeDate
		, C.MergeIntoPerfId AS MergeIntoId
		, P.FundName As MergeIntoName
		, P.ShortCode
		, C.CommentNote
		, (CASE C.EventCode
			WHEN 1 THEN 
				E.FullName + ' <b>Comment</b>: ' + CAST(ISNULL(C.CommentNote,'') AS nvarchar(max))
			WHEN 2 THEN
				P2.FundName + ' ('+ P2.ShortCode + ') ' + 
				(CASE WHEN C.MergeIntoPerfId IS NULL 
					THEN CAST(ISNULL(C.CommentNote,'') AS nvarchar(max)) 
					ELSE ' <b>merged</b> into: ' + P.ShortCode + 
						' (' + P.FundName + ')' END)
			WHEN 3 THEN
				'<b>InvManager</b>: ' + C.InvManagerNew + ' <b>OMGITeam</b>: ' +
				C.OurTeamNew + ' <b>OMGI PM</b>: ' + C.OurPMNew
			WHEN 4 THEN
				P2.FundName + ' ' + CAST(ISNULL(C.CommentNote,'') AS nvarchar(max)) 
			WHEN 5 THEN
				'<b>New benchmark</b>: ' + B.LongName
			END) AS EventString

FROM	tbl_ProductsChanges AS C LEFT JOIN
		tbl_EnumProdChangesTypes AS E ON (
			C.EventCode = E.Id
			) LEFT JOIN
		PerfRep.dbo.tbl_Products AS P ON (
			C.MergeIntoPerfid = P.Id
			) LEFT JOIN
		PerfRep.dbo.tbl_Products AS P2 ON (
			C.PerfId = P2.Id
			) LEFT JOIN
		PerfRep.dbo.tbl_Benchmarks AS B ON (
			C.BenchNew = B.Id
			)
WHERE	C.ChangeDate > @RefDate
ORDER BY E.Id, C.ChangeDate

-----------------------------------------------------------------

GO
GRANT EXECUTE ON dbo.spS_GetNextProdChanges TO [OMAM\Compliance]