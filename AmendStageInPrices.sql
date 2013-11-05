USE VIVALDI

------- Price Set
DECLARE @Novatek float
DECLARE @Roseneft float
DECLARE @Sberbank float
DECLARE @UralKali float
DECLARE @MobileTles float

SET @Novatek = 118.5
SET @Roseneft = 7.17 
SET @Sberbank = 11.93
SET @Uralkali = 38.04
SET @MobileTles = 17.44


------- STARTING POINT
SELECT StartPrice, MarketPrice FROM tbl_Vivaldi_StageIn
WHERE PortfolioCode = 'GSAF'
AND	[ID ISIN] IN ('B0DK750', 'B17FSC2', 'B5SC091', 'B1FLM08', '2603225')

------- RUSSIAN STUFF
UPDATE tbl_Vivaldi_StageIn
SET StartPrice = @Novatek, MarketPrice = @Novatek
WHERE [ID ISIN] = 'B0DK750'

UPDATE tbl_Vivaldi_StageIn
SET StartPrice = @Roseneft, MarketPrice = @Roseneft
WHERE [ID ISIN] = 'B17FSC2'

UPDATE tbl_Vivaldi_StageIn
SET StartPrice = @Sberbank, MarketPrice = @Sberbank
WHERE [ID ISIN] = 'B5SC091'


UPDATE tbl_Vivaldi_StageIn
SET StartPrice = @Uralkali, MarketPrice = @Uralkali
WHERE [ID ISIN] = 'B1FLM08'

------- NULL PRICE THAT MIGHT GO AWAY
UPDATE tbl_Vivaldi_StageIn
SET StartPrice = @MobileTles, MarketPrice = @MobileTles
WHERE [ID ISIN] = '2603225'

------- CHECK
SELECT StartPrice, MarketPrice FROM tbl_Vivaldi_StageIn
WHERE PortfolioCode = 'GSAF'
AND	[ID ISIN] IN ('B0DK750', 'B17FSC2', 'B5SC091', 'B1FLM08', '2603225')