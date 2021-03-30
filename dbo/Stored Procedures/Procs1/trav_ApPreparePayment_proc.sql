
CREATE PROCEDURE dbo.trav_ApPreparePayment_proc
AS
BEGIN TRY 
	DECLARE @BatchID pBatchID,@CheckDate datetime, @DiscountsDue datetime, @InvoicesDue datetime, 
	@VendorIDFrom nvarchar(10), @VendorIDThru nvarchar(10), @CurrencyID nvarchar(6), 
	@GlPeriod smallint, @GlYear smallint, @GlAcctDisc nvarchar(40), @BankId pBankID,  
	@LogMsg1 nvarchar (255), @LogMsg1Pos tinyint, @LogMsg2 nvarchar (255), 
	@LogMsg2Pos tinyint, @PmtCurrencyID pCurrency,@PmtExchRate pDecimal,@PrecCurr  smallint, @PmtPrecCurr  smallint,
	@CurrBase pCurrency, @Multicurr bit,@GlCashAcct nvarchar(40), @PrepaidDiscAmtTotal pDecimal, @DiscAmtTotal pDecimal

	--Retrieve global values
	SELECT @BatchID = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'BatchId'
	SELECT @CheckDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'CheckDate'
	SELECT @DiscountsDue = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DiscountsDue'
	SELECT @InvoicesDue = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'InvoicesDue'
	SELECT @VendorIDFrom = NULLIF(Cast([Value] AS nvarchar(10)),'') FROM #GlobalValues WHERE [Key] = 'VendorIdFrom'
	SELECT @VendorIDThru = NULLIF(Cast([Value] AS nvarchar(10)),'') FROM #GlobalValues WHERE [Key] = 'VendorIdThru'
	SELECT @CurrencyID = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrencyId'
	SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
	SELECT @GlYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlYear'
	SELECT @GlAcctDisc = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'GlAcctDisc'
	SELECT @BankId = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'BankId'
	SELECT @Multicurr = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @LogMsg1 = Cast([Value] AS nvarchar(255)) FROM #GlobalValues WHERE [Key] = 'LogMsg1'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @LogMsg2 = Cast([Value] AS nvarchar(255)) FROM #GlobalValues WHERE [Key] = 'LogMsg2'
	SELECT @PmtCurrencyID = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'PmtCurrencyId'
	SELECT @PmtExchRate = Cast([Value] AS decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'PmtExchRate'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PmtPrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PmtPrecCurr'

	IF @BatchID IS NULL OR @CheckDate IS NULL OR @DiscountsDue IS NULL OR @InvoicesDue IS NULL 
		OR @CurrencyID IS NULL OR @GlPeriod IS NULL OR @GlYear IS NULL OR @PmtPrecCurr IS NULL
		OR @GlAcctDisc IS NULL OR @BankId IS NULL OR @Multicurr IS NULL OR @LogMsg1 IS NULL OR @PrecCurr IS NULL 
		OR @LogMsg2 IS NULL OR @PmtCurrencyID IS NULL OR @PmtExchRate IS NULL OR @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	SELECT @LogMsg1Pos = CHARINDEX('%',@LogMsg1), @LogMsg2Pos = CHARINDEX('%',@LogMsg2)

	SELECT @GlCashAcct = CASE WHEN b.AcctType=1 THEN ISNULL(v.GLAcct,b.GlCashAcct) ELSE  b.GLCashAcct  END FROM dbo.tblSmBankAcct b
													LEFT JOIN dbo.tblApVendor v ON b.VendorId = v.VendorID WHERE b.BankId = @BankId
	
	CREATE TABLE #tmpPrintOrder(VendorId pVendorID, InvoiceNum pInvoiceNum, Counter Int, PrintCounter int IDENTITY (1,1))

	/*0=Rel,1=Hold,2=Temp,3=Paid*/

	INSERT INTO dbo.tblApPrepChkInvc 
	(	VendorHoldYN, Ten99FormCode, VendorID, 
		Counter, InvoiceNum, Status, 
		Ten99InvoiceYN, DistCode, InvoiceDate, 
		DiscDueDate, NetDueDate, GrossAmtDue, 
		BaseGrossAmtDue, 
		DiscAmt, GrossAmtDueFgn, DiscAmtFgn, 
		CheckNum, CheckDate, CurrencyId, 
		DiscTaken, DiscTakenFgn, DiscLost, 
		DiscLostFgn, ExchRate, GlPeriod, FiscalYear, GlCashAcct, GlDiscAcct, BankId, 
		CalcGainLoss,  GLAccGainLoss,  PmtCurrencyId, PmtExchRate, Notes, GrpID, BatchID                     
	) 
	SELECT	v.VendorHoldYN, v.Ten99FormCode, 
		v.VendorID, i.Counter, 
		i.InvoiceNum, i.Status, 
		i.Ten99InvoiceYN, i.DistCode, 
		i.InvoiceDate, i.DiscDueDate, 
		i.NetDueDate, 
		i.GrossAmtDue, i.BaseGrossAmtDue, 
		i.DiscAmt, i.GrossAmtDueFgn, 
		i.DiscAmtFgn, i.CheckNum, 
		@CheckDate, i.CurrencyId, 
		CASE 
			WHEN DiscDueDate >= @DiscountsDue THEN DiscAmt 
			ELSE 0 
		END, 
		CASE 	
			WHEN DiscDueDate >= @DiscountsDue THEN DiscAmtFgn 
			ELSE 0
		END, 
		CASE 
			WHEN DiscDueDate < @DiscountsDue THEN DiscAmt 

			ELSE 0
		END, 
		CASE
			WHEN DiscDueDate < @DiscountsDue THEN DiscAmtFgn
			ELSE 0 
		END, 
		i.ExchRate, @GlPeriod, @GlYear, @GlCashAcct, @GlAcctDisc, @BankId,
			0,'', @PmtCurrencyId, @PmtExchRate, Notes,
	Case WHEN v.ChkOpt = 0 then 0 else i.counter end, @BatchID

	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i
		ON v.VendorID = i.VendorID 
		lEFT Join #GainLossAccounts g on i.CurrencyId = g.CurrencyId
	WHERE (@VendorIdFrom IS NULL OR v.VendorID >= @VendorIdFrom) AND 
		(@VendorIdThru IS NULL OR v.VendorID <= @VendorIdThru)
		AND i.Status = 0 
		AND i.CurrencyId = @CurrencyID 
		AND (i.NetDueDate <= @InvoicesDue OR i.GrossAmtDue < 0)
		AND NOT EXISTS (SELECT 1 FROM dbo.tblApPrepChkInvc p WHERE p.VendorID = i.VendorID AND p.InvoiceNum = i.InvoiceNum AND p.Counter = i.Counter)
		AND (i.BankId IS NULL OR i.BankId = @BankId)

	INSERT INTO dbo.tblApPrepChkInvc 
	(	VendorHoldYN, Ten99FormCode, VendorID, 
		Counter, InvoiceNum, Status, 
		Ten99InvoiceYN, DistCode, InvoiceDate, 
		DiscDueDate, NetDueDate, GrossAmtDue, 
		BaseGrossAmtDue, 
		DiscAmt, GrossAmtDueFgn, DiscAmtFgn, 
		CheckNum, CheckDate, CurrencyId, 
		DiscTaken, DiscTakenFgn, DiscLost, 
		DiscLostFgn, ExchRate, GlPeriod, FiscalYear, GlCashAcct, GlDiscAcct, 
		BankId, CalcGainLoss,  GLAccGainLoss, PmtCurrencyId, PmtExchRate, Notes, GrpID, BatchID    
	) 
	SELECT	v.VendorHoldYN, v.Ten99FormCode, 
		v.VendorID, i.Counter, 
		i.InvoiceNum, i.Status, 
		i.Ten99InvoiceYN, i.DistCode, 
		i.InvoiceDate, i.DiscDueDate, 
		i.NetDueDate,
		i.GrossAmtDue, i.BaseGrossAmtDue, 
		i.DiscAmt, i.GrossAmtDueFgn, 
		i.DiscAmtFgn, i.CheckNum, 
		@CheckDate, i.CurrencyId, 
		CASE 
			WHEN DiscDueDate >= @DiscountsDue THEN DiscAmt 
			ELSE 0 
		END, 
		CASE 	
			WHEN DiscDueDate >= @DiscountsDue THEN DiscAmtFgn 
			ELSE 0

		END, 
		CASE 
			WHEN DiscDueDate < @DiscountsDue THEN DiscAmt 
			ELSE 0
		END, 
		CASE
			WHEN DiscDueDate < @DiscountsDue THEN DiscAmtFgn
			ELSE 0 
		END, 
		i.ExchRate, @GlPeriod, @GlYear, @GlCashAcct, @GlAcctDisc, @BankId,  
		0,'', @PmtCurrencyId, @PmtExchRate, Notes,
	Case WHEN v.ChkOpt = 0 then 0 else i.counter end, @BatchID
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i
		ON v.VendorID = i.VendorID 
	lEFT Join #GainLossAccounts g on i.CurrencyId = g.CurrencyId
	WHERE (@VendorIdFrom IS NULL OR v.VendorID >= @VendorIdFrom) AND 
		(@VendorIdThru IS NULL OR v.VendorID <= @VendorIdThru)
		AND i.Status = 0 
		AND i.DiscDueDate BETWEEN @DiscountsDue AND @InvoicesDue
		AND i.NetDueDate > @InvoicesDue 
		AND i.GrossAmtDue > 0
		AND i.DiscAmt > 0 
		AND i.CurrencyId = @CurrencyID
		AND NOT EXISTS (SELECT 1 FROM dbo.tblApPrepChkInvc p WHERE p.VendorID = i.VendorID AND p.InvoiceNum = i.InvoiceNum AND p.Counter = i.Counter)
		AND (i.BankId IS NULL OR i.BankId = @BankId)

	/* append paid invoices to tblApPrepChkInvc */
	INSERT INTO dbo.tblApPrepChkInvc 
	(	VendorHoldYN, Ten99FormCode, Counter, 
		VendorID, InvoiceNum, Status, Ten99InvoiceYN, 
		DistCode, InvoiceDate, DiscDueDate, 
		NetDueDate, GrossAmtDue, BaseGrossAmtDue, DiscAmt, 
		GrossAmtDueFgn, DiscAmtFgn, CheckNum, 
		CheckDate, CurrencyId, DiscTaken, 
		DiscTakenFgn, CheckAmt, CheckAmtFgn, ExchRate, 
		GlCashAcct, GlDiscAcct, GlPeriod, FiscalYear, BankId,
		CalcGainLoss,  GLAccGainLoss, PmtCurrencyId, PmtExchRate, Notes, GrpID, BatchID          
	) 
	SELECT	v.VendorHoldYN, v.Ten99FormCode, 
		i.Counter, v.VendorID, 
		i.InvoiceNum, i.Status, 
		i.Ten99InvoiceYN, i.DistCode, 
		i.InvoiceDate, i.DiscDueDate, 
		i.NetDueDate, 
		i.GrossAmtDue, i.BaseGrossAmtDue, 
		i.DiscAmt, i.GrossAmtDueFgn, 
		i.DiscAmtFgn, i.CheckNum, 
		i.CheckDate, i.CurrencyId, 
		i.DiscAmt, i.DiscAmtFgn, 
		GrossAmtDue - DiscAmt, GrossAmtDueFgn - DiscAmtFgn, 
		i.ExchRate, b.GlCashAcct, @GlAcctDisc, CheckPeriod, CheckYear, i.BankId, 
		i.CalcGainLoss,  i.GLAccGainLoss, i.PmtCurrencyId, i.PmtExchRate, Notes,
		Case WHEN v.ChkOpt = 0 then 0 else i.counter end, @BatchID
		FROM dbo.tblApVendor v INNER JOIN dbo.tblApOpenInvoice i
		ON v.VendorID = i.VendorID INNER JOIN dbo.tblSmBankAcct b ON
		i.BankId = b.BankId
		WHERE (@VendorIdFrom IS NULL OR v.VendorID >= @VendorIdFrom) AND 
		(@VendorIdThru IS NULL OR v.VendorID <= @VendorIdThru)
		AND i.Status = 3 AND i.CurrencyId = @CurrencyID And i.PmtCurrencyId = @PmtCurrencyID
		AND NOT EXISTS (SELECT 1 FROM dbo.tblApPrepChkInvc p WHERE p.VendorID = i.VendorID AND p.InvoiceNum = i.InvoiceNum AND p.Counter = i.Counter)
		AND i.BankId = @BankId

	/* Log Vendor on hold messages */
	INSERT INTO dbo.tblApPrepChkLog ( ErrorLogMsg, BatchID ) 
	SELECT STUFF(@LogMsg1, @LogMsg1Pos, 2, VendorID), @BatchID
	FROM dbo.tblApPrepChkInvc 
	WHERE VendorHoldYN = 1 AND BatchID = @BatchID
	GROUP BY VendorID

	/* Log Not a Ten99 vendor warning messages */
	INSERT INTO dbo.tblApPrepChkLog ( ErrorLogMsg, BatchID ) 
	SELECT STUFF(@LogMsg2, @LogMsg2Pos, 2, VendorID), @BatchID 
	FROM dbo.tblApPrepChkInvc 
	WHERE Ten99InvoiceYN = 1 AND Ten99FormCode = '0' AND BatchID = @BatchID
	GROUP BY VendorID

	/* delete recs from Invc table for vendors on hold */
	DELETE dbo.tblApPrepChkInvc 
	WHERE VendorHoldYN = 1 AND BatchID = @BatchID

	/* sum invoice recs from Invc table into Checks table */
	If @Multicurr = 1
	begin
	INSERT INTO dbo.tblApPrepChkCheck 
	(	VendorID, CheckAmt, CheckAmtFgn, DiscLost, DiscLostFgn, 
		DiscTaken, DiscTakenFgn, Ten99Pmt, 
		Ten99PmtFgn, 
		CalcGainLoss,  GLAccGainLoss,
		CheckDate, CurrencyId, GrpID, BatchID
	)
	SELECT	VendorID, 
		round(Sum(round((i.GrossAmtDueFgn/i.PmtExchRate),  @PrecCurr) - round((i.DiscTakenFgn)/i.PmtExchRate,  @PrecCurr)),  @PrecCurr), 
		Sum(i.GrossAmtDueFgn - i.DiscTakenFgn), 
		Sum(i.DiscLost), 
		Sum(i.DiscLostFgn), 
		Sum(i.DiscTaken), 
		Sum(i.DiscTakenFgn), 
		Sum(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDue - i.DiscTaken ELSE 0 END), 
		Sum(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDueFgn - i.DiscTakenFgn ELSE 0 END), 
		Case when i.CurrencyID <> @CurrBase AND Max(i.ExchRate) <> ISNULL(@PmtExchRate,1) --PTS 45583
		then
			sum((Round((i.GrossAmtDueFgn/@PmtExchRate), @PrecCurr) -   round((i.DiscTakenFgn/@PmtExchRate), @PrecCurr)) - ((i.GrossAmtDue) -  round((i.DiscTakenFgn/i.ExchRate), @PrecCurr))) 
		else 
			0 
		end,
		CASE WHEN ((sum((i.GrossAmtDueFgn - i.DiscTakenFgn)/@PmtExchRate) - sum((i.GrossAmtDuefgn-i.DiscTakenfgn)/i.ExchRate)) < 0) --PTS 45583 (2)
			THEN g.RealGainAcct 
			ELSE g.RealLossAcct 
		END,
		@CheckDate, 
 		@PmtCurrencyId, GrpID, BatchID
	FROM dbo.tblApPrepChkInvc i  
	lEFT Join #GainLossAccounts g on i.CurrencyId = g.CurrencyId
	WHERE i.Status = 0 AND i.BatchID = @BatchID AND (i.CurrencyId <> @CurrBase OR (i.CurrencyId = @CurrBase AND i.PmtCurrencyId = @CurrBase )) --Foreign invoice or base currecy invoice paid with base currency
	GROUP BY VendorID, i.CurrencyId, GrpID, BatchID
		, g.RealGainAcct, g.RealLossAcct
	UNION ALL 
	SELECT	VendorID, 
		Sum(i.GrossAmtDue - i.DiscTaken),
		ROUND(Sum((i.GrossAmtDue * i.PmtExchRate) - (i.DiscTaken * i.PmtExchRate)), @PmtPrecCurr), 
		Sum(i.DiscLost), 
		ROUND(Sum(i.DiscLost * i.PmtExchRate), @PmtPrecCurr), 
		Sum(i.DiscTaken), 
		ROUND(Sum(i.DiscTaken * i.PmtExchRate), @PmtPrecCurr), 
		Sum(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDue - i.DiscTaken ELSE 0 END), 
		Sum(CASE WHEN i.Ten99InvoiceYn = 1 THEN i.GrossAmtDue * i.PmtExchRate - i.DiscTaken * i.PmtExchRate ELSE 0 END), 
		0, NULL, @CheckDate, @PmtCurrencyId, GrpID, BatchID
	FROM dbo.tblApPrepChkInvc i  
	lEFT Join #GainLossAccounts g on i.CurrencyId = g.CurrencyId
	WHERE i.Status = 0 AND i.BatchID = @BatchID AND (i.CurrencyId = @CurrBase AND i.PmtCurrencyId <> @CurrBase ) --base currecy invoice paid with foreign currency
	GROUP BY VendorID, i.CurrencyId, GrpID, BatchID
		, g.RealGainAcct, g.RealLossAcct	
		
	end 
	else
	begin
	INSERT INTO dbo.tblApPrepChkCheck 

	(	VendorID, CheckAmt, CheckAmtFgn, DiscLost, DiscLostFgn, 
		DiscTaken, DiscTakenFgn, Ten99Pmt, 
		Ten99PmtFgn, CheckDate, CurrencyId, GrpID, BatchID
	)
	SELECT	VendorID, 
		Sum(GrossAmtDue - DiscTaken), 
		Sum(GrossAmtDueFgn - DiscTakenFgn), 
		Sum(DiscLost), 
		Sum(DiscLostFgn), 
		Sum(DiscTaken), 
		Sum(DiscTakenFgn), 
		Sum(CASE WHEN Ten99InvoiceYn = 1 THEN GrossAmtDue - DiscTaken ELSE 0 END), 
		Sum(CASE WHEN Ten99InvoiceYn = 1 THEN GrossAmtDueFgn - DiscTakenFgn ELSE 0 END), 
		@CheckDate, 
		CurrencyId, GrpID, BatchID  
	FROM dbo.tblApPrepChkInvc 
	WHERE Status = 0 AND BatchID = @BatchID 
	GROUP BY VendorID, CurrencyId, GrpID, BatchID 
	end

	/* Update  check delivery info */
	UPDATE dbo.tblApPrepChkCheck 
	SET DeliveryType = v.DeliveryType,BankAcctNum = v.BankAcctNum, RoutingCode = v.RoutingCode, BankAccountType = v.BankAccountType
	FROM dbo.tblApPrepChkCheck INNER JOIN dbo.tblApVendor v ON dbo.tblApPrepChkCheck.VendorId = v.VendorId
	WHERE dbo.tblApPrepChkCheck.BatchID = @BatchID 

	/* remove invoice recs from Invc table for negative checks */
	DELETE	dbo.tblApPrepChkInvc 
	FROM	dbo.tblApPrepChkCheck 
	WHERE	dbo.tblApPrepChkCheck.VendorID = dbo.tblApPrepChkInvc.VendorID 
		AND dbo.tblApPrepChkCheck.CheckAmt < 0 
		AND dbo.tblApPrepChkInvc.Status = 0  
		AND dbo.tblApPrepChkInvc.BatchID = @BatchID

	/* remove negative check recs from Checks table */

	DELETE dbo.tblApPrepChkCheck 
	FROM dbo.tblApPrepChkCheck 
		LEFT JOIN dbo.tblApPrepChkInvc 
			ON dbo.tblApPrepChkCheck.VendorId = dbo.tblApPrepChkInvc.VendorId 
				AND dbo.tblApPrepChkCheck.BatchId = dbo.tblApPrepChkInvc.BatchId 
	WHERE (dbo.tblApPrepChkCheck.CheckAmt < 0 OR dbo.tblApPrepChkInvc.VendorId IS NULL) 
		AND dbo.tblApPrepChkCheck.BatchID = @BatchID

	/* append non-paid control info to tblApPrepChkCntl */
	INSERT INTO dbo.tblApPrepChkCntl 
	(	InvoicesDue, 
		VendorIDFrom, 
		VendorIDThru, 
		Currency, 
		DiscountsDue, 
		GLPeriod, 
		FiscalYear, 
		DiscountTakenTotal, 
		DiscountTakenTotalFgn, 
		CheckAmountTotal, 
		CheckAmountTotalFgn, 
		CheckDate,
		BankId,
		PmtCurrencyId, 
		PmtExchRate,
		BatchID
	) 
	SELECT	@InvoicesDue, 
		@VendorIDFrom, 
		@VendorIDThru, 
		@CurrencyID, 
		@DiscountsDue, 
		@GlPeriod, 
		@GlYear, 
		Sum(IsNULL(CASE WHEN BatchId = @BatchId THEN DiscTaken ELSE 0 END, 0)), 
		Sum(IsNULL(CASE WHEN BatchId = @BatchId THEN DiscTakenFgn ELSE 0 END, 0)), 
		Sum(IsNULL(CASE WHEN BatchId = @BatchId THEN CheckAmt ELSE 0 END, 0)), 
		Sum(IsNULL(CASE WHEN BatchId = @BatchId THEN CheckAmtFgn ELSE 0 END, 0)), 
		@CheckDate,
		@BankId,
		@PmtCurrencyId, 
		@PmtExchRate,
		@BatchID 
	FROM dbo.tblApPrepChkCheck 
	WHERE (dbo.tblApPrepChkCheck.BatchID = @BatchID or
	 @BatchID Not In(Select BatchID from dbo.tblApPrepChkCheck WHERE BatchID  = @BatchID))

	/* update control info in tblApPrepChkCntl w/paid info */
	UPDATE dbo.tblApPrepChkCntl 
	SET	PrepaidCheckTotal = ISNULL((SELECT Sum(CheckAmt) FROM tblApPrepChkInvc WHERE Status = 3 and BatchID = @BatchID),0), 
		PrepaidCheckTotalFgn = ISNULL((SELECT Sum(CheckAmtFgn) FROM tblApPrepChkInvc WHERE Status = 3 and BatchID = @BatchID),0),
			DiscountTakenTotal = ISNULL(DiscountTakenTotal, 0), CheckAmountTotal = IsNULL(CheckAmountTotal, 0), 
		DiscountTakenTotalFgn =ISNULL(DiscountTakenTotalFgn, 0), CheckAmountTotalFgn =ISNULL(CheckAmountTotalFgn, 0)
	  WHERE BatchID = @BatchID  

	--Update print counter
	INSERT INTO #tmpPrintOrder (VendorId,InvoiceNum,Counter) 
	SELECT VendorId,InvoiceNum,Counter
	FROM dbo.tblApPrepChkInvc 
	WHERE BatchId = @BatchID
	ORDER BY VendorId,InvoiceNum,InvoiceDate

	UPDATE dbo.tblApPrepChkInvc SET PrintCounter = t.PrintCounter 
	FROM dbo.tblApPrepChkInvc INNER JOIN #tmpPrintOrder t
	ON dbo.tblApPrepChkInvc.VendorId = t.VendorId AND dbo.tblApPrepChkInvc.InvoiceNum = t.InvoiceNum AND dbo.tblApPrepChkInvc.Counter = t.Counter 
	WHERE dbo.tblApPrepChkInvc.BatchId = @BatchID

	--return logs
	SELECT @PrepaidDiscAmtTotal = SUM(CASE WHEN Status = 3 THEN CASE WHEN @PmtCurrencyID = @CurrBase THEN DiscTaken ELSE DiscTakenFgn END ELSE 0 END),
		@DiscAmtTotal = SUM(CASE WHEN Status = 0 THEN CASE WHEN @PmtCurrencyID = @CurrBase THEN DiscTaken ELSE DiscTakenFgn END ELSE 0 END) 
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
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPreparePayment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPreparePayment_proc';

