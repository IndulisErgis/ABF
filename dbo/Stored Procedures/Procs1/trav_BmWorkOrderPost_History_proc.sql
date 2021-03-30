
CREATE PROCEDURE dbo.trav_BmWorkOrderPost_History_proc
AS
BEGIN TRY
DECLARE @PostRun nvarchar(14)

--Retrieve global values
SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
IF @PostRun IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

INSERT INTO dbo.tblBmWorkOrderHist (PostRun, TransId, EntryNum, TransDate, WorkType, Status, PrintedYn
	, BmBomId, ItemId, LocId, ItemType, BuildUOM, BuildQty, ActualQty, LaborCost, UnitCost, ConvFactor
	, GLPeriod, GlYear, SumHistPeriod, QtySeqNum, HistSeqNum, WorkUser, Descr, UomBase
	, ItemStatus, ItemLocStatus, GLAcctCode, CF)
SELECT @PostRun, h.TransId, h.EntryNum, h.TransDate, h.WorkType, h.Status, h.PrintedYn
	, h.BmBomId, h.ItemId, h.LocId, h.ItemType, h.BuildUOM, h.BuildQty, h.ActualQty, h.LaborCost, h.UnitCost, h.ConvFactor
	, h.GLPeriod, h.GlYear, h.SumHistPeriod, h.QtySeqNum, h.HistSeqNum, h.WorkUser, b.Descr, i.UomBase
	, i.ItemStatus, l.ItemLocStatus, GLAcctCode, h.CF 
FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrder h ON t.TransId = h.TransId 
	INNER JOIN dbo.tblBmBom b ON b.BmBomId = h.BmBomId 
	INNER JOIN dbo.tblInItem i ON h.ItemId = i.ItemId 
	INNER JOIN dbo.tblInItemLoc l ON h.ItemId = l.ItemId AND h.LocId = l.LocId 

INSERT INTO dbo.tblBmWorkOrderHistDetail(PostRun, TransId, EntryNum, ItemId, LocId, ItemType
	, OriCompQty, EstQty, ActQty, Uom, ConvFactor, UnitCost, QtySeqNum, HistSeqNum, CF)
SELECT @PostRun, d.TransId, d.EntryNum, d.ItemId, d.LocId, d.ItemType
	, d.OriCompQty, d.EstQty, d.ActQty, d.Uom, d.ConvFactor, d.UnitCost, d.QtySeqNum, d.HistSeqNum, d.CF 
FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrderDetail d ON t.TransId = d.TransId 

INSERT INTO dbo.tblBmWorkOrderHistLot (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
	, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, QtySeqNum, CF)
SELECT @PostRun, l.TransId, l.EntryNum, l.SeqNum, l.ItemId, l.LocId, l.LotNum
	, l.QtyOrder, l.QtyFilled, l.QtyBkord, l.CostUnit, l.CostUnitFgn, l.HistSeqNum, l.Cmnt, l.QtySeqNum, l.CF 
FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrderLot l ON t.TransId = l.TransId 

INSERT INTO dbo.tblBmWorkOrderHistSer (PostRun, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
	, SerNum, CostUnit, CostUnitFgn, PriceUnit, PriceUnitFgn, HistSeqNum, Cmnt, QtySeqNum, CF)
SELECT @PostRun, r.TransId, r.EntryNum, r.SeqNum, r.ItemId, r.LocId, r.LotNum
	, r.SerNum, r.CostUnit, r.CostUnitFgn, r.PriceUnit, r.PriceUnitFgn, r.HistSeqNum, r.Cmnt, r.QtySeqNum, r.CF
FROM #PostTransList t INNER JOIN dbo.tblBmWorkOrderSer r ON t.TransId = r.TransId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_History_proc';

