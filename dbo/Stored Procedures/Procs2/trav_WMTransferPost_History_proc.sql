
CREATE PROCEDURE [dbo].[trav_WMTransferPost_History_proc] 
AS  
BEGIN TRY  

	DECLARE @PostRun pPostRun, @PrecQty tinyint, @PrecCurr tinyint, @ApplyXferCostAdj tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @ApplyXferCostAdj = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'ApplyXferCostAdj'

	INSERT INTO dbo.tblWmHistTransfer (PostRun, TranKey, BatchID, ItemID, LocID, LocIDTo, LotNum, Qty, QtyBase, UOM, UOMBase, CostTransfer, GLAcctXferCost, 
		GLAcctInTransit, GLAcctInvAdj, GLAcctInvFrom, GLAcctInvTo, EntryDate, TransDate, PackNum, QtySeqNum_OnOrd, QtySeqNum_Cmtd, Cmnt, CF)
	SELECT @PostRun, f.TranKey, f.BatchID, f.ItemId, f.LocId, f.LocIdTo, f.LotNum, f.Qty, ROUND(f.Qty * u.ConvFactor, @PrecQty), f.UOM, i.UomBase, f.CostTransfer, 
		CASE WHEN f.CostTransfer <> 0 THEN CASE WHEN @ApplyXferCostAdj = 0 THEN gf.GLAcctXferCost ELSE gt.GLAcctXferCost END END, 
		CASE WHEN @ApplyXferCostAdj = 0 THEN gf.GLAcctInTransit ELSE gt.GLAcctInTransit END,
		CASE WHEN @ApplyXferCostAdj = 0 THEN gf.GLAcctInvAdj ELSE gt.GLAcctInvAdj END, 
		gf.GLAcctInv, gt.GLAcctInv, f.EntryDate, f.TransDate, f.PackNum, f.QtySeqNum_OnOrd, f.QtySeqNum_Cmtd, f.Cmnt, f.CF
	FROM #PostTransList t INNER JOIN dbo.tblWmTransfer f ON t.TransId = f.TranKey 
		LEFT JOIN dbo.tblInItem i ON f.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON f.ItemId = u.ItemId AND f.UOM = u.Uom 
		LEFT JOIN dbo.tblInItemLoc lf ON f.ItemId = lf.ItemId AND f.LocId = lf.LocId 
		LEFT JOIN dbo.tblInGLAcct gf ON lf.GLAcctCode = gf.GLAcctCode
		LEFT JOIN dbo.tblInItemLoc lt ON f.ItemId = lt.ItemId AND f.LocIdTo = lt.LocId 
		LEFT JOIN dbo.tblInGLAcct gt ON lt.GLAcctCode = gt.GLAcctCode
	WHERE f.[Status] = 2
		
	INSERT INTO dbo.tblWmHistTransferPick (HeaderID, TranPickKey, SerNum, LotNum, ExtLocA, ExtLocB, ExtLocAID, ExtLocBID, Qty, QtyBase, UOM, CostUnit, CostExt, 
		EntryDate, TransDate, FiscalPeriod, FiscalYear, QOHSeqNum, QOHSeqNumExt, QOOSeqNum, HistSeqNum, HistSeqNumSer, CF)
	SELECT f.ID, p.TranPickKey, p.SerNum, p.LotNum, p.ExtLocA, p.ExtLocB, a.ExtLocID, b.ExtLocID, p.Qty, ROUND(p.Qty * u.ConvFactor, @PrecQty), p.UOM, p.UnitCost, 
		ROUND(p.Qty * p.UnitCost, @PrecCurr), p.EntryDate, p.TransDate, p.GlPeriod, p.GlYear, p.QOHSeqNum, p.QOHSeqNumExt, p.QOOSeqNum, p.HistSeqNum, p.HistSeqNumSer, p.CF
	FROM #PostTransList t INNER JOIN dbo.tblWmHistTransfer f ON t.TransId = f.TranKey 
		INNER JOIN dbo.tblWmTransferPick p ON f.TranKey = p.TranKey 
		LEFT JOIN dbo.tblInItemUom u ON f.ItemID = u.ItemId AND f.UOM = u.Uom
		LEFT JOIN dbo.tblWmExtLoc a ON p.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON p.ExtLocB = b.Id
	WHERE f.PostRun = @PostRun

	INSERT INTO dbo.tblWmHistTransferRcpt (PickID, TranRcptKey, SerNum, LotNum, ExtLocA, ExtLocB, ExtLocAID, ExtLocBID, Qty, QtyBase, UOM, CostUnit, CostExt, EntryDate, 
		TransDate, FiscalPeriod, FiscalYear, QOHSeqNum, QOHSeqNumExt, HistSeqNum, HistSeqNumSer, CF)
	SELECT p.ID, r.TranRcptKey, r.SerNum, r.LotNum, r.ExtLocA, r.ExtLocB, a.ExtLocID, b.ExtLocID, r.Qty, ROUND(r.Qty * u.ConvFactor, @PrecQty), r.UOM, r.UnitCost, 
		ROUND(r.Qty * r.UnitCost, @PrecCurr), r.EntryDate, r.TransDate, r.GlPeriod, r.GlYear, r.QOHSeqNum, r.QOHSeqNumExt, r.HistSeqNum, r.HistSeqNumSer, r.CF
	FROM #PostTransList t INNER JOIN dbo.tblWmHistTransfer f ON t.TransId = f.TranKey 
		INNER JOIN dbo.tblWmHistTransferPick p ON f.ID = p.HeaderID
		INNER JOIN dbo.tblWmTransferRcpt r ON p.TranPickKey = r.TranPickKey 
		LEFT JOIN dbo.tblInItemUom u ON f.ItemID = u.ItemId AND f.UOM = u.Uom
		LEFT JOIN dbo.tblWmExtLoc a ON r.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON r.ExtLocB = b.Id
	WHERE f.PostRun = @PostRun
	
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_History_proc';

