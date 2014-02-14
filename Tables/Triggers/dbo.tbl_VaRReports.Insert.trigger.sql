USE VIVALDI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (	SELECT * 
		FROM dbo.sysobjects 
		WHERE id = OBJECT_ID(N'dbo.tbl_VaRReports$Insert') 
			AND OBJECTPROPERTY(id, N'IsTrigger') = 1)

DROP TRIGGER dbo.tbl_VaRReports$Insert
GO

CREATE TRIGGER dbo.tbl_VaRReports$Insert
   ON dbo.tbl_VaRReports AFTER INSERT
AS 
	UPDATE tbl_VaRReports
	
	SET 	BBGInstrId = 'VaRTotal' 
		, UnusedID = null
		, SecName = null
	FROM tbl_VaRReports AS V JOIN INSERTED AS I ON
		(V.ReportDate = I.ReportDate
		AND V.ReportId = I.ReportId
		AND V.SecTicker = I.SecTicker)
	WHERE V.SecTicker = 'Totals'

	UPDATE	tbl_VaRReports
	SET		BBGInstrId = 'EQ0000000033226494'
	FROM	tbl_VaRReports AS V JOIN INSERTED AS I ON
			(V.ReportDate = I.ReportDate
				AND V.ReportId = I.ReportId
				AND V.SecTicker = I.SecTicker)
	WHERE	I.BBGInstrId = 'EQ0000000012165557'
GO








