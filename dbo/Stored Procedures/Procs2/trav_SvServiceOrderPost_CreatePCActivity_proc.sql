
CREATE PROCEDURE dbo.trav_SvServiceOrderPost_CreatePCActivity_proc
AS
BEGIN TRY

	INSERT INTO dbo.tblPcActivity(ProjectDetailId, RcptId
	, Source
	, Type
	, Qty
	, QtyInvoiced
	, ExtCost
	, ExtIncome
	, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId
	, Reference
	, DistCode, GLAcctWIP
	, GLAcctPayrollClearing
	, GLAcctIncome 
	, GLAcctCost
	, GLAcctAdjustments, GLAcctFixedFeeBilling
	, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear
	, OverheadPosted , RateId, Uom
	, Status
	, BillOnHold, SourceId, LinkSeqNum, CF, LinkId)
	SELECT o.ProjectDetailID, NULL
	, CASE WHEN o.BillVia = 0 THEN 13   WHEN o.BillVia= 1 THEN 14 END
	, CASE WHEN tr.TransType = 2 THEN 3 ELSE tr.TransType END
	, CASE WHEN tr.TransType = 0  OR tr.TransType = 1 THEN tr.QtyUsed ELSE 0 END
	, 0
	, CASE WHEN tr.TransType = 0  OR tr.TransType = 1 THEN tr.CostExt ELSE 0 END
	, CASE WHEN tr.TransType = 0  OR tr.TransType = 1 THEN tr.PriceExt ELSE tr.CostExt END
	, 0 , 0, tr.Description, tr.AdditionalDescription, tr.TransDate, tr.ID, NULL, tr.ResourceID, tr.LocID
	, CASE WHEN tr.TransType = 0 THEN 'Labor' 
	       WHEN tr.TransType = 1 THEN 'Part' 
		   WHEN tr.TransType = 2 THEN 'Freight' 
		   WHEN tr.TransType = 3 THEN 'Misc' 
	  END Reference
	, d.DistCode, CASE WHEN tr.TransType = 1 AND o.BillVia = 1 AND p.Type = 1 THEN tr.GLAcctDebit ELSE dc.GLAcctWIP END
	, CASE WHEN tr.TransType = 0  THEN tr.GLAcctCredit ELSE dc.GLAcctPayrollClearing END
	, dc.GLAcctIncome
	, CASE WHEN o.BillVia = 0 OR ((tr.TransType = 0  OR tr.TransType = 1) AND p.Type <> 1 ) THEN  tr.GLAcctDebit ELSE dc.GLAcctCost END
	, dc.GLAcctAdjustments,dc.GLAcctFixedFeeBilling
	, dc.GLAcctOverheadContra, dc.GLAcctAccruedIncome, tr.TaxClass, tr.FiscalPeriod, tr.FiscalYear
	, 0, NULL, tr.Unit
	, CASE WHEN o.BillVia = 0 THEN CASE WHEN p.Type = 1 THEN 5 ELSE 4  END ELSE 2 END 
	, 0, NULL, tr.LinkSeqNum, NULL, NULL
	FROM #TransactionListToProcessTable t	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.TransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder o ON tr.WorkOrderID = o.ID 
	INNER JOIN dbo.tblPcProjectDetail d ON o.ProjectDetailID=  d.Id
	INNER JOIN dbo.tblPcDistCode dc ON d.DistCode = dc.DistCode
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_CreatePCActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_CreatePCActivity_proc';

