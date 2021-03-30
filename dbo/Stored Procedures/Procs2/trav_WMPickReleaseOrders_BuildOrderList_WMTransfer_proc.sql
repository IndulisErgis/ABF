
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_WMTransfer_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PrecQty pDecimal
	
	--Retrieve global values
	SELECT @PrecQty = Cast([Value] AS decimal(28,10)) FROM #GlobalValues WHERE [Key] = 'PrecQty'

	IF @PrecQty IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--identify any WM Transfers that are available for picking	
	INSERT INTO #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum
		, ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq
		, ReqDate, GrpId, OriCompQty, Ref1, Ref2, Ref3, BatchId)
	SELECT 4, 'XFER', h.TranKey, 0, Null
		, h.ItemId, h.LocId, h.LotNum, Null, Null, h.UOM, (h.Qty - s.QtyPicked)
		, h.TransDate, Null, 0, h.BatchId, Null, Null, h.BatchId --use the batch id to identify Ref1 Groupings
	FROM dbo.tblWmTransfer h 
	INNER JOIN 
	(SELECT t.TranKey, SUM(ROUND(ISNULL(((p.Qty * ISNULL(ub.ConvFactor, 1.0)) / ISNULL(us.ConvFactor, 1.0)), 0), @PrecQty)) QtyPicked
		FROM dbo.tblWmTransfer t 
		LEFT JOIN dbo.tblWmTransferPick p ON t.TranKey = p.TranKey 
		LEFT JOIN dbo.tblInItemUOM ub ON p.ItemId = ub.ItemId And p.UOM = ub.UOM
		LEFT JOIN dbo.tblInItemUOM us ON p.ItemId = us.ItemId and t.UOM = us.UOM
		GROUP BY t.TranKey
	) s ON h.TranKey = s.TranKey
	LEFT JOIN (SELECT BatchId, [Lock] FROM dbo.tblSmBatch WHERE FunctionId = 'WMTRANSFER') b ON h.BatchID = b.BatchId
	WHERE h.[Status] = 0 --New transfer
		AND ISNULL(b.Lock, 0) = 0 --not in a locked batch
		AND (h.Qty - s.QtyPicked) > 0 --has remaining qty to process
			

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_WMTransfer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_WMTransfer_proc';

