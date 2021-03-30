  
CREATE PROCEDURE dbo.ALP_InItemLocationList_proc  
@SortBy tinyint = 0 -- 0, Item ID; 1, Product Line;  
AS  
SET NOCOUNT ON  
BEGIN TRY  
  
CREATE TABLE #tmpInGetOnHandForAllItems  
(  
 ItemId pItemID,   
 LocId pLocID,   
 QtyOnHand pDec  
)  
  
CREATE TABLE #tmpInGetQtyTotals  
(  
 ItemId pItemID,   
 LocId pLocID,   
 QtyCmtd pDec,   
 QtyOnOrder pDec,  
 QtyInUse pDec
)  
-- OnHand  
INSERT INTO #tmpInGetOnHandForAllItems(ItemId, LocId, QtyOnHand)  
SELECT q.ItemId, q.LocId, q.QtyOnHand  
FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHandSer_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId   
UNION ALL  
SELECT q.ItemId, q.LocId, q.QtyOnHand  
FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemOnHand_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId   
  
-- Cmtd, OnOrder  
INSERT INTO #tmpInGetQtyTotals(ItemId, LocId, QtyCmtd, QtyOnOrder,QtyInUse)  
SELECT q.ItemId, q.LocId, q.QtyCmtd, q.QtyOnOrder  ,ALP_QtyInUse
FROM #tmpItemLocationList t INNER JOIN dbo.ALP_InItemQtys_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId   
  
SELECT CASE @SortBy WHEN 0 THEN i.ItemId WHEN 1 THEN ProductLine END SortOrder, i.ItemId, i.ItemId + l.LocId AS ItemLoc, i.ItemType, l.ForecastId, i.Descr, l.LocId, l.ItemLocStatus, l.DfltVendId,   
 l.DfltBinNum, l.DfltPriceId, l.DfltLeadTime, l.OrderQtyUom, i.ProductLine, g.GLAcctCode, g.Descr AS GLAcctCodeDescr,   
 l.QtyOnHandMax / u.ConvFactor AS QtyOnHandMaxDflt, l.QtyOrderPoint / u.ConvFactor AS QtyOrderPointDflt,   
 l.QtySafetyStock / u.ConvFactor AS QtySafetyStockDflt, l.Eoq / u.ConvFactor AS EoqDflt, l.OrderPointType, l.SafetyStockType, l.EoqType,   
 l.CostStd, l.CostAvg, l.CostLast, l.CostBase, l.CarrCostPct, l.OrderCostAmt, ISNULL(q.QtyCmtd, 0) / u.ConvFactor AS QtyCmtd,   
 ISNULL(q.QtyOnOrder, 0) / u.ConvFactor AS QtyOnOrder, ISNULL(o.QtyOnHand, 0) / u.ConvFactor AS QtyOnHand,   
 (ISNULL(o.QtyOnHand, 0) - ISNULL(q.QtyCmtd, 0)) / u.ConvFactor AS QtyAvail, QtyOrderMin / u.ConvFactor AS QtyOrderMin, l.ABCClass,  
 CASE WHEN c.ItemId IS NULL THEN 0 ELSE 1 END AS CostYn, CASE WHEN p.ItemId IS NULL THEN 0 ELSE 1 END AS PriceYn,  
 CASE WHEN v.ItemId IS NULL THEN 0 ELSE 1 END AS VendorYn, CASE WHEN b.ItemId IS NULL THEN 0 ELSE 1 END AS BinYn,  
 CASE WHEN lt.ItemId IS NULL THEN 0 ELSE 1 END AS LotYn, CASE WHEN s.ItemId IS NULL THEN 0 ELSE 1 END AS SerYn  ,
 ISNULL(q.QtyInUse,0)QtyInUse
FROM #tmpItemLocationList t INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId   
 INNER JOIN dbo.tblInItemUom u ON i.ItemId = u.ItemId AND i.UomDflt = u.Uom   
 INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
 INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode   
 LEFT JOIN #tmpInGetOnHandForAllItems o ON t.ItemId = o.ItemId AND t.LocId = o.LocId   
 LEFT JOIN #tmpInGetQtyTotals q ON t.ItemId = q.ItemId AND t.LocId = q.LocId   
 LEFT JOIN dbo.trav_InItemLocCostBracket_view c ON t.ItemId = c.ItemId AND t.LocId = c.LocId  
 LEFT JOIN dbo.tblInItemLocUomPrice p ON t.ItemId = p.ItemId AND t.LocId = p.LocId  
 LEFT JOIN dbo.tblInItemLocVend v ON t.ItemId = v.ItemId AND t.LocId = v.LocId  
 LEFT JOIN dbo.tblInItemLocBin b ON t.ItemId = b.ItemId AND t.LocId = b.LocId  
 LEFT JOIN dbo.tblInItemLocLot lt ON t.ItemId = lt.ItemId AND t.LocId = lt.LocId  
 LEFT JOIN dbo.tblInItemSer s ON t.ItemId = s.ItemId AND t.LocId = s.LocId  
   
SELECT t.ItemId,t.LocId,q.LotNum,q.InitialDate,q.Cost,q.Qty,q.CostExt  
FROM #tmpItemLocationList t INNER JOIN dbo.trav_InItemLocCostBracket_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId   
ORDER BY q.InitialDate  
   
SELECT u.LocId, u.ItemId, u.Uom, u.PriceAvg, u.PriceMin, u.PriceList, u.PriceBase, p.BrkQty, p.BrkAdj, p.BrkAdjType   
FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLocUomPrice u ON t.ItemId = u.ItemId AND t.LocId = u.LocId  
 LEFT JOIN dbo.tblInPriceBreaks p ON u.BrkId = p.BrkId   
ORDER BY p.BrkQty  
  
SELECT v.LocId, v.ItemId, v.VendId, v.LastPOUnitCost, v.LastPODate, v.LastPOQty, v.LastPOOrderNum, v.LeadTime, v.CurrencyID, v.ExchRate, v.LandedCostId   
FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLocVend v ON t.ItemId = v.ItemId AND t.LocId = v.LocId  
ORDER BY v.VendName  
  
SELECT b.LocId, b.ItemId, b.BinNum, b.LastCountBatchId, b.LastCountQty, b.LastCountUom, b.LastCountDate, b.LastCountTagNum   
FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLocBin b ON t.ItemId = b.ItemId AND t.LocId = b.LocId  
ORDER BY b.BinNum  
   
SELECT l.LocId, l.ItemId, l.LotNum, l.ExpDate, l.LotStatus, l.Cmnt, l.VendID   
FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemLocLot l ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
ORDER BY l.LotNum  
   
SELECT s.LocId, s.ItemId, SerNum, SerNumStatus, CostUnit, PriceUnit, InitialDate, Cmnt   
FROM #tmpItemLocationList t INNER JOIN dbo.tblInItemSer s ON t.ItemId = s.ItemId AND t.LocId = s.LocId  
ORDER BY s.SerNum  
   
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH