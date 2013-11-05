USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_BenchmData]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_BenchmData]
GO

CREATE TABLE [dbo].[tbl_BenchmData](
	[ID] int NOT NULL,
	[PriceDate] datetime NOT NULL,
	[Price] float NOT NULL,
	[Perf] float NOT NULL,
 CONSTRAINT [tbl_BenchmData_PK] PRIMARY KEY NONCLUSTERED 

(
                [ID],
		[PriceDate]
) ON [PRIMARY]
) ON [PRIMARY]
GO

