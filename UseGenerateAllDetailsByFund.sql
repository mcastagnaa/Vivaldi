DECLARE @RC int
DECLARE @FundId int
DECLARE @StartDate datetime
DECLARE @EndDate datetime
DECLARE @PercDayVol float
-- Set 

SET @FundId = 5
SET @StartDate = '2010-May-15'
Set @EndDate = '2010-May-28'
SET @PercDayVol = 0.1

EXEC @RC = [RM_PTFL].[dbo].[spS_GenerateAllDetailsByFund] @FundId, @StartDate, @EndDate, @PercDayVol