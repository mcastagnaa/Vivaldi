USE RM_PTFL
GO

IF EXISTS (
	SELECT 	* 
	FROM   	sys.objects 
	WHERE	type = 'FN' AND 
		name = 'fn_GetPriceChange'
	)
DROP FUNCTION [dbo].[fn_GetPriceChange]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetPriceChange]
(
	@IsPurePriceChange bit,
	@StartPrice float,
	@EndPrice float,
	@BaseCCYQuote float,
	@IsBaseCCYInverted bit,
	@AssetCCYQuote float,
	@IsAssetCCYInverted bit
	
)
RETURNS float
AS

BEGIN
	DECLARE 
		@PriceChange float,
		@numerator float,
		@denominator float,
		@finalExp float,
		@multiplier INT;
	
	IF @IsPurePriceChange = 1
		BEGIN
			SET @PriceChange = 0
			IF @StartPrice <> 0
				BEGIN
				SET @PriceChange = (@EndPrice/@StartPrice - 1)				
				END
		END
	ELSE
		BEGIN
			SET @denominator = @BaseCCYQuote
			SET @numerator = @AssetCCYQuote
			SET @finalExp = 1
			SET @multiplier = -1
			IF @IsBaseCCYInverted = 1
				BEGIN
				SET @denominator =  POWER(@BaseCCYQuote, -1)
				--SET @multiplier = 1
				END
			--SET @multiplier = @multiplier * (-1)
			IF @IsAssetCCYInverted = 1
				BEGIN
				SET @numerator = POWER(@AssetCCYQuote, -1)
				SET @finalExp = -1
				SET @multiplier = @multiplier * (-1)
				END
		SET @PriceChange =  @multiplier * (POWER(@numerator/@denominator, @finalExp)/@StartPrice - 1)
		END
		
	RETURN @PriceChange
END

GO
