
CREATE PROCEDURE dbo.trav_BmWorkOrderHistoryReport_proc
AS
SET NOCOUNT ON
BEGIN TRY

SELECT h.PostRun, h.TransId, h.EntryNum, h.TransDate, h.WorkType, h.Status, h.PrintedYn, 
	h.BmBomId, h.ItemId, h.LocId, h.ItemType, h.BuildUOM, h.BuildQty, h.ActualQty, h.LaborCost, 
	h.UnitCost, h.ConvFactor, h.GLPeriod, h.GlYear, h.SumHistPeriod, h.QtySeqNum, h.HistSeqNum, 
	h.WorkUser, h.Descr, h.UomBase, h.ItemStatus, h.ItemLocStatus, h.GLAcctCode, b.Descr BomDescr,
	h.ActualQty * (h.UnitCost + h.LaborCost) AS ExtCost
FROM #tmpHistoryList t INNER JOIN dbo.tblBmWorkOrderHist h ON t.PostRun = h.PostRun AND t.TransId = h.TransId
	LEFT JOIN dbo.tblBmBom b ON h.BmBomId = b.BmBomId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderHistoryReport_proc';

