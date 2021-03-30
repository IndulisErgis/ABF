
CREATE PROCEDURE dbo.trav_PcPrepareBilling_StartOver_proc
@BatchId pBatchId,
@DeleteBatch bit
AS
BEGIN TRY

	DELETE dbo.tblPcWIPDetailFixedFee WHERE BatchId = @BatchId

	DELETE dbo.tblPcWIPDetail WHERE BatchId = @BatchId
	
	DELETE dbo.tblPcWIPHeader WHERE BatchId = @BatchId
	
	IF (@DeleteBatch = 1)
	BEGIN
		DELETE dbo.tblPcWIPControl WHERE BatchId = @BatchId
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareBilling_StartOver_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareBilling_StartOver_proc';

