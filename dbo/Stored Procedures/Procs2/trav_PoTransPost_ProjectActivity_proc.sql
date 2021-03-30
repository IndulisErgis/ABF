
CREATE PROCEDURE dbo.trav_PoTransPost_ProjectActivity_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PrecCurr smallint, @UseLandedCost bit

	--Retrieve global values
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @UseLandedCost = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UseLandedCost'

	IF @PrecCurr IS NULL OR @UseLandedCost IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Create activity for invoice
	INSERT INTO dbo.tblPcActivity(ProjectDetailId, RcptId, [Source], [Type], Qty, ExtCost, ExtIncome,  
		[Description], AddnlDesc, ActivityDate, SourceReference, ResourceId, LocId, Reference, DistCode, 
		GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, 
		GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, Uom, [Status])
	SELECT d.ProjectDetailId, r.ActivityId, 12, d.[Type], SIGN(h.TransType) * ir.Qty, SIGN(h.TransType) * ROUND(ir.Qty * v.ExtCost / v.Qty, @PrecCurr), 
		SIGN(h.TransType) * ROUND(ROUND(ir.Qty * v.ExtCost / v.Qty, @PrecCurr) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr),
		d.Descr, d.AddnlDescr, t.InvcDate, h.TransId, d.ItemId, d.LocId, t.InvcNum, p.DistCode, c.GLAcctWIP, c.GLAcctPayrollClearing,
		c.GLAcctIncome, d.GLAcct, c.GLAcctAdjustments, c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome,
		d.TaxClass, t.GLPeriod, t.FiscalYear, d.Units, 2
	FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
		INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum) 
			ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
		INNER JOIN dbo.tblPoTransInvc_Rcpt ir ON v.InvoiceID = ir.InvoiceID 
		INNER JOIN dbo.tblPoTransLotRcpt r ON ir.ReceiptID = r.ReceiptID
		INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
		INNER JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode
	WHERE v.[Status] = 0
	
	--Create activity for landed cost
	IF (@UseLandedCost = 1)
	BEGIN
		INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], Qty, ExtCost, ExtIncome,  
			[Description], ActivityDate, SourceReference, ResourceId, LocId, Reference, DistCode, 
			GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, 
			GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, Uom, [Status])
		SELECT d.ProjectDetailId, 9, d.[Type], 0, SIGN(h.TransType) * SUM(c.Amount-c.PostedAmount),
			SIGN(h.TransType) * SUM(ROUND((c.Amount-c.PostedAmount) * (1 + CASE d.[Type] WHEN 1 THEN p.MaterialMarkup WHEN 2 THEN p.ExpenseMarkup WHEN 3 THEN p.OtherMarkup ELSE 0 END/100),@PrecCurr)),
			t.[Description], y.ReceiptDate, h.TransId, d.ItemId, d.LocId, y.ReceiptNum, p.DistCode, e.GLAcctWIP, e.GLAcctPayrollClearing,
			e.GLAcctIncome, d.GLAcct, e.GLAcctAdjustments, e.GLAcctFixedFeeBilling, e.GLAcctOverheadContra, e.GLAcctAccruedIncome,
			d.TaxClass, y.GLPeriod, y.FiscalYear, d.Units, 2
		FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
			INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
			INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
			INNER JOIN dbo.tblPoTransReceipt y ON r.TransId = y.TransId AND r.RcptNum = y.ReceiptNum
			INNER JOIN dbo.tblPoTransReceiptLandedCost c ON r.ReceiptId = c.ReceiptId
			INNER JOIN dbo.tblPoTransDetailLandedCost t ON c.LCTransSeqNum = t.LCTransSeqNum 
			INNER JOIN dbo.tblPcProjectDetail p ON d.ProjectDetailId = p.Id
			INNER JOIN dbo.tblPcDistCode e ON p.DistCode = e.DistCode
			LEFT JOIN dbo.tblPoLandedCostDetail s ON t.LCDtlSeqNum = s.LCDtlSeqNum  
		WHERE c.Amount-c.PostedAmount <> 0 
		GROUP BY h.TransId, h.TransType, y.ReceiptNum, y.ReceiptDate, y.FiscalYear, y.GlPeriod, d.ItemId, d.LocId, d.TaxClass, d.Units,
			d.ProjectDetailId, d.[Type], t.[Description], p.DistCode, e.GLAcctWIP, e.GLAcctPayrollClearing,
			e.GLAcctIncome, d.GLAcct, e.GLAcctAdjustments, e.GLAcctFixedFeeBilling, e.GLAcctOverheadContra, e.GLAcctAccruedIncome
	END
	
	--Update actual start date
	UPDATE dbo.tblPcProjectDetail SET ActStartDate = t.TransDate
	FROM dbo.tblPcProjectDetail INNER JOIN 
		(SELECT td.ProjectDetailId, MIN(th.TransDate) AS TransDate
		 FROM #PostTransList l INNER JOIN dbo.tblPoTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblPoTransDetail td ON th.TransId = td.TransID 
		 GROUP BY td.ProjectDetailId) t ON dbo.tblPcProjectDetail.Id = t.ProjectDetailId 
	WHERE dbo.tblPcProjectDetail.ActStartDate IS NULL
	
	UPDATE dbo.tblPcProjectDetail SET ActStartDate = t.TransDate
	FROM dbo.tblPcProjectDetail INNER JOIN 
		(SELECT d.ProjectId, MIN(th.TransDate) AS TransDate
		 FROM #PostTransList l INNER JOIN dbo.tblPoTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblPoTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblPcProjectDetail d ON td.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject j ON d.ProjectId = j.Id
		 GROUP BY d.ProjectId) t ON dbo.tblPcProjectDetail.ProjectId = t.ProjectId 
	WHERE dbo.tblPcProjectDetail.PhaseId IS NULL AND dbo.tblPcProjectDetail.TaskId IS NULL AND dbo.tblPcProjectDetail.ActStartDate IS NULL
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ProjectActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ProjectActivity_proc';

