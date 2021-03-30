
CREATE PROCEDURE [dbo].[trav_WmItemRcptList_proc] 
@ItemID pItemid = NULL ,
@DocNo pInvoiceNum = NULL,
@PrecQty Tinyint = NULL,
@WmPoYn Bit = NULL,
@WmSoYn Bit = NULL,
@WmJcYn Bit = NULL,
@WmMpYn Bit = NULL,
@WmXfer Bit = NULL,  
@WmMatReq Bit = NULL   
AS
BEGIN TRY
SET NOCOUNT ON

DECLARE @DocNumber int

Select @DocNumber = Case When isNumeric(@DocNo) = 1 Then Cast(@DocNo as int) Else 0 End

/* PO */
-- By IN item id
SELECT d.ItemID,d.LocID,h.TransId AS DocNo,h.TransID,cast(null AS nvarchar(24)) AS AltItemId,d.Units,d.QtyOrd AS QtyOrdered,
ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDate, d.EntryNum AS EntryNum,u.Upccode,0 AS Source,ISNULL(r.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber,ISNULL( d.ExpReceiptDate,h.ExpReceiptDate) as RequiredDate 
FROM dbo.tblPoTransHeader h (NOLOCK) 
	INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON h.TransID = d.TransID 
    LEFT JOIN (
		 SELECT t.TransID,r.EntryNum, SUM(r.QtyFilled) QtyRcptTot FROM dbo.tblPoTransLotRcpt r (NOLOCK) 
		  INNER JOIN dbo.tblPoTransReceipt t (NOLOCK) ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum
			GROUP BY t.TransID,r.EntryNum 
          ) r 
ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.Units = u.Uom
WHERE @WmPoYn = 1 AND (d.ItemID = @ItemID OR @ItemID IS NULL) AND (h.TransID = @DocNo OR @DocNo IS NULL) 
AND h.TransType > 0 AND d.LineStatus = 0
UNION
-- By vendor item id
SELECT d.ItemID,d.LocID,h.TransId AS DocNo,h.TransID,a.AliasID AS AltItemId,d.Units,d.QtyOrd AS QtyOrdered,
ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDate,d.EntryNum AS EntryNum,u.Upccode,0 AS Source,ISNULL(r.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber ,ISNULL( d.ExpReceiptDate,h.ExpReceiptDate) as RequiredDate  
FROM dbo.tblPoTransHeader h (NOLOCK) 
	INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON h.TransID = d.TransID 
	LEFT JOIN (
		SELECT t.TransID,r.EntryNum, SUM(r.QtyFilled) QtyRcptTot FROM dbo.tblPoTransLotRcpt r (NOLOCK) 
		INNER JOIN dbo.tblPoTransReceipt t (NOLOCK) ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum
		GROUP BY t.TransID,r.EntryNum 
			) r 
ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum 
 INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.Units = u.Uom
 LEFT JOIN (SELECT itemid, aliasid, refid FROM dbo.tblInItemAlias WHERE aliastype=2) a
ON d.ItemId = a.ItemId AND h.VendorId = a.RefID 
WHERE @WmPoYn = 1 AND (a.AliasId = @ItemID) AND (@DocNo IS NULL)  
AND h.TransType > 0 AND d.LineStatus = 0
UNION
-- By UPC code
SELECT d.ItemID,d.LocID,h.TransId AS DocNo,h.TransID,null AS AltItemId,d.Units,d.QtyOrd AS QtyOrdered,
ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDate,d.EntryNum AS EntryNum,u.Upccode,0 AS Source,ISNULL(r.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber, ISNULL( d.ExpReceiptDate,h.ExpReceiptDate) as RequiredDate   
FROM dbo.tblPoTransHeader h (NOLOCK) 
INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON h.TransID = d.TransID 
LEFT JOIN (
	SELECT t.TransID,r.EntryNum, SUM(r.QtyFilled) QtyRcptTot FROM dbo.tblPoTransLotRcpt r (NOLOCK) 
	INNER JOIN dbo.tblPoTransReceipt t (NOLOCK) ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum
   GROUP BY t.TransID,r.EntryNum
         ) r 
ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.Units = u.Uom
WHERE @WmPoYn = 1 AND  (u.Upccode = @ItemID) AND (@DocNo IS NULL) AND h.TransType > 0 AND d.LineStatus = 0  
UNION
/* Transfer */
-- By IN item id
SELECT d.ItemID,h.LocIDto LocID,ISNULL(h.PackNum, h.BatchId) AS DocNo,Cast(h.Trankey as nvarchar),NULL AS AltItemId,d.Uom AS Units,d.Qty AS QtyOrdered,
h.TransDate AS ReqShipDate,d.TranPickKey AS EntryNum,u.Upccode,1 AS Source,ISNULL(pr.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID
 ,d.LotNum  as LotNumber, d.TransDate as RequiredDate
FROM dbo.tblWmTransfer h (NOLOCK) 
INNER JOIN dbo.tblWmTransferPick d (NOLOCK) ON h.TranKey = d.Trankey 
LEFT JOIN (
		SELECT p.TranPickKey, SUM(ROUND(r.Qty * ru.Convfactor / pu.Convfactor,@PrecQty)) QtyRcptTot,p.LotNum FROM dbo.tblWmTransferPick p (NOLOCK)
		INNER JOIN dbo.tblWmTransferRcpt r (NOLOCK) ON p.TranPickKey = r.TranPickKey INNER JOIN dbo.tblInItemUom pu (NOLOCK)
		 ON p.ItemId = pu.ItemId AND p.Uom = pu.Uom 
	     INNER JOIN dbo.tblInItemUom ru (NOLOCK) ON r.ItemId = ru.ItemId AND r.Uom = ru.Uom  
		GROUP BY p.TranPickKey,p.LotNum
		) pr ON d.TranPickKey = pr.TranPickKey 
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.Uom = u.Uom
WHERE @WmXfer=1 AND (d.ItemID = @ItemID OR @ItemID IS NULL) AND (ISNULL(h.PackNum, h.BatchId) = @DocNo OR @DocNo IS NULL) AND h.[Status] IN (0, 1)
UNION
-- By UPC code
SELECT d.ItemID,h.LocIDTo LocID,ISNULL(h.PackNum, h.BatchId) AS DocNo,Cast(h.Trankey as nvarchar),NULL AS AltItemId,d.Uom AS Units,d.Qty AS QtyOrdered,
h.TransDate AS ReqShipDate,d.TranPickKey AS EntryNum,u.Upccode,1 AS Source,ISNULL(pr.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID 
 ,d.LotNum  as LotNumber, d.TransDate as RequiredDate 
FROM dbo.tblWmTransfer h (NOLOCK) 
INNER JOIN dbo.tblWmTransferPick d (NOLOCK) ON h.TranKey = d.Trankey 
LEFT JOIN (
		SELECT p.TranPickKey, SUM(ROUND(r.Qty * ru.Convfactor / pu.Convfactor,@PrecQty)) QtyRcptTot,p.LotNum FROM dbo.tblWmTransferPick p (NOLOCK)
		INNER JOIN dbo.tblWmTransferRcpt r (NOLOCK) ON p.TranPickKey = r.TranPickKey 
		INNER JOIN dbo.tblInItemUom pu (NOLOCK) ON p.ItemId = pu.ItemId AND p.Uom = pu.Uom 
		INNER JOIN dbo.tblInItemUom ru (NOLOCK) ON r.ItemId = ru.ItemId AND r.Uom = ru.Uom  
		GROUP BY p.TranPickKey,p.LotNum
		) pr ON d.TranPickKey = pr.TranPickKey 
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.Uom = u.Uom
WHERE @WmXfer=1 AND (u.Upccode = @ItemID) AND (@DocNo IS NULL) AND h.[Status] = 1  
UNION
/* Material Req */
-- By IN item id
SELECT d.ItemId,d.LocId,h.ReqNum AS DocNo, Cast(h.TranKey as nvarchar), NULL AS AltItemId,d.Uom AS Units,d.Qty AS QtyOrdered,
h.DatePlaced AS ReqShipDate,d.LineNum AS EntryNum,u.UpcCode,8 AS Source,ISNULL(pr.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber ,h.DateNeeded as RequiredDate  
FROM dbo.tblWmMatReq h (NOLOCK)
 INNER JOIN dbo.tblWmMatReqRequest d (NOLOCK) ON h.TranKey = d.TranKey
LEFT JOIN (
		SELECT p.TranKey, SUM(ROUND(r.Qty * ru.Convfactor / pu.Convfactor,@PrecQty)) QtyRcptTot 
		FROM dbo.tblWmMatReqRequest p (NOLOCK) 
		INNER JOIN dbo.tblWmMatReqFilled r (NOLOCK) ON p.TranKey = r.TranKey AND p.LineNum = r.LineNum
		INNER JOIN dbo.tblInItemUom pu (NOLOCK) ON p.ItemId = pu.ItemId AND p.Uom = pu.Uom
		INNER JOIN dbo.tblInItemUom ru (NOLOCK) ON r.ItemId = ru.ItemId AND r.Uom = ru.Uom
		GROUP BY p.TranKey
		) pr ON d.TranKey = pr.TranKey
INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.Uom = u.Uom
WHERE @WmMatReq=1 AND (d.ItemId = @ItemID OR @ItemId is NULL) AND (h.ReqNum = @DocNo OR @DocNo is NULL)AND h.ReqType = -1
UNION
-- By UPC code
SELECT d.ItemId,d.LocId,h.ReqNum AS DocNo, Cast(h.TranKey as nvarchar), NULL AS AltItemId,d.Uom AS Units,d.Qty AS QtyOrdered,
h.DatePlaced AS ReqShipDate,d.LineNum AS EntryNum,u.UpcCode,8 AS Source,ISNULL(pr.QtyRcptTot,0) AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber ,h.DateNeeded as RequiredDate   
FROM dbo.tblWmMatReq h (NOLOCK) 
INNER JOIN dbo.tblWmMatReqRequest d (NOLOCK) ON h.TranKey = d.TranKey
LEFT JOIN (
		SELECT p.TranKey, SUM(ROUND(r.Qty * ru.Convfactor / pu.Convfactor,@PrecQty)) QtyRcptTot 
		FROM dbo.tblWmMatReqRequest p (NOLOCK) 
		INNER JOIN dbo.tblWmMatReqFilled r (NOLOCK) ON p.TranKey = r.TranKey AND p.LineNum = r.LineNum
		INNER JOIN dbo.tblInItemUom pu (NOLOCK) ON p.ItemId = pu.ItemId AND p.Uom = pu.Uom
		INNER JOIN dbo.tblInItemUom ru (NOLOCK) ON r.ItemId = ru.ItemId AND r.Uom = ru.Uom
		GROUP BY p.TranKey
		) pr ON d.TranKey = pr.TranKey
INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.Uom = u.Uom
WHERE @WmMatReq=1 AND (u.UPCCode = @ItemID) AND (@DocNo is NULL) AND h.ReqType = -1  
UNION 
/* SO RMA */
-- By IN item id
SELECT d.ItemID,d.LocID,ISNULL(h.InvcNum, h.TransId) AS DocNo,h.TransId,NULL AS AltItemId,d.UnitsSell AS Units,d.QtyOrdSell AS QtyOrdered,
ISNULL(d.ReqShipDate, h.ReqShipDate) AS ReqShipDate,d.EntryNum AS EntryNum,u.Upccode,16 AS Source,d.QtyShipSell AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber, ISNULL(d.ReqShipDate, h.ReqShipDate) as RequiredDate  
FROM dbo.tblSoTransHeader h (NOLOCK) 
INNER JOIN dbo.tblSoTransDetail d (NOLOCK) ON h.TransID = d.TransID 
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom
WHERE @WmSoYn = 1 AND (d.ItemID = @ItemID OR @ItemID IS NULL) AND (ISNULL(h.InvcNum, h.TransId) = @DocNo OR @DocNo IS NULL)
	AND h.TransType = -2 
UNION
-- By customer item id
SELECT d.ItemID,d.LocID,ISNULL(h.InvcNum, h.TransId) AS DocNo,h.TransId,a.AliasID AS AltItemId,d.UnitsSell AS Units,d.QtyOrdSell AS QtyOrdered,
ISNULL(d.ReqShipDate, h.ReqShipDate) AS ReqShipDate,d.EntryNum AS EntryNum,u.Upccode,16 AS Source,d.QtyShipSell AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber,ISNULL(d.ReqShipDate, h.ReqShipDate) as RequiredDate 
FROM dbo.tblSoTransHeader h (NOLOCK) 
INNER JOIN dbo.tblSoTransDetail d (NOLOCK) ON h.TransID = d.TransID 
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom
 LEFT JOIN (
		SELECT itemid, aliasid, refid FROM dbo.tblInItemAlias WHERE aliastype=1
		) a
ON d.ItemId = a.ItemId AND h.SoldToId = a.RefID 
WHERE @WmSoYn = 1 AND (a.AliasId = @ItemID) AND (@DocNo IS NULL)  
 And h.TransType = -2 
UNION
-- By UPC code
SELECT d.ItemID,d.LocID,h.InvcNum AS DocNo,h.TransId,NULL AS AltItemId,d.UnitsSell AS Units,d.QtyOrdSell AS QtyOrdered,
ISNULL(d.ReqShipDate, h.ReqShipDate) AS ReqShipDate,d.EntryNum AS EntryNum,u.Upccode,16 AS Source,d.QtyShipSell AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber, ISNULL(d.ReqShipDate, h.ReqShipDate) as RequiredDate       
FROM dbo.tblSoTransHeader h (NOLOCK) 
INNER JOIN dbo.tblSoTransDetail d (NOLOCK) ON h.TransID = d.TransID 
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom
WHERE @WmSoYn = 1 AND  (u.Upccode = @ItemID) AND (@DocNo IS NULL)  
 And h.TransType = -2
/* PC Material Req Return */
-- By IN item id
UNION
SELECT t.ItemID,t.LocID,h.ProjectName AS DocNo,Cast(t.Id as nvarchar),NULL AS AltItemId,t.Uom AS Units,t.QtyNeed AS QtyOrdered,
t.TransDate AS ReqShipDate,t.Id AS EntryNum,u.Upccode,32 AS Source,t.QtyFilled  AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber, t.TransDate AS  RequiredDate  
FROM dbo.tblPcProject h (NOLOCK)
INNER JOIN dbo.tblPcProjectDetail d (NOLOCK) ON h.Id = d.ProjectId 
INNER JOIN dbo.tblPcTrans t (NOLOCK) ON t.ProjectDetailId = d.Id 
INNER JOIN dbo.tblInItemUom u (NOLOCK) ON u.ItemId= t.ItemId AND t.Uom=u.Uom
WHERE @WmJcYn = 1 AND (t.ItemID = @ItemID OR @ItemId is NULL ) AND (h.ProjectName = @DocNo OR @DocNo IS NULL)
	AND t.TransType = 1	
UNION
-- By customer item id
SELECT t.ItemID,t.LocID,h.ProjectName AS DocNo,Cast(t.Id as nvarchar),a.AliasID AS AltItemId,t.Uom AS Units,t.QtyNeed AS QtyOrdered,
t.TransDate AS ReqShipDate,t.Id AS EntryNum,u.Upccode,32 AS Source,t.QtyFilled AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber,  t.TransDate AS  RequiredDate
FROM dbo.tblPcProject h (NOLOCK) 
INNER JOIN dbo.tblPcProjectDetail d (NOLOCK) ON h.Id = d.ProjectId 
INNER JOIN dbo.tblPcTrans t (NOLOCK) ON t.ProjectDetailId = d.Id 
INNER JOIN dbo.tblInItemUom u ON u.ItemId= t.ItemId and t.Uom=u.Uom
LEFT JOIN (
		SELECT itemid, aliasid, refid FROM dbo.tblInItemAlias WHERE aliastype=1
		) a
ON t.ItemId = a.ItemId AND h.CustId = a.RefID 
WHERE @WmJcYn = 1 AND (a.AliasId = @ItemID ) AND (@DocNo IS NULL)
	AND t.TransType = 1
UNION
-- By UPC code
SELECT t.ItemID,t.LocID,h.ProjectName AS DocNo,Cast(t.Id as nvarchar),NULL AS AltItemId,t.Uom AS Units,t.QtyNeed AS QtyOrdered,
t.TransDate AS ReqShipDate,t.Id AS EntryNum,u.Upccode,32 AS Source,t.QtyFilled AS QtyReceived,NULL  as MPTransID
,NULL  as LotNumber , t.TransDate AS  RequiredDate 
FROM dbo.tblPcProject h (NOLOCK) 
INNER JOIN dbo.tblPcProjectDetail d (NOLOCK) ON h.Id = d.ProjectId 
INNER JOIN dbo.tblPcTrans t (NOLOCK) ON t.ProjectDetailId = d.Id 
INNER JOIN dbo.tblInItemUom u ON u.ItemId= t.ItemId and t.Uom=u.Uom
WHERE @WmJcYn = 1 AND  (u.Upccode = @ItemID ) AND (@DocNo IS NULL)
	AND t.TransType = 1

UNION
/* MP Manufacturing Production */   
-- By IN item id  
SELECT d.ComponentID,d.LocID,h.OrderNo AS DocNo,cast(h.ReleaseNo as nvarchar),NULL AS AltItemId,d.Uom AS Units ,d.EstQtyRequired  AS QtyOrdered,
req.EstStartDate AS ReqShipDate ,req.ReqId AS EntryNum,u.Upccode,2 AS Source,ISNULL(r.QtyRcptTot,0) AS QtyReceived ,d.TransId as  MPTransID
,NULL  as LotNumber, req.EstStartDate AS RequiredDate    
FROM dbo.tblMpOrderReleases h (NOLOCK) 
INNER JOIN dbo.tblMpRequirements req (NOLOCK) on  h.Id=req.ReleaseId  
INNER JOIN dbo.tblMpMatlSum d (NOLOCK)  ON req.TransId =d.TransId 
LEFT JOIN 
(
SELECT s.TransId, SUM(ROUND(d.Qty * du.Convfactor / su.Convfactor,@PrecQty) ) QtyRcptTot 
FROM dbo.tblMpMatlSum s
INNER JOIN dbo.tblMpMatlDtl d (NOLOCK) ON s.TransId = d.TransId 
LEFT Join tblInItemUom su ON (s.ComponentId =su.ItemId AND s.UOM =su.Uom) 
LEFT Join tblInItemUom du ON (d.ComponentId =du.ItemId AND d.UOM =du.Uom) GROUP BY s.TransID
)r ON d.TransId = r.TransId  
INNER JOIN dbo.tblInItemUom u ON d.ComponentID = u.ItemId AND d.Uom = u.Uom  
WHERE h.Status <> 6 AND ((d.ComponentType = 5 AND d.Status <> 6) OR d.ComponentType = 0) 
AND @WmMpYn = 1 AND (d.ComponentID = @ItemID OR @ItemID IS NULL) AND (h.OrderNo = @DocNo OR @DocNo IS NULL)  
  
UNION  
-- By UPC code  
SELECT d.ComponentID,d.LocID,h.OrderNo AS DocNo,CAST(h.ReleaseNo as nvarchar),NULL AS AltItemId,d.Uom AS Units,d.EstQtyRequired AS QtyOrdered,
req.EstStartDate AS ReqShipDate ,req.ReqId AS EntryNum ,u.Upccode,2 AS Source,
ISNULL(r.QtyRcptTot,0) AS QtyReceived  ,d.TransId as  MPTransID 
,NULL  as LotNumber, req.EstStartDate AS RequiredDate   
FROM dbo.tblMpOrderReleases h (NOLOCK) 
INNER JOIN dbo.tblMpRequirements req (NOLOCK) on  h.Id=req.ReleaseId  
INNER JOIN dbo.tblMpMatlSum d (NOLOCK)  ON req.TransId =d.TransId   
LEFT JOIN 
(
SELECT s.TransId, SUM(ROUND(d.Qty * du.Convfactor / su.Convfactor,@PrecQty) ) QtyRcptTot 
FROM dbo.tblMpMatlSum s INNER JOIN dbo.tblMpMatlDtl d (NOLOCK)   
ON s.TransId = d.TransId 
LEFT Join tblInItemUom su ON (s.ComponentId =su.ItemId AND s.UOM =su.Uom) 
LEFT Join tblInItemUom du ON (d.ComponentId =du.ItemId AND d.UOM =du.Uom) GROUP BY s.TransID
)r ON d.TransId = r.TransId  
INNER JOIN dbo.tblInItemUom u ON d.ComponentID = u.ItemId AND d.Uom = u.Uom  
WHERE h.Status <> 6 AND ((d.ComponentType = 5 AND d.Status <> 6) OR d.ComponentType = 0) 
AND @WmMpYn = 1 AND (u.Upccode = @ItemID OR @ItemID IS NULL) AND (h.OrderNo = @DocNo OR @DocNo IS NULL) 
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc 
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmItemRcptList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmItemRcptList_proc';

