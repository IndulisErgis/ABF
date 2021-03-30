--PET:http://problemtrackingsystem.osas.com/view.php?id=254204
--PET:http://problemtrackingsystem.osas.com/view.php?id=263947
CREATE VIEW dbo.trav_SmTransLinkSource_SO
AS
SELECT d.TransId, d.EntryNum, ISNULL(d.ItemId,'') ItemId, d.Descr, ISNULL(d.LocId,'') LocId, ISNULL(l.SeqNum,0) AS LinkSeqNum
	, CASE WHEN h.TransType IN (3, 5, 9) AND ISNULL(d.Status, 0) = 0 
		AND d.QtyShipSell = 0 AND (l.SeqNum IS NULL OR l.DestStatus = 2)  THEN 0 ELSE 1 END SourceStatus,
	CASE WHEN (l.SeqNum > 0 AND l.DestStatus <> 2) THEN 1 ELSE 0 END Linked
FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId
	LEFT JOIN dbo.tblSmTransLink l ON d.LinkSeqNum = l.SeqNum 
WHERE h.VoidYn = 0 AND d.Kit = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_SO';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SmTransLinkSource_SO';

