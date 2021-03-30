
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_CreatePCActivity_proc
AS
BEGIN TRY

	INSERT INTO dbo.tblPcActivity(ProjectDetailId, RcptId, Source, Type	, Qty, QtyInvoiced, ExtCost	, ExtIncome
	, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId, Reference
	, DistCode, GLAcctWIP
	, GLAcctPayrollClearing
	, GLAcctIncome 
	, GLAcctCost
	, GLAcctAdjustments, GLAcctFixedFeeBilling
	, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear
	, OverheadPosted , RateId, Uom, Status, BillOnHold, SourceId, LinkSeqNum, CF, LinkId)

	SELECT w.ProjectDetailID, NULL
	, CASE WHEN w.BillVia = 0 THEN 13   WHEN w.BillVia= 1 THEN 14 END 
	, CASE WHEN tr.TransType =2 THEN 3 ELSE tr.TransType END
	, CASE WHEN tr.TransType =0  OR tr.TransType = 1 THEN
		CASE WHEN w.FixedPrice=1 THEN tr.QtyEstimated ELSE tr.QtyUsed END 
	  ELSE 0 END  Qty
	, 0
	, CASE WHEN tr.TransType =0  OR tr.TransType = 1 THEN tr.CostExt ELSE 0 END ExtCost
	, CASE WHEN tr.TransType =0  OR tr.TransType = 1 THEN tr.PriceExt ELSE tr.CostExt END ExtIncome
	, CASE WHEN w.BillVia = 0  AND b.BillableYN =1 AND wd.CancelledYN =0  THEN
		CASE WHEN tr.TransType =0  OR tr.TransType = 1 THEN
			CASE WHEN w.FixedPrice=1 THEN tr.QtyEstimated ELSE tr.QtyUsed END 
		ELSE 0 END 
	  ELSE 0 END QtyBilled
	 , CASE WHEN w.BillVia = 0 THEN
			CASE WHEN tr.TransType =2  OR tr.TransType = 3 THEN tr.CostExt 
			ELSE CASE WHEN b.BillableYN =1 AND wd.CancelledYN =0 THEN tr.PriceExt ELSE 0 END
		    END
		ELSE 0 END ExtIncomeBilled
	 , tr.Description, tr.AdditionalDescription, tr.TransDate, tr.ID 
	 , CASE WHEN w.BillVia = 0 THEN d.TransID ELSE NULL END  BillingReference
	 , tr.ResourceID, tr.LocID
	 , CASE WHEN tr.TransType = 0 THEN 'Labor' 
	       WHEN tr.TransType = 1 THEN 'Part' 
		   WHEN tr.TransType = 2 THEN 'Freight' 
		   WHEN tr.TransType = 3 THEN 'Misc' 
		END Reference
	, pd.DistCode, CASE WHEN tr.TransType = 1 AND w.BillVia = 1 AND pr.Type = 1 THEN tr.GLAcctDebit ELSE dc.GLAcctWIP END
	, CASE WHEN tr.TransType = 0  THEN tr.GLAcctCredit ELSE dc.GLAcctPayrollClearing END
	, CASE WHEN w.BillVia =0 AND b.BillableYN =1 AND wd.CancelledYN =0 AND (tr.TransType = 0 OR tr.TransType= 1) THEN tr.GLAcctSales ELSE dc.GLAcctIncome END
	, CASE WHEN (tr.TransType = 0 OR tr.TransType= 1) AND( w.BillVia = 0 OR pr.Type <> 1) THEN tr.GLAcctDebit ELSE dc.GLAcctCost END 
	, dc.GLAcctAdjustments,dc.GLAcctFixedFeeBilling
	, dc.GLAcctOverheadContra, dc.GLAcctAccruedIncome, tr.TaxClass, tr.FiscalPeriod, tr.FiscalYear
	, 0	, NULL	, tr.Unit
	, CASE WHEN w.BillVia = 0 THEN CASE WHEN pr.Type = 1 THEN 5 ELSE 4  END ELSE 2 END 
	, 0
	, CASE WHEN w.BillVia = 0 THEN h.SourceId END
	, tr.LinkSeqNum, NULL, NULL
	FROM #PostTransList p
	INNER JOIN dbo.tblSvInvoiceHeader h ON p.TransId = h.TransID
	INNER JOIN dbo.tblSvInvoiceDetail d ON  p.TransId = d.TransID	
	INNER JOIN dbo.tblSvWorkOrderTrans tr ON d.WorkOrderTransID = tr.ID
	INNER JOIN dbo.tblSvWorkOrder w ON tr.WorkOrderID = w.ID 
	INNER JOIN dbo.tblPcProjectDetail pd ON w.ProjectDetailID=  pd.Id
	INNER JOIN dbo.tblPcDistCode dc ON pd.DistCode = dc.DistCode
	INNER JOIN dbo.tblPcProject pr ON pd.ProjectId = pr.Id
	INNER JOIN dbo.tblSvWorkOrderDispatch wd ON wd.ID = d.DispatchID
	LEFT JOIN dbo.tblSvBillingType b ON b.BillingType = wd.BillingType
	WHERE h.VoidYN =0
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_CreatePCActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_CreatePCActivity_proc';

