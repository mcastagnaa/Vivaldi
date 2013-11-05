USE VIVALDI;
GO

ALTER TABLE tbl_VaRReportsPORT
ALTER COLUMN SecTicker nvarchar(50)

ALTER TABLE tbl_VaRReportsPORT
ALTER COLUMN BBGInstrId nvarchar(50) not null

ALTER TABLE tbl_VaRReportsPORT
ALTER COLUMN SecName nvarchar(50)

GO
