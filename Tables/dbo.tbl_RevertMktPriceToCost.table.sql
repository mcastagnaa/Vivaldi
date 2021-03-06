USE [RM_PTFL]
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_RevertMktPriceToCost]') 
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)

DROP TABLE [dbo].[tbl_RevertMktPriceToCost]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_RevertMktPriceToCost](
	[SecurityId] NVaRChar(15) NOT NULL,
	[RevertToCost] [bit] NOT NULL DEFAULT (1),
 CONSTRAINT [tbl_RevertMktPriceToCost_PK] PRIMARY KEY NONCLUSTERED 
(
	[SecurityId] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO
