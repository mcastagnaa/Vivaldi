USE Vivaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = 
		OBJECT_ID(N'[dbo].[tbl_VaRRepExceptStIn]') 
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_VaRRepExceptStIn]
GO

CREATE TABLE [dbo].[tbl_VaRRepExceptStIn](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportDate] [datetime] NOT NULL,
	[FundId] [int] NOT NULL,
	[ReportId] [int] NOT NULL,
	[SecTicker] [nvarchar](50) NOT NULL,
	[BBGInstrId] [nvarchar] (50),
	[ReasonFail] [nvarchar] (225) NOT NULL,
	[Position] [float],

 CONSTRAINT [PK_tbl_VaRRepExceptStIn] PRIMARY KEY CLUSTERED 
(
	[ID] ASC

) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [ReportId] ON [dbo].[tbl_VaRRepExceptStIn] 
(
	[ReportId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [FundId] ON [dbo].[tbl_VaRRepExceptStIn] 
(
	[FundId] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ReportDate] ON [dbo].[tbl_VaRRepExceptStIn] 
(
	[ReportDate] ASC
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [SecTicker] ON [dbo].[tbl_VaRRepExceptStIn] 
(
	[SecTicker] ASC
) ON [PRIMARY]
