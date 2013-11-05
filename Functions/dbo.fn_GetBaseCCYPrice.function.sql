USE Vivaldi
GO

IF EXISTS (
	SELECT 	* 
	FROM   	sys.objects 
	WHERE	type = 'FN' AND 
		name = 'fn_GetBaseCCYPrice'
	)
DROP FUNCTION [dbo].[fn_GetBaseCCYPrice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetBaseCCYPrice]
(
	
	@GrossPrice float,
	@PriceCCYQuote float,
	@PriceCCYIsInverted bit,
	@BaseCCYQuote float,
	@BaseCCYIsInverted bit,
	@AssetType as nvarchar (30),
	@IsStartPrice as bit
	
)
RETURNS float
AS

BEGIN
	DECLARE 
		@BaseCCYPrice float,
		@numerator float,
		@denominator float
	
	IF @AssetType in ('Fx'
			, 'FutOft'
			, 'Cash'
			, 'CashOft'
			, 'CD')
		BEGIN
		SET @BaseCCYPrice = @GrossPrice
		IF @PriceCCYIsInverted = 0 
			BEGIN
				SET @BaseCCYPrice = POWER(@GrossPrice,-1)
			END
		IF @IsStartPrice = 0 
			BEGIN
				SET @denominator = @BaseCCYQuote
				IF @BaseCCYIsInverted = 0 
					BEGIN
						SET @denominator = POWER(@BaseCCYQuote,-1)
					END
				IF @denominator <> 0 
				BEGIN
					SET @BaseCCYPrice = @BaseCCYPrice/@denominator
				END
			END
		END
				
	ELSE IF @AssetType in ('CFD'
				, 'CFDi'
				, 'Equities'
				, 'IndexFut'
				, 'Derivatives'
				, 'BondFut'
				, 'IntRateFut'
				, 'CCyFut'
				, 'IndexOpt'
				, 'EqOpt'
				, 'CCyOpt'
				, 'BondFutOpt'
				, 'IntRateOpt'
				, 'Others'
				, 'Bonds'
				, 'Placing'
				, 'MMFunds'
				, 'TBills'
				, 'AgsCmdtFut'
				, 'EngyCmdtFut'
				, 'BMtlCmdtFut'
				, 'PMtlCmdtFut'
				, 'CDS'
				, 'CDSIndex')
		BEGIN
		SET @numerator = @PriceCCYQuote
		IF @PriceCCYIsInverted = 0
			BEGIN
				SET @numerator = POWER(@PriceCCYQuote, -1)
			END
		SET @denominator = @BaseCCYQuote
		IF @BaseCCYIsInverted = 0
			BEGIN
				SET @denominator = POWER(@BaseCCYQuote,-1)
			END
		SET @BaseCCYPrice = 1000000
		IF @denominator <> 0
			BEGIN
			SET @BaseCCYPrice = @GrossPrice * @numerator/@denominator
			END
		END
	ELSE
		BEGIN 
			SET @BaseCCYPrice =0
		END

RETURN @BaseCCYPrice
END

GO
