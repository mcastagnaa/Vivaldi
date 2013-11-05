DECLARE @RC int
DECLARE @FundId int
DECLARE @ValuationDate datetime
DECLARE @PercDayVol float
-- Set 

SET @FundId = 73
SET @ValuationDate = '2010-Aug-5'
SET @PercDayVol = 0.1

EXEC @RC = [RM_PTFL].[dbo].[spS_GenerateFundDetailsByDate] @ValuationDate, @FundId, @PercDayVol