USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE	id = OBJECT_ID(N'[dbo].[tbl_FundsPeopleRoles]')
		AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_FundsPeopleRoles]
GO

CREATE TABLE [dbo].[tbl_FundsPeopleRoles](
	[FundId] [int] NOT NULL,
	[PeopleId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [tbl_FundsPeopleRoles_PK] PRIMARY KEY NONCLUSTERED 
(
	[FundId] ASC,
	[PeopleId] ASC,
	[RoleId] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO