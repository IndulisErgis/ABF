
CREATE PROCEDURE dbo.trav_SoBackOrderAllocationReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@ExchRate pDecimal = 1,
@SortBy tinyint = 0 --0, Order Date; 1, Customer ID; 2, Sales Rep; 3, Transaction Number
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpSoBackAllocRpt
	(
		TransId pTransId NOT NULL,
		BatchId pBatchId NULL,
		CustId pCustId NULL, 
		Rep1Id pSalesRep NULL, 
		Rep2Id pSalesRep NULL, 
		TransDate datetime NULL, 
		LocId pLocId NULL, 
		ItemId pItemId NULL, 
		ItemType tinyint NULL DEFAULT (0),
		INItemYN bit NOT NULL DEFAULT (0), 
		BinNum nvarchar(10) NULL, 
		UnitsBase pUOM NULL, 
		QtyBackOrder pDecimal DEFAULT (0), 
		UnitPrice pDecimal DEFAULT (0) 
	)

	CREATE TABLE #tmpItemLoc
	(
		LocId pLocId NULL, 
		LocDescr nvarchar(35) NULL, 
		ItemId pItemId NULL, 
		ItemDescr nvarchar(35) NULL, 
		ItemType tinyint NULL, 
		PriceBase pDecimal DEFAULT (0), 
		QtyOnHand pDecimal DEFAULT (0), 
		QtyAvail pDecimal DEFAULT (0) 
	)


	--insert all non-kit inventory items with backordered quantities (kit item doesn't have quantities)
	--	AND any kit components that are inventory items
	INSERT INTO #tmpSoBackAllocRpt (TransId, BatchId, CustId, Rep1Id, Rep2Id, TransDate
	, LocId, ItemId, ItemType, InItemYn, BinNum, UnitsBase, QtyBackOrder, UnitPrice)
	SELECT h.TransId, h.BatchId, h.CustId, h.Rep1Id, h.Rep2Id
		, CASE WHEN CustPONum IS Null THEN TransDate ELSE PODate END
		, d.LocId, d.ItemId, d.ItemType, d.INItemYN, d.BinNum, UnitsBase
		, CASE WHEN TransType = 3 THEN QtyOrdSell * ConversionFactor ELSE QtyBackordSell * ConversionFactor END
		, CASE WHEN @PrintAllInBase = 0 THEN UnitPriceSellFgn / ConversionFactor Else UnitPriceSell / ConversionFactor End
	FROM dbo.tblSoTransHeader h	INNER JOIN dbo.tblSoTransDetail d ON h.TransID = d.TransID 
		INNER JOIN #tmpTransDetailList l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum
	WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) AND h.VoidYn = 0 AND 
		((h.TransType = 3 AND d.QtyOrdSell <> 0) OR (h.TransType <> 3 AND d.QtyBackordSell <> 0))
		AND d.ItemType <> 0 AND ISNULL(d.Kit, 0) = 0 AND d.Status = 0

	--populate the item info table
	INSERT INTO #tmpItemLoc (LocID, ItemID, ItemType)
	SELECT LocID, ItemID, ItemType 
	FROM #tmpSoBackAllocRpt
	GROUP BY LocID, ItemID, ItemType 

	--Item Description
	UPDATE #tmpItemLoc SET ItemDescr = i.Descr 
	FROM dbo.tblInItem i (NOLOCK) INNER JOIN #tmpItemLoc
	ON i.ItemID = #tmpItemLoc.ItemID

	--Location Description
	UPDATE #tmpItemLoc SET LocDescr = l.Descr 
	FROM dbo.tblInLoc l (NOLOCK) INNER JOIN #tmpItemLoc	ON l.LocID = #tmpItemLoc.LocID

	--PriceBase
	UPDATE #tmpItemLoc 
	SET PriceBase = CASE WHEN @PrintAllInBase = 1 THEN p.PriceBase 
			ELSE p.PriceBase * @ExchRate END
	FROM (#tmpItemLoc t INNER JOIN dbo.tblInItem i (NOLOCK) ON t.ItemID = i.ItemID) 
		INNER JOIN dbo.tblInItemLocUomPrice p (NOLOCK) ON t.ItemID = p.ItemID AND t.LocID = p.LocID AND i.UomBase = p.Uom 
  
	--QtyOnHand
	UPDATE #tmpItemLoc SET QtyOnHand = q.QtyOnHand
	FROM #tmpItemLoc INNER JOIN dbo.trav_InItemOnHand_view q ON #tmpItemLoc.ItemId = q.ItemId AND #tmpItemLoc.LocId = q.LocId

	UPDATE #tmpItemLoc SET QtyOnHand = q.QtyOnHand
	FROM #tmpItemLoc INNER JOIN dbo.trav_InItemOnHandSer_view q ON #tmpItemLoc.ItemId = q.ItemId AND #tmpItemLoc.LocId = q.LocId

	--QtyAvail
	UPDATE #tmpItemLoc SET QtyAvail = QtyOnHand
	WHERE QtyOnHand > 0

	--return resultset
	SELECT CASE @SortBy WHEN 0 THEN CONVERT(nvarchar(8), t.TransDate,112) 
		WHEN 1 THEN t.CustId WHEN 2 THEN t.Rep1Id WHEN 3 THEN t.TransId END SortBy
		, t.TransId, t.BatchId, t.CustId, c.CustName, t.Rep1Id, t.Rep2Id
		, t.TransDate, t.LocId, t.ItemId, t.ItemType, t.INItemYN
		, t.BinNum, t.UnitsBase, t.QtyBackOrder, t.UnitPrice
		, i.LocDescr, i.ItemDescr, i.PriceBase, i.QtyAvail
	FROM #tmpSoBackAllocRpt t LEFT JOIN #tmpItemLoc i ON t.ItemId = i.ItemId AND t.LocId = i.LocId
		LEFT JOIN dbo.tblArCust c ON t.CustId = c.CustId
	WHERE QtyAvail > 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoBackOrderAllocationReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoBackOrderAllocationReport_proc';

