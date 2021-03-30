
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_PCMatReq_proc
AS
BEGIN TRY
	--PET:http://webfront:801/view.php?id=235736
	--PET:http://webfront:801/view.php?id=242411
	SET NOCOUNT ON


	--identify any WM Material Requisitions that are available for picking	
	INSERT INTO #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum
		, ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq
		, ReqDate, GrpId, OriCompQty, Ref1, Ref2, Ref3, BatchId)
	SELECT 32, 'MATREQ', h.[Id], ISNULL(e.[Id], 0), Null
		, h.ItemId, h.LocId, e.LotNum, e.ExtLocA, e.ExtLocB, h.UOM
		, ISNULL((e.QtyNeed - e.QtyFilled), (h.QtyNeed - h.QtyFilled))
		, h.TransDate, Null, 0, h.BatchId, Null, Null, h.BatchId
	FROM dbo.tblPcTrans h
	INNER JOIN dbo.tblInItem i ON h.[ItemId] = i.[ItemId]
	LEFT JOIN dbo.tblPcTransExt e ON h.[Id] = e.TransId
	LEFT JOIN dbo.tblSmTransLink l ON h.[LinkSeqNum] = l.[SeqNum]
	WHERE h.TransType = 0 --is a regular MatReq
		AND (h.QtyNeed - h.QtyFilled) > 0 --has quantity to process at the line item
		AND (l.SeqNum IS NULL OR l.TransLinkType = 1  OR l.SourceStatus = 2 OR l.DestStatus = 2 OR (l.TransLinkType = 0 AND l.DropShipYn=0)) --((transaction linked and not DropShipped) or link is broken)
		AND i.[ItemType] <> 3 AND i.[KittedYN] = 0 --must be an IN items - but not Service Items or Kit
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_PCMatReq_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_PCMatReq_proc';

