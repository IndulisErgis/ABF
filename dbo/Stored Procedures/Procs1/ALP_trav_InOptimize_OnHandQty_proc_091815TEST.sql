
  
CREATE PROCEDURE dbo.ALP_trav_InOptimize_OnHandQty_proc_091815TEST  
AS  
BEGIN TRY  
 --TODO, add warning to UI  
 --TODO, zero qty lot number (inactive)  
 --TODO, transaction to inventory check  
  
 DECLARE @PostRun pPostRun  
  
 CREATE TABLE #SeqNumNotInTrans (OnHandSeqNum int NOT NULL, Source varchar(100) NULL  Primary Key (OnHandSeqNum))  
  
 CREATE TABLE #OnHandLinkInTrans (OnHandLink int NOT NULL, Source varchar(100) NULL Primary Key (OnHandLink))  
  
 CREATE TABLE #ItemLocationBefore (ItemId pItemId NOT NULL, LocId pLocId NOT NULL, QtyOnHand pdecimal, Cost pdecimal Primary Key (ItemId, LocId))  
  
 CREATE TABLE #ItemLocationAfter (ItemId pItemId NOT NULL, LocId pLocId NOT NULL, QtyOnHand pdecimal, Cost pdecimal Primary Key (ItemId, LocId))  
  --mah added:
  CREATE TABLE #ItemLocationList (ItemId pItemId NOT NULL, LocId pLocId NOT NULL)
  INSERT INTO #ItemLocationList (ItemId, LocId )
  SELECT ItemId, 'ABF' FROM tblInItem WHERE ItemId like 'DTMOTION'
  SELECT '#ItemLocationList',* FROM #ItemLocationList
  --
  
 --SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'  
 SET @PostRun = 'MAH-TEST-091815' 
 
 IF @PostRun IS NULL  
 BEGIN  
  RAISERROR(90025,16,1)  
 END  
  
 /*Capture a snapshot of qty onhand and cost for all regular item/location before process*/  
 BEGIN  
  INSERT INTO #ItemLocationBefore(ItemId, LocId, QtyOnHand, Cost)  
  SELECT l.ItemId, l.LocId, ISNULL(o.QtyOnHand,0), ISNULL(o.Cost,0)  
  FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId   
   LEFT JOIN dbo.trav_InItemOnHand_view o (TABLOCKX) ON l.ItemId = o.ItemId AND l.LocId = o.LocId  
  WHERE i.ItemType = 1  
 END  
 
  --mah added:
 -- select '#ItemLocationBefore', * from #ItemLocationBefore
  
  
 /*Populate a list OnHandLink from Qty offset records that are still in live transactions*/  
 BEGIN  
  INSERT INTO #OnHandLinkInTrans (OnHandLink, Source)  
  --DebitAP  
  SELECT f.OnHandLink  , 'DebitAP' 
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 70 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblApTransDetail d INNER JOIN dbo.tblApTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblApTransLot d INNER JOIN dbo.tblApTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0)  
  UNION  
  --Return  
  SELECT f.OnHandLink , 'Return'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 71 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblPoTransLotRcpt d INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0)  
  UNION  
  --DebitIN  
  SELECT f.OnHandLink , 'DebitIN'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 72 AND f.SeqNum IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 15 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 15 AND d.QtySeqNum > 0)   
  UNION  
  --Decrease  
  --Note it was 73 in WM transaction  
  SELECT f.OnHandLink , 'Decrease-73'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 73 AND f.SeqNum IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 32 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 32 AND d.QtySeqNum > 0  
   UNION ALL SELECT QtySeqNum FROM dbo.tblWmTrans WHERE TransType = 32 AND QtySeqNum > 0)   
  UNION  
  --TransferFrom  
  SELECT f.OnHandLink , 'TransferFrom'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 74 AND f.SeqNum IN   
   (SELECT QtySeqNumFrom FROM dbo.tblInXfers WHERE QtySeqNumFrom > 0  
   UNION ALL SELECT d.QtySeqNumFrom FROM dbo.tblInXferLot d INNER JOIN dbo.tblInXfers h ON d.TransId = h.TransId WHERE d.QtySeqNumFrom > 0)   
  UNION  
  --MaterialReq  
  SELECT f.OnHandLink , 'MaterialReq'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 75 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblInMatReqDetail d INNER JOIN dbo.tblInMatReqHeader h ON d.TransId = h.TransId WHERE h.ReqType > 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInMatReqLot d INNER JOIN dbo.tblInMatReqHeader h ON d.TransId = h.TransId WHERE h.ReqType > 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT QtySeqNum FROM dbo.tblPcTrans WHERE TransType = 0 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblPcTransExt d INNER JOIN dbo.tblPcTrans h ON d.TransId = h.Id WHERE h.TransType = 0 AND d.QtySeqNum > 0)   
  UNION  
  --BuildComponentMP  
  SELECT f.OnHandLink , 'BuildComponentMP'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 76 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblMpMatlDtl d INNER JOIN dbo.tblMpMatlSum h ON d.TransId = h.TransId   
    WHERE (h.ComponentType IN (3, 4) OR (h.ComponentType = 2 AND d.SubAssemblyTranType = 1)) AND d.QtySeqNum > 0   
   UNION ALL SELECT e.QtySeqNum FROM dbo.tblMpMatlDtlExt e INNER JOIN dbo.tblMpMatlDtl d ON e.TransId = d.TransId AND e.EntryNum = d.SeqNo   
    INNER JOIN dbo.tblMpMatlSum h ON d.TransId = h.TransId WHERE (h.ComponentType IN (3, 4) OR (h.ComponentType = 2 AND d.SubAssemblyTranType = 1)) AND e.QtySeqNum > 0) --Stocked Subassembly, Material, Non-Stock Subassembly that is Pulled From Stock  
  UNION  
  --DecreaseWM(78)  
  SELECT f.OnHandLink ,'DecreaseWM(78)'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 78 AND f.SeqNum IN   
   (SELECT QtySeqNum FROM dbo.tblWmTrans WHERE TransType = 32 AND QtySeqNum > 0)   
  UNION  
  --TransferFromWM  
  SELECT f.OnHandLink , 'TransferFromWM'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 79 AND f.SeqNum IN   
   (SELECT QOHSeqNum FROM dbo.tblWmTransferPick WHERE QOHSeqNum > 0)   
  UNION  
  --InvoiceAR  
  SELECT f.OnHandLink , 'InvoiceAR'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 80 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblArTransDetail d INNER JOIN dbo.tblArTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblArTransLot d INNER JOIN dbo.tblArTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT QtySeqNum FROM dbo.tblSvWorkOrderTrans WHERE TransType = 1 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblSvWorkOrderTransExt d INNER JOIN dbo.tblSvWorkOrderTrans h ON d.TransID = h.ID WHERE h.TransType = 1 AND d.QtySeqNum > 0)  
  UNION  
  --VerifySO, InvoiceSO  
  SELECT f.OnHandLink , 'VerifySO, InvoiceSO '  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] IN (81, 82) AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblSoTransDetail d INNER JOIN dbo.tblSoTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblSoTransDetailExt d INNER JOIN dbo.tblSoTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0   
   UNION ALL SELECT i.QtySeqNum FROM dbo.tblPsTransDetailIN i INNER JOIN dbo.tblPsTransDetail d ON i.DetailID = d.ID  
    INNER JOIN dbo.tblPsTransHeader h ON d.HeaderID = h.ID WHERE h.TransType > 0 AND i.QtySeqNum > 0)  
  UNION  
  --VerifyIN, InvoiceSaleIN  
  SELECT f.OnHandLink , 'VerifyIN, InvoiceSaleIN'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] IN (83, 84) AND f.SeqNum IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType IN (23,24) AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType IN (23,24) AND d.QtySeqNum > 0)   
  UNION  
  --BuildComponentBM  
  SELECT f.OnHandLink , 'BuildComponentBM'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 85 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblBmWorkOrderDetail d INNER JOIN dbo.tblBmWorkOrder h ON d.TransId = h.TransId WHERE h.WorkType = 1 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblBmWorkOrderLot d INNER JOIN dbo.tblBmWorkOrder h ON d.TransId = h.TransId WHERE h.WorkType = 1 AND d.QtySeqNum > 0)  
  UNION  
  --UnbuildAssemblyBM  
  SELECT f.OnHandLink , 'UnbuildAssemblyBM'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 86 AND f.SeqNum IN   
   (SELECT QtySeqNum FROM dbo.tblBmWorkOrder WHERE WorkType = 2 AND QtySeqNum > 0)  
  UNION  
  --MaterialReqWM  
  SELECT f.OnHandLink, 'MaterialReqWM'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 87 AND f.SeqNum IN   
   (SELECT d.QtySeqNum FROM dbo.tblWmMatReqFilled d INNER JOIN dbo.tblWmMatReq h ON d.TranKey = h.TranKey WHERE h.ReqType > 0 AND d.QtySeqNum > 0)   
  UNION  
  --DebitPO  
  SELECT f.OnHandLink , 'DebitPO'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.[Source] = 88 AND f.SeqNum IN   
   (SELECT i.QtySeqNum FROM dbo.tblPoTransInvc_Rcpt i INNER JOIN dbo.tblPoTransLotRcpt d ON i.ReceiptID = d.ReceiptID   
    INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND i.QtySeqNum > 0)   
  UNION  
  --Zero Qty offset record that has posted cogs adjustment  
  SELECT f.OnHandLink , 'Zero Qty offset record'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
   INNER JOIN dbo.tblInQtyOnHand_Offset f ON o.SeqNum = f.OnHandLink  
  WHERE f.CostAdjPosted <> 0 AND f.Qty = 0  
 END 
 
 --mah added:
 select '#ItemLocationList', * from #ItemLocationList
 select '#OnHandLinkInTrans',* from #OnHandLinkInTrans 
 --
  
 /*Populate a list SeqNum for zero Qty Onhand records that are not in live transactions*/  
 BEGIN  
  INSERT INTO #SeqNumNotInTrans (OnHandSeqNum, Source)  
  --ReceiptIN  
  SELECT o.SeqNum , 'ReceiptIN'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 11 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 12 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 12 AND d.QtySeqNum > 0)   
  UNION ALL  
  --InvoiceAP  
  SELECT o.SeqNum , 'InvoiceAP'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 12 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblApTransDetail d INNER JOIN dbo.tblApTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblApTransLot d INNER JOIN dbo.tblApTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0)  
  UNION ALL  
  --InvoicePO  
  SELECT o.SeqNum , 'InvoicePO'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 13 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT i.QtySeqNum FROM dbo.tblPoTransInvc_Rcpt i INNER JOIN dbo.tblPoTransLotRcpt d ON i.ReceiptID = d.ReceiptID   
    INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND i.QtySeqNum > 0)  
  UNION ALL  
  --InvoicePurchaseIN  
  SELECT o.SeqNum  , 'InvoicePurchaseIN' 
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 14 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 14 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 14 AND d.QtySeqNum > 0)   
  UNION ALL  
  --Increase  
  ----Note: it was 15 in WM transaction  
  --SELECT o.SeqNum  , 'Increase-15' 
  --FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  --WHERE  o.[Source] = 15 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
  -- (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 31 AND QtySeqNum > 0  
  -- UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 31 AND d.QtySeqNum > 0  
  -- UNION ALL SELECT QtySeqNum FROM dbo.tblWmTrans WHERE TransType = 31 AND QtySeqNum > 0)   
  --UNION ALL  
    --mah added: Note: find JM increases  
  SELECT o.SeqNum  , 'Increase-15-withJM' 
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 15 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 31 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 31 AND d.QtySeqNum > 0  
   UNION ALL SELECT QtySeqNum FROM dbo.tblWmTrans WHERE TransType = 31 AND QtySeqNum > 0
   UNION ALL SELECT QtySeqNum_Cmtd FROM ALP_tblJmSvcTktItem WHERE QtySeqNum_Cmtd > 0 )   
  UNION ALL  
  --TransferTo  
  SELECT o.SeqNum  , 'TransferTo' 
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 16 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNumTo FROM dbo.tblInXfers WHERE QtySeqNumTo > 0  
   UNION ALL SELECT d.QtySeqNumTo FROM dbo.tblInXferLot d INNER JOIN dbo.tblInXfers h ON d.TransId = h.TransId WHERE d.QtySeqNumTo > 0)   
  UNION ALL  
  --MaterialReqReturn  
  SELECT o.SeqNum, 'MaterialReqReturn'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 17 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblInMatReqDetail d INNER JOIN dbo.tblInMatReqHeader h ON d.TransId = h.TransId WHERE h.ReqType < 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInMatReqLot d INNER JOIN dbo.tblInMatReqHeader h ON d.TransId = h.TransId WHERE h.ReqType < 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT QtySeqNum FROM dbo.tblPcTrans WHERE TransType = 1 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblPcTransExt d INNER JOIN dbo.tblPcTrans h ON d.TransId = h.Id WHERE h.TransType = 1 AND d.QtySeqNum > 0)   
  UNION ALL  
  --BuildAssemblyMP  
  SELECT o.SeqNum, 'BuildAssemblyMP'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId   
  WHERE  o.[Source] = 18 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblMpMatlDtl d INNER JOIN dbo.tblMpMatlSum h ON d.TransId = h.TransId   
    WHERE (h.ComponentType IN (0,5) OR (h.ComponentType = 2 AND d.SubAssemblyTranType = -1)) AND d.QtySeqNum > 0   
   UNION ALL SELECT e.QtySeqNum FROM dbo.tblMpMatlDtlExt e INNER JOIN dbo.tblMpMatlDtl d ON e.TransId = d.TransId AND e.EntryNum = d.SeqNo   
    INNER JOIN dbo.tblMpMatlSum h ON d.TransId = h.TransId WHERE (h.ComponentType IN (0,5) OR (h.ComponentType = 2 AND d.SubAssemblyTranType = -1)) AND e.QtySeqNum > 0) --Build assembly, By-Product, Non-Stock Subassembly that is Moved To Stock  
  UNION ALL  
  --IncreaseWM(20)  
  --Note it was 15 in WM transaction  
  SELECT o.SeqNum, 'IncreaseWM(20)'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 20 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNum FROM dbo.tblWmTrans WHERE TransType = 31 AND QtySeqNum > 0)   
  UNION ALL  
  --TransferToWM  
  SELECT o.SeqNum, 'TransferToWM '   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 21 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QOHSeqNum FROM dbo.tblWmTransferRcpt WHERE QOHSeqNum > 0)   
  UNION ALL  
  --MaterialReqReturnWM  
  SELECT o.SeqNum, 'MaterialReqReturnWM'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 22 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblWmMatReqFilled d INNER JOIN dbo.tblWmMatReq h ON d.TranKey = h.TranKey WHERE h.ReqType < 0 AND d.QtySeqNum > 0)   
  UNION ALL  
  --CreditAR  
  SELECT o.SeqNum, 'CreditAR'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 30 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblArTransDetail d INNER JOIN dbo.tblArTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblArTransLot d INNER JOIN dbo.tblArTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0)  
  UNION ALL  
  --CreditSO  
  SELECT o.SeqNum, 'CreditSO' FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId   
  WHERE  o.[Source] = 31 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblSoTransDetail d INNER JOIN dbo.tblSoTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblSoTransDetailExt d INNER JOIN dbo.tblSoTransHeader h ON d.TransId = h.TransId WHERE h.TransType < 0 AND d.QtySeqNum > 0   
   UNION ALL SELECT QtySeqNum FROM dbo.tblSoReturnedItem WHERE QtySeqNum > 0  
   UNION ALL SELECT i.QtySeqNum FROM dbo.tblPsTransDetailIN i INNER JOIN dbo.tblPsTransDetail d ON i.DetailID = d.ID  
    INNER JOIN dbo.tblPsTransHeader h ON d.HeaderID = h.ID WHERE h.TransType < 0 AND i.QtySeqNum > 0)  
  UNION ALL  
  --CreditIN  
  SELECT o.SeqNum , 'CreditIN'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 32 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNum FROM dbo.tblInTrans WHERE TransType = 25 AND QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblInTransLot d INNER JOIN dbo.tblInTrans h ON d.TransId = h.TransId WHERE h.TransType = 25 AND d.QtySeqNum > 0)   
  UNION ALL  
  --BuildAssemblyBM  
  SELECT o.SeqNum , 'BuildAssemblyBM'  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 33 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT QtySeqNum FROM dbo.tblBmWorkOrder WHERE WorkType = 1 AND QtySeqNum > 0)  
  UNION ALL  
  --UnbuildComponentBM  
  SELECT o.SeqNum, 'UnbuildComponentBM'   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 34 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblBmWorkOrderDetail d INNER JOIN dbo.tblBmWorkOrder h ON d.TransId = h.TransId WHERE h.WorkType = 2 AND d.QtySeqNum > 0  
   UNION ALL SELECT d.QtySeqNum FROM dbo.tblBmWorkOrderLot d INNER JOIN dbo.tblBmWorkOrder h ON d.TransId = h.TransId WHERE h.WorkType = 2 AND d.QtySeqNum > 0)   
  UNION ALL  
  --Sale type transactions  
  SELECT o.SeqNum  , 'Sale transactions - Source >= 70' 
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE o.[Source] >= 70 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0  
    
 END  
  
  --mah added:
  select '#SeqNumNotInTrans', * from #SeqNumNotInTrans
  --
  
 /*Backup and remove zero onhand/offset quantity record that are not in live transactions.*/  
 BEGIN  
  INSERT INTO dbo.tblInQtyOnHand_Temp (PostRun, SeqNum, EntryDate, EntryID, ItemId, LocId, LotNum, [Source], Qty, Cost, InvoicedQty,   
  RcptLink, RemoveQty, LinkID, LinkIDSub, LinkIDSubLine, PostedYn, DeletedYn)  
  SELECT @PostRun, SeqNum, EntryDate, EntryID, ItemId, LocId, LotNum, [Source], Qty, Cost, InvoicedQty,   
   RcptLink, RemoveQty, LinkID, LinkIDSub, LinkIDSubLine, PostedYn, DeletedYn   
  FROM dbo.tblInQtyOnHand  
  WHERE SeqNum IN (SELECT OnHandSeqNum FROM #SeqNumNotInTrans WHERE OnHandSeqNum NOT IN (SELECT OnHandLink FROM #OnHandLinkInTrans)) 
    
---- mah commented out following delete
  -- DELETE dbo.tblInQtyOnHand
  --WHERE SeqNum IN (SELECT OnHandSeqNum FROM #SeqNumNotInTrans WHERE OnHandSeqNum NOT IN (SELECT OnHandLink FROM #OnHandLinkInTrans))   
  --mah added:
  select 'To Be Deleted From OnHand-1', * from tblInQtyOnHand
  WHERE SeqNum IN (SELECT OnHandSeqNum FROM #SeqNumNotInTrans WHERE OnHandSeqNum NOT IN (SELECT OnHandLink FROM #OnHandLinkInTrans))  
  
  
  
  --PO receipt onhand records that do not have PO invoice onhand records  
  INSERT INTO dbo.tblInQtyOnHand_Temp (PostRun, SeqNum, EntryDate, EntryID, ItemId, LocId, LotNum, [Source], Qty, Cost, InvoicedQty,   
  RcptLink, RemoveQty, LinkID, LinkIDSub, LinkIDSubLine, PostedYn, DeletedYn)  
  SELECT @PostRun, o.SeqNum, o.EntryDate, o.EntryID, o.ItemId, o.LocId, o.LotNum, o.[Source], o.Qty, o.Cost, o.InvoicedQty,   
   o.RcptLink, o.RemoveQty, o.LinkID, o.LinkIDSub, o.LinkIDSubLine, o.PostedYn, o.DeletedYn   
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId  
  WHERE  o.[Source] = 10 AND o.Qty - o.InvoicedQty - o.RemoveQty = 0 AND o.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblPoTransLotRcpt d INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0)   
   AND SeqNum NOT IN (SELECT RcptLink FROM dbo.tblInQtyOnHand WHERE [Source] = 13)  
 
 ---- mah commented out following delete 
 -- DELETE dbo.tblInQtyOnHand  
 -- FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand ON t.ItemId = dbo.tblInQtyOnHand.ItemId AND t.LocId = dbo.tblInQtyOnHand.LocId  
 -- WHERE  dbo.tblInQtyOnHand.[Source] = 10 AND dbo.tblInQtyOnHand.Qty - dbo.tblInQtyOnHand.InvoicedQty - dbo.tblInQtyOnHand.RemoveQty = 0 AND dbo.tblInQtyOnHand.SeqNum NOT IN   
 --  (SELECT d.QtySeqNum FROM dbo.tblPoTransLotRcpt d INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0)   
 --  AND SeqNum NOT IN (SELECT RcptLink FROM dbo.tblInQtyOnHand WHERE [Source] = 13)   
 --mah added:
 select 'ToBeDeletedFrom OnHand - 2', dbo.tblInQtyOnHand.*  
  FROM #ItemLocationList t INNER JOIN dbo.tblInQtyOnHand ON t.ItemId = dbo.tblInQtyOnHand.ItemId AND t.LocId = dbo.tblInQtyOnHand.LocId  
  WHERE  dbo.tblInQtyOnHand.[Source] = 10 AND dbo.tblInQtyOnHand.Qty - dbo.tblInQtyOnHand.InvoicedQty - dbo.tblInQtyOnHand.RemoveQty = 0 AND dbo.tblInQtyOnHand.SeqNum NOT IN   
   (SELECT d.QtySeqNum FROM dbo.tblPoTransLotRcpt d INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId WHERE h.TransType > 0 AND d.QtySeqNum > 0)   
   AND SeqNum NOT IN (SELECT RcptLink FROM dbo.tblInQtyOnHand WHERE [Source] = 13)   
  
  INSERT INTO dbo.tblInQtyOnHand_Offset_Temp (PostRun, SeqNum, GrpID, EntryDate, [Source], Qty, Cost, OnHandLink, LinkID, LinkIDSub,   
   LinkIDSubLine, CostActual, CostAdj, CostAdjPosted, PostedYn, DeletedYn)  
  SELECT @PostRun, SeqNum, GrpID, EntryDate, [Source], Qty, Cost, OnHandLink, LinkID, LinkIDSub, LinkIDSubLine,   
   CostActual, CostAdj, CostAdjPosted, PostedYn, DeletedYn   
  FROM dbo.tblInQtyOnHand_Offset  
  WHERE OnHandLink NOT IN (SELECT SeqNum FROM dbo.tblInQtyOnHand)  
 
 ---- mah commented out following delete 
 -- DELETE dbo.tblInQtyOnHand_Offset  
 -- WHERE OnHandLink NOT IN (SELECT SeqNum FROM dbo.tblInQtyOnHand)  
 --mah added:
select 'ToBeDeleted-OnHandOffset',* from dbo.tblInQtyOnHand_Offset  
 WHERE OnHandLink NOT IN (SELECT SeqNum FROM dbo.tblInQtyOnHand) 
  
 END  
 
  --mah added:
  select 'tblInQtyOnHand_Temp', * from tblInQtyOnHand_Temp
  select 'tblInQtyOnHand_Offset_Temp', * from tblInQtyOnHand_Offset_Temp
  --
  --mah added:
  delete from tblInQtyOnHand_Temp
  delete  from tblInQtyOnHand_Offset_Temp
  --
  
 /*Capture a snapshot of qty onhand and cost for all regular item/location after process, then check if any variance for qty onhand and cost*/  
 BEGIN  
  INSERT INTO #ItemLocationAfter(ItemId, LocId, QtyOnHand, Cost)  
  SELECT l.ItemId, l.LocId, ISNULL(o.QtyOnHand,0), ISNULL(o.Cost,0)  
  FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId   
   LEFT JOIN dbo.trav_InItemOnHand_view o (TABLOCKX) ON l.ItemId = o.ItemId AND l.LocId = o.LocId  
  WHERE i.ItemType = 1  
  
  IF EXISTS(SELECT * FROM #ItemLocationBefore b INNER JOIN #ItemLocationAfter a ON b.ItemId = a.ItemId AND b.LocId = a.LocId WHERE b.QtyOnHand <> a.QtyOnHand OR b.Cost <> a.Cost)  
  BEGIN  
   RAISERROR('Process causes onhand quantity variance or cost variance.', 16, 1)  
  END  
 END  
  --mah added:
  --select '#ItemLocationAfter', * from #ItemLocationAfter
  -- 
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH