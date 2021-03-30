
CREATE PROCEDURE dbo.trav_InSerializedHistoryReport_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT i.ItemId, l.LocId,i.ItemId AS ItemId1, l.locid as locid1, s.SerNum, ISNULL(i.ProductLine,'') AS ProductLineZls, s.LotNum, 
	i.Descr AS ItemDescr, a.AddlDescr, s.Cmnt, d.Source, d.TransId, d.RefId, 
	d.SrceID, d.TransDate, s.DateInvc, s.DateShip, s.DateRcpt, s.InvcNum, s.CostUnit, s.PriceUnit, 
	l.Descr AS LocDescr
	FROM #tmpHistorySerList t INNER JOIN dbo.tblInHistSer s (NOLOCK) ON t.SeqNum = s.SeqNum 
		INNER JOIN dbo.tblInHistDetail d ON s.HistSeqNum = d.HistSeqNum
		INNER JOIN dbo.tblInItem i  ON d.ItemId = i.ItemId 
		INNER JOIN tblInLoc l (NOLOCK) ON d.LocId = l.LocId 
		LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
	UNION ALL 
	SELECT i.ItemId, l.LocId,i.ItemId AS ItemId1, l.locid as locid1, s.SerNum, ISNULL(i.ProductLine,'') AS ProductLineZls, s.LotNum, 
	i.Descr AS ItemDescr, a.AddlDescr, s.Cmnt, d.Source, d.TransId, r.RefId, 
	d.SrceID, d.TransDate, s.DateInvc, s.DateShip, s.DateRcpt, s.InvcNum, -v.CostUnit, -s.PriceUnit, 
	l.Descr AS LocDescr
	FROM #tmpHistorySerList t INNER JOIN dbo.tblInHistSer s (NOLOCK) ON t.SeqNum = s.SeqNum 
		INNER JOIN dbo.tblInHistDetail d ON s.HistSeqNum = d.HistSeqNum
		INNER JOIN dbo.tblInHistDetail r ON d.HistSeqNum_Rcpt = r.HistSeqNum 
		INNER JOIN dbo.tblInHistSer v ON r.HistSeqNum = v.HistSeqNum AND s.SerNum = v.SerNum
		INNER JOIN dbo.tblInItem i  ON d.ItemId = i.ItemId 
		INNER JOIN tblInLoc l (NOLOCK) ON d.LocId = l.LocId 
		LEFT JOIN tblInItemAddlDescr a (NOLOCK) ON i.ItemId = a.ItemId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSerializedHistoryReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InSerializedHistoryReport_proc';

