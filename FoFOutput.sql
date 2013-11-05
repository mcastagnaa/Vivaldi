USE VIVALDI; 

SELECT	LtFoFs.*
	, UnderFunds.BaseCCYId AS UnderFundCCYId
	, CCYUnderFunds.ISO3 AS UnderfundCCY
	, LEFT(LtFoFs.FundShortName,LEN(LtFoFs.FundShortName)-3) AS FoFName
	, ISNULL(AssetGroup.SecGroup, LtFoFs.SecurityType) AS AssetGroup

INTO	#RawData
	
FROM	tbl_InternalFoFs AS LtFoFs LEFT JOIN
		tbl_Funds AS UnderFunds ON (
--		LEFT(LtFoFs.FundShortName,LEN(LtFoFs.FundShortName)-3) = UnderFunds.FundCode
		LtFoFs.FundFeedSN = UnderFunds.FundCode
	) LEFT JOIN tbl_CcyDetails AS CCYUnderFunds ON (
		Underfunds.BaseCCYId = CCYUnderFunds.Id
	) LEFT JOIN tbl_BMISAssets AS AssetGroup ON (
		LtFoFs.SecurityType = AssetGroup.AssetName
	)

WHERE	LtFoFs.FundShortName = 'SMFO_LT'
	AND LtFoFs.PositionDate = '2013/09/27'

----------------------------------------------------------------------------------

SELECT	PositionId
	, AVG(StartPrice) AS GBPStartP

INTO	#GBPCashFxSP

FROM #RawData

WHERE	AssetGroup = 'CashFx'
	AND UnderFundCCY = 'GBP'
GROUP BY	PositionId

----------------------------------------------------------------------------------


SELECT	RawData.*
	, (CASE RawData.AssetGroup
		WHEN 'CashFx' THEN GBPBase.GBPStartP
		ELSE RawData.StartPrice
		END) AS GBPStartPrice

INTO	#FinalDataSet

FROM	#RawData AS RawData LEFT JOIN
	#GBPCashFxSP AS GBPBase ON (
		RawData.PositionId = GBPBase.PositionId
	)

----------------------------------------------------------------------------------

SELECT	PositionId
	, SUM(Units) AS Units
	, SecurityType
	, FundShortName AS Fund
	, AVG(GBPStartPrice) AS StartPrice
	, PositionDate

--	, 'FLT' AS BOShortName

FROM	#FinalDataSet
GROUP BY	 PositionId, SecurityType, FundShortName, PositionDate


DROP TABLE #RawData
DROP TABLE #GBPCashFxSP
DROP TABLE #FinalDataSet

