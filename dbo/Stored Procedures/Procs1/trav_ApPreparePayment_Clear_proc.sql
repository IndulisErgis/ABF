
CREATE PROCEDURE dbo.trav_ApPreparePayment_Clear_proc
@BatchID pBatchID,
@gApBatchYn bit
AS
BEGIN TRY 
	--clear checks
	DELETE FROM dbo.tblApPrepChkCheck
	WHERE (BatchID = @BatchID and @gApBatchYn = 1) OR @gApBatchYn = 0

	--clear invoices
	DELETE FROM dbo.tblApPrepChkInvc
	WHERE (BatchID = @BatchID and @gApBatchYn = 1) or @gApBatchYn = 0

	--clear control table
	DELETE FROM dbo.tblApPrepChkCntl
	WHERE (BatchID = @BatchID and @gApBatchYn = 1) or @gApBatchYn = 0

	--clear log
	DELETE FROM dbo.tblApPrepChkLog
	WHERE (BatchID = @BatchID and @gApBatchYn = 1) or @gApBatchYn = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPreparePayment_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPreparePayment_Clear_proc';

