
CREATE PROCEDURE dbo.trav_PoGoodsNotReceivedReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@CurrencyPrecision tinyint = 2,
@SortBy tinyint = 0 -- 0, Transaction Number; 1, Vendor ID; 2, Item ID; 3, Requested Date; 4, Status 
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT d.TransID, d.EntryNum, MIN(d.GLAcct) AS GLAcct, MIN(d.QtyOrd) AS OrdQty, 
		MIN(CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn END) AS OrdUnitCost, 
		MIN(CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn END) AS OrdExtCost, 
		MIN(ISNULL(d.ItemId, '')) AS ItemId, MIN(d.ItemType) AS ItemType, MIN(ISNULL(d.LocId, '')) AS LocIdDtl, 
		MIN(ISNULL(d.Descr, '')) AS Descr, MIN(ISNULL(d.UnitsBase, '')) AS UnitsBase, 
		MIN(ISNULL(d.Units, '')) AS Units, MIN(d.LineStatus) AS LineStatus, 
		MIN(ISNULL(d.GLDesc, '')) AS GLDesc, MIN(ISNULL(d.ReqShipDate,h.ReqShipDate)) AS ReqShipDateDtl, 
		SUM(CASE WHEN r.TransId IS NOT NULL THEN r.QtyFilled ELSE 0 END) AS RcptQty, 
		SUM(CASE WHEN r.TransId IS NOT NULL THEN CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END ELSE  0 END) AS RcptExtCost
		, MIN(ISNULL(d.ExpReceiptDate,h.ExpReceiptDate)) AS ExpReceiptDate 
	INTO #tmpPoNotRecvRptSub
	FROM #tmpTransDetailList t 
	    INNER JOIN dbo.tblPoTransHeader h ON h.TransId = t.TransId
	    INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum
		LEFT JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
	WHERE h.TransType <> 0
	GROUP BY d.TransID, d.EntryNum

	SELECT CASE @SortBy WHEN 0 THEN t.TransId WHEN 1 THEN h.VendorId WHEN 2 THEN t.ItemId 
			WHEN 3 THEN CONVERT(nvarchar(8),t.ReqShipDateDtl,112) 
			WHEN 4 THEN CASE h.TransType
			--PET:http://webfront:801/view.php?id=242578
			--PET:http://webfront:801/view.php?id=243057
			      WHEN  1 THEN '0'
				  WHEN 2 THEN '0'
				  WHEN -2 THEN '0'
				  WHEN 9 THEN '1'
				  WHEN -1 THEN '1'
			   END
		END AS SortColumn1,
		CASE @SortBy WHEN 0 THEN h.VendorId ELSE t.TransId END AS SortColumn2,
		CASE @SortBy WHEN 2 THEN t.TransId ELSE t.ItemId END AS SortColumn3,
		h.BatchId, h.TransType, h.VendorId, h.TransDate, h.ReqShipDate AS ReqShipDateHdr, 
		h.OrderedBy, h.ReceivedBy, h.ExchRate, ([OrdQty]-[RcptQty]) AS UnrecvQty,
		(([OrdQty]-[RcptQty])*[OrdUnitCost]) AS UnrecvExtCost, 
		ROUND([OrdUnitCost]*([OrdQty]-[RcptQty]), @CurrencyPrecision) AS UnrecvExtCostGrp0, h.TransID AS TransID2,
		t.TransId, t.EntryNum, t.GlAcct, t.OrdQty, t.OrdUnitCost, t.OrdExtCost,
		t.ItemId, t.ItemType, t.LocIdDtl, t.Descr, t.UnitsBase,
		t.Units, t.LineStatus, t.GLDesc, t.ReqShipDateDtl, t.RcptQty, t.RcptExtCost, t.ExpReceiptDate
	FROM dbo.tblPoTransHeader h INNER JOIN #tmpPoNotRecvRptSub t ON h.TransId = t.TransId 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) AND (t.OrdQty - t.RcptQty) > 0  
 
	--Lot
	SELECT r.TransId, r.EntryNum, r.LotNum, SUM(r.QtyFilled) Qty
		, SUM(CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END) AS ExtCost
	FROM #tmpTransDetailList t 
	INNER JOIN dbo.tblPoTransHeader h ON h.TransId = t.TransId
	INNER JOIN dbo.tblPoTransLotRcpt r (NOLOCK) ON t.TransId = r.TransId AND t.EntryNum = r.EntryNum
	WHERE r.LotNum IS NOT NULL AND h.TransType <> 0
	GROUP BY r.TransId, r.EntryNum, r.LotNum

	--Ser
	SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, CASE WHEN @PrintAllInBase = 1 THEN s.RcptUnitCost ELSE s.RcptUnitCostFgn END AS RcptUnitCost
	FROM #tmpTransDetailList t 
	INNER JOIN dbo.tblPoTransHeader h ON h.TransId = t.TransId
	INNER JOIN dbo.tblPoTransSer s (NOLOCK) ON t.TransId = s.TransId AND t.EntryNum = s.EntryNum
	WHERE h.TransType <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoGoodsNotReceivedReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoGoodsNotReceivedReport_proc';

