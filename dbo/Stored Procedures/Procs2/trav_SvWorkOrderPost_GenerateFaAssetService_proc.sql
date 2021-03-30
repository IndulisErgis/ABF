
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_GenerateFaAssetService_proc
AS
BEGIN TRY

	DECLARE @AssetServiceID int
	SELECT @AssetServiceID = MAX(ID) FROM dbo.tblFaAssetService
	SET @AssetServiceID = ISNULL(@AssetServiceID,0)

	-- create one record in tblFaAssetService per dispatch
	INSERT INTO dbo.tblFaAssetService (ID,AssetID,ServiceDateAct,ServDescr,WorkOrderID,WorkOrderNo,ServiceCost)
	SELECT @AssetServiceID + ROW_NUMBER() OVER (ORDER BY d.ID), e.AssetID, a.CompletedDate
		, (SELECT TOP 1 [Description] FROM dbo.tblSvWorkOrderDispatchWorkToDo WHERE DispatchID = d.iD ORDER BY GroupID)
		,w.ID, w.WorkOrderNo, ISNULL(ServiceCost,0)
	FROM  dbo.tblSvWorkOrderDispatch d 
	INNER JOIN dbo.tblSvWorkOrder w ON  d.WorkOrderID = w.ID 
	INNER JOIN dbo.tblSvEquipment e ON e.ID = d.EquipmentID
	INNER JOIN tblSvInvoiceDispatch dis ON dis.DispatchID = d.ID
	INNER JOIN #PostTransList p ON p.TransID = dis.TransID 
	INNER JOIN tblSvInvoiceHeader h ON p.TransID =h.TransID 
	LEFT JOIN (SELECT DispatchID, SUM(i.CostExt) ServiceCost from dbo.tblSvInvoiceDetail i
				INNER JOIN #PostTransList p ON p.TransID = i.TransID 
				INNER JOIN tblSvInvoiceHeader h ON i.TransID =h.TransID 
				WHERE h.VoidYN =0 GROUP BY DispatchID) s
				ON s.DispatchID = d.ID
	LEFT JOIN ( SELECT DispatchID, MAX(ActivityDateTime) CompletedDate
				FROM tblSvWorkOrderActivity where ActivityType = 4
				GROUP BY DispatchID ) a  ON d.ID =a.DispatchID 
	WHERE h.VoidYN =0 AND d.CancelledYN = 0 AND e.Ownership= 2 AND e.AssetID IS NOT NULL 	


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_GenerateFaAssetService_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_GenerateFaAssetService_proc';

