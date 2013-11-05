USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_People]') AND 
			OBJECTPROPERTY(id, N'IsUserTable') = 1
)
DROP TABLE [dbo].[tbl_People]
GO

CREATE TABLE [dbo].[tbl_People](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(30) NULL,
	[Surname] nvarchar(30) NULL,
	[ShortCode] nvarchar(4) NOT NULL,
	[email] nvarchar(30) NULL,
	[extension] integer NULL
 CONSTRAINT [tbl_People_PK] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO