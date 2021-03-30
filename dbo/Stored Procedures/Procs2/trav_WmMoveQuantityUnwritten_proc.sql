
CREATE PROCEDURE [dbo].[trav_WmMoveQuantityUnwritten_proc]
@UID pUserID,
@HostId pWrkStnID
AS
BEGIN TRY
	SELECT m.Id AS TransKey, m.MoveBy, m.MoveById, m.LocId, m.LotNum, m.Qty, m.UOM
		, af.ExtLocId AS ExtLocAIdFrom, at.ExtLocId AS ExtLocAIdTo
		, bf.ExtLocId AS ExtLocBIdFrom, bt.ExtLocId AS ExtLocBIdTo
		, s.SerNum, i.ItemType, i.LottedYn
	FROM dbo.tblWmMoveQuantity m
		LEFT JOIN dbo.tblWmMoveQuantity s ON m.Id = s.ParentId
		LEFT JOIN dbo.tblInItem i ON m.MoveById = i.ItemId AND m.MoveBy = 0
		LEFT JOIN dbo.tblWmExtLoc af ON m.ExtLocAFrom = af.Id
		LEFT JOIN dbo.tblWmExtLoc at ON m.ExtLocATo = at.Id
		LEFT JOIN dbo.tblWmExtLoc bf ON m.ExtLocBFrom = bf.Id
		LEFT JOIN dbo.tblWmExtLoc bt ON m.ExtLocBTo = bt.Id
	WHERE m.ParentId IS NULL AND m.[UID] = @UID AND m.HostId = @HostId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityUnwritten_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMoveQuantityUnwritten_proc';

