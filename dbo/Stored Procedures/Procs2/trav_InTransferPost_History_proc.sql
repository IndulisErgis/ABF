
CREATE PROCEDURE dbo.trav_InTransferPost_History_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @PrecQty tinyint, @PrecCurr tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @PrecQty IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblInHistXfers (PostRun, TransID, BatchID, ItemID, LocIDFrom, LocIDTo, XferDate, FiscalYear, FiscalPeriod, Qty, QtyBase, Uom, UomBase, 
		CostUnit, CostExt, CostXfer, GLAcctInvFrom, GLAcctInvTo, GLAcctXferCost, HistSeqNumFrom, HistSeqNumTo, QtySeqNumFrom, QtySeqNumTo, Cmnt, CF)
	SELECT @PostRun, t.TransId, t.BatchId, t.ItemIdFrom, t.LocIdFrom, t.LocIdTo, t.XferDate, t.SumYear, t.GLPeriod, t.Qty, ROUND(t.Qty * u.ConvFactor, @PrecQty), 
		t.Uom, i.UomBase, t.CostUnit, ROUND(t.CostUnit * t.Qty, @PrecCurr), t.CostUnitXfer, gf.GLAcctInv, gt.GLAcctInv, 
		CASE WHEN t.CostUnitXfer <> 0 THEN gf.GLAcctXferCost END, t.HistSeqNumFrom, t.HistSeqNumTo, t.QtySeqNumFrom, t.QtySeqNumTo, t.Cmnt, t.CF
	FROM #PostTransList p INNER JOIN dbo.tblInXfers t ON p.TransId = t.TransId 
		LEFT JOIN dbo.tblInItem i ON t.ItemIdFrom = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON t.ItemIdFrom = u.ItemId AND t.Uom = u.Uom 
		LEFT JOIN dbo.tblInItemLoc lf ON t.ItemIdFrom = lf.ItemId AND t.LocIdFrom = lf.LocId
		LEFT JOIN dbo.tblInGLAcct gf ON lf.GLAcctCode = gf.GLAcctCode 
		LEFT JOIN dbo.tblInItemLoc lt ON t.ItemIdFrom = lt.ItemId AND t.LocIdTo = lt.LocId
		LEFT JOIN dbo.tblInGLAcct gt ON lt.GLAcctCode = gt.GLAcctCode

	INSERT INTO dbo.tblInHistXferLot (HeaderID, SeqNum, LotNumFrom, LotNumTo, Qty, QtyBase, CostUnit, CostExt, CostXfer, HistSeqNumFrom, HistSeqNumTo, 
		QtySeqNumFrom, QtySeqNumTo, Cmnt, CF)
	SELECT h.ID, l.SeqNum, l.LotNumFrom, l.LotNumTo, l.QtyFilled, ROUND(l.QtyFilled * u.ConvFactor, @PrecQty), l.CostUnit, ROUND(l.CostUnit * l.QtyFilled, @PrecCurr), 
		l.CostXfer, l.HistSeqNum, l.HistSeqNumTo, l.QtySeqNumFrom, l.QtySeqNumTo, l.Cmnt, l.CF
	FROM #PostTransList p INNER JOIN dbo.tblInXfers t ON p.TransId = t.TransId 
		INNER JOIN dbo.tblInHistXfers h ON  t.TransId = h.TransId 
		INNER JOIN dbo.tblInXferLot l ON t.TransId = l.TransId
		LEFT JOIN dbo.tblInItemUom u ON t.ItemIdFrom = u.ItemId AND t.Uom = u.Uom
	WHERE h.PostRun = @PostRun

	INSERT INTO dbo.tblInHistXferSer (HeaderID, SeqNum, LotNumFrom, LotNumTo, SerNum, CostUnit, CostXfer, HistSeqNumFrom, HistSeqNumTo, Cmnt, CF)
	SELECT h.ID, s.SeqNum, s.LotNumFrom, s.LotNumTo, s.SerNum, s.CostUnit, s.CostXfer, s.HistSeqNum, s.HistSeqNumTo, s.Cmnt, s.CF
	FROM #PostTransList p INNER JOIN dbo.tblInHistXfers h ON  p.TransId = h.TransId 
		INNER JOIN dbo.tblInXferSer s ON h.TransId = s.TransId
	WHERE h.PostRun = @PostRun

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferPost_History_proc';

