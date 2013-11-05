SELECT	*
INTO	#DerivDets
FROM 	dbo.fn_GetCubeDataTable('31 jan 2011', null)
WHERE 	IsDerivative = 1
	AND SecurityType <> 'FutOft'
ORDER BY	FundCode

---------------------------------------------------------------------------------------

SELECT 	DDets.FundId
	DDets.FundCode
	DDets.SecurityGroup
	DDets.SecurityType
	DDets.BMISCode AS Code
	DDets.BBGTicker AS Description
	DDets.UnderlyingCTD AS Underlying
	DDets.PositionSize AS Position
	DDets.IndustrySector AS Sector
	DDets.OptDelta AS OptionDelta
	DDets.OptGamma AS OptionGamma
	DDets.OptVega AS OptionVega
	DDets.OptDaysToExp AS DaysToExpiry
	DDets.BaseCCYExposure


---------------------------------------------------------------------------------------

DROP TABLE	#DerivDets