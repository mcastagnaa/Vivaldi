USE [Vivaldi]
GO
/****** Object:  Table [dbo].[tbl_MandateChecks]    Script Date: 07/29/2014 14:34:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_MandateChecks](
	[Id] int IDENTITY(1,1) PRIMARY KEY, 
	[RefDate] [datetime] NOT NULL,
	[SegId] [int] NOT NULL,
	[RefId] [int] NOT NULL,
	[SecurityGroup] [nvarchar](30) NOT NULL,
	[BMISCode] [nvarchar](30) NOT NULL,
	[BBGTicker] [nvarchar](40) NOT NULL,
	[SegW] [float] NOT NULL,
	[RefW] [float] NOT NULL,
	[AssetCCY] [nvarchar](3) NOT NULL,
	[IsCCYExp] [bit] NOT NULL
) ON [PRIMARY]
