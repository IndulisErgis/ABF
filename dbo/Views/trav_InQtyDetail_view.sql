
CREATE VIEW [dbo].[trav_InQtyDetail_view]
AS

SELECT 'IN' Source,dbo.tblInQty.Qty, CAST(dbo.tblInTrans.TransID AS nvarchar(10)) AS TransID, '' AS EntryNum, NULL Reference,NULL ReqShipDate,dbo.tblInTrans.ItemId,dbo.tblInTrans.LocId,
			dbo.tblInQty.TransType,dbo.tblInQty.LotNum,dbo.tblInTrans.TransDate [RequiredDate]
FROM        dbo.tblInTrans (NOLOCK) INNER JOIN
            dbo.tblInQty (NOLOCK) ON dbo.tblInTrans.QtySeqNum = dbo.tblInQty.SeqNum
WHERE		dbo.tblInTrans.TransType IN (11,21) AND dbo.tblInQty.Qty <> 0
UNION ALL
SELECT 'PO' Source,dbo.tblInQty.Qty, dbo.tblPoTransDetail.TransID, CAST(dbo.tblPoTransDetail.EntryNum AS nvarchar(10)),  
            dbo.tblPoTransHeader.VendorId Reference ,COALESCE(dbo.tblPoTransDetail.ReqShipDate, dbo.tblPoTransHeader.ReqShipDate) AS ReqShipDate,dbo.tblPoTransDetail.ItemId,dbo.tblPoTransDetail.LocId,
            dbo.tblInQty.TransType,dbo.tblInQty.LotNum,ISNULL(tblPoTransDetail.ExpReceiptDate, tblPoTransHeader.ExpReceiptDate) [RequiredDate]
FROM        dbo.tblPoTransHeader (NOLOCK) INNER JOIN
            dbo.tblPoTransDetail  (NOLOCK) ON dbo.tblPoTransDetail.TransID = dbo.tblPoTransHeader.TransId INNER JOIN
			dbo.tblInQty (NOLOCK) ON dbo.tblPoTransDetail.QtySeqNum = dbo.tblInQty.SeqNum
WHERE		dbo.tblInQty.Qty > 0
UNION ALL
SELECT 'SO' Source, COALESCE(t.Qty, q.Qty) AS Qty, d.TransID, CAST(d.EntryNum AS nvarchar(10)), h.CustId Reference, 
			COALESCE(d.ReqShipDate, h.ReqShipDate) ReqShipDate, d.ItemId, d.LocId, 0, COALESCE(t.LotNum, q.LotNum) AS LotNum,ISNULL(d.ReqShipDate, h.ReqShipDate) [RequiredDate]
 FROM		dbo.tblSoTransHeader h (NOLOCK) INNER JOIN dbo.tblSoTransDetail d (NOLOCK) ON h.TransID = d.TransId
	LEFT JOIN dbo.tblSoTransDetailExt e (NOLOCK) ON d.TransID = e.TransId AND d.EntryNum = e.EntryNum
    INNER JOIN dbo.tblInQty q (NOLOCK) ON d.QtySeqNum_Cmtd = q.SeqNum 
    LEFT JOIN dbo.tblInQty_Ext t (NOLOCK) ON e.QtySeqNum_Cmtd = t.ExtSeqNum
WHERE h.VoidYn = 0 AND COALESCE(t.Qty, q.Qty) <> 0
UNION ALL
SELECT 'BM' Source, i.Qty, w.TransId AS TransID, '', NULL, NULL, w.ItemId, w.LocId,i.TransType,i.LotNum,w.TransDate  [RequiredDate]
FROM dbo.tblBmWorkOrder w (NOLOCK) INNER JOIN dbo.tblInQty i (NOLOCK)  ON  i.SeqNum = w.QtySeqNum 
WHERE w.Status = 0
UNION ALL
SELECT 'BM' Source, i.Qty, w.TransId AS TransID, CAST(d.EntryNum AS nvarchar(10)), NULL, NULL, d.ItemId, d.LocId,i.TransType,i.LotNum,w.TransDate [RequiredDate]
FROM dbo.tblBmWorkOrder w (NOLOCK) INNER JOIN dbo.tblBmWorkOrderDetail d (NOLOCK) ON w.TransId = d.TransId
INNER JOIN dbo.tblInQty i (NOLOCK)  ON  i.SeqNum = d.QtySeqNum
WHERE w.Status = 0
Union All
Select [Source], SUM(Qty), TransID, EntryNum, Reference, ReqShipDate, ItemId, LocId, TransType, LotNum ,RequiredDate
From (Select 'WMTransfer' Source, q.Qty, CAST(w.TranKey AS nvarchar(10)) as TransID
	, '' EntryNum, NULL Reference, NULL ReqShipDate, p.ItemId, w.LocIdTo as LocId, 2 As TransType, p.LotNum ,p.TransDate AS  [RequiredDate] 
	From dbo.tblWmTransferPick p 
	Inner Join dbo.tblWmTransfer w on p.TranKey = w.TranKey
	Inner Join dbo.tblInQty q on p.QOOSeqNum = q.SeqNum
	Where q.Qty <> 0
Union All
Select 'WMTransfer' Source, q.Qty, CAST(w.TranKey AS nvarchar(10)) as TransID
	, '' EntryNum, NULL Reference, NULL ReqShipDate, w.ItemId, w.LocIdTo LocId, 2 As TransType, w.LotNum,null as [RequiredDate]
	From dbo.tblWmTransfer w Inner Join dbo.tblInQty q on w.QtySeqNum_OnOrd = q.SeqNum
	Where q.Qty <> 0
Union All
Select 'WMTransfer' Source, q.Qty as Qty, CAST(w.TranKey AS nvarchar(10)) as TransID
	, '' EntryNum, NULL Reference, NULL ReqShipDate, w.ItemId, w.LocId, 0 As TransType, w.LotNum  ,null as [RequiredDate]
	From dbo.tblWmTransfer w Inner Join dbo.tblInQty q on w.QtySeqNum_Cmtd = q.SeqNum
	Where q.Qty <> 0) xfer
Group by [Source], TransID, EntryNum, Reference, ReqShipDate, ItemId, LocId, TransType, LotNum ,[RequiredDate] 
Union ALL
		SELECT 'WMMat' Source, Sum(IsNull(qe.Qty, q.Qty)) as Qty, CAST(r.TranKey AS nvarchar(10)) as TransID
			   ,CAST(r.LineNum AS nvarchar(10)) EntryNum, m.ReqNum Reference, m.DateNeeded ReqShipDate, r.ItemId, r.LocId, q.TransType, r.LotNum  ,m.DateNeeded as [RequiredDate]
		  FROM dbo.tblWmMatReqRequest r
	INNER JOIN dbo.tblWmMatReq m on r.TranKey = m.TranKey
	 LEFT JOIN dbo.tblInQty q on r.QtySeqNum = q.SeqNum
	 LEFT JOIN dbo.tblInQty_ext qe on q.SeqNum = qe.SeqNum
		 WHERE COALESCE(qe.Qty, q.Qty, 0) <> 0
	  GROUP BY r.TranKey, r.LineNum, m.ReqNum, m.DateNeeded, r.ItemId, r.LocId, q.TransType, r.LotNum 
	 UNION ALL
		SELECT 'JC' AS [Source], COALESCE(x.Qty, q.Qty) AS Qty, CAST(t.Id AS nvarchar(10)) AS TransID, NULL AS EntryNum
				,p.ProjectName + CASE WHEN p.TaskId IS NULL THEN '' ELSE '/' + p.TaskId END AS Reference
				,NULL AS ReqShipDate,t.ItemId, t.LocId, q.TransType, COALESCE(x.LotNum, q.LotNum) AS LotNum,null as [RequiredDate]
	      FROM dbo.tblPcTrans t INNER JOIN dbo.tblInQty q (NOLOCK) ON t.QtySeqNum_Cmtd = q.SeqNum 
	INNER JOIN dbo.trav_PcProjectTask_view p ON t.ProjectDetailId = p.Id
	 LEFT JOIN dbo.tblPcTransExt e ON t.Id = e.TransId  
	 LEFT JOIN dbo.tblInQty_Ext x (NOLOCK) ON e.QtySeqNum_Cmtd = x.ExtSeqNum 
		 WHERE COALESCE(x.Qty, q.Qty) <> 0
	 UNION ALL
		SELECT 'MP' AS [Source], COALESCE(qe.Qty, i.Qty), o.OrderNo AS TransID, o.ReleaseNo, CAST(r.ReqId AS nvarchar), r.EstStartDate AS RequiredDate, d.ComponentId, d.LocId, i.TransType
			   ,COALESCE(qe.LotNum, i.LotNum) AS LotNum
			   ,CASE  WHEN d.ComponentType = 0 then o.EstCompletionDate else o.EstStartDate	 END as [RequiredDate]
		  FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN  dbo.tblMpMatlSum d ON r.TransId = d.TransId 
	INNER JOIN dbo.tblInQty i  on d.QtySeqNum = i.SeqNum 
	 LEFT JOIN dbo.tblMpMatlSumExt e  on d.TransId = e.TransId
	 LEFT JOIN dbo.tblInQty_Ext qe  on e.QtySeqNumExt = qe.ExtSeqNum
	 UNION ALL
		SELECT 'SD' AS [Source], COALESCE(x.Qty, q.Qty) AS Qty, CAST(t.Id AS nvarchar) AS TransID, NULL AS EntryNum, w.WorkOrderNo + '/' + CAST(d.DispatchNo AS nVarchar) AS Reference
			   ,COALESCE(a.ScheduleDate, d.RequestedDate, t.TransDate) AS ReqShipDate
			   ,t.ResourceID, t.LocId, q.TransType, COALESCE(x.LotNum, q.LotNum) AS LotNum,COALESCE(a.ScheduleDate, d.RequestedDate, t.TransDate) as [RequiredDate]
		  FROM dbo.tblSvWorkOrderTrans t 
    INNER JOIN dbo.tblInQty q (NOLOCK) ON t.QtySeqNum_Cmtd = q.SeqNum  
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID
	INNER JOIN dbo.tblSvWorkOrder w ON t.WorkOrderID = w.ID
	 LEFT JOIN (SELECT DispatchID, MIN(ActivityDateTime) AS ScheduleDate FROM dbo.tblSvWorkOrderActivity WHERE ActivityType = 1 GROUP BY DispatchID) a ON d.ID = a.DispatchID
	 LEFT JOIN dbo.tblSvWorkOrderTransExt e ON t.Id = e.TransId  
	 LEFT JOIN dbo.tblInQty_Ext x (NOLOCK) ON e.QtySeqNum_Cmtd = x.ExtSeqNum 
		 WHERE t.TransType = 1 AND COALESCE(x.Qty, q.Qty) <> 0
     UNION ALL
	    SELECT 'PS' AS [Source], q.Qty, CAST(h.ID AS nvarchar) AS TransID, d.EntryNum AS EntryNum
			   ,h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS nvarchar),8) AS Reference, h.DueDate AS ReqShipDate
			   ,d.ItemID, d.LocId, q.TransType, d.LotNum,h.DueDate  as [RequiredDate]
		 FROM dbo.tblPsTransDetailIN t 
   INNER JOIN dbo.tblInQty q (NOLOCK) ON t.QtySeqNum_Cmtd = q.SeqNum  
   INNER JOIN dbo.tblPsTransDetail d ON t.DetailID = d.ID
   INNER JOIN dbo.tblPsTransHeader h ON d.HeaderID = h.ID
	    WHERE q.Qty <> 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InQtyDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InQtyDetail_view';

