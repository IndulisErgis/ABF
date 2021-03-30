
CREATE PROCEDURE [dbo].[trav_InItemExtQtyLot_proc] 
@ItemId [pItemId],
@LocId [pLocId],
@LotNum [pLotNum] = null --optional lot number
AS
BEGIN TRY

	SET NOCOUNT ON

	SELECT qtydtl.ItemId, qtydtl.LocId, qtyDtl.LotNum, qtydtl.ExtLocA, a.ExtLocId AS ExtLocAId, qtydtl.ExtLocB, b.ExtLocId AS ExtLocBId
		, qtyDtl.QtyCmtd, qtyDtl.QtyOnOrder
	FROM (
		SELECT qt.ItemId, qt.LocId, qt.LotNum, qt.ExtLocA, qt.ExtLocB
			, Sum(qt.QtyCmtd) QtyCmtd, Sum(qt.QtyOnOrder) QtyOnOrder
		FROM (
			SELECT q.ItemId, q.LocId, q.LotNum, q.ExtLocA, q.ExtLocB
				, Sum(q.QtyCmtd) QtyCmtd, Sum(q.QtyOnOrder) QtyOnOrder
				--use qty from tblInQty as total
				FROM (SELECT d.ItemId, d.LocId, d.LotNum, Null ExtLocA, Null ExtLocB
						, CASE WHEN d.TransType = 0 THEN d.Qty ELSE 0 END QtyCmtd
						, CASE WHEN d.TransType = 2 THEN d.Qty ELSE 0 END QtyOnOrder
						FROM dbo.tblInQty d 
						WHERE (d.TransType = 0 or d.TransType = 2) --cmtd/onorder
							AND d.[ItemId] = @ItemId AND d.[LocId] = @LocId 
							AND (d.LotNum = @LotNum OR @LotNum Is Null)
					UNION ALL --reduce the Null extLoc qtys by the total from tblInQty_Ext
					SELECT d.ItemId, d.LocId, d.LotNum, Null ExtLocA, Null ExtLocB
						, CASE WHEN d.TransType = 0 THEN -d.Qty ELSE 0 END QtyCmtd
						, CASE WHEN d.TransType = 2 THEN -d.Qty ELSE 0 END QtyOnOrder
						FROM dbo.tblInQty_Ext d 
						WHERE (d.TransType = 0 or d.TransType = 2) --cmtd/onorder
							AND d.[ItemId] = @ItemId AND d.[LocId] = @LocId 
							AND (d.LotNum = @LotNum OR @LotNum Is Null)
					UNION ALL --Add in the detail for extloc from tblInQty_Ext
					SELECT d.ItemId, d.LocId, d.LotNum, ExtLocA,ExtLocB
						, CASE WHEN d.TransType = 0 THEN d.Qty ELSE 0 END QtyCmtd
						, CASE WHEN d.TransType = 2 THEN d.Qty ELSE 0 END QtyOnOrder
						FROM dbo.tblInQty_Ext d 
						WHERE (d.TransType = 0 or d.TransType = 2) --cmtd/onorder
							AND d.[ItemId] = @ItemId AND d.[LocId] = @LocId 
							AND (d.LotNum = @LotNum OR @LotNum Is Null)
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
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemExtQtyLot_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemExtQtyLot_proc';

