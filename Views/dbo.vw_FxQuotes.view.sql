USE Vivaldi
GO

IF  EXISTS (
SELECT 	* FROM dbo.sysobjects 
WHERE 	id = OBJECT_ID(N'[dbo].[vw_FxQuotes]') AND 
	OBJECTPROPERTY(id, N'IsView') = 1
)
DROP VIEW [dbo].[vw_FxQuotes]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FxQuotes]
AS



SELECT	 CcyDetails.Id
	, ActualQuotes.ISO
	, ActualQuotes.LastQuoteDate AS FXQuoteDate
	, ActualQuotes.BBGCode
	, ActualQuotes.LastQuote
	, ActualQuotes.PreviousQuote
--	, (SELECT PrevQuotes.LastQuote
--		FROM tbl_FXQuotes AS PrevQuotes
--		WHERE PrevQuotes.ISO = ActualQuotes.ISO
--			AND PrevQuotes.LastQuoteDate = (SELECT MAX(LastQuoteDate)
--							FROM	tbl_FXQuotes
--							WHERE LastQuoteDate < ActualQuotes.LastQuoteDate)
--	) AS PreviousQuote
-- The commented-out version would keep a continous record of FX performances
-- but it requires the full TS of the FX quotes. On 20.4.2015 NGN and RON where
-- added without adding that full TS which is in the way of pulling this view
-- as it was pulled before.
	, CcyDetails.IsInverse
	, CcyDetails.Cluster
	, CcyDetails.Name

FROM	tbl_FXQuotes AS ActualQuotes LEFT JOIN
	tbl_CcyDetails AS CcyDetails ON
		(ActualQuotes.ISO = CcyDetails.ISO3)
	