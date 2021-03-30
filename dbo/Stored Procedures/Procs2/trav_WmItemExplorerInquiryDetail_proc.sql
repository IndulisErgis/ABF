
CREATE Procedure [dbo].[trav_WmItemExplorerInquiryDetail_proc]
@ItemId pItemId,
@LocId pLocId = NULL,
@LotNum pLotNum = NULL,
@SerNum pSerNum = NULL

As

BEGIN TRY

Create table #HistDtl (
	HistSeqNum int,
	HistSeqNumLot int,
	HistSeqNumSer int,
	BackRcptYn bit,
	ItemId pItemId,
	LocId pLocId,
	ItemType tinyint,
	LottedYn bit,
	Source tinyint,
	TransDate datetime,
	SrceId nvarchar(10),
	UOM pUOM,
	Qty pDecimal,
	LotNum pLotNum,
	SerNum pSerNum
)

--capture matching records from history
Insert into #HistDtl (HistSeqNum, HistSeqNumSer, BackRcptYn
	, ItemId, LocId, ItemType, LottedYn
	, Source, TransDate, SrceId, UOM
	, Qty, LotNum, SerNum)
SELECT h.HistSeqNum, s.SeqNum HistSeqNumSer, 0 AS BackRcptYn
	, h.ItemId, h.LocId, h.ItemType, h.LottedYN
	, h.Source, h.TransDate, h.SrceID, h.Uom
	, Case When h.ItemType = 2 Then 1.0 Else h.Qty End Qty
	, Case When h.ItemType = 2 Then s.LotNum Else h.LotNum End LotNum
	, s.SerNum
	FROM dbo.tblInHistDetail h 
	--Left Join dbo.tblInHistLot l on h.HistSeqNum = l.HistSeqNum
	Left Join dbo.tblInHistSer s on h.HistSeqNum = s.HistSeqNum
	WHERE h.ItemId = @ItemId
		AND h.LocId = @LocID 
		AND (Coalesce(s.LotNum, h.LotNum) = @LotNum or @LotNum is Null)
		AND (s.SerNum = @SerNum or @SerNum is Null)

--back out receipts for invoiced transactions
Insert into #HistDtl (HistSeqNum, HistSeqNumSer, BackRcptYn
	, ItemId, LocId, ItemType, LottedYn
	, Source, TransDate, SrceId, UOM
	, Qty, LotNum, SerNum)
SELECT h.HistSeqNum, s.SeqNum HistSeqNumSer, 1 AS BackRcptYn
	, h.ItemId, h.LocId, h.ItemType, h.LottedYN
	, h.Source, h.TransDate, h.SrceID, h.Uom
	, -Case When h.ItemType = 2 Then 1.0 Else h.Qty End Qty
	, Case When h.ItemType = 2 Then s.LotNum Else h.LotNum End LotNum
	, s.SerNum
	FROM dbo.tblInHistDetail h 
	INNER JOIN dbo.tblInHistDetail r ON h.HistSeqNum_Rcpt = r.HistSeqNum
	Left Join dbo.tblInHistSer s on h.HistSeqNum = s.HistSeqNum
	WHERE h.ItemId = @ItemId
		AND h.LocId = @LocID 
		AND (Coalesce(s.LotNum, h.LotNum) = @LotNum or @LotNum is Null)
		AND (s.SerNum = @SerNum or @SerNum is Null)
		AND h.Qty > 0

--return the resultset 
Select tmp.*, Case When a.Type = 0 Then a.ExtLocID Else '' End ExtLocAId
	, Case When a.Type = 1 Then a.ExtLocID Else '' End ExtLocBId
	, i.Descr ItemDescr, NULL AS TransType -- t.TransType --todo: tblInSourceType is obsolete
	From (Select d.ExtHistSeqNum
		, h.HistSeqNum, h.HistSeqNumSer, h.BackRcptYn
		, h.ItemId, h.LocId, h.ItemType, h.LottedYn
		, h.Source, Case When d.ExtHistSeqNum is Null Then h.TransDate Else d.TransDate End TransDate
		, h.SrceId
		, Case When d.ExtHistSeqNum is Null Then h.UOM Else i.UomBase End UOM
		, Case When d.ExtHistSeqNum is Null Then h.Qty Else d.Qty End Qty
		, h.LotNum, h.SerNum, d.ExtLocA, d.ExtLocB
		From #HistDtl h
		Inner Join dbo.tblInItem i on h.ItemId = i.ItemId
		Left Join dbo.tblWmHistDetail d
			on h.HistSeqNum = d.HistSeqNum
				--and isnull(h.HistSeqNumLot, 0) = isnull(d.HistSeqNumLot, 0)
				and isnull(h.HistSeqNumSer, 0) = isnull(d.HistSeqNumSer, 0)
		Union All --include "Move Qty" history
		Select d.ExtHistSeqNum
			, d.HistSeqNum, d.HistSeqNumSer, 0 BackRcptYn
			, d.ItemId, d.LocId, i.ItemType, i.LottedYn
			, d.Source, d.TransDate, isnull(d.TransId, cast(ReferenceId as nvarchar)) SrceId, i.UomBase UOM
			, d.Qty, d.LotNum, d.SerNum, d.ExtLocA, d.ExtLocB
		From dbo.tblWmHistDetail d
		Inner Join dbo.tblInItem i on d.ItemId = i.ItemId
		Where d.HistSeqNum is NULL -- not tied to IN History
			AND d.ItemId = @ItemId
			AND d.LocId = @LocID 
			AND (d.LotNum = @LotNum or @LotNum is Null)
			AND (d.SerNum = @SerNum or @SerNum is Null)
		
	) tmp
	--Left Join dbo.tblInSourceType t ON tmp.Source = t.SourceID --todo:tblInSourceType is obsolete
	Left Join dbo.tblWmExtLoc a on tmp.ExtLocA = a.Id
	Left Join dbo.tblWmExtLoc b on tmp.ExtLocB = b.Id
	Left Join dbo.tblInItem i on tmp.ItemId = i.ItemId
	Order By tmp.LotNum, tmp.SerNum, tmp.TransDate DESC, a.ExtLocID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmItemExplorerInquiryDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmItemExplorerInquiryDetail_proc';

