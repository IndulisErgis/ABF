
CREATE PROCEDURE dbo.trav_InUpdatePerpetual_ProcessInvalidExtLoc_proc 
@BatchId pBatchId
AS
BEGIN TRY

INSERT INTO dbo.tblInQtyOnHand_Ext ([ItemId], [LocId], [LotNum], [ExtLocA], [ExtLocB], [Qty])
SELECT e.ItemId, e.LocId, e.LotNum, e.ExtLocA, e.ExtLocB, -SUM(Qty) AS QtyOnHand
			FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInQtyOnHand_Ext e ON 
					c.ItemId = e.ItemId AND c.LocId = e.LocId AND (c.LotNum = e.LotNum OR (c.LotNum IS NULL AND e.LotNum IS NULL))
				LEFT JOIN dbo.tblWmExtLoc a ON e.ExtLocA = a.Id 
				LEFT JOIN dbo.tblWmExtLoc b ON e.ExtLocB = b.Id 
			WHERE c.BatchId = @BatchId AND (e.ExtLocA IS NOT NULL AND a.Id IS NULL) OR (e.ExtLocB IS NOT NULL AND b.Id IS NULL)
			GROUP BY e.ItemId, e.LocId, e.LotNum, e.ExtLocA, e.ExtLocB

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_ProcessInvalidExtLoc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_ProcessInvalidExtLoc_proc';

