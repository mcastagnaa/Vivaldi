USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_FormsSetup]')
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_FormsSetup]
GO

CREATE TABLE [dbo].[tbl_FormsSetup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FormName] [nvarchar](30) NOT NULL,
	[FormCaption] [nvarchar](100) NOT NULL,
	[Modal] bit DEFAULT 1 NOT NULL,
	[PopUp] bit DEFAULT 0 NOT NULL,
	[CloseButton] bit DEFAULT 0 NOT NULL,
	[BorderStyle] INT DEFAULT 1 NOT NULL,
	
 CONSTRAINT [tbl_FormsSetup_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO