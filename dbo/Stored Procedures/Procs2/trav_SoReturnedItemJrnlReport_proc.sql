
CREATE PROCEDURE [dbo].[trav_SoReturnedItemJrnlReport_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT [Status], ResCode, ISNULL(RMANumber, TransId) AS RMANumber, r.ItemId, CustID, TransId, EntryNum, r.LocId
		, ExtLocA, a.ExtLocId AS ExtLocAID, ExtLocB, b.ExtLocId AS ExtLocBID
		, EntryDate, TransDate, Units, QtyReturn, LotNum, SerNum, UnitCost, CostExt, UnitPrice, PriceExt
		, QtySeqNum, QtySeqNumExt, HistSeqNum, HistSeqNumSer, GLAcctCOGS, GLAcctInv, i.Descr ItemDescr
	FROM dbo.tblSoReturnedItem r
	LEFT JOIN dbo.tblInItem i ON r.ItemId = i.ItemId
	LEFT JOIN dbo.tblWmExtLoc a ON r.ExtLocA = a.Id AND a.Type = 0 
    LEFT JOIN dbo.tblWmExtLoc b ON r.ExtLocB = b.Id AND b.Type = 1
	WHERE r.Status = 0 --only approved
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemJrnlReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemJrnlReport_proc';

