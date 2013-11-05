USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_FxQuotes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_FxQuotes]
GO

CREATE TABLE [dbo].[tbl_FxQuotes](
	[ISO] [nvarchar] (3) NOT NULL,
	[BBGCode] [nvarchar] (30) NOT NULL,
	[LastQuote] float NOT NULL,
	[PreviousQuote] float NOT NULL,
	[LastQuoteDate] datetime NOT NULL,
 CONSTRAINT [tbl_FxQuotes_PK] PRIMARY KEY NONCLUSTERED 
(
	[ISO] ASC,
	[LastQuoteDate] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO