
CREATE PROCEDURE dbo.trav_SvServiceOrderPost_GenerateFaAssetService_proc
AS
BEGIN TRY

	DECLARE @AssetServiceID int
	SELECT @AssetServiceID = MAX(ID) FROM dbo.tblFaAssetService
	SET @AssetServiceID = ISNULL(@AssetServiceID,0)

	-- create one record in tblFaAssetService per dispatch
	INSERT INTO dbo.tblFaAssetService (ID,AssetID,ServiceDateAct,ServDescr,WorkOrderID,WorkOrderNo,ServiceCost)
	SELECT @AssetServiceID + ROW_NUMBER() OVER (ORDER BY d.ID), e.AssetID, c.CompletedDate, (SELECT TOP 1 [Description] FROM dbo.tblSvWorkOrderDispatchWorkToDo WHERE DispatchID = d.iD ORDER BY GroupID),w.ID,w.WorkOrderNo, ISNULL(tr.CostExt,0)
	FROM #ServiceOrderDispatchList t INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID
		INNER JOIN dbo.tblSvWorkOrder w ON  d.WorkOrderID = w.ID 
		INNER JOIN dbo.tblSvEquipment e ON e.ID = d.EquipmentID
		INNER JOIN dbo.tblFaAsset a ON e.AssetID = a.AssetId
		LEFT JOIN (SELECT t.DispatchID, SUM(tr.CostExt) AS CostExt FROM #ServiceOrderDispatchList t INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.DispatchID = tr.DispatchID GROUP BY t.DispatchID) tr 
			ON t.DispatchID = tr.DispatchID
		LEFT JOIN (SELECT t.DispatchID, MAX(c.ActivityDateTime) AS CompletedDate FROM #ServiceOrderDispatchList t INNER JOIN dbo.tblSvWorkOrderActivity c ON t.DispatchID = c.DispatchID AND c.ActivityType = 4 GROUP BY t.DispatchID) c 
			ON t.DispatchID = c.DispatchID 
	WHERE d.CancelledYN = 0 AND e.Ownership= 2 AND e.AssetID IS NOT NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GenerateFaAssetService_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GenerateFaAssetService_proc';

