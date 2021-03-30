
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_SD_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--identify any SD Part type transactions that are available for picking	
	INSERT INTO #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum
		, ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq
		, ReqDate, GrpId, OriCompQty, Ref1, Ref2, Ref3, BatchId)
	SELECT 2, 'PART', t.[Id], ISNULL(e.[Id], 0), Null
		, t.ResourceID, t.LocId, e.LotNum, e.ExtLocA, e.ExtLocB, t.Unit
		, ISNULL((e.QtyEstimated - e.QtyUsed), (t.QtyEstimated - t.QtyUsed))
		, t.TransDate, Null, 0, w.WorkOrderNo, d.DispatchNo, Null, Null
	FROM dbo.tblSvWorkOrderTrans t
	INNER JOIN dbo.tblInItem i ON t.[ResourceID] = i.[ItemId]
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.Id 
	INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.Id
	INNER JOIN (
						SELECT DISTINCT DispatchID
						FROM dbo.tblSvWorkOrderActivity
						WHERE ActivityType = 1 --Dispatch is scheduled
					) a ON t.DispatchID = a.DispatchID
	LEFT JOIN dbo.tblSvWorkOrderTransExt e ON t.[Id] = e.TransId
	LEFT JOIN dbo.tblSmTransLink l ON t.[LinkSeqNum] = l.[SeqNum]
	WHERE t.TransType = 1 --Transaction Type is Part
		AND  t.[Status] = 0 --Transaction is not posted
		AND d.[Status] = 0 --Dispatch is Open
		AND d.CancelledYN = 0 -- Dispatch is not cancelled
		AND d.HoldYN = 0 --Dispatch is not on hold	
		AND (t.QtyEstimated - t.QtyUsed) > 0 --has quantity to process 
		AND (l.SeqNum IS NULL OR l.TransLinkType = 1 OR l.SourceStatus = 2 OR l.DestStatus = 2 OR (l.TransLinkType = 0 AND l.DropShipYn=0)) --((transaction linked and not DropShipped) or link is broken)
		AND i.[ItemType] <> 3 --must be an IN items - but not Service Items
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_SD_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_SD_proc';

