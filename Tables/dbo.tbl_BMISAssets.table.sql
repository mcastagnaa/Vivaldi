USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects 
WHERE id = OBJECT_ID(N'[dbo].[tbl_BMISAssets]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_BMISAssets]
GO

CREATE TABLE [dbo].[tbl_BMISAssets](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AssetName] [nvarchar](25) NOT NULL,
	[PricePercChangeMethod] bit NOT NULL,
	[PriceDivider] [int] NOT NULL,
	[SecGroup] [nvarchar] (20)
 CONSTRAINT [tbl_BMISAssets_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO