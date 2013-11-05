USE RM_PTFL
GO

CREATE NONCLUSTERED INDEX [ISOIdx] ON [dbo].[tbl_FxQuotes] 
(
	[ISO] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [LastQuoteDateIdx] ON [dbo].[tbl_FxQuotes] 
(
	[LastQuoteDate] ASC
) ON [PRIMARY]
