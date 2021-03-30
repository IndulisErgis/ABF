
CREATE PROCEDURE dbo.trav_InSafetyStockAlertReport_proc
@PrintZeroSafety  bit = 0,
@CalculateQuantityOption tinyint = 0, -- 0, On Hand;1, Available;
@ReportUom tinyint = 0 -- 0, Reporting;1, Base;
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

	IF @PrintZeroSafety = 1
	BEGIN
		SELECT i.ItemId,i.Descr,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,
			ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,a.AddlDescr,
			CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END AS UomBase,
			ISNULL(l.QtyOrderMin,0) * p.ConvFactor / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOrderMin,
			ISNULL(l.QtyOrderPoint,0) * p.ConvFactor / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOrderPoint,
			l.ItemLocStatus,
			ISNULL(l.QtySafetyStock,0) * p.ConvFactor / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtySafetyStock,
			ISNULL(o.QtyOnHand,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOnHand,
			ISNULL(q.QtyCmtd,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyCmtd,
			ISNULL(q.QtyOnOrder,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOnOrder, 
			(ISNULL(o.QtyOnHand,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END - 
			ISNULL(q.QtyCmtd,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyAvail 
		FROM #tmpItemLocationList t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId
			INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId
			LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
			INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
			INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
			INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom          
			LEFT JOIN #tmpInGetOnHandForAllItems o ON l.ItemId = o.ItemId AND l.LocId = o.LocId
			LEFT JOIN #tmpInGetQtyTotals q ON l.ItemId = q.ItemId AND l.LocId = q.LocId
			LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
	  			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
		WHERE (l.QtySafetyStock * p.ConvFactor  > (CASE WHEN @CalculateQuantityOption = 0 THEN ISNULL(o.QtyOnHand,0) ELSE (ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0)) END) OR l.QtySafetyStock = 0) 
			AND i.KittedYN = 0
	END
	ELSE
	BEGIN
		SELECT i.ItemId,i.Descr,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,
            ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,a.AddlDescr,
			CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.Uom,i.UomDflt) ELSE Base.Uom END AS UomBase,
            ISNULL(l.QtyOrderMin,0) * p.ConvFactor / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOrderMin,
			ISNULL(l.QtyOrderPoint,0) * p.ConvFactor / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOrderPoint,
			l.ItemLocStatus,
			ISNULL(l.QtySafetyStock,0) * p.ConvFactor / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtySafetyStock,
			ISNULL(o.QtyOnHand,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOnHand,
            ISNULL(q.QtyCmtd,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyCmtd,
			ISNULL(q.QtyOnOrder,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END AS QtyOnOrder, 
            (ISNULL(o.QtyOnHand,0) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END 
			- CAST(ISNULL(q.QtyCmtd,0) AS Float) / CASE WHEN @ReportUom = 0 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS QtyAvail 
		FROM #tmpItemLocationList t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId
			INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId
			LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
			INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt
			INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase          
			INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom          
			LEFT JOIN #tmpInGetOnHandForAllItems o ON l.ItemId = o.ItemId AND l.LocId = o.LocId
			LEFT JOIN #tmpInGetQtyTotals q ON l.ItemId = q.ItemId AND l.LocId = q.LocId
			LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
	  			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId
		WHERE (l.QtySafetyStock * p.ConvFactor > (CASE WHEN @CalculateQuantityOption = 0 THEN ISNULL(o.QtyOnHand,0) ELSE (ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0)) END) AND l.QtySafetyStock > 0) 
			AND i.KittedYN = 0
			
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSafetyStockAlertReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSafetyStockAlertReport_proc';

