USE VIvaldi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (
	SELECT * FROM dbo.sysobjects 
	WHERE 	id = OBJECT_ID(N'[dbo].[spS_Compl_EqHoldings]') AND 
		OBJECTPROPERTY(id,N'IsProcedure') = 1
	)
DROP PROCEDURE [dbo].[spS_Compl_EqHoldings]
GO

CREATE PROCEDURE [dbo].[spS_Compl_EqHoldings] 
	@RefDate datetime 
AS

SET NOCOUNT ON;



SELECT	Positions.PositionDate
	, Positions.PositionId
	, Assets.Description
	, Assets.CountryISO AS Country
	, Countries.CountryName AS CountryLong
	, Assets.CCYISO AS Currency
	, Positions.Units AS FundsUnits
	, CFDShorts =
		CASE
			WHEN Assets.SecurityType = 'CFD' AND Positions.Units < 0 THEN
				Positions.Units
			ELSE 0
		END
	, MktUnits = 
		CASE 
			WHEN Assets.DivBy100 = 1 THEN
				ROUND(Assets.MktCapLocal/(Assets.PxLast/100),0)
			ELSE
				ROUND(Assets.MktCapLocal/Assets.PxLast,0)
		END

INTO	#FirstPass

FROM	tbl_Positions AS Positions LEFT JOIN
	tbl_AssetPrices AS Assets ON (
		Positions.PositionDate = Assets.PriceDate
		AND Positions.PositionId = Assets.SecurityId
		AND Positions.SecurityType = Assets.SecurityType
		) LEFT JOIN
	tbl_CountryCodes AS Countries ON (
		Assets.CountryISO = Countries.ISOCode
		)

WHERE	Assets.SecurityGroup = 'Equities'
	AND Assets.SecurityType <> 'Derivatives'
	AND Assets.IndustrySector <> 'funds'
	AND Positions.PositionDate = @RefDate
	AND Assets.CCyISO <> '---'

---------------------------------------------------------

SELECT	FirstPass.PositionDate
	, FirstPass.Description
	, FirstPass.PositionId
	, FirstPass.Country
	, FirstPass.CountryLong
	, FirstPass.Currency
	, SUM(FirstPass.FundsUnits) - SUM(FirstPass.CFDShorts) AS TotalUnits
	, AVG(FirstPass.MktUnits) AS MktUnits
	, (SUM(FirstPass.FundsUnits) - SUM(FirstPass.CFDShorts))/AVG(FirstPass.MktUnits) AS OMAMPercentage

FROM	#FirstPass AS FirstPass

GROUP By	FirstPass.PositionDate
		, FirstPass.Description
		, FirstPass.Country
		, FirstPass.CountryLong
		, FirstPass.Currency
		, FirstPass.PositionId


---------------------------------------------------------

DROP TABLE #FirstPass

---------------------------------------------------------

GO

GRANT EXECUTE ON spS_Compl_EqHoldings TO [OMAM\StephaneD]
					, [OMAM\MargaretA]
					, [OMAM\Compliance]
					, [OMAM\JaneD]
					, [OMAM\ChrisP]	
