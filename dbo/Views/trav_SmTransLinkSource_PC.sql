
CREATE VIEW dbo.trav_SmTransLinkSource_PC
AS
SELECT t.Id, p.CustId, p.ProjectName AS ProjectId, d.TaskId, d.PhaseId, ISNULL(t.ItemId,'') ItemId, t.[Description], ISNULL(t.LocId,'') LocId, ISNULL(l.SeqNum,0) AS LinkSeqNum
	, CASE WHEN t.QtyFilled = 0 AND (l.SeqNum IS NULL OR l.DestStatus = 2) THEN 0 ELSE 1 END SourceStatus,
	CASE WHEN (l.SeqNum > 0 AND l.DestStatus <> 2) THEN 1 ELSE 0 END Linked
FROM dbo.tblPcTrans t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id 
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
	LEFT JOIN dbo.tblSmTransLink l ON t.LinkSeqNum = l.SeqNum 
WHERE t.TransType = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_PC';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_PC';

