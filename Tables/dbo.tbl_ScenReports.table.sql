USE RM_PTFL
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_ScenReports]') 
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_ScenReports]
GO

CREATE TABLE [dbo].[tbl_ScenReports](
	[ReportDate] [datetime] NOT NULL,
	[FundId] [int] NOT NULL,
	[MktVal] [float] NOT NULL,
	[ReportId] [int] NOT NULL,
	[PortPerf] [float] NULL,
	[BenchPerf] [float] NULL,
 CONSTRAINT [PK_tbl_ScenReports] PRIMARY KEY CLUSTERED 
(
	[ReportDate] ASC,
	[FundId] ASC,
	[ReportId] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ReportId] ON [dbo].[tbl_ScenReports] 
(
	[ReportId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [FundId] ON [dbo].[tbl_ScenReports] 
(
	[FundId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ReportDate] ON [dbo].[tbl_ScenReports] 
(
	[ReportDate] ASC
) ON [PRIMARY]

