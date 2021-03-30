
CREATE PROCEDURE dbo.trav_PcPrepareBilling_RefreshActivity_proc
@BatchId pBatchId
AS
BEGIN TRY

	--Activity type is Time, Material, Expense or Other;
	--Activity source is Time Ticket, Transaction, Overhead, Adjustment, AP Invoice, PO, PO Invoice,Bill Via is PC ;
	--Activity status is Posted;
	--Activity does not already exist in table tblPcWIPDetail
	INSERT INTO dbo.tblPcWIPDetail(HeaderId, ActivityId, [Description], AddnlDesc, QtyBill, ExtIncomeBill, SelectYn,
		ExtCost, ResourceId, LocId, Uom, ExtIncome, Qty, ActivityDate, [Type], BatchId, TaxClass)
	SELECT h.Id, a.Id, a.[Description], a.AddnlDesc, a.Qty, CASE d.FixedFee WHEN 1 THEN a.ExtCost ELSE a.ExtIncome END, 1,
		a.ExtCost, a.ResourceId, a.LocId, a.Uom, a.ExtIncome, a.Qty, a.ActivityDate, a.[Type], @BatchId, a.TaxClass
	FROM tblPcWIPHeader h INNER JOIN dbo.tblPcActivity a ON h.ProjectDetailId = a.ProjectDetailId 
		INNER JOIN dbo.tblPcProjectDetail d ON h.ProjectDetailId = d.Id 
		LEFT JOIN dbo.tblPcWIPDetail w ON a.Id = w.ActivityId
	WHERE h.BatchId = @BatchId AND a.[Type] BETWEEN 0 AND 3 AND a.[Source] IN (0,1,2,3,8,9,12,14) AND a.[Status] = 2  AND a.BillOnHold = 0 
		AND w.Id IS NULL
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareBilling_RefreshActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareBilling_RefreshActivity_proc';

