
CREATE PROCEDURE dbo.trav_SoOpenOrderReport_proc 
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@PrintNew bit = 1,
@PrintPicked bit = 0,
@PrintVerified bit = 0,
@PrintCredited bit = 0,
@PrintBackordered bit = 0,
@PrintQuoted bit = 0,
@PrintRMA bit = 0,
@PrintKitDetail bit = 0,
@CurrencyPrecision tinyint = 2,
@SortBy tinyint = 0 --0, Customer ID; 1, Invoice Number; 2, Item ID; 3, Trans Type; 4, Req Ship Date
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #Tmp
	(
		TransId pTransId NOT NULL, 
		TransType smallint NOT NULL, 
		BatchId pBatchId NOT NULL, 
		InvcNum pInvoiceNum NULL, 
		EntryNum smallint NOT NULL, 
		CustId pCustId NULL, 
		Rep1Id pSalesRep NULL, 
		Rep2Id pSalesRep NULL, 
		TransDate datetime NULL, 
		ReqShipDate datetime NULL, 
		ActShipDate datetime NULL, 
		ItemJob tinyint NULL, 
		LocId pLocId NULL, 
		ItemId pItemId NULL, 
		Descr nvarchar (255) NULL, 
		UnitsSell pUom NULL, 
		GrpId int NULL, 
		Kit bit NULL, 
		KitComponent bit NULL, 
		UnitPriceSell pDecimal NULL, 
		OrigOrderQty pDecimal NULL, 
		QtyOrdSell pDecimal NULL, 
		QtyShipSell pDecimal NULL, 
		QtyBackordSell pDecimal NULL, 
		CurrencyId pCurrency NULL, 
		CurrMask nvarchar (50) NULL, 
		InItemYn bit NULL, 
		ConversionFactor pDecimal NULL, 
		ItemType tinyint NULL, 
		LottedYn bit NULL,
		LineSeq INT NULL
	)

	CREATE TABLE #tmpInQtyOnHand
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyOnHand pDecimal NOT NULL
	)

	CREATE TABLE #tmpInQtyCmtd
	(
		ItemId pItemId NOT NULL,
		LocId pLocId NOT NULL,
		QtyCmtd pDecimal NOT NULL
	)
	
	--Serial OnHand
	INSERT INTO #tmpInQtyOnHand(ItemId, LocId, QtyOnHand)
	SELECT DISTINCT q.ItemId, q.LocId, q.QtyOnHand
	FROM #tmpTransDetailList t INNER JOIN dbo.tblSoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum 
		INNER JOIN dbo.trav_InItemOnHandSer_view q ON d.ItemId = q.ItemId AND d.LocId = q.LocId 

	-- Regular OnHand
	INSERT INTO #tmpInQtyOnHand(ItemId, LocId, QtyOnHand)
	SELECT DISTINCT q.ItemId, q.LocId, q.QtyOnHand
	FROM #tmpTransDetailList t INNER JOIN dbo.tblSoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum 
		INNER JOIN dbo.trav_InItemOnHand_view q ON d.ItemId = q.ItemId AND d.LocId = q.LocId 

	-- Cmtd
	INSERT INTO #tmpInQtyCmtd(ItemId, LocId, QtyCmtd)
	SELECT DISTINCT q.ItemId, q.LocId, q.QtyCmtd
	FROM #tmpTransDetailList t INNER JOIN dbo.tblSoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum  
		INNER JOIN dbo.trav_InItemQtys_view q ON d.ItemId = q.ItemId AND d.LocId = q.LocId 

	-- capture all non-kit component records
	INSERT INTO #tmp (TransId, TransType, BatchId, InvcNum, EntryNum, CustId, Rep1Id, Rep2Id
	, TransDate, ReqShipDate, ActShipDate, ItemJob, LocId, ItemId, Descr, UnitsSell
	, GrpId, Kit, KitComponent, UnitPriceSell, OrigOrderQty, QtyOrdSell, QtyShipSell, QtyBackordSell
	, CurrencyId, CurrMask, InItemYn, ConversionFactor, ItemType, LottedYn, LineSeq) 
	SELECT h.TransId, h.TransType, h.BatchId, h.InvcNum, d.EntryNum, h.CustId AS CustId, h.Rep1Id, h.Rep2Id
		, h.TransDate, CASE WHEN d.ReqShipDate IS NULL THEN h.ReqShipDate ELSE d.ReqShipDate END
		, h.ActShipDate, d.ItemJob, d.LocId, d.ItemId, d.Descr, d.UnitsSell
		, d.GrpId, d.Kit, 0, CASE WHEN @PrintAllInBase = 1 THEN UnitPriceSell ELSE UnitPriceSellFgn END
		, d.OrigOrderQty, d.QtyOrdSell, d.QtyShipSell, d.QtyBackordSell, '', '', d.InItemYn, d.ConversionFactor, d.ItemType, d.LottedYn 
		, d.LineSeq
	FROM dbo.tblSoTransHeader h INNER JOIN #tmpTransDetailList l ON h.TransId = l.TransId
		LEFT JOIN dbo.tblSoTransDetail d ON l.TransID = d.TransId AND l.EntryNum = d.EntryNum 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency)  AND 
		((h.TransType = CASE WHEN @PrintNew = 1 THEN 9 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintPicked = 1 THEN 5 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintVerified = 1 THEN 4 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintVerified = 1 THEN 1 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintCredited = 1 THEN -1 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintBackOrdered = 1 THEN 3 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintQuoted = 1 THEN 2 ELSE 0 END) 
			OR (h.TransType = CASE WHEN @PrintRMA = 1 THEN -2 ELSE 0 END) )
		AND h.VoidYn = 0 AND d.GrpId IS NULL AND d.Status = 0

	-- add kit components for any detail records that were included
	IF @PrintKitDetail = 1
	BEGIN
		INSERT INTO #tmp (TransId, TransType, BatchId, InvcNum, EntryNum, CustId, Rep1Id, Rep2Id
			, TransDate, ReqShipDate, ActShipDate, ItemJob, LocId, ItemId, Descr, UnitsSell
			, GrpId, Kit, KitComponent, UnitPriceSell, OrigOrderQty, QtyOrdSell, QtyShipSell, QtyBackordSell
			, CurrencyId, CurrMask, InItemYn, ConversionFactor, ItemType, LottedYn, LineSeq) 
		SELECT h.TransId, h.TransType, h.BatchId, h.InvcNum, d.EntryNum, h.CustId AS CustId, h.Rep1Id, h.Rep2Id
			, h.TransDate, CASE WHEN d.ReqShipDate IS NULL THEN h.ReqShipDate ELSE d.ReqShipDate END
			, h.ActShipDate, d.ItemJob, d.LocId, d.ItemId, d.Descr, d.UnitsSell, d.GrpId, d.Kit, 1, 0
			, d.OrigOrderQty, d.QtyOrdSell, d.QtyShipSell, d.QtyBackordSell, h.CurrencyId, h.CurrMask, d.InItemYn
			, d.ConversionFactor, d.ItemType, d.LottedYn 
			, d.LineSeq
		FROM #tmp h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID AND h.EntryNum = d.GrpId 
		WHERE h.Kit = 1 AND NOT(d.GrpId IS NULL) AND d.Status = 0
	END

	-- return the resultset
	SELECT CASE @SortBy WHEN 0 THEN t.CustId WHEN 1 THEN t.InvcNum WHEN 2 THEN t.ItemId WHEN 3 THEN CAST(t.TransType AS nvarchar)
		WHEN 4 THEN CONVERT(nvarchar(8), t.ReqShipDate,112) END SortBy,
		t.TransId, t.TransType, t.BatchId, t.InvcNum, t.EntryNum, t.CustId, t.Rep1Id, t.Rep2Id,
		t.TransDate, t.ReqShipDate, t.ActShipDate, t.ItemJob, t.LocId, t.ItemId, t.Descr,
		(ISNULL(o.QtyOnHand,0) - ISNULL(q.QtyCmtd,0))/t.ConversionFactor AS QtyAvail, t.UnitsSell, t.GrpId, 
		t.KitComponent, t.UnitPriceSell, t.OrigOrderQty * SIGN(t.TransType) OrigOrderQty,
		t.QtyOrdSell * SIGN(t.TransType) QtyOrdSell, t.QtyShipSell * SIGN(t.TransType) QtyShipSell,
		t.QtyBackordSell * SIGN(t.TransType) QtyBackordSell,
		ROUND(t.OrigOrderQty * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS OrigOrderAmt1,
		ROUND(t.QtyOrdSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS AmtOrdSell1,
		ROUND(t.QtyShipSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS AmtShipSell1,
		ROUND(t.QtyBackordSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS AmtBackOrdSell1,
		ROUND(t.OrigOrderQty * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS SubOrigOrderAmt1,
		ROUND(t.QtyOrdSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS SubAmtOrdSell1,
		ROUND(t.QtyShipSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS SubAmtShipSell1,
		ROUND(t.QtyBackordSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS SubAmtBackordSell1,
		ROUND(t.OrigOrderQty * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS GrandOrigOrderAmt1,
		ROUND(t.QtyOrdSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS GrandAmtOrdSell1,
		ROUND(t.QtyShipSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS GrandAmtShipSell1,
		ROUND(t.QtyBackordSell * t.UnitPriceSell, @CurrencyPrecision ) * SIGN(t.TransType) AS GrandAmtBackordSell1,
		t.InItemYn, t.ConversionFactor, t.ItemType, t.LottedYn, t.LineSeq
	FROM  #tmp t LEFT JOIN #tmpInQtyOnHand o ON t.ItemId = o.ItemId AND t.LocId = o.LocId
		LEFT JOIN #tmpInQtyCmtd q ON t.ItemId = q.ItemId AND t.LocId = q.LocId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoOpenOrderReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoOpenOrderReport_proc';

