
CREATE PROCEDURE dbo.trav_BmKitSalesHistoryInquiry_proc
AS
SET NOCOUNT ON
BEGIN TRY

SELECT h.ItemId, h.LocId, h.SumYear, h.GLPeriod, h.BatchId, h.TransId, h.SrceID, h.Uom, h.Qty, h.Cost, h.Price, 
	h.CustId, h.TransDate, h.InvcNum, h.HistSeqNum, i.Descr, i.ProductLine, i.SalesCat
FROM #tmpHistoryList t INNER JOIN dbo.tblBmKitHistSumm h ON t.HistSeqNum = h.HistSeqNum 
	LEFT JOIN dbo.tblInItem i ON h.ItemId = i.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmKitSalesHistoryInquiry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmKitSalesHistoryInquiry_proc';

