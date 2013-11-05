USE RM_PTFL
GO

ALTER TABLE tbl_AssetPrices
	ADD Beta float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD ROE float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD EPSGrowth float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD SalesGrowth float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD BtP float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD DivYield float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD EarnYield float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD StP float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD EbitdaTP float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD MktCapLocal float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD MktCapUSD float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD Size Nvarchar(10) NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD Value NvarChar(10) NULL
GO
