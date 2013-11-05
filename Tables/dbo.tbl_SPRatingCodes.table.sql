USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_SPRatingsCodes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_SPRatingsCodes]
GO

CREATE TABLE [dbo].[tbl_SPRatingsCodes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RatingSPBB] [nvarchar] (30) NOT NULL,
	[RankNo] int NOT NULL,
	[CleanRating] [nvarchar](30) NOT NULL,
 CONSTRAINT [tbl_tbl_SPRatingsCodes_PK] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO