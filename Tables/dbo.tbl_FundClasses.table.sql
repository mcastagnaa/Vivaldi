USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_FundClasses]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_FundClasses]
GO

CREATE TABLE [dbo].[tbl_FundClasses](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShortName] [nvarchar](10) NOT NULL,
	[LongName] [nvarchar](100) NULL,
 CONSTRAINT [tbl_FundClasses_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO