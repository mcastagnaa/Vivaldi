USE [RM_PTFL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[tbl_FundsFactorsLoads]') AND 
		OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
DROP TABLE [dbo].[tbl_FundsFactorsLoads]
GO

CREATE TABLE [dbo].[tbl_FundsFactorsLoads](
	FundId INT NOT NULL
	, StatDate datetime NOT NULL
	, FactorType nvarChar(20) NOT NULL
	, FactorName nvarChar(20) NOT NULL
	, Long float NULL
	, Short float NULL
	, Net float NULL

, CONSTRAINT [tbl_FundsFactorsLoads_PK] PRIMARY KEY NONCLUSTERED 

(
                [FundId],
		[StatDate],
		[FactorType],
		[FactorName]
) ON [PRIMARY]
) ON [PRIMARY]
GO

