USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'[dbo].[tbl_OptionsData]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE [dbo].[tbl_OptionsData]
GO

CREATE TABLE [dbo].[tbl_OptionsData](
	[PriceDate] datetime NOT NULL,
	[SecurityId] nvarchar (30) NOT NULL,
	[SecurityType] nvarchar (30) NOT NULL,
	[Description] nvarchar (30) NULL,
	[CallPut] nvarchar (1) NOT NULL,
	[Strike] float NOT NULL,
	[ExpiryDate] datetime NOT NULL,
	[IsCashSettle] bit null,
	[Delta] float NULL,
	[Gamma] float NULL,
	[Vega] float NULL,
	[DaysToExp] float NULL,
	[Underlying] nvarchar (30) NULL,
	[UnderMult] float NULL,
	[UnderEffDur] float NULL
	
 CONSTRAINT [tbl_OptionsData_PK] PRIMARY KEY NONCLUSTERED 
(
	[PriceDate] ASC,
	[SecurityId] ASC,
	[SecurityType] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO