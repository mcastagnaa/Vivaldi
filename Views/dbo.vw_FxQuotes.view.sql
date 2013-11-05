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
	, (SELECT PrevQuotes.LastQuote
		FROM tbl_FXQuotes AS PrevQuotes
		WHERE PrevQuotes.ISO = ActualQuotes.ISO
			AND PrevQuotes.LastQuoteDate = (SELECT MAX(LastQuoteDate)
							FROM	tbl_FXQuotes
							WHERE LastQuoteDate < ActualQuotes.LastQuoteDate)
	) AS PreviousQuote
	, CcyDetails.IsInverse
	, CcyDetails.Cluster
	, CcyDetails.Name

FROM	tbl_FXQuotes AS ActualQuotes LEFT JOIN
	tbl_CcyDetails AS CcyDetails ON
		(ActualQuotes.ISO = CcyDetails.ISO3)
	