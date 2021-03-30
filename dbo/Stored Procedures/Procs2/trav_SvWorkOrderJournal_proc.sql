
CREATE PROCEDURE dbo.trav_SvWorkOrderJournal_proc
@SortBy tinyint = 0, -- 0 = Batch Code, 1 = Customer ID, 2 = Work Order Number, 3 = Invoice Number
@ViewAdditionalDescription bit = 0, 
@ViewSummary tinyint = 0, 
@PrintAllInBase bit = 1, 
@ReportCurrency pCurrency = NULL

AS
BEGIN TRY
	SET NOCOUNT ON
-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpTransactionList(TransID pTransID NOT NULL) -- filtered on the selected batches
--INSERT INTO #tmpTransactionList(TransID) SELECT TransID FROM dbo.tblSvInvoiceHeader

	CREATE TABLE #Temp
	(
		TransID pTransID NOT NULL
	)

	INSERT INTO #Temp (TransID) 
	SELECT h.TransId 
	FROM #tmpTransactionList t 
		INNER JOIN dbo.tblSvInvoiceHeader h ON t.TransID = h.TransID 
		INNER JOIN dbo.tblArCust c ON c.CustId = h.CustID 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency) AND h.VoidYN = 0 AND h.HoldYN = 0

	-- main report resultset (Table)
	SELECT CASE @SortBy 
			WHEN 0 THEN CAST(h.BatchID AS nvarchar) 
			WHEN 1 THEN CAST(h.CustID AS nvarchar) 
			WHEN 2 THEN CAST(w.WorkOrderNo AS nvarchar) 
			WHEN 3 THEN CAST(h.InvoiceNumber AS nvarchar) END AS GrpID1
		, h.BatchID, h.TransID, h.TransType, h.CustID, c.CustName, h.TermsCode, h.InvoiceNumber
		, h.CustomerPoNumber, h.OrderDate, h.InvoiceDate, h.CompletedDate, h.Rep1Id, h.Rep1Pct
		, h.Rep2Id, h.Rep2Pct, h.FiscalPeriod, h.FiscalYear, h.TaxGrpID, h.ExchRate
		, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS Taxable
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS Nontaxable
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal + NonTaxSubtotal + SalesTax + TaxAmtAdj 
			ELSE TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn + TaxAmtAdjFgn END AS InvTotal
		, tmp.ExtPrice, tmp.ExtCost
		, w.WorkOrderNo, w.SiteID 
	FROM dbo.tblSvInvoiceHeader h 
		INNER JOIN #Temp t ON h.TransID = t.TransID 
		LEFT JOIN dbo.tblArCust c ON h.CustID = c.CustId 
		LEFT JOIN dbo.tblSvWorkOrder w ON h.WorkOrderID = w.ID 
		LEFT JOIN
		(
			SELECT d.TransID
				, SUM(CASE WHEN @PrintAllInBase = 1 THEN PriceExt ELSE PriceExtFgn END) AS ExtPrice
				, SUM(CASE WHEN @PrintAllInBase = 1 THEN CostExt ELSE CostExtFgn END) AS ExtCost 
			FROM dbo.tblSvInvoiceDetail d 
				INNER JOIN #Temp t ON d.TransID = t.TransID GROUP BY d.TransID
		) tmp ON t.TransID = tmp.TransID

	-- detail report resultset (Table1)
	SELECT d.TransID, d.WorkOrderTransID, d.EntryNum, d.ResourceID
		, d.LocID, d.[Description]
		, CASE WHEN @ViewAdditionalDescription <> 0 
			THEN d.AdditionalDescription ELSE NULL END AS AdditionalDescription
		, d.TaxClass, ISNULL(d.WorkOrderTransType, 99) AS WorkOrderTransType, d.QtyEstimated, d.QtyUsed
		, d.GLAcctSales, d.GLAcctDebit, d.GLAcctCredit, d.Unit
		, CASE WHEN @PrintAllInBase = 1 THEN UnitPrice ELSE UnitPriceFgn END AS UnitPrice
		, CASE WHEN @PrintAllInBase = 1 THEN PriceExt ELSE PriceExtFgn END AS ExtPrice
		, CASE WHEN @PrintAllInBase = 1 THEN UnitCost ELSE UnitCostFgn END AS UnitCost
		, CASE WHEN @PrintAllInBase = 1 THEN CostExt ELSE CostExtFgn END AS ExtCost
		, d.LineSeq 
	FROM dbo.tblSvInvoiceDetail d
		INNER JOIN #Temp t ON d.TransID = t.TransID
	WHERE @ViewSummary = 0

	-- lot detail resultset (Table2)
	SELECT l.TransID, l.LotNum AS LotNo,  CASE WHEN t.TransType = 5 THEN (-1)*l.QtyUsed ELSE l.QtyUsed END AS Qty
		, CASE WHEN @PrintAllInBase = 1 THEN l.UnitCost 
			ELSE (l.UnitCost * h.ExchRate) END AS UnitCost 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvInvoiceHeader h ON tmp.TransID = h.TransID 
		INNER JOIN dbo.tblSvInvoiceDetail d ON tmp.TransID = d.TransID 
		INNER JOIN dbo.tblSvWorkOrderDispatch w ON d.DispatchID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTransExt l ON d.WorkOrderTransID = l.TransID 
		INNER JOIN dbo.tblSvWorkOrderTrans t ON l.TransID = t.ID
	WHERE @ViewSummary = 0 AND w.CancelledYN = 0 
	ORDER BY l.LotNum

	-- serial detail resultset (Table3)
	SELECT s.TransID, s.LotNum AS LotNo, s.SerNum AS SerNo
		, CASE WHEN @PrintAllInBase = 1 THEN s.UnitCost 
			ELSE (s.UnitCost * h.ExchRate) END AS UnitCost 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvInvoiceHeader h ON tmp.TransID = h.TransID 
		INNER JOIN dbo.tblSvInvoiceDetail d ON tmp.TransID = d.TransID 
		INNER JOIN dbo.tblSvWorkOrderDispatch w ON d.DispatchID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTransSer s ON d.WorkOrderTransID = s.TransID 
	WHERE @ViewSummary = 0 AND w.CancelledYN = 0 
	ORDER BY s.LotNum, s.SerNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderJournal_proc';

