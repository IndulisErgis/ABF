
CREATE PROCEDURE dbo.trav_BmWorkOrderView_proc

AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT h.PostRun, h.TransId, h.EntryNum, h.TransDate, h.WorkType, h.[Status], h.PrintedYn
		, h.BmBomId, h.ItemId, h.LocId, h.ItemType, h.BuildUOM
		, CASE WHEN h.WorkType = 1 THEN 1 ELSE -1 END * h.BuildQty AS BuildQty
		, CASE WHEN h.WorkType = 1 THEN 1 ELSE -1 END * h.ActualQty AS ActualQty
		, h.LaborCost, h.UnitCost, h.ConvFactor, h.GLPeriod, h.GlYear, h.SumHistPeriod, h.QtySeqNum, h.HistSeqNum
		, h.WorkUser, h.Descr, h.UomBase, h.ItemStatus, h.ItemLocStatus, h.GLAcctCode, b.Descr BomDescr
		, CASE WHEN h.WorkType = 1 THEN h.ActualQty * (h.UnitCost + h.LaborCost) 
			ELSE h.ActualQty * (-h.UnitCost + h.LaborCost) END AS ExtCost 
	FROM #tmpHistoryList t 
		INNER JOIN dbo.tblBmWorkOrderHist h ON t.PostRun = h.PostRun AND t.TransId = h.TransId 
		LEFT JOIN dbo.tblBmBom b ON h.BmBomId = b.BmBomId
	UNION ALL
	SELECT NULL AS PostRun, w.TransId, w.EntryNum, w.TransDate, w.WorkType, w.[Status], w.PrintedYn
		, w.BmBomId, w.ItemId, w.LocId, w.ItemType, w.BuildUOM
		, CASE WHEN w.WorkType = 1 THEN 1 ELSE -1 END * w.BuildQty AS BuildQty
		, CASE WHEN w.WorkType = 1 THEN 1 ELSE -1 END * w.ActualQty AS ActualQty
		, w.LaborCost, w.UnitCost, w.ConvFactor, w.GLPeriod, w.GlYear, w.SumHistPeriod, w.QtySeqNum, w.HistSeqNum
		, w.WorkUser, i.Descr, i.UomBase, i.ItemStatus, l.ItemLocStatus, l.GLAcctCode, b.Descr BomDescr
		, CASE WHEN w.WorkType = 1 THEN w.ActualQty * (w.UnitCost + w.LaborCost) 
			ELSE w.ActualQty * (-w.UnitCost + w.LaborCost) END AS ExtCost 
	FROM #tmpHistoryList t 
		INNER JOIN dbo.tblBmWorkOrder w ON t.TransId = w.TransId 
		LEFT JOIN dbo.tblBmBom b ON w.BmBomId = b.BmBomId 
		LEFT JOIN dbo.tblInItem i ON w.ItemId = i.ItemId 
		LEFT JOIN dbo.tblInItemLoc l ON w.ItemId = l.ItemId AND w.LocId = l.LocId 
	WHERE t.PostRun = '' -- live orders use an empty string for the PostRun in the primary key

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderView_proc';

