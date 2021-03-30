
CREATE PROCEDURE [dbo].[trav_WMAutoCreatePickReleaseOrders_BuildOrderList_SO_proc]
@transId pTransId
AS
BEGIN TRY
	SET NOCOUNT ON
	
	--identify Sales Order	
	INSERT INTO #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum
		, ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq, ReqDate
		, GrpId, OriCompQty, Ref1, Ref2, Ref3, BatchId)
	SELECT 0, h.TransId, d.EntryNum, d.SeqNum, h.PickNum
		, d.ItemId, d.LocId, d.LotNum, d.ExtLocA, d.ExtLocB, d.UnitsSell, d.QtyReq
		, ISNULL(d.ReqShipDate, ISNULL(h.ReqShipDate, h.TransDate))
		, d.GrpId, d.OriCompQty, h.TransId, Null, Null, h.BatchId
	FROM dbo.tblSoTransHeader h 
	INNER JOIN 
	(SELECT d1.TransId, d1.EntryNum, ISNULL(e.SeqNum, 0) SeqNum
		, d1.ItemType, d1.ItemId, d1.LocId
		, d1.ReqShipDate, d1.GrpId, d1.OriCompQty, d1.UnitsSell
		, e.LotNum, e.ExtLocA, e.ExtLocB
		, ISNULL(e.QtyOrder - e.QtyFilled, d1.QtyOrdSell - d1.QtyShipSell) QtyReq
		FROM dbo.tblSoTransDetail d1 
		LEFT JOIN dbo.tblSoTransDetailExt e
			ON d1.TransId = e.TransId AND d1.EntryNum = e.EntryNum 
		LEFT JOIN dbo.tblSmTransLink l ON d1.[LinkSeqNum] = l.[SeqNum]
		WHERE d1.[Status] = 0 --not completed
			AND d1.[ItemType] Not In (0, 3) --IN items, but not Service Items
			AND (l.SeqNum IS NULL OR l.TransLinkType = 1  OR l.SourceStatus = 2 OR l.DestStatus = 2 OR l.DestType = 10 ) --not transaction linked or link is broken
	) d ON h.TransId = d.TransId
	WHERE d.QtyReq > 0
		AND h.[TransId] = @transId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMAutoCreatePickReleaseOrders_BuildOrderList_SO_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMAutoCreatePickReleaseOrders_BuildOrderList_SO_proc';

