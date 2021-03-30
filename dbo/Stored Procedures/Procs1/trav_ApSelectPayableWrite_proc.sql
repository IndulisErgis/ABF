
CREATE PROCEDURE dbo.trav_ApSelectPayableWrite_proc
@BatchId pBatchId,
@BaseCurrency pCurrency = 'USD',
@BaseCurrencyPrecision Tinyint = 2,
@MultiCurrency bit = 1,
@PmtPrecCurr Tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @Cnt int 
	DECLARE @DiscDue datetime, @CheckDate datetime, @PmtCurrencyID pCurrency, @PmtExchRate pDecimal
	DECLARE @SumDiscTaken decimal(28,10), @SumDiscTakenFgn decimal(28,10) 
	DECLARE @SumCheckAmt decimal(28,10), @SumCheckAmtFgn decimal(28,10) 

	SELECT @Cnt = Counter FROM tblApPrepChkCntl
	WHERE BatchID = @BatchID 
	GROUP BY Counter
	HAVING Counter = MIN(Counter)

	SELECT @DiscDue = DiscountsDue, @CheckDate = CheckDate, @PmtCurrencyID = PmtCurrencyID, @PmtExchRate = PmtExchRate
	FROM dbo.tblApPrepChkCntl WHERE Counter = @Cnt AND BatchID = @BatchId 

	--purge dropped invoices
	DELETE dbo.tblApPrepChkInvc 
	FROM dbo.tblApPrepChkInvc INNER JOIN #tmpInvoiceToDropList i 
		ON dbo.tblApPrepChkInvc.VendorId = i.VendorId AND dbo.tblApPrepChkInvc.InvoiceNum = i.InvoiceNum AND dbo.tblApPrepChkInvc.Counter = i.Counter
	WHERE dbo.tblApPrepChkInvc.BatchId = @BatchId

	-- purge all checks
	DELETE FROM dbo.tblApPrepChkCheck WHERE BatchID = @BatchId

	IF @MultiCurrency = 0
	BEGIN
		INSERT INTO dbo.tblApPrepChkCheck 
		( 
			VendorID, CheckAmt, CheckAmtFgn, DiscLost, DiscLostFgn, DiscTaken, DiscTakenFgn, Ten99Pmt, 
			Ten99PmtFgn, CheckDate, CurrencyId, GrpID, BatchID
		) 
		SELECT VendorID, SUM(GrossAmtDue - DiscTaken), 
			SUM(GrossAmtDueFgn - CASE WHEN DiscDueDate >= @DiscDue THEN DiscAmtFgn ELSE 0 END), 
			SUM(DiscLost), SUM(DiscLostFgn), SUM(DiscTaken), SUM(DiscTakenFgn), 
			SUM(CASE WHEN Ten99InvoiceYn = 1 THEN GrossAmtDue - DiscTaken ELSE 0 END), 
			SUM(CASE WHEN Ten99InvoiceYn = 1 THEN GrossAmtDue - DiscTaken ELSE 0 END), 
			@CheckDate, CurrencyId, GrpID, @BatchId 
		FROM dbo.tblApPrepChkInvc 
		WHERE Status = 0 AND BatchID = @BatchId
		GROUP BY VendorID, CurrencyId, GrpID, BatchID 
	END 
	ELSE
	BEGIN
		INSERT INTO dbo.tblApPrepChkCheck 

		(	
			VendorID, CheckAmt, CheckAmtFgn, DiscLost, DiscLostFgn, DiscTaken, DiscTakenFgn, Ten99Pmt, 
			Ten99PmtFgn, CalcGainLoss,  GLAccGainLoss, CheckDate, CurrencyId, GrpID, BatchID  
		)
		SELECT	VendorID, ROUND(SUM(ROUND((i.GrossAmtDueFgn/i.PmtExchRate),  @BaseCurrencyPrecision) - ROUND((i.DiscTakenFgn)/i.PmtExchRate,  @BaseCurrencyPrecision)),  @BaseCurrencyPrecision), 
			SUM(i.GrossAmtDueFgn - i.DiscTakenFgn), SUM(i.DiscLost), SUM(i.DiscLostFgn), SUM(i.DiscTaken), SUM(i.DiscTakenFgn), 
			SUM(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDue - i.DiscTaken ELSE 0 END), 
			SUM(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDueFgn - i.DiscTakenFgn ELSE 0 END), 
			CASE WHEN i.CurrencyID <> @BaseCurrency AND Max(i.ExchRate) <> ISNULL(@PmtExchRate,1) 
				THEN SUM((ROUND((i.GrossAmtDueFgn/@PmtExchRate), @BaseCurrencyPrecision) -   ROUND((i.DiscTakenFgn/@PmtExchRate), @BaseCurrencyPrecision)) - (ROUND((i.GrossAmtDuefgn / i.ExchRate), @BaseCurrencyPrecision) -  ROUND((i.DiscTakenFgn/i.ExchRate), @BaseCurrencyPrecision))) 
				ELSE 0 END,
			CASE WHEN ((SUM((i.GrossAmtDueFgn - i.DiscTakenFgn)/@PmtExchRate) - SUM((i.GrossAmtDuefgn-i.DiscTakenfgn)/i.ExchRate)) < 0) --PTS 45583 (2)
				THEN g.RealGainAcct ELSE g.RealLossAcct END,
			@CheckDate, @PmtCurrencyId, i.GrpID, @BatchId 	
		FROM dbo.tblApPrepChkInvc i	INNER JOIN #GainLossAccounts g on i.CurrencyId = g.CurrencyId
		WHERE i.Status = 0 AND i.BatchID = @BatchId AND (i.CurrencyId <> @BaseCurrency OR (i.CurrencyId = @BaseCurrency AND i.PmtCurrencyId = @BaseCurrency )) --Foreign invoice or base currecy invoice paid with base currency
		GROUP BY VendorID, i.CurrencyId, i.GrpID, i.BatchID, g.RealGainAcct, g.RealLossAcct
		UNION ALL
		SELECT	VendorID, Sum(i.GrossAmtDue - i.DiscTaken),
			ROUND(Sum((i.GrossAmtDue - i.DiscTaken) * i.PmtExchRate), @PmtPrecCurr), 
			SUM(i.DiscLost), ROUND(SUM(i.DiscLost * i.PmtExchRate), @PmtPrecCurr), 
			SUM(i.DiscTaken), ROUND(SUM(i.DiscTaken * i.PmtExchRate), @PmtPrecCurr), 
			SUM(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDue - i.DiscTaken ELSE 0 END), 
			ROUND(SUM(CASE WHEN i.Ten99InvoiceYn = 1 THEN (i.GrossAmtDue - i.DiscTaken) * i.PmtExchRate ELSE 0 END), @PmtPrecCurr), 
			0, NULL, @CheckDate, @PmtCurrencyId, i.GrpID, @BatchId 	
		FROM dbo.tblApPrepChkInvc i	INNER JOIN #GainLossAccounts g on i.CurrencyId = g.CurrencyId
		WHERE i.Status = 0 AND i.BatchID = @BatchId AND (i.CurrencyId = @BaseCurrency AND i.PmtCurrencyId <> @BaseCurrency ) --base currecy invoice paid with foreign currency
		GROUP BY VendorID, i.CurrencyId, i.GrpID, i.BatchID, g.RealGainAcct, g.RealLossAcct

	END

	-- Update  check delivery info
	UPDATE dbo.tblApPrepChkCheck 
	SET DeliveryType = v.DeliveryType,BankAcctNum = v.BankAcctNum, RoutingCode = v.RoutingCode, BankAccountType = v.BankAccountType
	FROM dbo.tblApPrepChkCheck INNER JOIN dbo.tblApVendor v ON dbo.tblApPrepChkCheck.VendorId = v.VendorId
	WHERE dbo.tblApPrepChkCheck.BatchID = @BatchId 

	-- remove invoice recs from Invc table for negative checks 
	DELETE dbo.tblApPrepChkInvc 
	FROM dbo.tblApPrepChkCheck INNER JOIN dbo.tblApPrepChkInvc 
		ON dbo.tblApPrepChkCheck.VendorID = dbo.tblApPrepChkInvc.VendorID 
		AND dbo.tblApPrepChkCheck.GrpID = dbo.tblApPrepChkInvc.GrpID
	WHERE dbo.tblApPrepChkCheck.CheckAmt < 0 AND dbo.tblApPrepChkInvc.Status = 0 AND dbo.tblApPrepChkInvc.BatchID = @BatchId
	
	-- remove negative check recs from Checks table
	DELETE dbo.tblApPrepChkCheck WHERE CheckAmt < 0 AND BatchID = @BatchId

	-- append non-paid control info to tblApPrepChkCntl
	SELECT @SumDiscTaken = SUM(DiscTaken), @SumDiscTakenFgn = SUM(DiscTakenFgn) , 
		@SumCheckAmt = SUM(CheckAmt), @SumCheckAmtFgn = SUM(CheckAmtFgn) 
	FROM dbo.tblApPrepChkCheck 
	
	UPDATE dbo.tblApPrepChkCntl 
	SET DiscountTakenTotal = ISNULL(@SumDiscTaken,0), DiscountTakenTotalFgn = ISNULL(@SumDiscTakenFgn,0), 
		CheckAmountTotal = ISNULL(@SumCheckAmt,0), CheckAmountTotalFgn = ISNULL(@SumCheckAmtFgn,0) 
	WHERE Counter = @Cnt AND BatchID = @BatchId

	-- remove negative check recs from Checks table
	DELETE dbo.tblApPrepChkCheck WHERE CheckAmt < 0 AND BatchID = @BatchId

	-- remove check control if no invoice exists
	IF NOT EXISTS(SELECT * FROM dbo.tblApPrepChkInvc WHERE BatchId = @BatchId)
		DELETE dbo.tblApPrepChkCntl WHERE BatchId = @BatchId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApSelectPayableWrite_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApSelectPayableWrite_proc';

