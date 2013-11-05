USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tbl_MiscellaneousKeys]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[tbl_MiscellaneousKeys]
GO

CREATE TABLE [dbo].[tbl_MiscellaneousKeys](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[keyName] [nvarchar](50) NOT NULL,
	[keyValue] [nvarchar](1000) NULL,
 CONSTRAINT [tblMiscellaneousKeys_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO