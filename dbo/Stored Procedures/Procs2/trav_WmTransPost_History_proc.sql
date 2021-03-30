
CREATE PROCEDURE dbo.trav_WmTransPost_History_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PostRun pPostRun, @PrecQty tinyint, @PrecCurr tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	INSERT INTO dbo.tblWmHistTrans (PostRun, TransID, BatchID, TransType, ItemID, LocID, LotNum, ExtLocA, ExtLocB, ExtLocAID, ExtLocBID, Qty, 
		QtyBase, UOM, UOMBase, CostUnit, CostExt, EntryDate, TransDate, FiscalPeriod, FiscalYear, GLAcctOffset, GLAcctInvAdj, HistSeqNum, QtySeqNum, 
		QtySeqNumExt, Cmnt, CF)
	SELECT @PostRun, h.TransId, h.BatchId, h.TransType, h.ItemId, h.LocId, h.LotNum, h.ExtLocA, h.ExtLocB, a.ExtLocID, b.ExtLocID, h.Qty, 
		ROUND(h.Qty * u.ConvFactor, @PrecQty), h.Uom, i.UomBase, h.UnitCost, ROUND(h.Qty * h.UnitCost, @PrecCurr), h.EntryDate, h.TransDate, h.GLPeriod, 
		h.GlYear, h.GLAcctOffset, g.GLAcctInvAdj, h.HistSeqNum, h.QtySeqNum, h.QtySeqNumExt, h.Cmnt, h.CF
	FROM #PostTransList t INNER JOIN dbo.tblWmTrans h on t.TransId = h.TransId
		LEFT JOIN dbo.tblInItem i ON h.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON h.ItemId = u.ItemId AND h.Uom = u.Uom 
		LEFT JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		LEFT JOIN dbo.tblWmExtLoc a ON h.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON h.ExtLocB = b.Id

	INSERT INTO dbo.tblWmHistTransSer (HeaderID, SeqNum, LotNum, SerNum, ExtLocA, ExtLocB, ExtLocAID, ExtLocBID, CostUnit, HistSeqNum, Cmnt, CF)
	SELECT h.ID, s.SeqNum, s.LotNum, s.SerNum, s.ExtLocA, s.ExtLocB, a.ExtLocID, b.ExtLocID, s.CostUnit, s.HistSeqNum, s.Cmnt, s.CF
	FROM #PostTransList t INNER JOIN dbo.tblWmHistTrans h on t.TransId = h.TransId 
		INNER JOIN dbo.tblWmTransSer s ON h.TransId = s.TransId 
		LEFT JOIN dbo.tblWmExtLoc a ON s.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON s.ExtLocB = b.Id
	WHERE h.PostRun = @PostRun
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_History_proc';

