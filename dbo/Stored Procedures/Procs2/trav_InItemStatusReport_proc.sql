
CREATE PROCEDURE dbo.trav_InItemStatusReport_proc
@ReportUom tinyint = 0 -- 0;Reporting;1;Base
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
	INSERT INTO #tmpInGetOnHandForAllItems(ItemId,LocId,QtyOnHand)
	SELECT q.ItemId, q.LocId, q.QtyOnHand
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSer_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId

	-- Regular OnHand
	INSERT INTO #tmpInGetOnHandForAllItems(ItemId,LocId,QtyOnHand)
	SELECT q.ItemId, q.LocId, q.QtyOnHand
	FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHand_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId

	-- Cmtd, OnOrder
	INSERT INTO #tmpInGetQtyTotals(ItemId,LocId,QtyCmtd,QtyOnOrder)
	SELECT q.ItemId, q.LocId, Sum(CASE WHEN q.TransType = 0 THEN q.Qty ELSE 0 END ), Sum(CASE WHEN q.TransType = 2 THEN q.Qty ELSE 0 END )
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInQty q ON t.ItemId = q.ItemId AND t.LocId = q.LocId
	GROUP BY q.ItemId, q.LocId

	SELECT i.ItemId,l.LocId,d.AddlDescr,i.ProductLine,i.UsrFld1,i.UsrFld2,i.Descr,l.ItemLocStatus,
		   CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END AS UomDflt,
	       l.QtyOrderMin*p.ConvFactor/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS UomQtyOrderMin,
		   l.QtyOrderPoint*p.ConvFactor/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS UomQtyOrderPoint,
	       ISNULL(t2.QtyOnOrder,0)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOnOrder1,
		   ISNULL(t2.QtyCmtd,0)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyCmtd1,
	       ISNULL(t1.QtyOnHand,0)/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOnHand1,
	       (ISNULL(t1.QtyOnHand,0) - ISNULL(t2.QtyCmtd,0))/CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS Available,
	       i.KittedYN
	FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
		INNER JOIN dbo.tblInItem i ON i.ItemId = l.ItemId 
		INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND i.UomDflt = u.Uom
	    LEFT JOIN dbo.tblInItemAddlDescr d ON i.ItemId = d.ItemId
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
		LEFT JOIN #tmpInGetOnHandForAllItems t1 ON i.ItemId = t1.ItemId AND l.LocId = t1.LocId
		LEFT JOIN #tmpInGetQtyTotals t2 ON i.ItemId = t2.ItemId AND l.LocId = t2.LocId
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemStatusReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InItemStatusReport_proc';

