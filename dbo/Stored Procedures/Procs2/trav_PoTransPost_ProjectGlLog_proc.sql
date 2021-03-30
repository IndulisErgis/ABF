
CREATE PROCEDURE dbo.trav_PoTransPost_ProjectGlLog_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PrecCurr smallint,@PostRun nvarchar(14), @WksDate datetime,@CurrBase pCurrency, @UseLandedCost bit

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @UseLandedCost = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UseLandedCost'

	IF @PrecCurr IS NULL OR @PostRun IS NULL OR @WksDate IS NULL OR @CurrBase IS NULL OR @UseLandedCost IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--WIP Account 
	BEGIN
		--Income: General, Billable and non Fixed Fee
		--Invoice
		INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
			Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
			LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, t.TransId, t.InvcNum, t.GLPeriod, d.EntryNum, 300, 
			SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr),
			SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr),
			t.InvcDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, c.GLAcctWIP, 
			CASE WHEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) > 0 
				THEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) ELSE 0 END,
			CASE WHEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) < 0 
				THEN ABS(SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END,				
			t.FiscalYear, h.TransId, t.InvcNum, d.EntryNum, @CurrBase, 1, 
			CASE WHEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) > 0 
				THEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) ELSE 0 END,
			CASE WHEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) < 0 
				THEN ABS(SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)) ELSE 0 END				
		FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
			INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum) 
				ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
			INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
			INNER JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode 
			INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
		WHERE v.[Status] = 0 AND j.[Type] = 0 AND p.Billable = 1 AND p.FixedFee = 0 AND v.ExtCost <> 0
		
		--Cost: Job Cost
		--Invoice
		INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
			Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
			LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, t.TransId, t.InvcNum, t.GLPeriod, d.EntryNum, 301, SIGN(h.TransType) * v.ExtCost,	SIGN(h.TransType) * v.ExtCost,
			t.InvcDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, c.GLAcctWIP, 
			CASE WHEN SIGN(h.TransType) * v.ExtCost > 0 THEN SIGN(h.TransType) * v.ExtCost ELSE 0 END,
			CASE WHEN SIGN(h.TransType) * v.ExtCost < 0 THEN ABS(SIGN(h.TransType) * v.ExtCost) ELSE 0 END,				
			t.FiscalYear, h.TransId, t.InvcNum, d.EntryNum, @CurrBase, 1, 
			CASE WHEN SIGN(h.TransType) * v.ExtCost > 0 THEN SIGN(h.TransType) * v.ExtCost ELSE 0 END,
			CASE WHEN SIGN(h.TransType) * v.ExtCost < 0 THEN ABS(SIGN(h.TransType) * v.ExtCost) ELSE 0 END			
		FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
			INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum) 
				ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
			INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
			INNER JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode 
			INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
		WHERE v.[Status] = 0 AND j.[Type] = 1 AND v.ExtCost <> 0	
	END
	
	--Cost Account
	BEGIN
		--General, Administrative
		--Invoice
		INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
			Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
			LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, t.TransId, t.InvcNum, t.GLPeriod, d.EntryNum, 302, SIGN(h.TransType) * v.ExtCost,	SIGN(h.TransType) * v.ExtCost,
			t.InvcDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, d.GLAcct, --Use GL account from line item
			CASE WHEN SIGN(h.TransType) * v.ExtCost > 0 THEN SIGN(h.TransType) * v.ExtCost ELSE 0 END,
			CASE WHEN SIGN(h.TransType) * v.ExtCost < 0 THEN ABS(SIGN(h.TransType) * v.ExtCost) ELSE 0 END,				
			t.FiscalYear, h.TransId, t.InvcNum, d.EntryNum, @CurrBase, 1, 
			CASE WHEN SIGN(h.TransType) * v.ExtCost > 0 THEN SIGN(h.TransType) * v.ExtCost ELSE 0 END,
			CASE WHEN SIGN(h.TransType) * v.ExtCost < 0 THEN ABS(SIGN(h.TransType) * v.ExtCost) ELSE 0 END			
		FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
			INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum) 
				ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
			INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
			INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
		WHERE v.[Status] = 0 AND (j.[Type] = 0 OR j.[Type] = 2) AND v.ExtCost <> 0
	END
	
	--Accrued Income Account
	BEGIN
		--General, Billable and non Fixed Fee
		--Invoice
		INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], 
			Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
			LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, t.TransId, t.InvcNum, t.GLPeriod, d.EntryNum, 303, 
			-SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr),	
			-SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr),
			t.InvcDate, @WksDate, CASE WHEN ISNULL(d.GLDesc,'') = '' THEN ISNULL(j.CustId,'') + '/' + j.ProjectName ELSE d.GLDesc END, h.VendorId, c.GLAcctAccruedIncome, 
			CASE WHEN -SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) > 0 
				THEN -SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) ELSE 0 END,
			CASE WHEN -SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) < 0 
				THEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) ELSE 0 END,				
			t.FiscalYear, h.TransId, t.InvcNum, d.EntryNum, @CurrBase, 1, 
			CASE WHEN -SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) > 0 
				THEN -SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) ELSE 0 END,
			CASE WHEN -SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) < 0 
				THEN SIGN(h.TransType) * ROUND(v.ExtCost * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr) ELSE 0 END		
		FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
			INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum) 
				ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
			INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
			INNER JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode 
			INNER JOIN dbo.tblPcProject j ON p.ProjectId = j.Id 
		WHERE v.[Status] = 0 AND j.[Type] = 0 AND p.Billable = 1 AND p.FixedFee = 0 AND v.ExtCost <> 0
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ProjectGlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ProjectGlLog_proc';

