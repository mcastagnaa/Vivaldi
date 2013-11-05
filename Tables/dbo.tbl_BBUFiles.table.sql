USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects 
WHERE id = OBJECT_ID(N'[dbo].[tbl_BBUFiles]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_BBUFiles]
GO

CREATE TABLE [dbo].[tbl_BBUFiles](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar](25) NOT NULL,
	[LongName] [nvarchar](100) NOT NULL,
	[LastUpdated] datetime NOT NULL,
 CONSTRAINT [tbl_BBUFiles_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO