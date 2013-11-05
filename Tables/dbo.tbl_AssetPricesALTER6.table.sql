USE RM_PTFL
GO

ALTER TABLE tbl_AssetPrices
	ADD GICSSector nvarchar (40) NULL
GO
ALTER TABLE tbl_AssetPrices
	ADD GICSIndustry nvarchar (40) NULL
GO

