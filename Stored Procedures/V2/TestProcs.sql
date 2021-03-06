USE VIVALDI;

DECLARE @Today AS datetime
SET @Today = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)

--EXEC dbo.spS_GetFundsDetailsByDateUKSEF 0.2
EXEC dbo.spS_GetFundsDetailsByDate_V2 @today, null , null
--EXEC dbo.spS_GetNaVPLExpData_V2 '2015-4-20', null
--EXEC dbo.spS_GetFundsDetailsAndRiskByDate_V2 '12 Dec 2012', 18, null
--EXEC dbo.spS_CalcFundsStatistics_V2 '2012-12-12', null, null
--EXEC dbo.spS_GetFundsFactorsExposure_V2 '2012-12-12', null, null
--EXEC dbo.spS_HedgeFundsReport_V2 '2012-Dec-19', null
--EXEC dbo.spS_HFLimitsCheck_V2 '2012-12-12', null
--EXEC dbo.spS_FundFactorsPl_V2 '2012-12-12', 1
--EXEC dbo.spS_FundFactorsRisk_V2 '2012-12-12', 34
--EXEC spS_GetDerivativesData '2013-11-07', 35
--EXEC spS_GetDerivativesCashData '2012-12-12', 22	
--EXEC dbo.spS_VaRExceptions_V2 '2012-12-12', 21
--EXEC dbo.spS_FILessThan2y '2012-12-12', null, null
--EXEC dbo.spS_CheckMorningLoad '2012-12-12'
--EXEC dbo.spS_GetBondFundsWeights '2012-12-26'
--EXEC dbo.spS_Top10WeightsSum '2012-Dec-12', 42, null
--EXEC dbo.spS_GetUKDeskExpStats '2012-Dec-12'
--EXEC dbo.spS_CashReportByFundAllDates '2014-Jun-23', null
--EXEC spS_CashReportAllFunds '2014-Jun-23'
--EXEC dbo.spS_GetEqFundsLiquidity '2012-Dec-12', null
--EXEC dbo.spS_GetFundsDetailsByDate_KAIROS '2012-12-12', 43 , null
--EXEC dbo.spS_PricesCheckByDate '2012 Dec 12', 0.1, 0.05
--EXEC dbo.spS_VaRReportsDetailsByDate '2013 May 7', 3
--EXEC dbo.spS_GetPORTvsALGOVaR
--EXEC spU_AddVaRReportPORT
--EXEC dbo.spS_CheckFutOffsets '2013 Jun 24'
--EXEC spS_GetDerivativesCashData '2013-11-22', null
--EXEC spS_GetFoFsDetails '2014-Feb-6'

-------------------LIQUIDITY PROCS
--EXEC spS_LIQ_CalculateBFundsLoss '2011-Oct-26', null

--EXEC dbo.spS_GetFundsDetailsByDateAF_V2 '2011-7-5', null, null, 'B24CGK7'
--SELECT * FROM dbo.fn_GetCubeDataTable('5 Feb 2014', 128)-- WHERE BMISCode = 'G H3 Comdty'

--SELECT * FROM vw_TotalVarbYFundByDate WHERE FundId = 18 AND VaRDate = '1 Nov 2012'

--EXEC dbo.spS_GetScenariosByFundByDate '2012 Nov 1', 18

--EXEC dbo.spS_GetLastProdChanges '2013 Jul 3', 3
--EXEC dbo.spS_GetNextProdChanges '2014 Aug 29'
--EXEC dbo.spS_OffsetCheck '2014 Dec 17'
--EXEC dbo.spS_CalcFutOffsets @Today
--EXEC spS_GetOMGIEqExp '19/Mar/2014', null

--EXEC spS_SegMatch '1/Aug/2014'
