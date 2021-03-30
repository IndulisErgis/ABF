
CREATE PROCEDURE dbo.trav_PcRevenueAdjustPost_Purge_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE
	@PostRun as dbo.pPostRun,
	@BatchId as pBatchID,
	@PcGlDetailYn bit,
	@ArGlYn bit

	--Retrieve Global Values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PcGlDetailYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PcGlDetailYn'
	SELECT @BatchId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BatchId'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	IF @PostRun IS NULL OR @PcGlDetailYn IS NULL OR @BatchId IS NULL OR @ArGlYn IS NULL
	BEGIN  
		RAISERROR(90025,16,1)  
	END

	IF EXISTS(SELECT TOP 1 * FROM #PostSummary t WHERE t.[BatchId] = @BatchId)
		DELETE r 
		FROM dbo.tblPcRevenueAdjust r
		INNER JOIN dbo.tblPcRevenueAdjustBatch b ON b.Id = r.AdjustBatchID
		WHERE b.BatchID = @BatchId

	DELETE b FROM tblPcRevenueAdjustBatch b
	INNER JOIN #PostSummary t ON t.BatchID = b.BatchID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcRevenueAdjustPost_Purge_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcRevenueAdjustPost_Purge_proc';

