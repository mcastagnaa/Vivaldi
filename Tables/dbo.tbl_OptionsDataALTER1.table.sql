USE RM_PTFL
GO

ALTER TABLE tbl_OptionsData
ADD UnderPrice float NULL
GO
ALTER TABLE tbl_OptionsData
ADD UnderPxScale float NULL
GO
ALTER TABLE tbl_OptionsData
ADD CCYUnder nvarchar(3) NULL
GO

