USE RM_PTFL
GO



DECLARE @RefDate datetime
SET @RefDate = '2009-9-21'


CREATE TABLE #RawData (
	FundCode		int
        , PositionsCount	int
	, GrossExposure		float
	, NetExposure		float
	, LMV			float
	, SMV			float
	, TopTicker		nvarchar(30)
	, TopSecPerc		float
	, BotTicker		nvarchar(30)
	, BotSecPerc		float
	, TopIndSec		nvarchar(40)
	, TopIndSecNetExp	float
	, TopIndSecLong		float
	, TopIndSecShort	float
	, BotIndSec		nvarchar(40)
	, BotIndSecNetExp	float
	, BotIndSecLong		float
	, BotIndSecShort	float
	, TopCountry		nvarchar(100)
	, TopCountryNetExp	float
	, TopCountryLong	float
	, TopCountryShort	float
	, BotCountry		nvarchar(100)
	, BotCountryNetExp	float
	, BotCountryLong	float
	, BotCountryShort	float                           
	)	

------------------------------------------------------------------------------------------

INSERT INTO #RawData
EXEC spS_GenerateFundDetailsByDate @RefDate

------------------------------------------------------------------------------------------


	
FROM #RawData
------------------------------------------------------------------------------------------
DROP TABLE #RawData
