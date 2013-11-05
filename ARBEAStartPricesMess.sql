Use vivaldi;
SELECT portfoliocode
		,[ID ISIN]
		, security
		, StartPrice
		, Units
FROM tbl_Vivaldi_stagein
WHERE PortfolioCode in ('ARBEA')
AND StartPrice = 0 OR StartPrice is NULL

/*
UPDATE tbl_vivaldi_stagein
SET startprice = 1698, [ID ISIN] = 'B4WQ2Z2'
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = '0147899'

UPDATE tbl_vivaldi_stagein
SET startprice = 290, [ID ISIN] = 'B62W232'
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = '0434256'

UPDATE tbl_vivaldi_stagein
SET startprice = 351.1, [ID ISIN] = 'B8C3BL0'
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = '0802165'

UPDATE tbl_vivaldi_stagein
SET startprice = 49.85
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = '4937579'

UPDATE tbl_vivaldi_stagein
SET startprice = 65.12
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = '7062713'

UPDATE tbl_vivaldi_stagein
SET startprice = 2.412
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = 'B09RG69'

UPDATE tbl_vivaldi_stagein
SET startprice = 14.59
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = 'B1W4V69'

UPDATE tbl_vivaldi_stagein
SET startprice = 24.41
WHERE portfoliocode = 'ARBEA' AND
[ID ISIN] = 'B11HK39'*/