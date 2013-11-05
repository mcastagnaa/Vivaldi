USE RM_PTFL
GO

IF EXISTS (
	SELECT 	* 
	FROM   	sys.objects 
	WHERE	type = 'FN' AND 
		name = 'fn_GetLongShort'
	)
DROP FUNCTION [dbo].[fn_GetLongShort]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetLongShort]
(
	@PositionSize float,
	@SecurityGroup nvarchar(30),
	@AssetCCY nvarchar(3),
	@FundCCY nvarchar(3)
	
)
RETURNS nvarchar(15)
AS

BEGIN
	DECLARE 
		@LongShortLabel nvarchar(15);
	
	IF @PositionSize >=0
		BEGIN
			SET @LongShortLabel = 'Long'
		END
	ELSE	
		BEGIN
			SET @LongShortLabel = 'Short'
		END

	IF @SecurityGroup = 'CashFx' AND @AssetCCY = @FundCCY
		BEGIN
			SET @LongShortLabel = 'CashBaseCCY'
		END
		
	RETURN @LongShortLabel
END

GO
