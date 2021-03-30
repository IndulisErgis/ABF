
CREATE VIEW trav_WmHistDetailView_view
AS    
--PET:- 0230052, 0230438, 0229459
--PET:http://webfront:801/view.php?id=243811
    
SELECT grpd.ItemId, item.Descr AS ItemDescr, grpd.LocId, grpd.LotNum, grpd.SerNum, locA.ExtLocID AS ExtLocAID, locB.ExtLocID AS ExtLocBID, TransType, 
	grpd.TransDate, grpd.Qty, item.UomBase AS Unit, grpd.UID, Source
FROM (SELECT ItemId, LocId, TransType, TransDate, SUM(Qty) AS Qty, LotNum, SerNum, UID, Source, ExtLocA, ExtLocB
      FROM (SELECT NULL AS ExtHistSeqNum, inhd.HistSeqNum, inhd.ItemId, inhd.LocId, inhd.TransType, inhd.TransDate, CASE WHEN ItemType = 2 THEN 1 ELSE inhd.Qty * inhd.ConvFactor END AS Qty, 
			   ISNULL(inhs.LotNum, inhd.LotNum) AS [LotNum], inhs.SerNum, NULL AS UID, Source, NULL AS ExtLocA, NULL AS ExtLocB
			   FROM dbo.tblInHistDetail AS inhd 
					LEFT OUTER JOIN dbo.tblInHistSer AS inhs ON inhs.HistSeqNum = inhd.HistSeqNum
			   WHERE (inhd.Qty <> 0)

			   UNION ALL --reverse invoiced/completed quantities (PO/MP)
			   SELECT NULL AS ExtHistSeqNum, inhd.HistSeqNum, inhd.ItemId, inhd.LocId, rcpt.TransType, inhd.TransDate, CASE WHEN inhd.ItemType = 2 THEN -1 ELSE -(inhd.Qty * inhd.ConvFactor) END AS Qty, 
			   ISNULL(inhs.LotNum, inhd.LotNum) AS [LotNum], inhs.SerNum, NULL AS UID, rcpt.Source, NULL AS ExtLocA, NULL AS ExtLocB
			   FROM dbo.tblInHistDetail AS inhd 
			   INNER JOIN dbo.tblInHistDetail rcpt ON inhd.HistSeqNum_Rcpt = rcpt.HistSeqNum
			   LEFT OUTER JOIN dbo.tblInHistSer AS inhs ON inhs.HistSeqNum = inhd.HistSeqNum
			   WHERE (inhd.Qty <> 0)

			   UNION ALL
			   SELECT NULL AS ExtHistSeqNum, HistSeqNum, ItemId, LocId, TransType, TransDate, -Qty AS Qty, Lotnum, Sernum, NULL AS UID, Source, NULL AS ExtLocA,  NULL AS ExtLocB
			   FROM dbo.trav_WmHistDetail_view
			   WHERE (Qty <> 0) AND (HistSeqNum IS NOT NULL)
			   
			   UNION ALL
			   SELECT ExtHistSeqNum, HistSeqNum, ItemId, LocId, TransType, TransDate, Qty, Lotnum, Sernum, UID, Source, ExtLocA, ExtLocB
			   FROM dbo.trav_WmHistDetail_view
			   WHERE (Qty <> 0) ) AS temp
			   
        GROUP BY ExtHistSeqNum, HistSeqNum, ItemId, LocId, TransType, TransDate, Source, LotNum, SerNum, UID, ExtLocA, ExtLocB ) AS grpd 
        LEFT OUTER JOIN dbo.tblInItem AS item ON item.ItemId = grpd.ItemId 
        LEFT OUTER JOIN dbo.tblWmExtLoc AS locA ON locA.Id = grpd.ExtLocA AND locA.Type = 0 
        LEFT OUTER JOIN dbo.tblWmExtLoc AS locB ON locB.Id = grpd.ExtLocB AND locB.Type = 1
WHERE (grpd.Qty <> 0)
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmHistDetailView_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmHistDetailView_view';

