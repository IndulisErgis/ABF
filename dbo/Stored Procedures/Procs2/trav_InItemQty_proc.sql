
CREATE PROCEDURE dbo.trav_InItemQty_proc
@ItemId pItemId = NULL,
@Uom pUom = NULL
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT l.ItemId, l.LocId, ISNULL(v.QtyCmtd,0)/ISNULL(u.ConvFactor,1) AS QtyCmtd, ISNULL(v.QtyOnOrder,0)/ISNULL(u.ConvFactor,1) AS QtyOnOrder,
		ISNULL(o.QtyOnHand,0)/ISNULL(u.ConvFactor,1) AS QtyOnHand, (ISNULL(o.QtyOnHand,0) - ISNULL(v.QtyCmtd,0))/ISNULL(u.ConvFactor,1)  AS QtyAvail
		, l.ItemLocStatus
	FROM dbo.tblInItem i (NOLOCK) INNER JOIN dbo.tblInItemLoc l (NOLOCK) ON i.ItemId = l.ItemId
		INNER JOIN dbo.tblInItemUom u (NOLOCK) ON l.ItemId = u.ItemId
		LEFT JOIN dbo.trav_InItemOnHand_view o (NOLOCK) ON l.ItemId = o.ItemId AND l.LocId = o.LocId
		LEFT JOIN dbo.trav_InItemQtys_view v (NOLOCK) ON l.ItemId = v.ItemId AND l.LocId = v.LocId
	WHERE i.ItemId = @ItemId AND i.ItemType = 1 AND u.Uom = @Uom
	UNION ALL
	SELECT l.ItemId, l.LocId, ISNULL(v.QtyCmtd,0) AS QtyCmtd, ISNULL(v.QtyOnOrder,0) AS QtyOnOrder,
		ISNULL(o.QtyOnHand,0) AS QtyOnHand, (ISNULL(o.QtyOnHand,0) - ISNULL(v.QtyCmtd,0)) AS QtyAvail
		, l.ItemLocStatus
	FROM dbo.tblInItem i (NOLOCK) INNER JOIN dbo.tblInItemLoc l (NOLOCK) ON i.ItemId = l.ItemId
		LEFT JOIN dbo.trav_InItemOnHandSer_view o (NOLOCK) ON l.ItemId = o.ItemId AND l.LocId = o.LocId
		LEFT JOIN dbo.trav_InItemQtys_view v (NOLOCK) ON l.ItemId = v.ItemId AND l.LocId = v.LocId
	WHERE i.ItemId = @ItemId AND i.ItemType = 2

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemQty_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemQty_proc';

