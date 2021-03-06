USE RM_PTFL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT	* 
	FROM 	dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[trU_NonEquityFundamentals]') 
		AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
DROP TRIGGER [dbo].[trU_NonEquityFundamentals]
GO

CREATE TRIGGER [trU_NonEquityFundamentals]
   ON [dbo].[tbl_AssetPrices] AFTER INSERT
AS 

--DECLARE @RefDate AS Datetime
--SET @RefDate = (SELECT MAX(PriceDate) FROM tbl_AssetPrices)

UPDATE	tbl_AssetPrices
SET 	Beta = Null
	, ROE = Null
	, EPSGrowth = Null
	, SalesGrowth = Null
	, BtP = Null
	, DivYield = Null
	, EarnYield = Null
	, StP = Null
	, EbitdaTP = Null
	, MktCapLocal = Null
	, [Size] = Null
	, [Value] = Null
	, MktCapUSD = Null
WHERE	SecurityGroup<>'Equities'
--	AND PriceDate = @RefDate
