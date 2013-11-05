USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_EnumFiMktSector]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_EnumFiMktSector]
GO

CREATE TABLE [dbo].[tbl_EnumFiMktSector](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Group] [nvarchar](20) NULL,
 CONSTRAINT [tbl_EnumFiMktSector_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO