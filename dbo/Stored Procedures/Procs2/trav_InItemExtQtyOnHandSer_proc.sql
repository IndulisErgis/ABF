
CREATE PROCEDURE [dbo].[trav_InItemExtQtyOnHandSer_proc] 
@ItemId [pItemId],
@LocId [pLocId],
@LotNum [pLotNum] = null --optional lot number for prefiltering results
AS
BEGIN TRY

	SET NOCOUNT ON

	SELECT s.ItemId, s.LocId, s.LotNum, s.ExtLocA, a.ExtLocId AS ExtLocAId, s.ExtLocB, b.ExtLocId AS ExtLocBId
		, COUNT(1) AS QtyOnHand
	FROM dbo.tblInItemSer s 
	LEFT JOIN dbo.tblWmExtLoc  a
		ON s.ExtLocA = a.Id
	LEFT JOIN dbo.tblWmExtLoc  b
		ON s.ExtLocB = b.Id
	WHERE s.[ItemId] = @ItemId AND s.[LocId] = @LocId
		AND (s.LotNum = @LotNum OR @LotNum Is Null)
		AND (s.SerNumStatus = 1)
	GROUP BY s.ItemId, s.LocId, s.LotNum, s.ExtLocA, a.ExtLocID, s.ExtLocB, b.ExtLocID

	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemExtQtyOnHandSer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemExtQtyOnHandSer_proc';

