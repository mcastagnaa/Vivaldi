USE RM_PTFL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD3m float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD6m float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD1y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD2y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD3y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD4y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD5y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD6y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD7y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD8y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD9y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD10y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD15y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD20y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD25y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD KRD30y float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD EffDur float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD InflDur float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD RealDur float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD SpreadDur float NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD CoupType nvarchar(30) NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD Bullet bit NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD SecType Nvarchar(30) NULL
GO

ALTER TABLE tbl_AssetPrices
	ADD CollType NvarChar(30) NULL
GO
