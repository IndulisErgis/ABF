 
CREATE PROCEDURE dbo.trav_PoRequisitionCombine_proc  
@UnitCostPrecision tinyint,
@TransactionLink tinyint = 1

AS
BEGIN TRY

	CREATE TABLE #PurchReq (
		VendorId pVendorId NULL ,
		ItemId pItemId NULL ,
		ItemType tinyint NULL DEFAULT (0),
		LocId pLocId NULL ,
		Descr pDescription NULL ,
		Qty pDecimal NULL DEFAULT (0),
		UnitCost pDecimal NULL DEFAULT (0),
		ExtCost pDecimal NULL DEFAULT (0),
		Uom pUom NULL ,
		InitDate datetime NULL ,
		EnteredBy pUserID NULL ,
		SourceApp nvarchar (2) NULL ,
		RefId nvarchar (max) NULL ,
		GenerateYn bit NOT NULL DEFAULT (0),
		GlAcct pGlAcct NULL ,
		ReqShipDate datetime NULL ,
		[DropShipYn] bit default(0),
		[SourceType] smallint Null, 
		[LineNum] Int Null, 
		[LinkTransId] [pTransID] NULL ,
		[Seq] Int Null,
		[ReleaseNum] nvarchar(3) Null, 
		[OrderReqId] nvarchar(4) Null,
		[LinkSeqNum] INT NULL, --pointer to trans link record
		[CustId]  pCustId NULL,
		[ProjId] nvarchar(10) NULL,
		[PhaseId] nvarchar(10) NULL,
		[TaskId] nvarchar(10) NULL,
		AddnlDescr nvarchar(max) NULL 
	)
	
	IF (@TransactionLink = 1)
	BEGIN
	
		INSERT INTO #PurchReq ( VendorId, ItemId, LocId, Uom, ItemType, Descr, Qty, 
			ExtCost, InitDate, EnteredBy, SourceApp, RefId, GenerateYn, GlAcct, UnitCost,
			DropShipYn,SourceType,LineNum,LinkTransId,Seq,ReleaseNum,OrderReqId,LinkSeqNum,
			CustId,ProjId,PhaseId,TaskId )
		SELECT VendorId, ItemId, LocId, Uom, Min(ItemType), Min(Descr), Sum(Qty), 
			Sum(ExtCost), Min(InitDate), Min(EnteredBy), Min(SourceApp), Min(RefId), 1, Min(GlAcct), 
			ROUND((CASE WHEN Sum(Qty) <> 0 THEN Sum(Qty * UnitCost)/Sum(Qty) ELSE 0 END), @UnitCostPrecision) ,
			Min(CAST(DropShipYn AS Tinyint)),Min(SourceType),Min(LineNum),Min(LinkTransId),Min(Seq),Min(ReleaseNum),Min(OrderReqId),LinkSeqNum,
			Min(CustId),Min(ProjId),Min(PhaseId),Min(TaskId)
		FROM dbo.tblPoPurchaseReq
		WHERE GenerateYn = 1 AND Seq = 0
		GROUP BY VendorId, ItemId, LocId, Uom, LinkSeqNum
	END
	ELSE
	BEGIN
	
		INSERT INTO #PurchReq ( VendorId, ItemId, LocId, Uom, ItemType, Descr, Qty, 
			ExtCost, InitDate, EnteredBy, SourceApp, RefId, GenerateYn, GlAcct, UnitCost,
			DropShipYn,SourceType,LineNum,LinkTransId,Seq,ReleaseNum,OrderReqId,LinkSeqNum,
			CustId,ProjId,PhaseId,TaskId )
		SELECT VendorId, ItemId, LocId, Uom, Min(ItemType), Min(Descr), Sum(Qty), 
			Sum(ExtCost), Min(InitDate), Min(EnteredBy), Min(SourceApp), Min(RefId), 1, Min(GlAcct), 
			ROUND((CASE WHEN Sum(Qty) <> 0 THEN Sum(Qty * UnitCost)/Sum(Qty) ELSE 0 END), @UnitCostPrecision) ,
			Min(CAST(DropShipYn AS Tinyint)),Min(SourceType),Min(LineNum),Min(LinkTransId),Min(Seq),Min(ReleaseNum),Min(OrderReqId),NULL,
			Min(CustId),Min(ProjId),Min(PhaseId),Min(TaskId)
		FROM dbo.tblPoPurchaseReq
		WHERE GenerateYn = 1 AND Seq = 0
		GROUP BY VendorId, ItemId, LocId, Uom, LinkSeqNum

		UPDATE tblSmTransLink  SET  DestStatus = 1 
		FROM tblSmTransLink link
		INNER JOIN [dbo].[tblPoPurchaseReq] req on link.DestId=req.ReqId 
		WHERE DestStatus = 0  and req.GenerateYn = 1 AND req.Seq = 0
		 
	END

	DELETE dbo.tblPoPurchaseReq 
	WHERE GenerateYn = 1 AND Seq = 0

	INSERT INTO dbo.tblPoPurchaseReq ( VendorId, ItemId, ItemType, LocId, Descr, Qty, UnitCost, ExtCost, 
		Uom, InitDate, EnteredBy, SourceApp, RefId, GenerateYn, GlAcct, ReqShipDate,
		DropShipYn,SourceType,LineNum,LinkTransId,Seq,ReleaseNum,OrderReqId,LinkSeqNum,
		CustId,ProjId,PhaseId,TaskId )
	SELECT VendorId, ItemId, ItemType, LocId, Descr, Qty, UnitCost, ExtCost, 
		Uom, InitDate, EnteredBy, SourceApp, RefId, GenerateYn, GlAcct, ReqShipDate ,
		DropShipYn,SourceType,LineNum,LinkTransId,Seq,ReleaseNum,OrderReqId,LinkSeqNum,
		CustId,ProjId,PhaseId,TaskId
	FROM #PurchReq

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoRequisitionCombine_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoRequisitionCombine_proc';

