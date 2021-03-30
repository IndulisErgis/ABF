
CREATE PROCEDURE dbo.trav_ApPreparePayment_Log_proc
AS
BEGIN TRY 
DECLARE @BatchID pBatchID, @PmtCurrencyID pCurrency, @CurrBase pCurrency, @PrepaidDiscAmtTotal pDecimal, @DiscAmtTotal pDecimal

	--Retrieve global values
	SELECT @BatchID = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'BatchId'
	SELECT @PmtCurrencyID = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'PmtCurrencyId'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @BatchID IS NULL OR @PmtCurrencyID IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--return logs
	SELECT @PrepaidDiscAmtTotal = SUM(CASE WHEN Status = 3 THEN CASE WHEN @PmtCurrencyID = @CurrBase THEN DiscTaken ELSE DiscTakenFgn END ELSE 0 END),
		@DiscAmtTotal = SUM(CASE WHEN Status = 0 THEN CASE WHEN @PmtCurrencyID = @CurrBase THEN DiscTaken ELSE CASE WHEN CurrencyId <> @CurrBase THEN DiscTakenFgn ELSE DiscTaken * PmtExchRate END END ELSE 0 END) 
	FROM dbo.tblApPrepChkInvc 
	WHERE BatchId = @BatchId 

	SELECT CASE WHEN @PmtCurrencyID = @CurrBase THEN PrepaidCheckTotal ELSE PrepaidCheckTotalFgn END + ISNULL(@PrepaidDiscAmtTotal,0) AS GrossPrepaidAmount,
		CASE WHEN @PmtCurrencyID = @CurrBase THEN CheckAmountTotal ELSE CheckAmountTotalFgn END + ISNULL(@DiscAmtTotal,0) AS GrossCheckAmout,
		ISNULL(@PrepaidDiscAmtTotal,0) AS DiscountPrepaidAmount, ISNULL(@DiscAmtTotal,0) AS DiscountCheckAmount,
		CASE WHEN @PmtCurrencyID = @CurrBase THEN PrepaidCheckTotal ELSE PrepaidCheckTotalFgn END AS NetPrepaidAmount,
		CASE WHEN @PmtCurrencyID = @CurrBase THEN CheckAmountTotal ELSE CheckAmountTotalFgn END AS NetCheckAmount 
	FROM tblApPrepChkCntl 
	WHERE BatchId = @BatchId 
	
	SELECT ErrorLogMsg AS ErrorLogMessage 
	FROM dbo.tblApPrepChkLog
	WHERE BatchId = @BatchId 
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPreparePayment_Log_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPreparePayment_Log_proc';

