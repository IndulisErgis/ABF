
CREATE PROCEDURE [trav_MpMaterialRequirementsView_proc]

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmp
	(
		OrderNo pTransID, 
		ReleaseNo int, 
		ReqId int, 
		LocId pLocID NULL, 
		ComponentId pItemID NULL, 
		UOM pUom NULL, 
		[Description] pDescription, 
		RequiredDate datetime, 
		QtyReq pDecimal DEFAULT(0), 
		QtyAvail pDecimal DEFAULT(0), 
		QtyOnOrder pDecimal DEFAULT(0), 
		NetRequired pDecimal DEFAULT(0), 
		QtyOrderPoint pDecimal DEFAULT(0) NULL, 
		QtyOrderMin pDecimal DEFAULT(0) NULL, 
		DefaultUOM pUom NULL, 
		DefaultVendorId pVendorID NULL, 
		SalesCat nvarchar(2) NULL, 
		LeadTime pDecimal DEFAULT(0) NULL, 
		ReqType tinyint, 
		ParentId int, 
		TransId int, 
		ParentAssemblyId pItemID, 
		IndLevel int, 
		Step int, 
		QtyOnHand pDecimal DEFAULT(0), 
		QtyCmtd pDecimal DEFAULT(0), 
		ShortYn bit DEFAULT(0), 
		IssuedYn bit DEFAULT(0), 
		DefaultBin nvarchar(10) NULL, 
		IssuedQty pDecimal DEFAULT(0), 
		IssueCompleteYn bit DEFAULT(0), 
		MaxQty pDecimal DEFAULT(0) NULL, 
		ProductLine nvarchar(12), 
		CustId pCustID NULL, 
		SalesOrder nvarchar(8), 
		Notes nvarchar(MAX), 
		NetAvail pDecimal DEFAULT(0), 
		ItemType tinyint
	)

	CREATE TABLE #tmpParent
	(
		OrderNo pTransID, 
		ReleaseNo int, 
		ReqId int, 
		ParentId int, 
		ParentAssemblyId pItemID, 
		ParentType int, 
		ParentTransId int
	)

	INSERT INTO #tmp(OrderNo, ReleaseNo, ReqId, LocId, ComponentId, UOM, [Description], RequiredDate, QtyReq, QtyAvail, QtyOnOrder
		, QtyOrderPoint, QtyOrderMin, DefaultUOM, DefaultVendorId, SalesCat, LeadTime, ReqType, ParentId, TransId
		, ParentAssemblyId, IndLevel, Step, QtyOnHand, QtyCmtd
		, DefaultBin, MaxQty, ProductLine, CustId, SalesOrder, Notes, ItemType) 
	SELECT re.OrderNo, re.ReleaseNo, r.ReqId, m.LocId, m.ComponentId, m.UOM, r.[Description], r.EstStartDate
		, r.Qty AS QtyReq
		, ISNULL(CASE WHEN oh.QtyOnHand IS NULL THEN 0 ELSE oh.QtyOnHand END 
				- CASE WHEN oq.QtyCmtd IS NULL THEN 0 ELSE oq.QtyCmtd END, 0) AS QtyAvail
		, ISNULL(CASE WHEN oq.QtyOnOrder IS NULL THEN 0 ELSE oq.QtyOnOrder END, 0) AS QtyOnOrder
		, l.QtyOrderPoint, l.QtyOrderMin, i.UomDflt AS DefaultUOM, l.DfltVendId AS DefaultVendorId, i.SalesCat
		, l.DfltLeadTime AS LeadTime
		, r.[Type] AS ReqType
		, r.ParentId, r.TransId, NULL AS ParentAssemblyId, r.IndLevel, r.step
		, CASE WHEN oh.QtyOnHand IS NULL THEN 0 ELSE oh.QtyOnHand END AS QtyOnHand
		, CASE WHEN oq.QtyCmtd IS NOT NULL THEN oq.QtyCmtd ELSE 0 END AS QtyCmtd
		, l.DfltBinNum AS DefaultBin, l.QtyOnHandMax AS MaxQty, i.ProductLine, re.CustId, re.SalesOrder
		, re.Notes, CASE WHEN i.ItemId IS NULL THEN 0 ELSE 1 END AS ItemType 
	FROM #tmpOrderReleases t 
		INNER JOIN dbo.tblMpRequirements r ON t.Id = r.ReleaseId 
		LEFT JOIN dbo.tblMpOrderReleases re ON r.ReleaseId = re.Id 
		LEFT JOIN dbo.tblMpMatlSum m ON r.TransId = m.TransId 
		LEFT JOIN dbo.trav_InItemOnHand_view oh ON oh.LocId = m.LocId AND oh.ItemId = m.ComponentId 
		LEFT JOIN dbo.trav_InItemQtys_view oq ON oq.LocId = m.LocId AND oq.ItemId = m.ComponentId 
		LEFT JOIN dbo.tblInItem i ON m.ComponentId = i.ItemId 
		LEFT JOIN dbo.tblInItemLoc l ON m.LocId = l.LocId AND m.ComponentId = l.ItemId 
	WHERE r.[Type] > 1 AND [Type] < 5  ORDER BY r.IndLevel

	--Calculate net required, Note: Add back in qty required since the committed qty will include this amount, then factor in on order
	--NOTE: for non inventoried items, NetAvail should be 0 so that NetRequired equals QtyRequired
	UPDATE #tmp SET NetAvail = CASE WHEN ((QtyAvail + QtyReq) + QtyOnOrder) < 0 THEN 0 
									ELSE ((QtyAvail + QtyReq) + QtyOnOrder) END WHERE ItemType <> 0
	UPDATE #tmp SET NetRequired = ROUND(CASE WHEN NetAvail >= QtyReq THEN 0 ELSE QtyReq - NetAvail END, 2)

	--Set short y/n field
	UPDATE #tmp SET ShortYN = 1 WHERE QtyAvail < 0

	--Calculate issued YN and issues quantity
	UPDATE #tmp SET IssuedYN = 1, IssuedQty = g.Qty, IssueCompleteYn = CASE WHEN g.Qty >= r.QtyReq THEN 1 ELSE 0 END  
	FROM #tmp r 
		INNER JOIN (SELECT TransId, SUM(Qty) AS Qty FROM dbo.tblMpMatlDtl GROUP BY TransId) g ON r.TransId = g.TransId

	--Calculate Parent Assembly ID
	INSERT INTO #tmpParent(OrderNo, ReleaseNo, ReqId, ParentId)
	SELECT r.OrderNo, r.releaseNo, r.ReqId, r.ParentId FROM #tmp r

	UPDATE #tmpParent SET ParentType = req.[Type], ParentId = req.ParentId 
	FROM #tmpParent t INNER JOIN dbo.tblMpRequirements req ON t.ParentId = req.TransId

	UPDATE #tmpParent SET ParentType = req.[Type] 
	FROM #tmpParent t INNER JOIN dbo.tblMpRequirements req ON t.ParentId = req.TransId 
	WHERE t.ParentType = 1

	UPDATE #tmpParent SET ParentAssemblyId = s.ComponentId 
	FROM #tmpParent t INNER JOIN dbo.tblMpMatlSum s ON t.ParentId = s.TransId

	UPDATE #tmp SET ParentAssemblyId = t.ParentAssemblyId 
	FROM #tmp r INNER JOIN #tmpParent t ON t.OrderNo = r.OrderNo AND t.ReqId = r.ReqId

	SELECT * FROM #tmp ORDER BY OrderNo, ReleaseNo, ReqId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpMaterialRequirementsView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpMaterialRequirementsView_proc';

