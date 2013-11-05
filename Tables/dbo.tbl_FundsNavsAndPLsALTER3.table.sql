USE RM_PTFL
GO

ALTER TABLE tbl_FundsNavsAndPLs
	ADD NetExposure float DEFAULT 0 NOT NULL
GO

ALTER TABLE tbl_FundsNavsAndPLs
	ADD GrossExposure float DEFAULT 0 NOT NULL
GO
