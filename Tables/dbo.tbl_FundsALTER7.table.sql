USE RM_PTFL
GO

ALTER TABLE tbl_Funds
	ADD  ADVField NVARCHAR (20) DEFAULT 'VolumeAvg20d'
GO

