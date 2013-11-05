USE RM_PTFL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_VaRReports]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_VaRReports]
GO

CREATE TABLE [dbo].[tbl_VaRReports](
	[ReportDate] [datetime] NOT NULL,
	[FundId] [int] NOT NULL,
	[ReportId] [int] NOT NULL,
	[SecTicker] [nvarchar](15) NOT NULL,
	[BBGInstrId] [nvarchar] (25) NOT NULL,
	[UnusedID] [nvarchar] (50) NULL,
	[SecName] [nvarchar](30) NULL,
	[NumSec] [int] NOT NULL,
	[PortShare] [float] NOT NULL,
	[BenchPerc] [float] NULL,
	[ActivePerc] [float] NULL,
	[MarketValThousands] [float] NOT NULL,
	[VAR] [float] NOT NULL,
	[VARPerc] [float] NULL,
	[VARBench] [float] NULL,
	[VARActive] [float] NULL,
	[MargVAR] [float] NULL,
	[PartVAR] [float] NULL,
	[CondVAR] [float] NOT NULL,
 CONSTRAINT [PK_tbl_VaRReports] PRIMARY KEY CLUSTERED 
(
	[ReportDate] ASC,
	[FundId] ASC,
	[ReportId] ASC,
	[BBGInstrId] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ReportId] ON [dbo].[tbl_VaRReports] 
(
	[ReportId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [FundId] ON [dbo].[tbl_VaRReports] 
(
	[FundId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ReportDate] ON [dbo].[tbl_VaRReports] 
(
	[ReportDate] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [SecTicker] ON [dbo].[tbl_VaRReports] 
(
	[SecTicker] ASC
) ON [PRIMARY]
