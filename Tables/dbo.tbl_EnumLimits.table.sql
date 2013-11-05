USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_EnumLimits]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_EnumLimits]
GO

CREATE TABLE [dbo].[tbl_EnumLimits](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ShortName] [nvarchar](10) NOT NULL,
	[LongName] [nvarchar](100) NULL,
 CONSTRAINT [tbl_EnumLimits_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO