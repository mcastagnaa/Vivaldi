USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_EnumSingleFundReports]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_EnumSingleFundReports]
GO

CREATE TABLE [dbo].[tbl_EnumSingleFundReports](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportName] [nvarchar](30) NOT NULL,
	[Description] [nvarchar](100) NULL,
 CONSTRAINT [tbl_EnumSingleFundReports_PK] PRIMARY KEY NONCLUSTERED 

(
                [ID]
) ON [PRIMARY]
) ON [PRIMARY]
GO

