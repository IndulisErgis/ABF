
CREATE PROCEDURE dbo.trav_PsLayawayPost_BuildLog_proc
AS
BEGIN TRY

	DECLARE	@PostRun pPostRun, @PostDtlYn bit, @CurrBase pCurrency, @PrecCurr smallint, @CompId [sysname] , @WrkStnDate datetime, @SourceCode nvarchar(2), 
		@FiscalYear smallint, @FiscalPeriod smallint, @OnAccountInvcNum nvarchar(15), @PaymentTotal pCurrDecimal, @OpenInvoiceTotal pCurrDecimal

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @SourceCode = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'SourceCode'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @OnAccountInvcNum = Cast([Value] AS nvarchar(15)) FROM #GlobalValues WHERE [Key] = 'OnAccountInvcNum'


	IF @PostRun IS NULL OR @PostDtlYn IS NULL OR @CurrBase IS NULL OR @WrkStnDate IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL 
		OR @OnAccountInvcNum IS NULL 		
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #TransPostLog 
	(
		[Grouping] smallint Null, 
		[TransDate] datetime Null, 
		[Descr] nvarchar(30) Null, 
		[Reference] nvarchar(15) Null, 
		[DistCode] pDistCode Null,
		[GlAcct] pGlAcct Null, 
		[CreditAmount] pDecimal Null, 
		[DebitAmount] pDecimal Null, 
		[LinkID] nvarchar(255) Null, 	
		[CurrencyId] pCurrency Null, 
		[ExchRate] pDecimal Null Default(1), 
		[AmountFgn] pDecimal Null Default(0), 
		[DebitAmtFgn] pDecimal Null Default(0), 
		[CreditAmtFgn] pDecimal Null Default(0)
	)

	--Freight/Misc
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT h.TransDate, CASE d.LineType WHEN 3 THEN 30 WHEN 4 THEN 40 END, CASE WHEN ISNULL(d.Descr,'') = '' THEN 
		CASE d.LineType WHEN 3 THEN 'Freight' WHEN 4 THEN 'Misc Charges' END ELSE SUBSTRING(d.Descr, 1, 30) END, h.BillToID, t.DistCode, 
		CASE d.LineType WHEN 3 THEN c.GLAcctFreight WHEN 4 THEN c.GLAcctMisc END, -d.ExtPrice, 
		CASE WHEN d.ExtPrice > 0 THEN ABS(d.ExtPrice) ELSE 0 END, 
		CASE WHEN d.ExtPrice > 0 THEN 0  ELSE ABS(d.ExtPrice) END, h.ID, @CurrBase, 1, 
		CASE WHEN d.ExtPrice > 0 THEN ABS(d.ExtPrice) ELSE 0 END, 
		CASE WHEN d.ExtPrice > 0 THEN 0  ELSE ABS(d.ExtPrice) END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblArDistCode c ON t.DistCode = c.DistCode
	WHERE h.VoidDate IS NULL AND d.LineType IN (3, 4) AND d.ExtPrice <> 0
	
	--Coupon/Discount/Rounding
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT h.TransDate, CASE d.LineType WHEN -2 THEN 50 WHEN -3 THEN 60 WHEN -4 THEN 70 END, CASE WHEN ISNULL(d.Descr,'') = '' THEN 
		CASE d.LineType WHEN -2 THEN 'Coupon' WHEN -3 THEN 'Discount' WHEN -4 THEN 'Rounding Adjustment' END ELSE SUBSTRING(d.Descr, 1, 30) END, 
		h.BillToID, t.DistCode, CASE d.LineType WHEN -2 THEN c.GLAcctCoupon WHEN -3 THEN c.GLAcctDiscount WHEN -4 THEN c.GLAcctRounding END, 
		d.ExtPrice, CASE WHEN d.ExtPrice > 0 THEN 0  ELSE ABS(d.ExtPrice) END, 
		CASE WHEN d.ExtPrice > 0 THEN ABS(d.ExtPrice) ELSE 0 END, h.ID, @CurrBase, 1, 
		CASE WHEN d.ExtPrice > 0 THEN 0  ELSE ABS(d.ExtPrice) END, 
		CASE WHEN d.ExtPrice > 0 THEN ABS(d.ExtPrice) ELSE 0 END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblPsDistCode c ON t.DistCode = c.DistCode
	WHERE h.VoidDate IS NULL AND d.LineType IN (-2,-3,-4) AND d.ExtPrice <> 0

	--COGS
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT h.TransDate, 10, SUBSTRING(ISNULL(d.Descr,''), 1, 30), h.BillToID, t.DistCode, g.GLAcctCogs, i.ExtCost, 
		CASE WHEN i.ExtCost > 0 THEN 0  ELSE ABS(i.ExtCost) END, 
		CASE WHEN i.ExtCost > 0 THEN ABS(i.ExtCost) ELSE 0 END, h.ID, @CurrBase, 1, 
		CASE WHEN i.ExtCost > 0 THEN 0  ELSE ABS(i.ExtCost) END, 
		CASE WHEN i.ExtCost > 0 THEN ABS(i.ExtCost) ELSE 0 END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		INNER JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
		LEFT JOIN dbo.tblInItemLoc l ON d.ItemID = l.ItemId AND d.LocID = l.LocId
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
	WHERE h.VoidDate IS NULL AND i.ExtCost <> 0

	--Inventory
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT h.TransDate, 20, SUBSTRING(ISNULL(d.Descr,''), 1, 30), h.BillToID, t.DistCode, g.GLAcctInv, -i.ExtCost, 
		CASE WHEN i.ExtCost > 0 THEN ABS(i.ExtCost) ELSE 0 END, 
		CASE WHEN i.ExtCost > 0 THEN 0 ELSE ABS(i.ExtCost) END, h.ID, @CurrBase, 1, 
		CASE WHEN i.ExtCost > 0 THEN ABS(i.ExtCost) ELSE 0 END, 
		CASE WHEN i.ExtCost > 0 THEN 0 ELSE ABS(i.ExtCost) END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		INNER JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
		LEFT JOIN dbo.tblInItemLoc l ON d.ItemID = l.ItemId AND d.LocID = l.LocId
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
	WHERE h.VoidDate IS NULL AND i.ExtCost <> 0

	--Line Item Sales
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT h.TransDate, 80, SUBSTRING(ISNULL(d.Descr,''), 1, 30), h.BillToID, t.DistCode, 
		CASE WHEN i.DetailID IS NULL THEN c.GLAcctSales ELSE g.GLAcctSales END, -d.ExtPrice, 
		CASE WHEN d.ExtPrice > 0 THEN ABS(d.ExtPrice) ELSE 0 END, 
		CASE WHEN d.ExtPrice > 0 THEN 0  ELSE ABS(d.ExtPrice) END, h.ID, @CurrBase, 1, 
		CASE WHEN d.ExtPrice > 0 THEN ABS(d.ExtPrice) ELSE 0 END, 
		CASE WHEN d.ExtPrice > 0 THEN 0  ELSE ABS(d.ExtPrice) END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblPsDistCode c ON t.DistCode = c.DistCode 
		LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
		LEFT JOIN dbo.tblInItemLoc l ON d.ItemID = l.ItemId AND d.LocID = l.LocId
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
	WHERE h.VoidDate IS NULL AND d.LineType = 1 AND d.ExtPrice <> 0

	--Tax
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)
	SELECT h.TransDate, 90, SUBSTRING('Sales Tax' + ' / ' + x.TaxLocID, 1, 30), h.BillToID, t.DistCode, l.GLAcct, 
		-1 * x.TaxAmt, CASE WHEN x.TaxAmt > 0 THEN ABS(x.TaxAmt) ELSE 0 END, 
		CASE WHEN x.TaxAmt > 0 THEN 0  ELSE ABS(x.TaxAmt) END, h.ID, @CurrBase, 1, 
		CASE WHEN x.TaxAmt > 0 THEN ABS(x.TaxAmt) ELSE 0 END, 
		CASE WHEN x.TaxAmt > 0 THEN 0  ELSE ABS(x.TaxAmt) END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN (SELECT HeaderID, TaxLocID, SUM(TaxAmt) AS TaxAmt FROM dbo.tblPsTransTax GROUP BY HeaderID, TaxLocID) x ON h.ID = x.HeaderID
		LEFT JOIN dbo.tblSmTaxLoc l ON x.TaxLocID = l.TaxLocId
	WHERE h.VoidDate IS NULL AND x.TaxAmt <> 0
                        
	--Payment cash account
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT p.PmtDate, 100, i.InvoiceNum, h.BillToID, i.DistCode, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END, 
		p.AmountBase, CASE WHEN p.AmountBase > 0 THEN 0  ELSE ABS(p.AmountBase) END, 
		CASE WHEN p.AmountBase > 0 THEN ABS(p.AmountBase) ELSE 0 END, 
		p.ID, @CurrBase, 1, --Standard: only supports base currency external transactions
		CASE WHEN p.AmountBase > 0 THEN 0 ELSE ABS(p.AmountBase) END, 
		CASE WHEN p.AmountBase > 0 THEN ABS(p.AmountBase) ELSE 0 END
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #PsIncompleteLayawayList i ON p.HeaderID = i.ID 
		INNER JOIN dbo.tblPsTransHeader h ON i.ID = h.ID 
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0

	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT p.PmtDate, 100, i.InvoiceNum, h.BillToID, i.DistCode, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END, 
		p.AmountBase, CASE WHEN p.AmountBase > 0 THEN 0  ELSE ABS(p.AmountBase) END, 
		CASE WHEN p.AmountBase > 0 THEN ABS(p.AmountBase) ELSE 0 END, 
		p.ID, @CurrBase, 1, --Standard: only supports base currency external transactions
		CASE WHEN p.AmountBase > 0 THEN 0 ELSE ABS(p.AmountBase) END, 
		CASE WHEN p.AmountBase > 0 THEN ABS(p.AmountBase) ELSE 0 END
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #PsCompletedLayawayList i ON p.HeaderID = i.ID 
		INNER JOIN dbo.tblPsTransHeader h ON i.ID = h.ID 
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0

	--Layaway account
	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT p.PmtDate, 120, i.InvoiceNum, h.BillToID, i.DistCode, c.GLAcctLayaway, 
		-p.AmountBase, CASE WHEN p.AmountBase > 0 THEN p.AmountBase ELSE 0 END, 
		CASE WHEN p.AmountBase > 0 THEN 0 ELSE ABS(p.AmountBase) END, 
		p.ID, @CurrBase, 1, --Standard: only supports base currency external transactions
		CASE WHEN p.AmountBase > 0 THEN p.AmountBase ELSE 0 END, 
		CASE WHEN p.AmountBase > 0 THEN 0 ELSE ABS(p.AmountBase) END
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #PsIncompleteLayawayList i ON p.HeaderID = i.ID 
		INNER JOIN dbo.tblPsTransHeader h ON i.ID = h.ID 
		LEFT JOIN dbo.tblPsDistCode c ON i.DistCode = c.DistCode
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0 --Unposted payment of incomplete layaway

	INSERT INTO #TransPostLog (Transdate, [Grouping], Descr, Reference, DistCode, GlAcct, AmountFgn, 
		CreditAmount, DebitAmount, LinkID, CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   
	SELECT p.PmtDate, 120, t.InvoiceNum, h.BillToID, t.DistCode, c.GLAcctLayaway, 
		p.AmountBase, CASE WHEN p.AmountBase > 0 THEN 0 ELSE ABS(p.AmountBase) END, 
		CASE WHEN p.AmountBase > 0 THEN p.AmountBase ELSE 0 END, 
		p.ID, @CurrBase, 1, --Standard: only supports base currency external transactions
		CASE WHEN p.AmountBase > 0 THEN 0 ELSE ABS(p.AmountBase) END, 
		CASE WHEN p.AmountBase > 0 THEN p.AmountBase ELSE 0 END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsPayment p ON h.ID = p.HeaderID
		LEFT JOIN dbo.tblPsDistCode c ON t.DistCode = c.DistCode
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0 AND p.PostedYN = 1 --Posted payment of completed layaway

	--populate the GL Log table
	IF (@PostDtlYn = 0)
	BEGIN
		--Summarize credit/debit entries separately
		--Credit entry
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, AmountFgn, Reference, [Description], DebitAmount, CreditAmount, 
			DebitAmountFgn, CreditAmountFgn, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId)
		SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping], GlAcct, -SUM(CreditAmtFgn), 'PS', CASE WHEN [Grouping] = 10 THEN 'Cost of Sales' 
			WHEN [Grouping] = 20 THEN 'Inventory' WHEN [Grouping] = 30 THEN 'Freight' WHEN [Grouping] = 40 THEN 'Misc Charges' 
			WHEN [Grouping] = 50 THEN 'Coupon' WHEN [Grouping] = 60 THEN 'Discount' WHEN [Grouping] = 70 THEN 'Rounding Adjustment' 
			WHEN [Grouping] = 80 THEN 'Sales' WHEN [Grouping] = 90 THEN 'Sales Tax' WHEN [Grouping] = 100 THEN 'Payments Received' 
			WHEN [Grouping] = 110 THEN 'A/R' WHEN [Grouping] = 120 THEN 'Layaway' ELSE'Unknown' END, 0,	
			SUM(CreditAmount), 0, SUM(CreditAmtFgn), @SourceCode, @WrkStnDate, @WrkStnDate, CurrencyId, ExchRate, @CompId
		FROM #TransPostLog 
		WHERE CreditAmtFgn <> 0
		GROUP BY [Grouping], CurrencyId, ExchRate, GlAcct 

		--Debit entry
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId)

		SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping], GlAcct, SUM(DebitAmtFgn), 'PS', CASE WHEN [Grouping] = 10 THEN 'Cost of Sales' 
			WHEN [Grouping] = 20 THEN 'Inventory' WHEN [Grouping] = 30 THEN 'Freight' WHEN [Grouping] = 40 THEN 'Misc Charges' 
			WHEN [Grouping] = 50 THEN 'Discount' WHEN [Grouping] = 60 THEN 'Coupon' WHEN [Grouping] = 70 THEN 'Rounding Adjustment' 
			WHEN [Grouping] = 80 THEN 'Sales' WHEN [Grouping] = 90 THEN 'Sales Tax' WHEN [Grouping] = 100 THEN 'Payments Received' 
			WHEN [Grouping] = 110 THEN 'A/R' WHEN [Grouping] = 120 THEN 'Layaway' ELSE'Unknown' END, 
			SUM(DebitAmount), 0, SUM(DebitAmtFgn), 0, @SourceCode, @WrkStnDate, @WrkStnDate, CurrencyId, ExchRate, @CompId
		FROM #TransPostLog 
		WHERE DebitAmtFgn <> 0
		GROUP BY [Grouping],CurrencyId,ExchRate, GlAcct 

	END
	ELSE
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, AmountFgn, Reference, [Description], DebitAmount, CreditAmount, 
			DebitAmountFgn, CreditAmountFgn, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping], GlAcct, AmountFgn, Reference, Descr, DebitAmount, CreditAmount, DebitAmtFgn, 
			CreditAmtFgn, @SourceCode, @WrkStnDate, TransDate, CurrencyId, ExchRate, @CompId, LinkID, NULL, NULL
		FROM #TransPostLog 

	SELECT @PaymentTotal = SUM(p.AmountBase)
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
	WHERE p.VoidDate IS NULL

	SELECT @OpenInvoiceTotal = SUM(Amount)
	FROM (SELECT t.InvoiceTotal AS Amount
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId 
	WHERE h.VoidDate IS NULL AND t.InvoiceTotal <> 0 --invoice total of completed layaway 
	UNION ALL
	SELECT -p.AmountBase AS Amount
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblArCust c ON p.CustID = c.CustId 
	WHERE p.VoidDate IS NULL AND p.AmountBase <> 0 --unposted payment
	UNION ALL
	SELECT d.ExtPrice AS Amount
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId
	WHERE d.LineType = -4 --rounding adjustment
	) o

	--update the transaction summary log table
	INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod], [TransAmt], [PmtAmt], [CurrencyId], [OpenInvoiceAmt])
	SELECT @FiscalYear, @FiscalPeriod, ISNULL(SUM(t.InvoiceTotal),0), ISNULL(@PaymentTotal,0), @CurrBase, ISNULL(@OpenInvoiceTotal,0)
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
	WHERE h.VoidDate IS NULL
 
 	--update the payment summary log table
	INSERT INTO #PaymentSummary ([FiscalYear], [FiscalPeriod], [BankId], [PmtMethodId], [Description], [PaymentType], [PaymentAmount], [CurrencyId], [PaymentAmountFgn])
	SELECT @FiscalYear, @FiscalPeriod, m.BankId, p.PmtMethodId, m.[Desc], p.PmtType, p.AmountBase, @CurrBase, p.AmountBase --Standard: only supports base currency external transactions
	FROM #PsLayawayPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID 
	WHERE p.VoidDate IS NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_BuildLog_proc';

