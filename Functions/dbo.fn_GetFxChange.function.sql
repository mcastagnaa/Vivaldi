USE RM_PTFL
GO

IF EXISTS (
	SELECT 	* 
	FROM   	sys.objects 
	WHERE	type = 'FN' AND 
		name = 'fn_GetFxChange'
	)
DROP FUNCTION [dbo].[fn_GetFxChange]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetFxChange]
(
	@ACCYPrev float,
	@ACCYMkt float,
	@BCCYPrev float,
	@BCCYMkt float,
	@BCCYInv bit,
	@ACCYInv bit	
)
RETURNS float
AS

BEGIN
	DECLARE 
		@PrevBQuoteNum float,
		@PrevBQuoteDen float,
		@ActBquoteNum float,
		@ActBQuoteDen float,
		@FinalNumber float;
	
	SET @PrevBQuoteDen = @ACCYPrev
	SET @ActBQuoteDen = @ACCYMkt
	SET @PrevBQuoteNum = @BCCYPrev
	SET @ActBQuoteNum = @BCCYMkt


	IF @ACCYInv = 1
		BEGIN
			SET @ActBQuoteDen = POWER(@ACCYMkt,-1)
			SET @PrevBQuoteDen = POWER(@ACCYPrev,-1)
		END
	IF @BCCYInv = 1
		BEGIN
			SET @ActBQuoteNum = POWER(@BCCYMkt,-1)
			SET @PrevBQuoteNum = POWER(@BCCYPrev,-1)
		END

/*	SET @FinalNumber = (@ActBQuoteNum/@ActBQuoteDen)/(@PrevBQuoteNum/@PrevBQuoteDen) - 1*/

/*	IF @BCCYInv = 1
		BEGIN
			SET @FinalNumber = @FinalNumber
		END*/

	RETURN (@ActBQuoteNum/@ActBQuoteDen)/(@PrevBQuoteNum/@PrevBQuoteDen) - 1
END

GO
