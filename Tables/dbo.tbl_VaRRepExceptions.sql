USE RM_PTFL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_VaRRepExceptions]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_VaRRepExceptions]
GO

CREATE TABLE [dbo].[tbl_VaRRepExceptions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportDate] [datetime] NOT NULL,
	[FundId] [int] NOT NULL,
	[ReportId] [int] NOT NULL,
	[SecTicker] [nvarchar](15) NOT NULL,
	[BBGInstrId] [nvarchar] (25) NOT NULL,
	[ReasonFail] [nvarchar] (225) NOT NULL,
	[Position] [float] NOT NULL,

 CONSTRAINT [PK_tbl_VaRRepExceptions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC

) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ReportId] ON [dbo].[tbl_VaRRepExceptions] 
(
	[ReportId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [FundId] ON [dbo].[tbl_VaRRepExceptions] 
(
	[FundId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ReportDate] ON [dbo].[tbl_VaRRepExceptions] 
(
	[ReportDate] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [SecTicker] ON [dbo].[tbl_VaRRepExceptions] 
(
	[SecTicker] ASC
) ON [PRIMARY]
