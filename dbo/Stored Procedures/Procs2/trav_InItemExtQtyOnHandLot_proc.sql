
CREATE PROCEDURE [dbo].[trav_InItemExtQtyOnHandLot_proc] 
@ItemId [pItemId],
@LocId [pLocId], 
@LotNum [pLotNum] = null --optional lot number for prefiltering results
AS
BEGIN TRY

	SET NOCOUNT ON

	SELECT qtydtl.ItemId, qtydtl.LocId, qtydtl.LotNum, qtydtl.ExtLocA, a.ExtLocId AS ExtLocAId, qtydtl.ExtLocB, b.ExtLocId AS ExtLocBId
		, qtydtl.QtyOnHand
	FROM (
		SELECT qt.ItemId, qt.LocId, qt.LotNum, qt.ExtLocA, qt.ExtLocB
			, Sum(qt.QtyOnHand) QtyOnHand
		FROM (
			SELECT q.ItemId, q.LocId, q.LotNum, q.ExtLocA, q.ExtLocB
				, Sum(QtyOnHand) QtyOnHand
				FROM (SELECT d.ItemId, d.LocId, d.LotNum, Null ExtLocA, Null ExtLocB
					, (d.Qty - d.InvoicedQty - d.RemoveQty) QtyOnHand
						FROM dbo.tblInQtyOnHand d 
						WHERE d.[ItemId] = @ItemId AND d.[LocId] = @LocId AND (d.LotNum = @LotNum OR @LotNum Is Null)
					UNION ALL --reduce the Null ExtLoc Qtys by the total from tblInQtyOnHand_Ext
					SELECT d.ItemId, d.LocId, d.LotNum, Null ExtLocA, Null ExtLocB, -d.Qty
						FROM dbo.tblInQtyOnHand_Ext d
						WHERE d.[ItemId] = @ItemId AND d.[LocId] = @LocId AND (d.LotNum = @LotNum OR @LotNum Is Null)
					UNION ALL --Add in the detail for ExtLoc from tblInQtyOnHand_Ext
					SELECT d.ItemId, d.LocId, d.LotNum, d.ExtLocA, d.ExtLocB, d.Qty
						FROM dbo.tblInQtyOnHand_Ext d
						WHERE d.[ItemId] = @ItemId AND d.[LocId] = @LocId AND (d.LotNum = @LotNum OR @LotNum Is Null)
					) q
				GROUP BY q.ItemId, q.LocId, q.LotNum, q.ExtLocA, q.ExtLocB
			) qt

		GROUP BY qt.ItemId, qt.LocId, qt.LotNum, qt.ExtLocA, qt.ExtLocB
	) qtydtl
	LEFT JOIN dbo.tblWmExtLoc  a
		ON qtydtl.ExtLocA = a.Id
	LEFT JOIN dbo.tblWmExtLoc  b
		ON qtydtl.ExtLocB = b.Id
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemExtQtyOnHandLot_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemExtQtyOnHandLot_proc';

