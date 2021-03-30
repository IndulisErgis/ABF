
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_UpdatePCProject_proc
AS
BEGIN TRY

	
	UPDATE dbo.tblPcProjectDetail SET LastDateBilled = CASE WHEN LastDateBilled IS NULL OR i.InvoiceDate > LastDateBilled THEN i.InvoiceDate ELSE LastDateBilled END
	FROM dbo.tblPcProjectDetail INNER JOIN
		(SELECT w.ProjectDetailID, MAX(h.InvoiceDate) AS InvoiceDate 
		FROM #PostTransList p
		INNER JOIN dbo.tblSvInvoiceHeader h ON p.TransId = h.TransID
		INNER JOIN dbo.tblSvWorkOrder w ON w.ID = h.WorkOrderID 
		INNER JOIN dbo.tblPcProjectDetail d ON w.ProjectDetailID=  d.Id
		WHERE  w.BillVia = 0 AND h.VoidYN =0
		GROUP BY w.ProjectDetailID) i ON dbo.tblPcProjectDetail.Id = i.ProjectDetailId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_UpdatePCProject_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_UpdatePCProject_proc';

