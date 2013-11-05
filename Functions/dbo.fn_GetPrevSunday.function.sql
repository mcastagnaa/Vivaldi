USE RM_PTFL
GO

IF EXISTS (
	SELECT 	* 
	FROM   	sys.objects 
	WHERE	type = 'FN' AND 
		name = 'fn_GetPrevSunday'
	)
DROP FUNCTION [dbo].[fn_GetPrevSunday]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET DATEFIRST 1
GO


CREATE FUNCTION [dbo].[fn_GetPrevSunday]
(
	@RefDate Datetime
)
RETURNS datetime
AS

BEGIN
	DECLARE @PrevSunday datetime,
		@DayOfTheWeek int;
	

	SET @DayOfTheWeek = DATEPART(dw, @RefDate)
	
	SET @PrevSunday = DATEADD(day, - @DayOfTheWeek, @RefDate)

	
		
	RETURN @PrevSunday
END

GO
