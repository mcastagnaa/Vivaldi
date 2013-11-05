USE Vivaldi
GO

ALTER TABLE tbl_FuturesData
	ADD ConvFactor float NULL
GO

ALTER TABLE tbl_FuturesData
	ADD CTD nVarChar(30)
GO