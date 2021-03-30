
CREATE PROCEDURE dbo.trav_InOverStockReport_proc
@PrintZeroMaxOnHand bit = 0
--todo, user defined fields
AS
SET NOCOUNT ON
BEGIN TRY
	
	CREATE TABLE #tmpInGetOnHandForAllItems
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyOnHand pDecimal NOT NULL
	)

	CREATE TABLE #tmpInGetQtyTotals
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyCmtd pDecimal NOT NULL,
		QtyOnOrder pDecimal NOT NULL
	)
	
	--Serial OnHand
	INSERT INTO #tmpInGetOnHandForAllItems(ItemId, LocId, QtyOnHand)
	SELECT q.ItemId, q.LocId, q.QtyOnHand
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSer_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 


	-- Regular OnHand
	INSERT INTO #tmpInGetOnHandForAllItems(ItemId, LocId, QtyOnHand)
	SELECT q.ItemId, q.LocId, q.QtyOnHand
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHand_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

	-- Cmtd, OnOrder
	INSERT INTO #tmpInGetQtyTotals(ItemId, LocId, QtyCmtd, QtyOnOrder)
	SELECT q.ItemId, q.LocId, q.QtyCmtd, q.QtyOnOrder
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemQtys_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

	IF @PrintZeroMaxOnHand = 0
	BEGIN
		SELECT i.ItemId,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
			i.Descr,a.AddlDescr,i.UomBase,
			l.QtyOrderMin*p.ConvFactor QtyOrderMin,
			l.QtyOrderPoint*p.ConvFactor QtyOrderPoint,
			l.ItemLocStatus,ISNULL(o.QtyOnHand,0) QtyOnHand,
			ISNULL(q.QtyCmtd,0) QtyCmtd,ISNULL(q.QtyOnOrder,0) QtyOnOrder, 
			(ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0)) QtyAvail, l.QtyOnHandMax*p.ConvFactor AS  QtyOnHandMax 
		FROM #tmpItemLocationList t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId
			INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId
			LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
			INNER JOIN tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
			LEFT JOIN #tmpInGetOnHandForAllItems o ON l.ItemId = o.ItemId AND l.LocId = o.LocId
			LEFT JOIN #tmpInGetQtyTotals q ON l.ItemId = q.ItemId AND l.LocId = q.LocId
		WHERE (l.QtyOnHandMax*p.ConvFactor) < ISNULL(o.QtyOnHand,0) AND l.QtyOnHandMax > 0 AND i.KittedYN = 0 AND i.ItemType <> 3 
	END
	ELSE
	BEGIN
		SELECT i.ItemId,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,
			i.Descr,a.AddlDescr,i.UomBase,
			l.QtyOrderMin*p.ConvFactor QtyOrderMin,
			l.QtyOrderPoint*p.ConvFactor QtyOrderPoint,
			l.ItemLocStatus,ISNULL(o.QtyOnHand,0) QtyOnHand,
			ISNULL(q.QtyCmtd,0) QtyCmtd, ISNULL(q.QtyOnOrder,0) QtyOnOrder, 
			(ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0)) QtyAvail, l.QtyOnHandMax*p.ConvFactor AS QtyOnHandMax
		FROM #tmpItemLocationList t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId
			INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId
			LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
			INNER JOIN tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
			LEFT JOIN #tmpInGetOnHandForAllItems o ON l.ItemId = o.ItemId AND l.LocId = o.LocId
			LEFT JOIN #tmpInGetQtyTotals q ON l.ItemId = q.ItemId AND l.LocId = q.LocId
		WHERE ((l.QtyOnHandMax*p.ConvFactor) < ISNULL(o.QtyOnHand,0) OR l.QtyOnHandMax = 0) AND i.KittedYN = 0 AND i.ItemType <> 3
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InOverStockReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InOverStockReport_proc';

