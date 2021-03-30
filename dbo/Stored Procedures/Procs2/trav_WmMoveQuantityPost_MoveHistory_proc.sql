
CREATE PROCEDURE dbo.trav_WmMoveQuantityPost_MoveHistory_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @PrecQty tinyint
	
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'

	IF @PostRun IS NULL OR @PrecQty IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblWmHistMoveQuantity (PostRun, ID, ParentID, MoveBy, MoveByID, LocID, LotNum, SerNum, ExtLocAFrom, ExtLocBFrom, ExtLocATo, ExtLocBTo, 
		ExtLocAIDFrom, ExtLocBIDFrom, ExtLocAIDTo, ExtLocBIDTo, Qty, QtyBase, UOM, UOMBase, EntryDate, TransDate, [UID], HostID, CF)
	SELECT @PostRun, m.Id, m.ParentId, m.MoveBy, m.MoveById, m.LocID, m.LotNum, m.SerNum, m.ExtLocAFrom, m.ExtLocBFrom, m.ExtLocATo, m.ExtLocBTo, af.ExtLocID, 
		bf.ExtLocID, at.ExtLocID, bt.ExtLocID, m.Qty, ROUND(m.Qty * u.ConvFactor, @PrecQty), m.UOM, i.UomBase, m.EntryDate, m.TransDate, m.[UID], m.HostID, m.CF
	FROM #TransList t INNER JOIN dbo.tblWmMoveQuantity m ON t.TransId = m.Id
		LEFT JOIN dbo.tblInItem i ON m.MoveById = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON m.MoveById = u.ItemId AND m.Uom = u.Uom
		LEFT JOIN dbo.tblWmExtLoc af ON m.[ExtLocAFrom] = af.[Id]
		LEFT JOIN dbo.tblWmExtLoc bf ON m.[ExtLocBFrom] = bf.[Id]
		LEFT JOIN dbo.tblWmExtLoc at ON m.[ExtLocATo] = at.[Id]
		LEFT JOIN dbo.tblWmExtLoc bt ON m.[ExtLocBTo] = bt.[Id]
	WHERE m.MoveBy = 0 --By Item
	UNION ALL
	SELECT @PostRun, m.Id, m.ParentId, m.MoveBy, m.MoveById, m.LocID, m.LotNum, m.SerNum, m.ExtLocAFrom, m.ExtLocBFrom, m.ExtLocATo, m.ExtLocBTo, af.ExtLocID, 
		bf.ExtLocID, at.ExtLocID, bt.ExtLocID, m.Qty, ROUND(m.Qty * u.ConvFactor, @PrecQty), m.UOM, i.UomBase, m.EntryDate, m.TransDate, m.[UID], m.HostID, m.CF
	FROM #TransList t INNER JOIN dbo.tblWmMoveQuantity m ON t.TransId = m.ParentId
		LEFT JOIN dbo.tblInItem i ON m.MoveById = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON m.MoveById = u.ItemId AND m.Uom = u.Uom
		LEFT JOIN dbo.tblWmExtLoc af ON m.[ExtLocAFrom] = af.[Id]
		LEFT JOIN dbo.tblWmExtLoc bf ON m.[ExtLocBFrom] = bf.[Id]
		LEFT JOIN dbo.tblWmExtLoc at ON m.[ExtLocATo] = at.[Id]
		LEFT JOIN dbo.tblWmExtLoc bt ON m.[ExtLocBTo] = bt.[Id]
	WHERE m.MoveBy = 0 --By Item
	UNION ALL
	SELECT @PostRun, m.Id, m.ParentId, m.MoveBy, m.MoveById, m.LocID, m.LotNum, m.SerNum, m.ExtLocAFrom, m.ExtLocBFrom, m.ExtLocATo, m.ExtLocBTo, af.ExtLocID, 
		bf.ExtLocID, at.ExtLocID, bt.ExtLocID, m.Qty, m.Qty, m.UOM, m.UOM, m.EntryDate, m.TransDate, m.[UID], m.HostID, m.CF
	FROM #TransList t INNER JOIN dbo.tblWmMoveQuantity m ON t.TransId = m.Id
		LEFT JOIN dbo.tblWmExtLoc af ON m.[ExtLocAFrom] = af.[Id]
		LEFT JOIN dbo.tblWmExtLoc bf ON m.[ExtLocBFrom] = bf.[Id]
		LEFT JOIN dbo.tblWmExtLoc at ON m.[ExtLocATo] = at.[Id]
		LEFT JOIN dbo.tblWmExtLoc bt ON m.[ExtLocBTo] = bt.[Id]
	WHERE m.MoveBy = 1 --By Container

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_MoveHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityPost_MoveHistory_proc';

