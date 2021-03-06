USE [RM_PTFL]
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_CcyDetails]') 
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)

DROP TABLE [dbo].[tbl_CcyDetails]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CcyDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ISO3] [nchar] (3) NOT NULL,
	[BBGCode] [nchar] (15) NOT NULL,
	[Name] [nchar] (50) NOT NULL,
	[IsInverse] [bit] NOT NULL DEFAULT (0),
	[Cluster] [nvarchar](50) NULL,
 CONSTRAINT [tbl_CcyDetails_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [IX_Cluster] ON [dbo].[tbl_CcyDetails] 
(
	[Cluster] ASC
) ON [PRIMARY]
GO