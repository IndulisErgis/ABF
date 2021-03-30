
CREATE PROCEDURE dbo.trav_InPriceReport_proc
@ExchRate pDecimal = 1,
@CostingMethod tinyint = 0,
@SortBy tinyint = 0 -- 0, Item ID; 1, Location ID;
--todo, user defined fields
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpQtyCost
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyOnHand pDecimal NOT NULL,
		Cost pDecimal NOT NULL
	)

	INSERT #tmpQtyCost(ItemId,LocId,QtyOnHand,Cost) 
	SELECT q.ItemId,q.LocId,q.QtyOnHand,q.Cost
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHand_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

	INSERT #tmpQtyCost(ItemId,LocId,QtyOnHand,Cost) 
	SELECT q.ItemId,q.LocId,q.QtyOnHand,q.Cost
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSer_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

	SELECT CASE @SortBy 
			WHEN 0 THEN i.ItemId 
			WHEN 1 THEN l.LocId END AS SortOrder,
		i.ItemId, l.LocId, p.Uom, p.BrkId, i.Descr, i.PriceId, 1 AS QtyBase, 
		((p.PriceBase + (CASE WHEN b.BrkAdjType = 0 THEN b.BrkAdj ELSE b.BrkAdj/100* p.PriceBase END)) - 
		(CASE WHEN ISNULL(q.QtyOnHand,0) >0 THEN (CASE @CostingMethod WHEN 0 THEN q.Cost/q.QtyOnHand WHEN 1 THEN q.Cost/q.QtyOnHand
		WHEN 2 THEN l.CostAvg WHEN 3 THEN l.CostStd END) ELSE (l.CostLandedLast + l.CostLast) END)*u.ConvFactor)* @ExchRate AS BrkProfitMargin, 
		(p.PriceBase -(CASE WHEN ISNULL(q.QtyOnHand,0) >0 THEN (CASE @CostingMethod WHEN 0 THEN q.Cost/q.QtyOnHand WHEN 1 THEN q.Cost/q.QtyOnHand
		WHEN 2 THEN l.CostAvg WHEN 3 THEN l.CostStd END) ELSE (l.CostLandedLast + l.CostLast) END) * u.ConvFactor) * @ExchRate AS BaseProfitMargin,
		p.PriceBase * @ExchRate AS ERPriceBase,b.BrkQty, 
		p.PriceBase * @ExchRate + (CASE WHEN b.BrkAdjType = 0 THEN b.BrkAdj ELSE b.BrkAdj/100* p.PriceBase END)* @ExchRate AS AdjPrice,
		b.BrkAdj, b.BrkAdjType, u.ConvFactor, i.ProductLine, i.UsrFld1, i.UsrFld2
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.LocId = l.LocId AND t.ItemId = l.ItemId
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId 
		INNER JOIN (dbo.tblInItemUom u INNER JOIN (dbo.tblInItemLocUomPrice p LEFT JOIN dbo.tblInPriceBreaks b ON p.BrkId = b.BrkId) 
			ON u.ItemId = p.ItemId AND u.Uom = p.Uom) ON l.LocId = p.LocId AND l.ItemId = p.ItemId
		LEFT JOIN #tmpQtyCost q ON l.LocId = q.LocId AND l.ItemId = q.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPriceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPriceReport_proc';

