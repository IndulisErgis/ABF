
CREATE PROCEDURE dbo.trav_InTransactionHistoryReport_proc
@FiscalYearFrom smallint,
@FiscalPeriodFrom smallint,
@FiscalYearThru smallint,
@FiscalPeriodThru smallint,
@PrecCurr tinyint = 2,
@PrecQty tinyint = 4
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT d.ItemId, d.LocId, CASE d.ItemType WHEN 2 THEN NULL ELSE d.LotNum END AS LotNum, 
		d.AppId, d.GLPeriod, d.SumYear, i.Descr AS ItemDescr, 
		i.UomDflt, l.Descr AS LocDescr, d.TransDate, d.Source, d.SrceID,d.RefId,
		d.Uom, d.UomBase, i.ProductLine, i.LottedYn,
		CASE d.ConvFactor WHEN 0 THEN 0 ELSE d.CostUnit/d.ConvFactor END AS UnitCostBase, 
		ROUND((CASE WHEN d.Source < 70 THEN 1 ELSE -1 END) * d.Qty * d.ConvFactor,@PrecQty) AS MQtyBase,
		(CASE WHEN d.Source < 70 THEN 1 ELSE -1 END) * d.Qty AS MQty,
		(CASE WHEN d.Source < 70 THEN 1 ELSE -1 END) * d.CostExt AS MCostExt, d.ItemType, d.TransId
	FROM #tmpHistoryList t INNER JOIN dbo.tblInHistDetail d ON t.HistSeqNum = d.HistSeqNum
		INNER JOIN dbo.tblInItem i  ON d.ItemId = i.ItemId  
		INNER JOIN dbo.tblInLoc l ON d.LocId = l.LocId
	WHERE  d.SumYear * 1000 + d.GLPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom AND @FiscalYearThru * 1000 + @FiscalPeriodThru AND 
		d.Source > 0 AND d. Source NOT IN (200,201) AND (d.Qty > 0 OR (d.AppId = 'PO' AND d.Qty = 0 AND d.CostExt <> 0 )) -- Po invoice coversion
	UNION ALL      
	SELECT d.ItemId, d.LocId, CASE d.ItemType WHEN 2 THEN NULL ELSE d.LotNum END AS LotNum, 
		d.AppId, d.GLPeriod, d.SumYear, i.Descr AS ItemDescr, 
		i.UomDflt, l.Descr AS LocDescr, d.TransDate, d.Source, d.SrceID,r.RefId, 
		d.Uom, d.UomBase, i.ProductLine, i.LottedYn,
		CASE r.ConvFactor WHEN 0 THEN 0 ELSE r.CostUnit/r.ConvFactor END AS UnitCostBase, 
		ROUND((CASE WHEN d.Source < 70 THEN -1 ELSE 1 END) * d.Qty * r.ConvFactor,@PrecQty) AS MQtyBase,
		(CASE WHEN d.Source < 70 THEN -1 ELSE 1 END) * d.Qty AS MQty,
		ROUND((CASE WHEN d.Source < 70 THEN -1 ELSE 1 END) * d.Qty * r.CostUnit,@PrecCurr) AS MCostExt, d.ItemType, d.TransId
	FROM #tmpHistoryList t INNER JOIN dbo.tblInHistDetail d ON t.HistSeqNum = d.HistSeqNum
		INNER JOIN dbo.tblInItem i  ON d.ItemId = i.ItemId   
		INNER JOIN dbo.tblInLoc l ON d.LocId = l.LocId 
		INNER JOIN dbo.tblInHistDetail r ON d.HistSeqNum_Rcpt = r.HistSeqNum
	WHERE  d.SumYear * 1000 + d.GLPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom AND @FiscalYearThru * 1000 + @FiscalPeriodThru AND  
		d.Qty > 0
	UNION ALL 
	SELECT d.ItemId, d.LocId, CASE d.ItemType WHEN 2 THEN NULL ELSE d.LotNum END AS LotNum, 
		d.AppId, d.GLPeriod, d.SumYear, i.Descr AS ItemDescr, 
		i.UomDflt, l.Descr AS LocDescr, d.TransDate, d.Source, d.SrceID,d.RefId, 
		d.Uom, d.UomBase, i.ProductLine, i.LottedYn,
		0 UnitCostBase, 0 AS MQtyBase,0 AS MQty, -d.CostExt AS MCostExt, d.ItemType, d.TransId
	FROM #tmpHistoryList t INNER JOIN dbo.tblInHistDetail d ON t.HistSeqNum = d.HistSeqNum
		INNER JOIN dbo.tblInItem i  ON d.ItemId = i.ItemId   
		INNER JOIN dbo.tblInLoc l ON d.LocId = l.LocId 
	WHERE  d.SumYear * 1000 + d.GLPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom AND @FiscalYearThru * 1000 + @FiscalPeriodThru AND  
		d.Source IN (200,201)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransactionHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransactionHistoryReport_proc';

