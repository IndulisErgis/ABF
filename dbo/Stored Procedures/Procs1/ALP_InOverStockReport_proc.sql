  
CREATE PROCEDURE dbo.ALP_InOverStockReport_proc  
@PrintZeroMaxOnHand bit = 0  
--todo, user defined fields  
AS  
SET NOCOUNT ON  
BEGIN TRY  
   
 CREATE TABLE #tmpInGetOnHandForAllItems  
 (  
  ItemId pItemId NOT NULL,  
  LocId pLocId NOT NULL,  
  QtyOnHand pDec NOT NULL  
 )  
  
 CREATE TABLE #tmpInGetQtyTotals  
 (  
  ItemId pItemId NOT NULL,  
  LocId pLocId NOT NULL,  
  QtyCmtd pDec NOT NULL,  
  QtyOnOrder pDec NOT NULL ,
  QtyInUse  pDec NOT NULL
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
 INSERT INTO #tmpInGetQtyTotals(ItemId, LocId, QtyCmtd, QtyOnOrder,QtyInUse )  
 SELECT q.ItemId, q.LocId, q.QtyCmtd, q.QtyOnOrder  ,q.ALP_QtyInUse
 FROM #tmpItemLocationList t INNER JOIN dbo.ALP_InItemQtys_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId   
  
 IF @PrintZeroMaxOnHand = 0  
 BEGIN  
  SELECT i.ItemId,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,  
   i.Descr,a.AddlDescr,i.UomBase,  
   l.QtyOrderMin*p.ConvFactor QtyOrderMin,  
   l.QtyOrderPoint*p.ConvFactor QtyOrderPoint,  
   l.ItemLocStatus,ISNULL(o.QtyOnHand,0) QtyOnHand,  
   ISNULL(q.QtyCmtd,0) QtyCmtd,ISNULL(q.QtyOnOrder,0) QtyOnOrder,   
   (ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0)) QtyAvail, l.QtyOnHandMax  ,
   ISNULL(q.QtyInUse,0)QtyInUse  
  FROM #tmpItemLocationList t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
   INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId  
   LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId  
   INNER JOIN tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom  
   LEFT JOIN #tmpInGetOnHandForAllItems o ON l.ItemId = o.ItemId AND l.LocId = o.LocId  
   LEFT JOIN #tmpInGetQtyTotals q ON l.ItemId = q.ItemId AND l.LocId = q.LocId  
  WHERE l.QtyOnHandMax < ISNULL(o.QtyOnHand,0) AND l.QtyOnHandMax > 0 AND i.KittedYN = 0  
 END  
 ELSE  
 BEGIN  
  SELECT i.ItemId,l.LocId,ISNULL(i.ProductLine,'') AS ProductLineZls,ISNULL(i.UsrFld1,'') AS UsrFld1Zls,ISNULL(i.UsrFld2,'') AS UsrFld2Zls,  
   i.Descr,a.AddlDescr,i.UomBase,  
   l.QtyOrderMin*p.ConvFactor QtyOrderMin,  
   l.QtyOrderPoint*p.ConvFactor QtyOrderPoint,  
   l.ItemLocStatus,ISNULL(o.QtyOnHand,0) QtyOnHand,  
   ISNULL(q.QtyCmtd,0) QtyCmtd, ISNULL(q.QtyOnOrder,0) QtyOnOrder,   
   (ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0)) QtyAvail, l.QtyOnHandMax,
   ISNULL(q.QtyInUse,0)QtyInUse   
  FROM #tmpItemLocationList t INNER JOIN tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId  
   INNER JOIN tblInItem i (NOLOCK) ON l.ItemId = i.ItemId  
   LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId  
   INNER JOIN tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom  
   LEFT JOIN #tmpInGetOnHandForAllItems o ON l.ItemId = o.ItemId AND l.LocId = o.LocId  
   LEFT JOIN #tmpInGetQtyTotals q ON l.ItemId = q.ItemId AND l.LocId = q.LocId  
  WHERE (l.QtyOnHandMax < ISNULL(o.QtyOnHand,0) OR l.QtyOnHandMax = 0) AND i.KittedYN = 0  
 END  
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH