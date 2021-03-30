
CREATE procedure dbo.trav_PoFulfillmentReport_proc
@IncludeSo bit = 1, 
@IncludeSd bit = 1,
@IncludeJc bit = 1,
@IncludeMpMatl bit = 1,
@IncludeMpSubcon bit = 1,
@RcptDateFrom datetime = NULL,
@RcptDateThru datetime = NULL
AS
SET NOCOUNT ON
BEGIN TRY

--SO line items with Open status and links to PO transaction with received quantity
SELECT l.SourceType, d.TransId + '-' + CAST(d.EntryNum AS nvarchar) AS [References],
	d.ItemId, d.LocId, d.Descr AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblSoTransDetail d ON l.SeqNum = d.LinkSeqNum AND l.SourceId = d.TransId
	INNER JOIN dbo.tblSoTransHeader h ON d.TransId = h.TransId 
	INNER JOIN dbo.tblPoTransDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoTransLotRcpt rd ON pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoTransReceipt r ON rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum
WHERE @IncludeSo = 1 AND l.TransLinkType = 0 AND l.SourceType = 4 AND h.TransType IN (3, 5, 9) AND d.Status = 0 
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,d.TransId,d.EntryNum,d.ItemId,d.LocId,d.Descr
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
SELECT l.SourceType, d.TransId + '-' + CAST(d.EntryNum AS nvarchar) AS [References],
	d.ItemId, d.LocId, d.Descr AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblSoTransDetail d ON l.SeqNum = d.LinkSeqNum AND l.SourceId = d.TransId
	INNER JOIN dbo.tblSoTransHeader h ON d.TransId = h.TransId 
	INNER JOIN dbo.tblPoHistDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoHistLotRcpt rd ON pd.PostRun = rd.PostRun AND pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoHistReceipt r ON rd.PostRun = r.PostRun AND rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum
WHERE @IncludeSo = 1 AND l.TransLinkType = 0 AND l.SourceType = 4 AND h.TransType IN (3, 5, 9) AND d.Status = 0 
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,d.TransId,d.EntryNum,d.ItemId,d.LocId,d.Descr
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
--Project Costing
SELECT l.SourceType, p.CustId + '-' + p.ProjectName + '-'  + ISNULL(e.PhaseId,'') + '-' + ISNULL(e.TaskId,'') AS [References],
	d.ItemId, d.LocId, d.[Description] AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblPcTrans d ON l.SeqNum = d.LinkSeqNum
	INNER JOIN dbo.tblPoTransDetail pd ON  l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoTransLotRcpt rd ON pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoTransReceipt r ON rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum 
	INNER JOIN dbo.tblPcProjectDetail e ON d.ProjectDetailId = e.Id
	INNER JOIN dbo.tblPcProject p ON e.ProjectId = p.Id
WHERE @IncludeJc = 1 AND l.TransLinkType = 0 AND l.SourceType = 3 AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom)  
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND (@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,d.Id,d.ItemId,d.LocId,d.[Description],p.CustId,p.ProjectName,e.PhaseId,e.TaskId
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
--SD line items with Open status and links to PO transaction with received quantity
SELECT l.SourceType, w.WorkOrderNo + '-' + CAST(d.DispatchNo AS nvarchar) AS [References],
	t.ResourceID AS ItemId, t.LocID, t.[Description] AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblSvWorkOrderTrans t ON l.SeqNum = t.LinkSeqNum 
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID 
	INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID
	INNER JOIN dbo.tblPoTransDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoTransLotRcpt rd ON pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoTransReceipt r ON rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum
WHERE @IncludeSd = 1 AND l.TransLinkType = 0 AND l.SourceType IN (5,9) AND d.[Status] = 0
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,w.WorkOrderNo,d.DispatchNo,t.ResourceID,t.LocID,t.[Description]
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
SELECT l.SourceType, w.WorkOrderNo + '-' + CAST(d.DispatchNo AS nvarchar) AS [References],
	t.ResourceID AS ItemId, t.LocID, t.[Description] AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblSvWorkOrderTrans t ON l.SeqNum = t.LinkSeqNum 
	INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.ID 
	INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.ID
	INNER JOIN dbo.tblPoHistDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoHistLotRcpt rd ON pd.PostRun = rd.PostRun AND pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoHistReceipt r ON rd.PostRun = r.PostRun AND rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum
WHERE @IncludeSd = 1 AND l.TransLinkType = 0 AND l.SourceType IN (5,9) AND d.[Status] = 0
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,w.WorkOrderNo,d.DispatchNo,t.ResourceID,t.LocID,t.[Description]
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
--MP material line items with Open status and links to PO transaction with received quantity
SELECT l.SourceType, e.OrderNo + '-' + CAST(e.ReleaseNo AS nvarchar) + '-' + CAST(q.ReqID AS nvarchar) AS [References],
	s.ComponentId AS ItemId, s.LocId, i.Descr AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblMpMatlSum s ON l.SeqNum = s.LinkSeqNum
	INNER JOIN dbo.tblMpRequirements q ON s.TransId = q.TransId
	INNER JOIN dbo.tblMpOrderReleases e ON q.ReleaseId = e.Id
	INNER JOIN dbo.tblPoTransDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoTransLotRcpt rd ON pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoTransReceipt r ON rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum 
	LEFT JOIN dbo.tblInItem i ON s.ComponentId = i.ItemId
WHERE @IncludeMpMatl = 1 AND l.TransLinkType = 0 AND l.SourceType = 6 AND e.[Status] = 4 AND s.[Status] = 4
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,e.OrderNo,e.ReleaseNo,q.ReqID,s.ComponentId,s.LocId,i.Descr
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
SELECT l.SourceType, e.OrderNo + '-' + CAST(e.ReleaseNo AS nvarchar) + '-' + CAST(q.ReqID AS nvarchar) AS [References],
	s.ComponentId AS ItemId, s.LocId, i.Descr AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblMpMatlSum s ON l.SeqNum = s.LinkSeqNum
	INNER JOIN dbo.tblMpRequirements q ON s.TransId = q.TransId
	INNER JOIN dbo.tblMpOrderReleases e ON q.ReleaseId = e.Id
	INNER JOIN dbo.tblPoHistDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoHistLotRcpt rd ON pd.PostRun = rd.PostRun AND pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoHistReceipt r ON rd.PostRun = r.PostRun AND rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum
	LEFT JOIN dbo.tblInItem i ON s.ComponentId = i.ItemId
WHERE @IncludeMpMatl = 1 AND l.TransLinkType = 0 AND l.SourceType = 6 AND e.[Status] = 4 AND s.[Status] = 4
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,e.OrderNo,e.ReleaseNo,q.ReqID,s.ComponentId,s.LocId,i.Descr
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
--MP subcontracted line items with Open status and links to PO transaction with received quantity
SELECT l.SourceType, e.OrderNo + '-' + CAST(e.ReleaseNo AS nvarchar) + '-' + CAST(q.ReqID AS nvarchar) AS [References],
	NULL AS ItemId, NULL AS LocId, s.[Description] AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblMpSubContractSum s ON l.SeqNum = s.LinkSeqNum
	INNER JOIN dbo.tblMpRequirements q ON s.TransId = q.TransId
	INNER JOIN dbo.tblMpOrderReleases e ON q.ReleaseId = e.Id
	INNER JOIN dbo.tblPoTransDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoTransLotRcpt rd ON pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoTransReceipt r ON rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum 
WHERE @IncludeMpSubcon = 1 AND l.TransLinkType = 0 AND l.SourceType = 7 AND e.[Status] = 4 AND s.[Status] = 4
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,e.OrderNo,e.ReleaseNo,q.ReqID,s.[Description]
HAVING SUM(rd.QtyFilled) <> 0
UNION ALL
SELECT l.SourceType, e.OrderNo + '-' + CAST(e.ReleaseNo AS nvarchar) + '-' + CAST(q.ReqID AS nvarchar) AS [References],
	NULL AS ItemId, NULL AS LocId, s.[Description] AS ItemDescr
FROM dbo.tblSmTransLink l INNER JOIN dbo.tblMpSubContractSum s ON l.SeqNum = s.LinkSeqNum
	INNER JOIN dbo.tblMpRequirements q ON s.TransId = q.TransId
	INNER JOIN dbo.tblMpOrderReleases e ON q.ReleaseId = e.Id
	INNER JOIN dbo.tblPoHistDetail pd ON l.SeqNum = pd.LinkSeqNum AND l.DestId = pd.TransId 
	INNER JOIN dbo.tblPoHistLotRcpt rd ON pd.PostRun = rd.PostRun AND pd.TransId = rd.TransId AND pd.EntryNum = rd.EntryNum 
	INNER JOIN dbo.tblPoHistReceipt r ON rd.PostRun = r.PostRun AND rd.TransId = r.TransId AND rd.RcptNum = r.ReceiptNum
WHERE @IncludeMpSubcon = 1 AND l.TransLinkType = 0 AND l.SourceType = 7 AND e.[Status] = 4 AND s.[Status] = 4
	AND l.SourceStatus <> 2 AND l.DestStatus <> 2 --link is not broken
	AND l.DestType = 2 AND (@RcptDateFrom IS NULL OR r.ReceiptDate >= @RcptDateFrom) AND 
	(@RcptDateThru IS NULL OR r.ReceiptDate <= @RcptDateThru)
GROUP BY l.SourceType,e.OrderNo,e.ReleaseNo,q.ReqID,s.[Description]
HAVING SUM(rd.QtyFilled) <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoFulfillmentReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoFulfillmentReport_proc';

