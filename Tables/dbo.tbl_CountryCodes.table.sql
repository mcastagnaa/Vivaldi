USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_CountryCodes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_CountryCodes]
GO

CREATE TABLE [dbo].[tbl_CountryCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ISOCode] [nvarchar](10) NOT NULL,
	[CountryName] [nvarchar](100) NOT NULL,
	[RegionID] int NOT NULL,
 CONSTRAINT [tbl_CountryCodes_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO