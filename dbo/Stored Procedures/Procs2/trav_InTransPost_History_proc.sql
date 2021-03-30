
CREATE PROCEDURE dbo.trav_InTransPost_History_proc
AS
BEGIN TRY
	--PONewOrder = 11 
	--POGoodsRcvd = 12 
	--POInvoice = 14 
	--POMiscDebit = 15
	--SONewOrder = 21
	--SOVerifyOrder = 23
	--SOInvoice = 24
	--SOMiscCredit = 25
	--Increase = 31
	--Decrease = 32
	DECLARE @PostRun pPostRun, @PrecQty tinyint, @PrecCurr tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @PrecQty IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblInHistTrans (PostRun, TransID, TransType, BatchID, ItemID, LocID, TransDate, Qty, QtyBase, Uom, UomBase, FiscalYear, 
		FiscalPeriod, PriceUnit, CostUnit, PriceExt, CostExt, GLAcct, GLAcctOffset, GLAcctSales, GLAcctCogs, HistSeqNum, QtySeqNum, Cmnt, CF)
	SELECT @PostRun, t.TransId, t.TransType, t.BatchId, t.ItemId, t.LocId, t.TransDate, t.Qty, ROUND(t.Qty * u.ConvFactor, @PrecQty), t.Uom, 
		i.UomBase, t.SumYear, t.GLPeriod, t.PriceUnit, t.CostUnitTrans, ROUND(t.PriceUnit * t.Qty, @PrecCurr), ROUND(t.CostUnitTrans * t.Qty, @PrecCurr), 
		CASE WHEN t.TransType IN (12,14,15,23,24,25) THEN g.GLAcctInv WHEN t.TransType IN (31,32) THEN g.GLAcctInvAdj END, 
		CASE WHEN t.TransType IN (12,14,15,23,24,25,31,32) THEN t.GLAcctOffset END, CASE WHEN t.TransType IN (23,24,25) THEN g.GLAcctSales END, 
		CASE WHEN t.TransType IN (23,24,25) THEN g.GLAcctCogs END, t.HistSeqNum, t.QtySeqNum, t.Cmnt, t.CF
	FROM #PostTransList p INNER JOIN dbo.tblInTrans t ON p.TransId = t.TransId 
		LEFT JOIN dbo.tblInItem i ON t.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON t.ItemId = u.ItemId AND t.Uom = u.Uom 
		LEFT JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode

	INSERT INTO dbo.tblInHistTransLot (HeaderID, SeqNum, LotNum, Qty, QtyBase, CostUnit, CostExt, HistSeqNum, QtySeqNum, Cmnt, CF)
	SELECT h.ID, l.SeqNum, l.LotNum, l.QtyFilled, ROUND(l.QtyFilled * u.ConvFactor, @PrecQty), l.CostUnit, ROUND(l.CostUnit * l.QtyFilled, @PrecCurr), 
		l.HistSeqNum, l.QtySeqNum, l.Cmnt, l.CF
	FROM #PostTransList p INNER JOIN dbo.tblInTrans t ON p.TransId = t.TransId 
		INNER JOIN dbo.tblInHistTrans h ON  t.TransId = h.TransId 
		INNER JOIN dbo.tblInTransLot l ON t.TransId = l.TransId
		LEFT JOIN dbo.tblInItemUom u ON t.ItemId = u.ItemId AND t.Uom = u.Uom
	WHERE h.PostRun = @PostRun

	INSERT INTO dbo.tblInHistTransSer (HeaderID, SeqNum, LotNum, SerNum, CostUnit, PriceUnit, HistSeqNum, Cmnt, CF)
	SELECT h.ID, s.SeqNum, s.LotNum, s.SerNum, s.CostUnit, s.PriceUnit, s.HistSeqNum, s.Cmnt, s.CF
	FROM #PostTransList p INNER JOIN dbo.tblInHistTrans h ON  p.TransId = h.TransId 
		INNER JOIN dbo.tblInTransSer s ON h.TransId = s.TransId
	WHERE h.PostRun = @PostRun

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_History_proc';

