
CREATE VIEW dbo.trav_SmTransLinkSource_MP
AS
SELECT s.TransId, o.OrderNo, o.ReleaseNo, r.ReqId, ISNULL(s.ComponentId,'') AS ItemId, ISNULL(s.LocId,'') AS LocId, 
	ISNULL(l.SeqNum,0) AS LinkSeqNum, CASE WHEN d.TransId IS NULL AND (l.SeqNum IS NULL OR l.DestStatus = 2) THEN 0 ELSE 1 END SourceStatus,
	CASE WHEN (l.SeqNum > 0 AND l.DestStatus <> 2) THEN 1 ELSE 0 END Linked, i.Descr AS [Description], 0 AS Source --Material
FROM dbo.tblMpOrderReleases o INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId
	INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
	LEFT JOIN (SELECT TransId FROM dbo.tblMpMatlDtl GROUP BY TransId) d ON s.TransId = d.TransId
	LEFT JOIN dbo.tblSmTransLink l ON s.LinkSeqNum = l.SeqNum 
	LEFT JOIN dbo.tblInItem i ON s.ComponentId = i.ItemId
WHERE s.ComponentType = 4 AND s.[Status] = 4--material and in process 
UNION ALL
SELECT s.TransId, o.OrderNo, o.ReleaseNo, r.ReqId, '' AS ItemId, '' AS LocId, 
	ISNULL(l.SeqNum,0) AS LinkSeqNum, CASE WHEN d.TransId IS NULL AND (l.SeqNum IS NULL OR l.DestStatus = 2) THEN 0 ELSE 1 END SourceStatus,
	CASE WHEN (l.SeqNum > 0 AND l.DestStatus <> 2) THEN 1 ELSE 0 END Linked, s.OperationId AS [Description], 1 AS Source
FROM dbo.tblMpOrderReleases o INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId
	INNER JOIN dbo.tblMpSubContractSum s ON r.TransId = s.TransId 
	LEFT JOIN (SELECT TransId FROM dbo.tblMpSubContractDtl GROUP BY TransId) d ON s.TransId = d.TransId
	LEFT JOIN dbo.tblSmTransLink l ON s.LinkSeqNum = l.SeqNum 
WHERE s.[Status] = 4--in process 
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_MP';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_MP';

