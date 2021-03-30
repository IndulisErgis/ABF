
CREATE VIEW dbo.trav_SmTransLinkSource_SD
AS
--Transaction status is New;Transaction type is Part;Dispatch status is Open;Dispatch is not cancelled;

SELECT t.Id, w.WorkOrderNo AS OrderNo, d.DispatchNo, ISNULL(t.ResourceID,'') ItemId, t.[Description], ISNULL(t.LocId,'') LocId, ISNULL(l.SeqNum,0) AS LinkSeqNum
	, CASE WHEN t.QtyUsed = 0 AND (l.SeqNum IS NULL OR l.DestStatus = 2) THEN 0 ELSE 1 END SourceStatus,
	CASE WHEN (l.SeqNum > 0 AND l.DestStatus <> 2) THEN 1 ELSE 0 END Linked, w.CustId
FROM dbo.tblSvWorkOrderTrans t INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.DispatchID = d.Id 
	INNER JOIN dbo.tblSvWorkOrder w ON d.WorkOrderID = w.Id
	LEFT JOIN dbo.tblSmTransLink l ON t.LinkSeqNum = l.SeqNum 
WHERE t.[Status] = 0 AND t.TransType = 1 AND d.[Status] = 0 AND d.CancelledYN = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_SD';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_SD';

