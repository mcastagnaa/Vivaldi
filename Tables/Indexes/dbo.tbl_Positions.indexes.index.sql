USE RM_PTFL
GO

CREATE NONCLUSTERED INDEX [PositionIdIdx] ON [dbo].[tbl_Positions] 
(
	[PositionId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [SecurityTypeIdx] ON [dbo].[tbl_Positions] 
(
	[SecurityType] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [FundShortNameIdx] ON [dbo].[tbl_Positions] 
(
	[FundShortName] ASC
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [PositionDateIdx] ON [dbo].[tbl_Positions] 
(
	[PositionDate] ASC
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [BOShortNameIdx] ON [dbo].[tbl_Positions] 
(
	[BOShortName] ASC
) ON [PRIMARY]
