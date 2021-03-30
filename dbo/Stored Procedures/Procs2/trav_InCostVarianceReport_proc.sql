
CREATE PROCEDURE dbo.trav_InCostVarianceReport_proc
@PrintLotDetail bit = 1,
@ReportUom tinyint = 1 -- 1;Reporting;2;Base
--todo, user defined fields
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpQtyCost
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		LotNum pLotNum NULL,
		QtyOnHand pDecimal NOT NULL,
		Cost pDecimal NOT NULL
	)

	IF @PrintLotDetail = 0 
	BEGIN
		INSERT #tmpQtyCost(ItemId,LocId,QtyOnHand,Cost) 
		SELECT q.ItemId,q.LocId,q.QtyOnHand,q.Cost
		FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHand_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

		INSERT #tmpQtyCost(ItemId,LocId,QtyOnHand,Cost) 
		SELECT q.ItemId,q.LocId,q.QtyOnHand,q.Cost
		FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSer_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 
	END
	ELSE
	BEGIN
		INSERT #tmpQtyCost(ItemId,LocId,LotNum,QtyOnHand,Cost) 
		SELECT q.ItemId,q.LocId,q.LotNum,q.QtyOnHand,q.Cost
		FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandLot_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 
		
		INSERT #tmpQtyCost(ItemId,LocId,LotNum,QtyOnHand,Cost) 
		SELECT q.ItemId,q.LocId,q.LotNum,q.QtyOnHand,q.Cost
		FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSerLot_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId 

	END

	SELECT  i.ItemId,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls, 
        ISNULL(UsrFld2,'') AS UsrFld2Zls,i.Descr,a.AddlDescr,t.LotNum AS LotNumber, 
        t.QtyOnHand/CASE WHEN @ReportUom = 1 THEN Base.ConvFactor ELSE ISNULL(ud2.ConvFactor,u.ConvFactor) END AS Qty,
        t.Cost AS Actual, 
        l.CostStd*(t.QtyOnHand/CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END)-
        l.CostAvg*(t.QtyOnHand/CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS StdAvg, 
        t.Cost - l.CostStd*(t.QtyOnHand/CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS ActualStd, 
        t.Cost - l.CostAvg*(t.QtyOnHand/CASE WHEN @ReportUom = 1 THEN ISNULL(ud2.ConvFactor,u.ConvFactor) ELSE Base.ConvFactor END) AS ActualAvg,i.KittedYN   
	FROM #tmpQtyCost t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId
		INNER JOIN tblInItemUom u ON i.ItemId = u.ItemId AND u.Uom = i.UomDflt 
		INNER JOIN dbo.tblInItemUom base ON i.ItemId = base.ItemId AND base.Uom = i.UomBase
		LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
		LEFT JOIN (SELECT ud.ItemId, v.ConvFactor, ud.Uom, ud.DfltType FROM dbo.tblInItemUomDflt ud 
			INNER JOIN dbo.tblInItemUom v ON ud.ItemId = v.ItemId AND ud.Uom = v.Uom WHERE ud.DfltType = 1) AS ud2 ON i.itemId = ud2.ItemId	
	WHERE i.KittedYN =0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InCostVarianceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InCostVarianceReport_proc';

