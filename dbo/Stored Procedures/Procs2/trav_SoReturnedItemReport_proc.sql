
CREATE PROCEDURE dbo.trav_SoReturnedItemReport_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT r.Status,r.ResCode,r.RMANumber,r.EntryDate,r.ItemId,r.LocId,r.Units,r.QtyReturn,
		r.SerNum,r.LotNum,i.Descr ItemDescr, c.Descr ResCodeDescr,
		a.ExtLocID AS ExtLocAID, b.ExtLocID AS ExtLocBID
	FROM #tmpReturnedItemList t INNER JOIN dbo.tblSoReturnedItem r ON t.Counter = r.Counter
		LEFT JOIN dbo.tblInItem i ON r.ItemId = i.ItemId
		LEFT JOIN dbo.tblSoReasONCode c ON r.ResCode = c.ResCode
		LEFT JOIN dbo.tblWmExtLoc a ON r.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON r.ExtLocB = b.Id
	WHERE Status <> 9 --exclude "Posted" records

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemReport_proc';

