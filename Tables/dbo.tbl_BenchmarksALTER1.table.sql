USE RM_PTFL
GO

ALTER TABLE tbl_Benchmarks
	ADD  IsAvailable bit DEFAULT 0 NOT NULL
GO

