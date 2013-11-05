USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE id = OBJECT_ID(N'dbo.tbl_CDSData') AND OBJECTPROPERTY(id, N'IsUserTable') = 1
	)
	DROP TABLE dbo.tbl_CDSData
GO

CREATE TABLE dbo.tbl_CDSData(
	PositionId nvarchar (30) NOT NULL
	, SecurityType nvarchar (20) NOT NULL
	, BuySell nvarchar (4) NOT NULL
	, PayFreq nvarchar(3) NOT NULL
	, Maturity datetime
	, RecRate float
	, NotionalSpread float
	, FlatSpread float
	, Premium float
	, Accrued float
	, Model nvarchar(3)
	, PrevMtM float
	, DataDate datetime not null
	,
 CONSTRAINT [tbl_CDSData_PK] PRIMARY KEY NONCLUSTERED 
(
	PositionId ASC
	, SecurityType ASC
	, DataDate ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO