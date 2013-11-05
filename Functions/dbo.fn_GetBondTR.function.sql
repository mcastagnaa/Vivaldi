USE VIVALDI
GO

IF EXISTS (
	SELECT 	* 
	FROM   	sys.objects 
	WHERE	type = 'FN' AND 
		name = 'fn_GetBondTR'
	)
DROP FUNCTION [dbo].[fn_GetBondTR]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetBondTR]
(
	@MarketPrice float,
	@CostPrice float,
	@Accrual float,
	@1dAccrual float
	
)
RETURNS float
AS

BEGIN
	DECLARE 
		@BondTR float;
	SET @CostPrice = NULLIF(@CostPrice, 0)
	
	SET @BondTR =	(@MarketPrice + @Accrual + @1dAccrual) /
			(@CostPrice + @Accrual) - 1
		
	SET @BondTR = ISNULL(@BondTR, 0)	

	RETURN @BondTR
END

GO
