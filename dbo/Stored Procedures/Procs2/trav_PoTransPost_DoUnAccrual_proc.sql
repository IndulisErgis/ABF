
CREATE PROCEDURE dbo.trav_PoTransPost_DoUnAccrual_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PostRun nvarchar(14),@PoInYn bit, @WksDate datetime,@CurrBase pCurrency,
		@LinkID nvarchar(15), @LinkIDSub nvarchar(15), @LinkIDSubLine Int, @PrecCurr int
		
	SELECT @LinkID = 'UNACCRUAL', @LinkIDSub = NULL , @LinkIDSubLine = -3

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PoInYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PoInYn'
	SELECT @PrecCurr = Cast([Value] AS int) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @WksDate IS NULL OR @CurrBase IS NULL OR @PoInYn IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #arPd ([Year] smallint, Pd smallint, InItemAmt Decimal(28,10), NonInItemAmt Decimal(28,10),DropShipAmt Decimal(28,10), ProjItemAmt Decimal(28,10), 
		GlAcctApAccr pGlAcct NULL, GlAcctAccr pGlAcct NULL)

	INSERT INTO #arPd([Year],Pd,InItemAmt,NonInItemAmt,DropShipAmt,ProjItemAmt,GlAcctApAccr,GlAcctAccr)
	SELECT t.Fiscalyear,t.GlPeriod, 
		SUM(Sign(h.TransType) * CASE WHEN (DropShipYn = 0 OR ISNULL(d.LinkSeqNum,0) = 0) AND ISNULL(d.ProjectDetailId,0) = 0 AND (@PoInYn = 1 AND item.ItemId IS NOT NULL) THEN ROUND(ir.Qty * r.ExtCost / r.QtyFilled,@PrecCurr) ELSE 0 END) AS InItemAmt,
		SUM(Sign(h.TransType) * CASE WHEN (DropShipYn = 0 OR ISNULL(d.LinkSeqNum,0) = 0) AND ISNULL(d.ProjectDetailId,0) = 0 AND (@PoInYn = 0 OR item.ItemId IS NULL) THEN ROUND(ir.Qty * r.ExtCost / r.QtyFilled,@PrecCurr) ELSE 0 END) AS NonInItemAmt,
		SUM(Sign(h.TransType) * CASE WHEN DropShipYn = 1 AND ISNULL(d.LinkSeqNum,0) > 0 AND ISNULL(d.ProjectDetailId,0) = 0 THEN ROUND(ir.Qty * r.ExtCost / r.QtyFilled,@PrecCurr) ELSE 0 END) AS DropShipAmt,
		SUM(Sign(h.TransType) * CASE WHEN ISNULL(d.ProjectDetailId,0) <> 0 THEN ROUND(ir.Qty * r.ExtCost / r.QtyFilled,@PrecCurr) ELSE 0 END) AS ProjItemAmt,
		c.AccrualGLAcct, d.GLAcctAccrual
	FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
		LEFT JOIN  dbo.tblInItem item on d.ItemId=item.ItemId
		INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
		INNER JOIN dbo.tblPoTransInvc_Rcpt ir ON r.ReceiptId = ir.ReceiptId  
		INNER JOIN dbo.tblPoTransInvoice i ON ir.InvoiceId = i.InvoiceId 
		INNER JOIN dbo.tblPoTransInvoiceTot t ON i.TransId = t.TransId AND i.InvoiceNum = t.InvcNum 
		INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode
	WHERE r.QtyAccRev > 0 AND i.Status = 0
	GROUP BY t.Fiscalyear,t.GlPeriod, c.AccrualGLAcct, d.GLAcctAccrual

	UPDATE dbo.tblPoTransLotRcpt SET QtyAccRev = QtyAccRev - iq.Qty 
	FROM #PostTransList b INNER JOIN dbo.tblPoTransLotRcpt ON b.TransId = dbo.tblPoTransLotRcpt.TransId
		INNER JOIN 
			(SELECT ir.ReceiptId, SUM(ir.Qty) AS Qty FROM #PostTransList b INNER JOIN dbo.tblPoTransInvoice i ON b.TransId = i.TransId 
			INNER JOIN dbo.tblPoTransInvc_Rcpt ir ON i.InvoiceId = ir.InvoiceId WHERE i.Status = 0 GROUP BY ir.ReceiptId) iq 
			ON dbo.tblPoTransLotRcpt.ReceiptId = iq.ReceiptId  
	WHERE dbo.tblPoTransLotRcpt.QtyAccRev > 0
	
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 110, 
	 SUM(InItemAmt), SUM(InItemAmt), @WksDate, @WksDate, 'AP Accrual', 'INV RCVD', GlAcctApAccr,
	 CASE WHEN SUM(InItemAmt) > 0 THEN SUM(InItemAmt) ELSE 0 END, 
	 CASE WHEN SUM(InItemAmt) < 0 THEN - SUM(InItemAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN SUM(InItemAmt) > 0 THEN SUM(InItemAmt) ELSE 0 END, 
	 CASE WHEN SUM(InItemAmt) < 0 THEN - SUM(InItemAmt) ELSE 0 END
	FROM #arPd WHERE InItemAmt <> 0 
	GROUP BY [Year], Pd, GlAcctApAccr

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
	GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 110, 
	 SUM(DropShipAmt), SUM(DropShipAmt), @WksDate, @WksDate, 'AP Accrual', 'INV RCVD', GlAcctApAccr,
	 CASE WHEN SUM(DropShipAmt) > 0 THEN SUM(DropShipAmt) ELSE 0 END, 
	 CASE WHEN SUM(DropShipAmt) < 0 THEN - SUM(DropShipAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN SUM(DropShipAmt) > 0 THEN SUM(DropShipAmt) ELSE 0 END, 
	 CASE WHEN SUM(DropShipAmt) < 0 THEN - SUM(DropShipAmt) ELSE 0 END
	FROM #arPd WHERE DropShipAmt <> 0
	GROUP BY [Year], Pd, GlAcctApAccr

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
	GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 108, 
	 - SUM(InItemAmt),  - SUM(InItemAmt), @WksDate, @WksDate, 'IN Accrual', 'INV RCVD', GlAcctAccr,
	 CASE WHEN - SUM(InItemAmt) > 0 THEN - SUM(InItemAmt) ELSE 0 END, 
	 CASE WHEN - SUM(InItemAmt) < 0 THEN SUM(InItemAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN - SUM(InItemAmt) > 0 THEN - SUM(InItemAmt) ELSE 0 END, 
	 CASE WHEN - SUM(InItemAmt) < 0 THEN SUM(InItemAmt) ELSE 0 END
	FROM #arPd WHERE InItemAmt <> 0
	GROUP BY [Year], Pd, GlAcctAccr

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
	GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 110, 
	 SUM(NonInItemAmt), SUM(NonInItemAmt), @WksDate, @WksDate, 'AP Accrual', 'INV RCVD', GlAcctApAccr,
	 CASE WHEN SUM(NonInItemAmt) > 0 THEN SUM(NonInItemAmt) ELSE 0 END, 
	 CASE WHEN SUM(NonInItemAmt) < 0 THEN - SUM(NonInItemAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN SUM(NonInItemAmt) > 0 THEN SUM(NonInItemAmt) ELSE 0 END, 
	 CASE WHEN SUM(NonInItemAmt) < 0 THEN - SUM(NonInItemAmt) ELSE 0 END
	FROM #arPd WHERE NonInItemAmt <> 0
	GROUP BY [Year], Pd, GlAcctApAccr

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 109, 
	 - SUM(NonInItemAmt),  - SUM(NonInItemAmt), @WksDate, @WksDate, 'Exp Accrual', 'INV RCVD', GlAcctAccr,
	 CASE WHEN - SUM(NonInItemAmt) > 0 THEN - SUM(NonInItemAmt) ELSE 0 END, 
	 CASE WHEN - SUM(NonInItemAmt) < 0 THEN SUM(NonInItemAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN - SUM(NonInItemAmt) > 0 THEN - SUM(NonInItemAmt) ELSE 0 END, 
	 CASE WHEN - SUM(NonInItemAmt) < 0 THEN SUM(NonInItemAmt) ELSE 0 END
	FROM #arPd WHERE NonInItemAmt <> 0
	GROUP BY [Year], Pd, GlAcctAccr

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 110, 
	 SUM(ProjItemAmt), SUM(ProjItemAmt), @WksDate, @WksDate, 'AP Accrual', 'INV RCVD', GlAcctApAccr,
	 CASE WHEN SUM(ProjItemAmt) > 0 THEN SUM(ProjItemAmt) ELSE 0 END, 
	 CASE WHEN SUM(ProjItemAmt) < 0 THEN - SUM(ProjItemAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN SUM(ProjItemAmt) > 0 THEN SUM(ProjItemAmt) ELSE 0 END, 
	 CASE WHEN SUM(ProjItemAmt) < 0 THEN - SUM(ProjItemAmt) ELSE 0 END
	FROM #arPd WHERE ProjItemAmt <> 0
	GROUP BY [Year], Pd, GlAcctApAccr
	
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, NULL, NULL, pd, 99998, 109, 
	 - SUM(ProjItemAmt),  - SUM(ProjItemAmt), @WksDate, @WksDate, 'Project/Job Accrual', 'INV RCVD',GlAcctAccr,
	 CASE WHEN - SUM(ProjItemAmt) > 0 THEN - SUM(ProjItemAmt) ELSE 0 END, 
	 CASE WHEN - SUM(ProjItemAmt) < 0 THEN SUM(ProjItemAmt) ELSE 0 END, 
	 [Year], @LinkID, @LinkIDSub, @LinkIDSubLine,
	 @CurrBase, 1,
	 CASE WHEN - SUM(ProjItemAmt) > 0 THEN - SUM(ProjItemAmt) ELSE 0 END, 
	 CASE WHEN - SUM(ProjItemAmt) < 0 THEN SUM(ProjItemAmt) ELSE 0 END
	FROM #arPd WHERE ProjItemAmt <> 0
	GROUP BY [Year], Pd, GlAcctAccr
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_DoUnAccrual_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_DoUnAccrual_proc';

