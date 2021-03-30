
CREATE PROCEDURE [dbo].[trav_WmMatReqTransPost_History_proc]      
AS      
BEGIN TRY  
SET NOCOUNT ON

	DECLARE @PostRun pPostRun, @PrecQty tinyint, @PrecCurr tinyint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @PrecQty IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblWmHistMatReq (PostRun, TranKey, ReqType, ReqNum, DatePlaced, DateNeeded, LocID, ShipToID, ShipVia, ReqstdBy, Notes, CF)
	SELECT @PostRun, TranKey, ReqType, ReqNum, DatePlaced, DateNeeded, LocID, ShipToId, ShipVia, ReqstdBy, Notes, CF
	FROM dbo.tblWmMatReq 
	WHERE TranKey IN (SELECT TranKey FROM #MatReqPostLog) AND [Status] = 1 

	INSERT INTO dbo.tblWmHistMatReqRequest (HeaderID, LineNum, ItemID, LocID, LotNum, ExtLocA, ExtLocB, ExtLocAID, ExtLocBID, Qty, QtyBase, UOM, 
		UOMBase, GLAcct, GLAcctInv, GLDescr, QtySeqNum, QtySeqNum_Ext, LineSeq, CF) 
	SELECT s.ID, r.LineNum, r.ItemId, r.LocId, r.LotNum, r.ExtLocA, r.ExtLocB, a.ExtLocID, b.ExtLocID, r.Qty, ROUND(r.Qty * u.ConvFactor, @PrecQty), 
		r.UOM, i.UomBase, r.GLAcctNum, g.GLAcctInv, r.GLDescr, r.QtySeqNum, r.QtySeqNum_Ext, r.LineSeq, r.CF
	FROM dbo.tblWmHistMatReq s INNER JOIN dbo.tblWmMatReqRequest r ON s.TranKey = r.TranKey 
		LEFT JOIN dbo.tblInItem i ON r.ItemId = i.ItemId
		LEFT JOIN dbo.tblInItemUom u ON r.ItemId = u.ItemId AND r.UOM = u.Uom 
		LEFT JOIN dbo.tblInItemLoc l ON r.ItemId = l.ItemId AND r.LocId = l.LocId 
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		LEFT JOIN dbo.tblWmExtLoc a ON r.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON r.ExtLocB = b.Id
	WHERE s.PostRun = @PostRun AND s.TranKey IN (SELECT TranKey FROM #MatReqPostLog)

	INSERT INTO tblWmHistMatReqFilled (RequestID, SeqNum, SerNum, LotNum, ExtLocA, ExtLocB, ExtLocAID, ExtLocBID, Qty, QtyBase, UOM, CostUnit, CostExt, 
		EntryDate, TransDate, FiscalPeriod, FiscalYear, QtySeqNum, QtySeqNum_Ext, HistSeqNum, HistSeqNumSer, CF)
	SELECT r.ID, f.SeqNum, f.SerNum, f.LotNum, f.ExtLocA, f.ExtLocB, a.ExtLocID, b.ExtLocID, f.Qty, ROUND(f.Qty * u.ConvFactor, @PrecQty), f.UOM, f.UnitCost, 
		ROUND(f.Qty * f.UnitCost, @PrecCurr), f.EntryDate, f.TransDate, f.GlPeriod, f.GlYear, f.QtySeqNum, f.QtySeqNum_Ext, f.HistSeqNum, f.HistSeqNumSer, f.CF
	FROM dbo.tblWmHistMatReq s INNER JOIN dbo.tblWmHistMatReqRequest r ON s.ID = r.HeaderID 
		INNER JOIN dbo.tblWmMatReqFilled f ON s.TranKey = f.TranKey AND r.LineNum = f.LineNum 
		LEFT JOIN dbo.tblInItemUom u ON r.ItemId = u.ItemId AND r.UOM = u.Uom
		LEFT JOIN dbo.tblWmExtLoc a ON f.ExtLocA = a.Id
		LEFT JOIN dbo.tblWmExtLoc b ON f.ExtLocB = b.Id
	WHERE s.PostRun = @PostRun AND s.TranKey IN (SELECT TranKey FROM #MatReqPostLog)

END TRY      
BEGIN CATCH      
	EXEC dbo.trav_RaiseError_proc      
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMatReqTransPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmMatReqTransPost_History_proc';

