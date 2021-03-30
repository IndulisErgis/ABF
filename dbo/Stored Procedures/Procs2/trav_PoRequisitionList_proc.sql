
CREATE PROCEDURE dbo.trav_PoRequisitionList_proc
@SortBy int = 0 -- 0 = Item ID, 1 = Location ID, 2 = Vendor ID

AS
BEGIN TRY
	SET NOCOUNT ON

	INSERT INTO #tmpRequisitions(ReqId, GrpID1, VendorId, ItemId, ReqItemType, LocId, ReqDescr, Qty, UnitCost, ExtCost
		, Uom, InitDate, EnteredBy, SourceApp, RefId, GenerateYn, GlAcct, ReqShipDate, AddnlDescr, DropShipYn, SourceType
		, LineNum, LinkTransId, Seq, ReleaseNum, OrderReqId, LinkSeqNum, CustId, ProjId, PhaseId, TaskId, LinkedYn, Descr
		, ItemType, ItemStatus, ProductLine, SalesCat, PriceId, TaxClass, LottedYN, KittedYN) 
	SELECT ReqId
		, CASE @SortBy 
			WHEN 0 THEN p.ItemId 
			WHEN 1 THEN LocId 
			WHEN 2 THEN VendorId 
			END AS GrpId1
		, VendorId, p.ItemId, p.ItemType AS ReqItemType, LocId, p.Descr AS ReqDescr, Qty, UnitCost, ExtCost, Uom, InitDate
		, EnteredBy, SourceApp, RefId, GenerateYn, GlAcct, ReqShipDate, AddnlDescr, DropShipYn, SourceType, LineNum, LinkTransId
		, Seq, ReleaseNum, OrderReqId, LinkSeqNum, CustId, ProjId, PhaseId, TaskId
		, CASE WHEN LinkSeqNum IS NULL THEN 0 ELSE 1 END AS LinkedYn, i.Descr, i.ItemType, ItemStatus, ProductLine
		, SalesCat, PriceId, TaxClass, LottedYN, KittedYN 
	FROM dbo.tblPoPurchaseReq p LEFT JOIN dbo.tblInItem i ON p.ItemId = i.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoRequisitionList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoRequisitionList_proc';

