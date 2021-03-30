
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_PurchaseReturn_proc
AS
BEGIN TRY
	SET NOCOUNT ON


	--identify any Purchase Return that are available for picking	
	INSERT INTO #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum
		, ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq, ReqDate
		, GrpId, OriCompQty, Ref1, Ref2, Ref3, BatchId)
	SELECT 64, h.TransId, d.EntryNum, 0, NULL
		, d.ItemId, d.LocId, NULL, NULL, NULL, d.Units, (d.QtyOrd - ISNULL(QtyRcpt,0))
		, ISNULL(d.ReqShipDate, ISNULL(h.ReqShipDate, h.TransDate))
		, NULL, 0, h.TransId, Null, Null, h.BatchId
	FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
		LEFT JOIN (SELECT TransId, EntryNum, SUM(QtyFilled) AS QtyRcpt FROM dbo.tblPoTransLotRcpt GROUP BY TransId, EntryNum) r 
		ON d.TransID = r.TransId AND d.EntryNum = r.EntryNum
	WHERE (d.QtyOrd - ISNULL(QtyRcpt,0)) > 0 AND d.LineStatus = 0 --not completed
		AND d.ItemType NOT IN (0,3) --IN items, but not Service Items
		AND h.[TransType] < 0 --TransType of Return
		AND h.[TransId] NOT IN (SELECT TransId FROM dbo.tblSmTransControl WHERE FunctionId = 'POTRANS') --not locked	
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_PurchaseReturn_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_PurchaseReturn_proc';

