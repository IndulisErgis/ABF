
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_SO_proc
AS
BEGIN TRY
	SET NOCOUNT ON


	--identify any Sales Order that are available for picking	
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
		, ISNULL(SUM(e.QtyOrder - e.QtyFilled), MAX(d1.QtyOrdSell - d1.QtyShipSell)) QtyReq
		FROM dbo.tblSoTransDetail d1 
		LEFT JOIN dbo.tblSoTransDetailExt e
			ON d1.TransId = e.TransId AND d1.EntryNum = e.EntryNum 
		LEFT JOIN dbo.tblSmTransLink l ON d1.[LinkSeqNum] = l.[SeqNum]
		WHERE d1.[Status] = 0 --not completed
			AND d1.[ItemType] Not In (0, 3) --IN items, but not Service Items
			AND (l.SeqNum IS NULL OR l.TransLinkType = 1 OR l.SourceStatus = 2 OR l.DestStatus = 2 OR (l.TransLinkType = 0 AND l.DropShipYn=0)) --((transaction linked and not DropShipped) or link is broken)
			AND d1.QtyOrdSell > d1.QtyShipSell --has req qty at line item level
		GROUP BY d1.TransId, d1.EntryNum, e.SeqNum, d1.ItemType, d1.ItemId, d1.LocId
			, d1.ReqShipDate, d1.GrpId, d1.OriCompQty, d1.UnitsSell, e.LotNum, e.ExtLocA, e.ExtLocB
	) d ON h.TransId = d.TransId
	WHERE d.QtyReq > 0
		AND h.[TransType] in (3, 5, 9) --TransType of 9=New/3=Backordered/5=Picked
		AND h.[VoidYn] = 0 --not voided
		AND h.[TransId] NOT IN (SELECT TransId FROM dbo.tblSmTransControl WHERE FunctionId = 'SOTRANS') --not locked

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_SO_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_SO_proc';

