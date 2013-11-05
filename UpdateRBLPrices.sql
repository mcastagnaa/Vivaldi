USE VIVALDI
Go

-- !!!CHANGE THIS DATE!!!
DECLARE @RefDate datetime
SET @RefDate = '2013 Feb 19'

----------------------------------------------------------------------
--- First check (NOT REALLY NEEDED)

SELECT P.PositionId
		, P.FundShortName
		, P.StartPrice
		, A.PXLast
		, P.StartPrice/A.PXLAst As PxRatio
FROM Tbl_Positions AS P LEFT JOIN
		tbl_AssetPrices AS A ON (
				P.PositionId = A.SecurityId
				AND P.SecurityType = A.SecurityType
				AND P.PositionDate = A.PriceDate		
				)
WHERE PositionDate = @RefDate
	AND PositionId IN ('3189876', '5140989', 'B01WHG9', 'B0DK750'
					, 'B0RTNX3', 'B17FSC2', 'B1G4YH7', 'B1G50G1'
					, 'SBER S1')
ORDER BY PositionId

----------------------------------------------------------------------
--FOR NEW SECURITIES AMEND PRICES/SECURITY LIST HERE

CREATE TABLE #RublStPx (SecurityId NVarchar(7), StPx float); 
INSERT INTO #RublStPx VALUES ('3189876', 65.95);
INSERT INTO #RublStPx VALUES ('5140989', 8.96);
INSERT INTO #RublStPx VALUES ('B01WHG9', 10.02);
INSERT INTO #RublStPx VALUES ('B0DK750', 117.4);
INSERT INTO #RublStPx VALUES ('B0RTNX3', 20.34);
INSERT INTO #RublStPx VALUES ('B17FSC2', 8.38);
INSERT INTO #RublStPx VALUES ('B1G4YH7', 12.11);
INSERT INTO #RublStPx VALUES ('B1G50G1', 44.31);
INSERT INTO #RublStPx VALUES ('SBER S1', 14.165);
----------------------------------------------------------------------
UPDATE tbl_Positions
SET	StartPrice = GoodPx.StPx 
FROM #RublStPx AS GoodPx JOIN tbl_Positions AS P ON (
				Goodpx.SecurityId = P.PositionId
				)
-- AND HERE
WHERE	P.PositionDate = @RefDate
		AND P.PositionId IN ('3189876', '5140989', 'B01WHG9', 'B0DK750'
					, 'B0RTNX3', 'B17FSC2', 'B1G4YH7', 'B1G50G1'
					, 'SBER S1')
DROP TABLE #RublStPx
----------------------------------------------------------------------
--- Second check (NOT REALLY NEEDED)

SELECT P.PositionId
		, P.StartPrice
		, A.PXLast
		, P.StartPrice/A.PXLAst As PxRatio
FROM Tbl_Positions AS P LEFT JOIN
		tbl_AssetPrices AS A ON (
				P.PositionId = A.SecurityId
				AND P.SecurityType = A.SecurityType
				AND P.PositionDate = A.PriceDate		
				)
WHERE PositionDate = @RefDate
	AND PositionId IN ('3189876', '5140989', 'B01WHG9', 'B0DK750'
					, 'B0RTNX3', 'B17FSC2', 'B1G4YH7', 'B1G50G1'
					, 'SBER S1')
ORDER BY PositionId