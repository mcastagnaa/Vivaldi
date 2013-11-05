USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_RegionsCodes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_RegionsCodes]
GO

CREATE TABLE [dbo].[tbl_RegionsCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RegionName] [nvarchar](100) NOT NULL,
 CONSTRAINT [tbl_RegionsCodes_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO