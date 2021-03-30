
CREATE PROCEDURE dbo.trav_PcRevenueAdjustPost_History_proc
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE
	@PostRun dbo.pPostRun,
	@BatchId pBatchID,
	@WksDate datetime,
	@PcGlDetailYn bit,
	@ArGlYn bit,
	@AdjustDate datetime,
	@CompId dbo.pCompId,
	@BaseCurrency dbo.pCurrency

	--Retrieve Global Values
	SELECT @CompId = DB_NAME()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PcGlDetailYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PcGlDetailYn'
	SELECT @BatchId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BatchId'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	SELECT @AdjustDate = CONVERT(datetime, [Value]) FROM #GlobalValues WHERE [Key] = 'AdjustDate'
	SELECT @BaseCurrency = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'BaseCurrency'
	SELECT @WksDate = CONVERT(datetime, [Value]) FROM #GlobalValues WHERE [Key] = 'WksDate'
	IF @PostRun IS NULL OR @PcGlDetailYn IS NULL OR @BatchId IS NULL OR @ArGlYn IS NULL OR @AdjustDate IS NULL OR @BaseCurrency IS NULL
	BEGIN  
		RAISERROR(90025,16,1)  
	END 


	INSERT INTO dbo.tblPcHistoryRevenueAdjust(PostRun, ID, BatchID, ProjectID, ProjectName, 
												CustID, CustName, ProjectDescription, DistCode, Rep1Id, Rep2Id, ProjectManager, 
												FiscalPeriod, FiscalYear, AdjustDate, FixedFeeAmount, BilledAmount, EstimatedCost, EstimatedHour, 
												PostedCost, PostedHour, PercentCostCompletion, PercentHourCompletion, OverridePercent, 
												EarnedIncome, PostedAdjustAmount, NetAdjustAmount, GLAcctIncome, 
												GLAcctOffset, CF)
	SELECT	@PostRun, r.ID, b.BatchID, r.ProjectID, r.ProjectName, 
			r.CustID, r.CustName, r.ProjectDescription, r.DistCode, r.Rep1Id, r.Rep2Id, r.ProjectManager, 
			b.FiscalPeriod, b.FiscalYear, @AdjustDate, r.FixedFeeAmount, r.BilledAmount, r.EstimatedCost, r.EstimatedHour, 
			r.PostedCost, r.PostedHour, r.PercentCostCompletion, r.PercentHourCompletion, r.OverridePercent, 
			r.EarnedIncome, r.PostedAdjustAmount, r.NetAdjustAmount, r.GLAcctIncome, 
		CASE WHEN r.BilledAmount > r.EarnedIncome THEN r.GLAcctBillingExcess 
			WHEN r.BilledAmount < r.EarnedIncome THEN r.GLAcctEarningExcess
			WHEN r.BilledAmount = r.EarnedIncome THEN 
			(CASE WHEN r.PostedAdjustAmount > 0 THEN r.GLAcctBillingExcess ELSE r.GLAcctEarningExcess END) 
		END as GLAcctOffset
		, r.CF
	FROM dbo.tblPcRevenueAdjust r
	INNER JOIN #PostSummary t ON t.ProjectID = r.ProjectId
	INNER JOIN dbo.tblPcRevenueAdjustBatch b ON r.AdjustBatchID = b.ID
	WHERE r.NetAdjustAmount <> 0 AND b.BatchID = @BatchId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcRevenueAdjustPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcRevenueAdjustPost_History_proc';

