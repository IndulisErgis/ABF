
CREATE PROCEDURE dbo.trav_WmMoveQuantityPost_Inventory_proc
@TransId int
AS
BEGIN TRY

	IF @TransId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--Update tblInItemSer for any items in #MoveQuantity with an ItemType = 2
	UPDATE dbo.tblInItemSer 
		SET [ExtLocA] = t.[ExtLocATo], [ExtLocB] = t.[ExtLocBTo]
		FROM #MoveQuantity t
		WHERE t.[TransId] = @TransId
			AND t.[ItemType] = 2
			AND dbo.tblInItemSer.[ItemId] = t.[ItemId] AND dbo.tblInItemSer.[SerNum] = t.[SerNum]


	--Create In/Out records in tblInQtyOnHand_Ext for any item in #MoveQuantity with an ItemType <> 2 and Qty <> 0
	--move out
	INSERT INTO dbo.tblInQtyOnHand_Ext ([ItemId], [LocId], [LotNum], [ExtLocA], [ExtLocB], [Qty])
	SELECT [ItemId], [LocId], [LotNum], [ExtLocAFrom], [ExtLocBFrom], -[Qty]
	FROM #MoveQuantity t
	WHERE t.[TransId] = @TransId AND t.[Qty] <> 0.0 AND t.[ItemType] <> 2
	
	--move in
	INSERT INTO dbo.tblInQtyOnHand_Ext ([ItemId], [LocId], [LotNum], [ExtLocA], [ExtLocB], [Qty])
	SELECT [ItemId], [LocId], [LotNum], [ExtLocATo], [ExtLocBTo], [Qty]
	FROM #MoveQuantity t
	WHERE t.[TransId] = @TransId AND t.[Qty] <> 0.0 And t.[ItemType] <> 2

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_Inventory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_Inventory_proc';

