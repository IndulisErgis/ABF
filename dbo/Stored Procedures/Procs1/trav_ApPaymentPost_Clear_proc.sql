
CREATE PROCEDURE dbo.trav_ApPaymentPost_Clear_proc
AS
BEGIN TRY

	/* clear PrepChk tables */
	DELETE dbo.tblApPrepChkCheck FROM dbo.tblApPrepChkCheck 
	INNER JOIN #PostTransList i ON i.TransId = dbo.tblApPrepChkCheck.BatchID 

	DELETE dbo.tblApPrepChkInvc FROM dbo.tblApPrepChkInvc
	INNER JOIN #PostTransList i ON i.TransId = dbo.tblApPrepChkInvc.BatchID 

	DELETE dbo.tblApPrepChkCntl FROM dbo.tblApPrepChkCntl
	INNER JOIN #PostTransList i ON i.TransId = dbo.tblApPrepChkCntl.BatchID 

	DELETE dbo.tblApPrepChkLog  FROM dbo.tblApPrepChkLog
	INNER JOIN #PostTransList i ON i.TransId = dbo.tblApPrepChkLog.BatchID 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_Clear_proc';

