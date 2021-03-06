USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_VaRModels]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_VaRModels]
GO

CREATE TABLE [dbo].[tbl_VaRModels](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShortName] [nvarchar](10) NOT NULL,
	[LongName] [nvarchar](100) NULL,
 CONSTRAINT [tbl_VaRModels_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO