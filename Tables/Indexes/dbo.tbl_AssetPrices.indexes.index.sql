USE RM_PTFL
GO

CREATE NONCLUSTERED INDEX [PriceDateIdx] ON [dbo].[tbl_AssetPrices] 
(
	[PriceDate] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [SecurityIdIdx] ON [dbo].[tbl_AssetPrices] 
(
	[SecurityId] ASC
) ON [PRIMARY]
