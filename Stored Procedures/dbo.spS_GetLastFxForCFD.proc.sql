USE RM_PTFL
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_GetLastFxForCFD]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
	DROP PROCEDURE [dbo].[spS_GetLastFxForCFD]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spS_GetLastFxForCFD] 
	@RefDate datetime
AS
SET NOCOUNT ON;

SELECT	Quotes.ISO,
	Quote = 
	CASE 
		WHEN Quotes.ISO IN ('KRW', 'INR', 'TWD') THEN Quotes.LastQuote
		ELSE 1
	END
FROM	tbl_FxQuotes AS Quotes
WHERE	LastQuoteDate = @RefDate

GO

GRANT EXECUTE ON spS_GetLastFxForCFD TO [OMAM\StephaneD], [OMAM\MargaretA]		