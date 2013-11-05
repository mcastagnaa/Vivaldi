USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_Funds]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_Funds]
GO

CREATE TABLE [dbo].[tbl_Funds](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FundCode] [nvarchar] (15) NOT NULL,
	[FundName] [nvarchar](100) NOT NULL,
	[BaseCCYId] [int] NOT NULL,
	[VaRModelId] [int] NOT NULL,
	[ConfidenceInt] [float] NOT NULL,
	[Horizon] [nvarchar] (10) NOT NULL,
	[Lookback] [nvarchar] (10) NOT NULL,
	[FundClassId] [int] NULL,
	[BenchmarkId] [int] NULL,
	[Skip] [bit] NOT NULL,
	[Alive] [bit] NOT NULL,
	[VehicleId] [int] NULL,
	[VehStrategyId] [int] NULL,
	[StyleId] [int] NULL,
	[RefFund] [int] NULL,
	[BackOfficeId] [int] NULL,
 CONSTRAINT [tbl_Funds_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO