USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects 
WHERE id = OBJECT_ID(N'[dbo].[tbl_InternalFoFs]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_InternalFoFs]
GO

CREATE TABLE [dbo].[tbl_InternalFoFs](
	[PositionId] [nvarchar] (20) NOT NULL,
	[Units] float NOT NULL,
	[SecurityType] [nvarchar](20) NOT NULL,
	[FundShortName] [nvarchar] (15) NOT NULL,
	[StartPrice] float NOT NULL,
	[PositionDate] datetime NOT NULL,
	[FundFeedSN] nvarchar(10) NOT NULL,
CONSTRAINT [tbl_InternalFoFs_PK] PRIMARY KEY NONCLUSTERED 
(
	[PositionId] ASC,
	[SecurityType] ASC,
	[FundShortName] ASC,
	[PositionDate] ASC,
	[FundFeedSN] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO