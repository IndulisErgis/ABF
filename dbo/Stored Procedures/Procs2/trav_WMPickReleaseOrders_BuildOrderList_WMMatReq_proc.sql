
CREATE PROCEDURE dbo.trav_WMPickReleaseOrders_BuildOrderList_WMMatReq_proc
AS
BEGIN TRY
	SET NOCOUNT ON


	--identify any WM Material Requisitions that are available for picking	
	INSERT INTO #OrderList(SourceId, TransId, EntryNum, SeqNum, PickNum
		, ItemId, LocId, LotNum, ExtLocA, ExtLocB, UOM, QtyReq
		, ReqDate, GrpId, OriCompQty, Ref1, Ref2, Ref3)
	SELECT 8, 'MATREQ', r.TranKey, r.LineNum, Null
		, r.ItemId, r.LocId, r.LotNum, r.ExtLocA, r.ExtLocB, r.UOM, (r.Qty - r.QtyFilled)
		, m.DateNeeded, Null, 0
		, Case When Len(IsNull(m.ReqNum, '')) > 8 Then LEFT(m.ReqNum, 7) + '*' Else m.ReqNum End --truncate the ReqNum when it exceeds 8 characters / append an astrisk to denote the truncation
		, Null, Null 
	FROM dbo.tblWmMatReqRequest r 
	INNER JOIN dbo.tblWmMatReq m ON r.TranKey = m.TranKey
	WHERE m.ReqType = 1 --is a regular MatReq
		AND (r.Qty - r.QtyFilled) > 0 --has quantity to process

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_WMMatReq_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPickReleaseOrders_BuildOrderList_WMMatReq_proc';

