
CREATE PROCEDURE dbo.trav_PcBillingPost_UpdateActivity_proc
AS
BEGIN TRY

	DECLARE @PostRun pPostRun
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Credit Memo or Fixed Fee Billing
	UPDATE dbo.tblPcActivity SET Status = 2 --Posted
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
	WHERE h.VoidYn = 0 AND (h.TransType = -1 OR a.[Type] = 6) 
	
	--Deposit applied
	UPDATE dbo.tblPcActivity SET Status = 2 --Posted
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDeposit d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
	WHERE h.VoidYn = 0 

	--Non-Fixed Fee activity billing
	UPDATE dbo.tblPcActivity SET Status = 4, --Billed
		BillingReference = h.TransId, QtyBilled = d.Qty, ExtIncomeBilled = d.ExtPrice, SourceId = h.SourceId
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
	WHERE h.VoidYn = 0 AND (h.TransType > 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 3) --Invoice;Activity Type is Time, Material, Expense, Other;Activity Status is WIP
		
	--Fixed Fee activity billing																  
	UPDATE dbo.tblPcActivity SET Status = 4 --Billed
	FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ProjectDetailId  = a.ProjectDetailId AND d.TransId = a.BillingReference
	WHERE h.VoidYn = 0 AND h.TransType > 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 3 --Invoice;Activity Type is Time, Material, Expense, Other;Activity Status is WIP
	
	--Unbill
	BEGIN
		--Create offset activity for unbilled activity
		INSERT INTO dbo.tblPcActivity(ProjectDetailId, RcptId, [Source], [Type], Qty, QtyInvoiced, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, [Description], AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, GLAcct, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, [Status], BillOnHold, SourceId, LinkSeqNum, CF, LinkId)
		SELECT a.ProjectDetailId, a.RcptId, 7, a.[Type], -a.Qty, -a.QtyInvoiced, -a.ExtCost, -a.ExtIncome, -a.QtyBilled, -a.ExtIncomeBilled, a.[Description], a.AddnlDesc, a.ActivityDate, a.SourceReference, h.TransId, a.ResourceId, a.LocId, a.Reference, a.DistCode, a.GLAcctWIP, a.GLAcctPayrollClearing, a.GLAcctIncome, a.GLAcctCost, a.GLAcctAdjustments, a.GLAcctFixedFeeBilling, a.GLAcctOverheadContra, a.GLAcctAccruedIncome, a.GLAcct, a.TaxClass, a.FiscalPeriod, a.FiscalYear, 0, a.RateId, a.Uom, 4, a.BillOnHold, h.SourceId, a.LinkSeqNum, a.CF, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
				INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
				INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
		WHERE h.VoidYn = 0 AND h.TransType = -2 AND a.[Type] BETWEEN 0 AND 3
	
		--Update tblArHistDetail.TransHistId to id of new offset activity
		UPDATE dbo.tblArHistDetail SET TransHistId = n.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
				INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
				INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
				INNER JOIN dbo.tblPcActivity n ON a.Id = n.LinkId
				INNER JOIN dbo.tblArHistDetail r ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
		WHERE h.VoidYn = 0 AND h.TransType = -2 AND a.[Type] BETWEEN 0 AND 3 AND r.PostRun = @PostRun

		--Create new activity for unbilled activity
		INSERT INTO dbo.tblPcActivity(ProjectDetailId, RcptId, [Source], [Type], Qty, QtyInvoiced, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, [Description], AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, GLAcct, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, [Status], BillOnHold, SourceId, LinkSeqNum, CF, LinkId)
		SELECT a.ProjectDetailId, a.RcptId, a.[Source], a.[Type], a.Qty, a.QtyInvoiced, a.ExtCost, a.ExtIncome, 0, 0, a.[Description], a.AddnlDesc, a.ActivityDate, a.SourceReference, NULL, a.ResourceId, a.LocId, a.Reference, a.DistCode, a.GLAcctWIP, a.GLAcctPayrollClearing, a.GLAcctIncome, a.GLAcctCost, a.GLAcctAdjustments, a.GLAcctFixedFeeBilling, a.GLAcctOverheadContra, a.GLAcctAccruedIncome, a.GLAcct, a.TaxClass, a.FiscalPeriod, a.FiscalYear, 0, a.RateId, a.Uom, 2, a.BillOnHold, NULL, a.LinkSeqNum, a.CF, a.Id
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
				INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
				INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
		WHERE h.VoidYn = 0 AND h.TransType = -2 AND a.[Type] BETWEEN 0 AND 3

	END

	UPDATE dbo.tblPcProjectDetail SET LastDateBilled = CASE WHEN LastDateBilled IS NULL OR i.InvoiceDate > LastDateBilled THEN i.InvoiceDate ELSE LastDateBilled END
	FROM dbo.tblPcProjectDetail INNER JOIN
		(SELECT ProjectDetailId, MAX(h.InvcDate) AS InvoiceDate 
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId 
		WHERE h.VoidYn = 0 AND h.TransType > 0
		GROUP BY d.ProjectDetailId) i ON dbo.tblPcProjectDetail.Id = i.ProjectDetailId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_UpdateActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_UpdateActivity_proc';

