USE Vivaldi
GO

ALTER TABLE tbl_EnumVaRReports
	ADD PORTFileName nvarchar(25)
GO
ALTER TABLE tbl_EnumVaRReports
	ADD PORTFileLast datetime
GO