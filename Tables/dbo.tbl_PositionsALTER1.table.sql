USE RM_PTFL
GO

-- This one takes quite long time (about 1minute on 5/8/2010) to run


ALTER TABLE tbl_Positions
DROP CONSTRAINT tbl_Positions_PK
GO

ALTER TABLE tbl_Positions
ALTER COLUMN PositionId nvarchar(30) NOT NULL
GO

ALTER TABLE tbl_Positions
ADD CONSTRAINT [tbl_Positions_PK] PRIMARY KEY NONCLUSTERED 
(
	[PositionId] ASC,
	[SecurityType] ASC,
	[FundShortName] ASC,
	[PositionDate] ASC
)

GO

