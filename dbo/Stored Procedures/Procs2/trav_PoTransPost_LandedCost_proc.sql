
CREATE PROCEDURE dbo.trav_PoTransPost_LandedCost_proc
AS
BEGIN TRY
	DECLARE @gPoGlAcctInAccr nvarchar(40),@PostRun nvarchar(14), @WksDate datetime,@CurrBase pCurrency,
		@gPoGlLandedExp nvarchar(40), @PrecCurr smallint

	--Retrieve global values
	SELECT @gPoGlAcctInAccr = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'GlAcctInAccr'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @gPoGlLandedExp = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'GlLandedExp'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	
	IF @gPoGlAcctInAccr IS NULL	OR @PostRun IS NULL OR @WksDate IS NULL OR @PrecCurr IS NULL OR @CurrBase IS NULL OR @gPoGlLandedExp IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	-- Landed Cost Expense
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun,h.TransId,NULL,y.GlPeriod,d.EntryNum,111 AS [Grouping],-(c.Amount-c.PostedAmount) AS Amount,
	-(c.Amount-c.PostedAmount) AS AmountFgn,y.ReceiptDate, @WksDate,LEFT(t.[Description],30),d.LandedCostId, ISNULL(s.GlAcctExpense,@gPoGlLandedExp),
	CASE WHEN c.Amount-c.PostedAmount > 0 THEN 0 ELSE ABS(c.Amount-c.PostedAmount) END AS DR,
	CASE WHEN c.Amount-c.PostedAmount < 0 THEN 0 ELSE ABS(c.Amount-c.PostedAmount) END AS CR,
	y.FiscalYear,h.TransId,y.ReceiptNum,-7,@CurrBase,1,	
	CASE WHEN c.Amount-c.PostedAmount > 0 THEN 0 ELSE ABS(c.Amount-c.PostedAmount) END AS DR,
	CASE WHEN c.Amount-c.PostedAmount < 0 THEN 0 ELSE ABS(c.Amount-c.PostedAmount) END AS CR
	FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId
	INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
	INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
	INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
	INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
	INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
	LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  
	WHERE c.Amount-c.PostedAmount <> 0 

	-- Landed Cost Inventory
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
	GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun,h.TransId,NULL,y.GlPeriod,d.EntryNum,111 AS [Grouping],(c.Amount-c.PostedAmount) AS Amount,
	(c.Amount-c.PostedAmount) AS AmountFgn,y.ReceiptDate, @WksDate,LEFT(t.[Description],30),d.LandedCostId, d.GlAcct,
	CASE WHEN c.Amount-c.PostedAmount > 0 THEN ABS(c.Amount-c.PostedAmount) ELSE 0 END AS DR,
	CASE WHEN c.Amount-c.PostedAmount < 0 THEN ABS(c.Amount-c.PostedAmount) ELSE 0 END AS CR,
	y.FiscalYear,h.TransId,y.ReceiptNum,-7,@CurrBase,1,	
	CASE WHEN c.Amount-c.PostedAmount > 0 THEN ABS(c.Amount-c.PostedAmount) ELSE 0 END AS DR,
	CASE WHEN c.Amount-c.PostedAmount < 0 THEN ABS(c.Amount-c.PostedAmount) ELSE 0 END AS CR
	FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId
	INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
	INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
	INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
	INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
	INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
	LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  
	WHERE ISNULL(d.ProjectDetailId,0) = 0 AND c.Amount-c.PostedAmount <> 0 -- Exclude project items

	--Project Costing
	BEGIN
		--WIP Account 
		BEGIN
			--Income: General, Billable and non Fixed Fee
			INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
				Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
				LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
			SELECT @PostRun, h.TransId, y.ReceiptNum, y.GLPeriod, d.EntryNum, 300, 
				SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)),
				SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)),
				y.ReceiptDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, e.GLAcctWIP, 
				CASE WHEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) > 0 
					THEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END,
				CASE WHEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) < 0 
					THEN ABS(SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr))) ELSE 0 END,		
				y.FiscalYear, h.TransId, y.ReceiptNum, d.EntryNum, @CurrBase, 1, 
				CASE WHEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) > 0 
					THEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END,
				CASE WHEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) < 0 
					THEN ABS(SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr))) ELSE 0 END			
			FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
				INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
				INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
				INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
				INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
				INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
				INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
				INNER JOIN dbo.tblPcDistCode e ON p.DistCode = e.DistCode
				INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
				LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  
			WHERE j.[Type] = 0 AND p.Billable = 1 AND p.FixedFee = 0 AND c.Amount-c.PostedAmount <> 0 
			GROUP BY h.TransId, h.TransType, h.VendorId, y.ReceiptNum, y.FiscalYear, y.GLPeriod, y.ReceiptDate, d.EntryNum, d.GLDesc, j.CustId, j.ProjectName, e.GLAcctWIP

			--Cost: Job Cost
			INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
				Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
				LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)		
			SELECT @PostRun, h.TransId, y.ReceiptNum, y.GLPeriod, d.EntryNum, 301, SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount), SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount),
				y.ReceiptDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, e.GLAcctWIP, 
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) > 0 THEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) ELSE 0 END,
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) < 0 THEN ABS(SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount)) ELSE 0 END,		
				y.FiscalYear, h.TransId, y.ReceiptNum, d.EntryNum, @CurrBase, 1, 
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) > 0 THEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) ELSE 0 END,
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) < 0 THEN ABS(SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount)) ELSE 0 END			
			FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
				INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
				INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
				INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
				INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
				INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
				INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
				INNER JOIN dbo.tblPcDistCode e ON p.DistCode = e.DistCode
				INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
				LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  
			WHERE j.[Type] = 1 AND c.Amount-c.PostedAmount <> 0 
			GROUP BY h.TransId, h.TransType, h.VendorId, y.ReceiptNum, y.FiscalYear, y.GLPeriod, y.ReceiptDate, d.EntryNum, d.GLDesc, j.CustId, j.ProjectName, e.GLAcctWIP
		END
		
		--Cost Account
		BEGIN
			--General, Administrative
			INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
				Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
				LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
			SELECT @PostRun, h.TransId, y.ReceiptNum, y.GLPeriod, d.EntryNum, 302, 
				SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount), SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount),
				y.ReceiptDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, d.GLAcct, --Use GL account from line item
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) > 0 THEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) ELSE 0 END,
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) < 0 THEN ABS(SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount)) ELSE 0 END,				
				y.FiscalYear, h.TransId, y.ReceiptNum, d.EntryNum, @CurrBase, 1,
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) > 0 THEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) ELSE 0 END,
				CASE WHEN SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount) < 0 THEN ABS(SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount)) ELSE 0 END			
			FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
				INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
				INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
				INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
				INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
				INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
				INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
				INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
				LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  
			WHERE (j.[Type] = 0 OR j.[Type] = 2) AND c.Amount-c.PostedAmount <> 0 
			GROUP BY h.TransId, h.TransType, h.VendorId, y.ReceiptNum, y.FiscalYear, y.GLPeriod, y.ReceiptDate, d.EntryNum, d.GLDesc, j.CustId, j.ProjectName, d.GLAcct
		END
	
		--Accrued Income Account
		BEGIN
			--General, Billable and non Fixed Fee
			INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
				Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
				LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
			SELECT @PostRun, h.TransId, y.ReceiptNum, y.GLPeriod, d.EntryNum, 303, 
				-SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)),
				-SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)),
				y.ReceiptDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, e.GLAcctAccruedIncome, 
				CASE WHEN -SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) > 0 
					THEN -SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END,
				CASE WHEN -SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) < 0 
					THEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END,		
				y.FiscalYear, h.TransId, y.ReceiptNum, d.EntryNum, @CurrBase, 1, 
				CASE WHEN -SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) > 0 
					THEN -SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END,
				CASE WHEN -SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) < 0 
					THEN SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END		
			FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
				INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
				INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
				INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
				INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
				INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
				INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
				INNER JOIN dbo.tblPcDistCode e ON p.DistCode = e.DistCode
				INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
				LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  		
			WHERE j.[Type] = 0 AND p.Billable = 1 AND p.FixedFee = 0 AND c.Amount-c.PostedAmount <> 0 
			GROUP BY h.TransId, h.TransType, h.VendorId, y.ReceiptNum, y.FiscalYear, y.GLPeriod, y.ReceiptDate, d.EntryNum, d.GLDesc, j.CustId, j.ProjectName, e.GLAcctAccruedIncome
		END
		
	END
	
	UPDATE dbo.tblPoTransReceiptLandedCost SET PostedAmount = Amount 
	FROM dbo.tblPoTransReceiptLandedCost INNER JOIN dbo.tblPoTransLotRcpt r ON dbo.tblPoTransReceiptLandedCost.ReceiptId = r.ReceiptId 
		INNER JOIN dbo.tblPoTransHeader h ON r.TransId = h.TransId 
		INNER JOIN #PostTransList b ON h.TransId = b.TransId
	WHERE dbo.tblPoTransReceiptLandedCost.PostedAmount <> dbo.tblPoTransReceiptLandedCost.Amount

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_LandedCost_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_LandedCost_proc';

