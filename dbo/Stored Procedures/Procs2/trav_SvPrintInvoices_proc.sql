
CREATE PROCEDURE dbo.trav_SvPrintInvoices_proc
@LastInvoice pInvoiceNum = NULL, 
@PrintAdditionalDescriptions bit = 0, 
@PrintAllInBase bit = 0, 
@BaseCurrencyId pCurrency = NULL, 
@PlainPaperInvoices bit = 0 

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #TaxSummary
	(
		TransID pTransID, 
		TaxLoc1 pTaxLoc NULL, 
		TaxAmt1 pDecimal, 
		TaxLoc2 pTaxLoc NULL, 
		TaxAmt2 pDecimal, 
		TaxLoc3 pTaxLoc NULL, 
		TaxAmt3 pDecimal, 
		TaxLoc4 pTaxLoc NULL, 
		TaxAmt4 pDecimal, 
		TaxLoc5 pTaxLoc NULL, 
		TaxAmt5 pDecimal, 
		PRIMARY KEY CLUSTERED ([TransID])
	)

	CREATE TABLE #Temp
	( 
		[Counter] int IDENTITY(1,1), 
		TransID pTransID NOT NULL, 
		SoldToID pCustID NOT NULL, 
		DisplayBillingAmountYN bit
		PRIMARY KEY CLUSTERED ([TransID], [SoldToID])
	)

-- creating temp table for testing (will remove once testing is completed)
--CREATE TABLE #tmpTransactionList(TransID pTransID NOT NULL) -- filtered on the selected batches
--INSERT INTO #tmpTransactionList(TransID) SELECT TransID FROM dbo.tblSvInvoiceHeader

	-- process live transactions
	-- build the list of invoices that are valid for printing
	IF (@PlainPaperInvoices <> 0)
	BEGIN
		INSERT INTO #Temp (TransID, SoldToID, DisplayBillingAmountYN) 
		SELECT TransID, SoldToID, DisplayBillingAmountYN 
		FROM
		(
			SELECT h.TransID, h.BillToID AS SoldToID, 1 AS DisplayBillingAmountYN 
			FROM #tmpTransactionList t 
				INNER JOIN dbo.tblSvInvoiceHeader h ON t.TransID = h.TransID 
				INNER JOIN dbo.tblArCust c ON c.CustId = h.BillToID 
			WHERE h.VoidYN = 0 -- exclude voids
				AND (h.PrintStatus = 0 OR h.PrintStatus = 2) 
				AND (c.StmtInvcCode = 2 OR c.StmtInvcCode = 3) 
				AND (h.InvoiceNumber > @LastInvoice OR NULLIF(h.InvoiceNumber, '') IS NULL) 
			UNION ALL
			SELECT h.TransID, h.CustID AS SoldToID, 0 AS DisplayBillingAmountYN 
			FROM #tmpTransactionList t 
				INNER JOIN dbo.tblSvInvoiceHeader h ON t.TransID = h.TransID 
				INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId 
			WHERE h.VoidYN = 0 -- exclude voids
				AND (h.PrintStatus = 0 OR h.PrintStatus = 2) 
				AND (c.StmtInvcCode = 2 OR c.StmtInvcCode = 3) 
				AND (h.InvoiceNumber > @LastInvoice OR NULLIF(h.InvoiceNumber, '') IS NULL) 
				AND h.BillToID <> h.CustID
		) x ORDER BY TransID, DisplayBillingAmountYN DESC
	END
	ELSE
	BEGIN
		INSERT INTO #Temp (TransID, SoldToID, DisplayBillingAmountYN) 
		SELECT h.TransID, h.BillToID AS SoldToID, 1 AS DisplayBillingAmountYN 
		FROM #tmpTransactionList t 
			INNER JOIN dbo.tblSvInvoiceHeader h ON t.TransID = h.TransID 
			INNER JOIN dbo.tblArCust c ON c.CustId = h.BillToID 
		WHERE h.VoidYN = 0 -- exclude voids
			AND (h.PrintStatus = 0 OR h.PrintStatus = 2) 
			AND (c.StmtInvcCode = 2 OR c.StmtInvcCode = 3) 
			AND (h.InvoiceNumber > @LastInvoice OR NULLIF(h.InvoiceNumber, '') IS NULL) 
		ORDER BY TransID
	END

	-- summarize and cross-tab the taxes by level
	--	note: TaxLocId cannot be duplicated for multiple tax levels
	INSERT INTO #TaxSummary (TransID
		, TaxLoc1, TaxAmt1, TaxLoc2, TaxAmt2, TaxLoc3, TaxAmt3, TaxLoc4, TaxAmt4, TaxLoc5, TaxAmt5) 
	SELECT TransID, MAX(TaxLoc1), SUM(TaxAmt1), MAX(TaxLoc2), SUM(TaxAmt2)
		, MAX(TaxLoc3), SUM(TaxAmt3), MAX(TaxLoc4), SUM(TaxAmt4), MAX(TaxLoc5), SUM(TaxAmt5) 
	FROM 
	(
		SELECT x.TransID
			, CASE WHEN x.[Level] = 1 THEN x.TaxLocId ELSE NULL END TaxLoc1
			, CASE WHEN x.[Level] = 1 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END 
				ELSE 0 END TaxAmt1
			, CASE WHEN x.[Level] = 2 THEN x.TaxLocId ELSE NULL END TaxLoc2
			, CASE WHEN x.[Level] = 2 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END 
				ELSE 0 END TaxAmt2
			, CASE WHEN x.[Level] = 3 THEN x.TaxLocId ELSE NULL END TaxLoc3
			, CASE WHEN x.[Level] = 3 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END 
				ELSE 0 END TaxAmt3
			, CASE WHEN x.[Level] = 4 THEN x.TaxLocId ELSE NULL END TaxLoc4
			, CASE WHEN x.[Level] = 4 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END 
				ELSE 0 END TaxAmt4
			, CASE WHEN x.[Level] = 5 THEN x.TaxLocId ELSE NULL END TaxLoc5
			, CASE WHEN x.[Level] = 5 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END 
				ELSE 0 END TaxAmt5 
		FROM #Temp l 
			INNER JOIN dbo.tblSvInvoiceTax x ON l.TransID = x.TransID 
			INNER JOIN dbo.tblSvInvoiceHeader h ON x.TransID = h.TransID 
			INNER JOIN dbo.tblSmTaxGroup s  ON h.TaxGrpID = s.TaxGrpID 
		WHERE s.ReportMethod <> 0
	) ctab 
	GROUP BY TransID
	
	-- add the tax adjustment to the appropriate tax location
	UPDATE #TaxSummary 
		SET TaxAmt1 = TaxAmt1 + CASE WHEN [TaxLoc1] = h.[TaxLocAdj] THEN 
				CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
			, TaxAmt2 = TaxAmt2 + CASE WHEN [TaxLoc2] = h.[TaxLocAdj] THEN 
				CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
			, TaxAmt3 = TaxAmt3 + CASE WHEN [TaxLoc3] = h.[TaxLocAdj] THEN 
				CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
			, TaxAmt4 = TaxAmt4 + CASE WHEN [TaxLoc4] = h.[TaxLocAdj] THEN 
				CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
			, TaxAmt5 = TaxAmt5 + CASE WHEN [TaxLoc5] = h.[TaxLocAdj] THEN 
				CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END 
	FROM dbo.tblSvInvoiceHeader h 
	WHERE h.TaxAmtAdjFgn <> 0 AND #TaxSummary.TransID = h.TransID

	-- retrieve the datasets
	--  header info (Table)
	SELECT tmp.[Counter], h.TransID, tmp.DisplayBillingAmountYN, h.TransType, h.InvoiceDate, h.InvoiceNumber, h.CurrencyID, h.ExchRate
		, ISNULL(w.SiteID, w.CustID) AS CustID
		, CASE WHEN w.SiteID IS NOT NULL THEN s.ShiptoName ELSE c.CustName END AS CustName
		, w.Attention, w.Address1, w.Address2, w.City
		, w.Region, w.PostalCode, w.Country, b.CustId AS BillCustID, b.CustName AS BillCustName
		, b.Attn AS BillAttention, b.Addr1 AS BillAddress1, b.Addr2 AS BillAddress2, b.City AS BillCity
		, b.Region AS BillRegion, b.PostalCode AS BillPostalCode, b.Country AS BillCountry
		, h.Rep1Id, h.Rep2Id, h.NetDueDate, h.DiscDueDate, h.WorkOrderNo AS OrderNo, h.OrderDate, h.CompletedDate
		, t.[Desc] AS TermsDescription, h.CustomerPoNumber, w.FixedPrice, h.BillingFormat
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS ReportCurrencyID
		, x.TaxLoc1 AS TaxLocation1
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 ELSE ISNULL(x.TaxAmt1, 0) END AS TaxAmount1
		, x.TaxLoc2 AS TaxLocation2
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 ELSE ISNULL(x.TaxAmt2, 0) END AS TaxAmount2
		, x.TaxLoc3 AS TaxLocation3
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 ELSE ISNULL(x.TaxAmt3, 0) END AS TaxAmount3
		, x.TaxLoc4 AS TaxLocation4
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 ELSE ISNULL(x.TaxAmt4, 0) END AS TaxAmount4
		, x.TaxLoc5 AS TaxLocation5
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 ELSE ISNULL(x.TaxAmt5, 0) END AS TaxAmount5
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END END AS TaxableSubtotal
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END END AS NontaxableSubtotal
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj 
				ELSE SalesTaxFgn + TaxAmtAdjFgn END END AS SalesTax
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 
				THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) 
					+ ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0) 
				END 
			END AS InvoiceTotal
		, 0 AS Payment
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN h.TransType < 0 -- return 0 for NetDue on Credit Transactions
				THEN 0 
				ELSE CASE WHEN @PrintAllInBase = 1 
					THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) 
						+ ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
					ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) 
						+ ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0) 
					END 
				END 
			END AS NetDue
		, h.SourceId
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvInvoiceHeader h ON tmp.TransID = h.TransID 
		INNER JOIN dbo.tblSvWorkOrder w ON h.WorkOrderID = w.ID 
		INNER JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
		LEFT JOIN dbo.tblArShipTo s ON s.CustId = w.CustID AND s.ShiptoId = w.SiteID 
		INNER JOIN dbo.tblArCust c ON c.CustId = w.CustID 
		INNER JOIN dbo.tblArCust b ON b.CustId = tmp.SoldToID 
		LEFT JOIN #TaxSummary x ON h.TransID = x.TransID 
	ORDER BY h.TransID

	-- detail info (Table1)
	SELECT d.TransID, tmp.DisplayBillingAmountYN, d.EntryNum, d.ResourceID, d.[Description]
		, CASE WHEN @PrintAdditionalDescriptions = 1 THEN d.AdditionalDescription 
			ELSE NULL END AS AdditionalDescription
		, d.TaxClass, d.LocID, d.LineSeq, d.Unit, d.QtyUsed AS QtyShipped, d.QtyEstimated AS QtyOrdered
		, CASE WHEN @PrintAllInBase = 1 THEN d.UnitPrice ELSE d.UnitPriceFgn END AS UnitPrice
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END END AS ExtPrice
		, d.Rep1Id, d.Rep2Id, d.WorkOrderTransID, ISNULL(d.WorkOrderTransType, 99) AS WorkOrderTransType 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvInvoiceHeader h ON tmp.TransID = h.TransID 
		INNER JOIN dbo.tblSvInvoiceDetail d ON tmp.TransID = d.TransID 
		LEFT JOIN dbo.tblSvWorkOrderDispatch w ON d.DispatchID = w.ID 
	WHERE ISNULL(w.CancelledYN, 0) = 0 
	ORDER BY d.TransID, d.LineSeq, d.EntryNum

	-- lot info (Table2)
	SELECT l.TransID, l.LotNum AS LotNo, l.QtyUsed AS Qty 
	FROM (SELECT DISTINCT TransID FROM #Temp) tmp 
		INNER JOIN dbo.tblSvInvoiceDetail d ON tmp.TransID = d.TransID 
		INNER JOIN dbo.tblSvWorkOrderDispatch w ON d.DispatchID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTransExt l ON d.WorkOrderTransID = l.TransID 
	WHERE w.CancelledYN = 0 
	ORDER BY l.LotNum

	-- serial info (Table3)
	SELECT s.TransID, s.LotNum AS LotNo, s.SerNum AS SerNo 
	FROM (SELECT DISTINCT TransID FROM #Temp) tmp 
		INNER JOIN dbo.tblSvInvoiceDetail d ON tmp.TransID = d.TransID 
		INNER JOIN dbo.tblSvWorkOrderDispatch w ON d.DispatchID = w.ID 
		INNER JOIN dbo.tblSvWorkOrderTransSer s ON d.WorkOrderTransID = s.TransID 
	WHERE w.CancelledYN = 0 
	ORDER BY s.LotNum, s.SerNum

	-- work to do detail (Table4)
	SELECT tmp.TransID, w.WorkToDoID, w.[Description] 
	FROM (SELECT DISTINCT TransID FROM #Temp) tmp 
		INNER JOIN dbo.tblSvInvoiceDispatch d ON tmp.TransID = d.TransID 
		INNER JOIN dbo.tblSvWorkOrderDispatchWorkToDo w ON d.DispatchID = w.DispatchID 
	GROUP BY tmp.TransID, w.WorkToDoID, w.[Description]

	-- totals
	SELECT SUM(CASE WHEN tmp.DisplayBillingAmountYN <> 0 THEN 1 ELSE 0 END) AS [InvoicesPrinted]
		, SUM(CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 1 ELSE 0 END) AS [InvoiceCopiesPrinted]
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS [CurrencyID]
		, SUM(SIGN(h.TransType) * CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END END) AS [Taxable]
		, SUM(SIGN(h.TransType) * CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END END) AS [Nontaxable]
		, SUM(SIGN(h.TransType) * CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj 
				ELSE SalesTaxFgn + TaxAmtAdjFgn END END) AS [SalesTax]
		, SUM(SIGN(h.TransType) * 
			CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
				ELSE CASE WHEN @PrintAllInBase = 1 
					THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) 
						+ ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
					ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) 
						+ ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0) 
					END 
				END) AS InvoiceTotal
		, SUM(CASE WHEN h.TransType < 0 -- return 0 for NetDue on Credit Transactions
			THEN 0 
			ELSE CASE WHEN tmp.DisplayBillingAmountYN = 0 
				THEN 0 
				ELSE CASE WHEN @PrintAllInBase = 1 
					THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) 
						+ ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
					ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) 
						+ ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0) 
					END 
				END
			END) AS NetDue 
	FROM #Temp tmp 
		INNER JOIN dbo.tblSvInvoiceHeader h ON tmp.TransID = h.TransID 
	GROUP BY CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvPrintInvoices_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvPrintInvoices_proc';

