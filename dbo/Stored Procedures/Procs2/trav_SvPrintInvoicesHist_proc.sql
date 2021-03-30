
CREATE PROCEDURE dbo.trav_SvPrintInvoicesHist_proc
@PrintAdditionalDescriptions bit = 0, 
@PrintAllInBase bit = 0, 
@BaseCurrencyId pCurrency = NULL, 
@PlainPaperInvoices bit = 0,
@PrintByBillTo	bit=1
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #TaxSummary
	(
		TransID pTransID, 
		PostRun pPostRun,
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
		PostRun pPostRun NOT NULL,
		SoldToID pCustID NOT NULL, 
		DisplayBillingAmountYN bit
		PRIMARY KEY CLUSTERED ([TransID], [SoldToID])
	)

	-- build the list of invoices that are valid for printing
	IF (@PlainPaperInvoices <> 0)
	BEGIN
		IF(@PrintByBillTo=1)
		BEGIN
			INSERT INTO #Temp (TransID, PostRun, SoldToID, DisplayBillingAmountYN) 
			SELECT	h.TransID, h.PostRun, h.CustId AS SoldToID, 1 AS DisplayBillingAmountYN 
			FROM	#tmpTransactionList t
					INner join dbo.tblArHistHeader h on t.SourceId = h.SourceId
					INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId
			WHERE	h.VoidYN = 0 -- exclude voids
			ORDER BY TransID, DisplayBillingAmountYN DESC
		END
		ELSE
		BEGIN
			INSERT INTO #Temp (TransID, PostRun, SoldToID, DisplayBillingAmountYN) 
			SELECT	h.TransID, h.PostRun, h.SoldToId AS SoldToID, 0 AS DisplayBillingAmountYN 
			FROM	#tmpTransactionList t 
					INNER JOIN dbo.tblArHistHeader h ON t.SourceId = h.SourceId
					INNER JOIN dbo.tblArCust c ON c.CustId = h.SoldToId
			WHERE	h.VoidYN = 0 -- exclude voids
					AND h.SoldToId <> h.CustID
			ORDER BY TransID, DisplayBillingAmountYN DESC
		END
	END
	ELSE
	BEGIN
		INSERT INTO #Temp (TransID, PostRun, SoldToID, DisplayBillingAmountYN) 
		SELECT	h.TransID, h.PostRun, h.CustId AS SoldToID, 1 AS DisplayBillingAmountYN 
		FROM	#tmpTransactionList t 
				INNER JOIN dbo.tblArHistHeader h ON t.SourceId = h.SourceId 
				INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId
		WHERE	h.VoidYN = 0 -- exclude voids
		ORDER BY h.TransID
	END

	-- summarize and cross-tab the taxes by level
	--	note: TaxLocId cannot be duplicated for multiple tax levels
	INSERT INTO #TaxSummary (TransID, PostRun, TaxLoc1, TaxAmt1, TaxLoc2, TaxAmt2, TaxLoc3, TaxAmt3, TaxLoc4, TaxAmt4, TaxLoc5, TaxAmt5) 
	SELECT TransID, PostRun, MAX(TaxLoc1), SUM(TaxAmt1), MAX(TaxLoc2), SUM(TaxAmt2), MAX(TaxLoc3), SUM(TaxAmt3), MAX(TaxLoc4), SUM(TaxAmt4), MAX(TaxLoc5), SUM(TaxAmt5) 
	FROM 
	(
		SELECT x.TransID, x.PostRun
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
			INNER JOIN dbo.tblArHistTax x ON l.TransID = x.TransID AND l.PostRun = x.PostRun
			INNER JOIN dbo.tblArHistHeader h ON x.TransID = h.TransID AND l.PostRun = h.PostRun
			INNER JOIN dbo.tblSmTaxGroup s  ON h.TaxGrpID = s.TaxGrpID 
		WHERE s.ReportMethod <> 0	
	) ctab 
	GROUP BY TransID, PostRun
	
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
	FROM dbo.tblArHistHeader h 
	WHERE h.TaxAmtAdjFgn <> 0 AND #TaxSummary.TransID = h.TransID AND #TaxSummary.PostRun = h.PostRun

	SELECT WorkOrderID, DispatchID, SourceId INTO #tblSvWorkOrderDispatch FROM (
	SELECT DISTINCT d.WorkOrderID, d.ID [DispatchID], d.SourceId
	FROM tblSvWorkOrderDispatch d INNER JOIN #tmpTransactionList t ON t.SourceId = d.SourceId
	UNION ALL
	SELECT DISTINCT d.WorkOrderID, d.ID [DispatchID], d.SourceId
	FROM tblSvHistoryWorkOrderDispatch d INNER JOIN #tmpTransactionList t ON t.SourceId = d.SourceId) d

	SELECT	ID, PostRun, WorkOrderNo, SiteID, CustID, Attention, Address1, Address2, City, Region, PostalCode, Country, FixedPrice, BillingFormat
	INTO #tblSvWorkOrder FROM (
	SELECT	ID, NULL [PostRun], WorkOrderNo, SiteID, CustID, Attention, Address1, Address2, City, Region, PostalCode, Country, FixedPrice, BillingFormat
	FROM	tblSvWorkOrder WHERE ID IN (SELECT DISTINCT WorkOrderID FROM #tblSvWorkOrderDispatch)
	UNION ALL
	SELECT ID, PostRun, WorkOrderNo, SiteID, CustID, Attention, Address1, Address2, City, Region, PostalCode, Country, FixedPrice, BillingFormat
	FROM	tblSvHistoryWorkOrder WHERE ID IN (SELECT DISTINCT WorkOrderID FROM #tblSvWorkOrderDispatch)) w

	SELECT WorkOrderID, CompletedDate INTO #tblSvWorkOrderActivity FROM (
	SELECT WorkOrderID, MAX(ActivityDateTime) CompletedDate FROM tblSvWorkOrderActivity WHERE ActivityType = 4 and WorkOrderID IN (SELECT DISTINCT ID FROM #tblSvWorkOrder)
	GROUP BY WorkOrderID
	UNION ALL
	SELECT WorkOrderID, MAX(ActivityDateTime) CompletedDate FROM tblSvHistoryWorkOrderActivity WHERE ActivityType = 4 and WorkOrderID IN (SELECT DISTINCT ID FROM #tblSvWorkOrder)
	GROUP BY WorkOrderID) a

	SELECT DispatchID, WorkOrderID, WorkToDoID, [Description] INTO #tblSvWorkOrderDispatchWorkToDo FROM (
	SELECT DispatchID, WorkOrderID, WorkToDoID, [Description] FROM tblSvWorkOrderDispatchWorkToDo WHERE DispatchID IN (SELECT DISTINCT DispatchID FROM #tblSvWorkOrderDispatch)
	UNION ALL
	SELECT DispatchID, WorkOrderID, WorkToDoID, [Description] FROM tblSvHistoryWorkOrderDispatchWorkToDo WHERE DispatchID IN (SELECT DISTINCT DispatchID FROM #tblSvWorkOrderDispatch)) wd

	SELECT WorkOrderTransID, DispatchID, EntryNum, TransType INTO #tblSvWorkOrderTrans FROM (
	SELECT ID [WorkOrderTransID], DispatchID, EntryNum, TransType FROM tblSvWorkOrderTrans WHERE DispatchID IN (SELECT DISTINCT DispatchID FROM #tblSvWorkOrderDispatch)
	UNION ALL
	SELECT ID [WorkOrderTransID], DispatchID, EntryNum, TransType FROM tblSvHistoryWorkOrderTrans WHERE DispatchID IN (SELECT DISTINCT DispatchID FROM #tblSvWorkOrderDispatch)) t

	SELECT TransID, LotNum, QtyUsed INTO #tblSvWorkOrderTransExt FROM (
	SELECT TransID, LotNum, QtyUsed FROM tblSvWorkOrderTransExt WHERE TransID IN (SELECT DISTINCT WorkOrderTransID FROM #tblSvWorkOrderTrans)
	UNION ALL
	SELECT TransID, LotNum, QtyUsed FROM tblSvHistoryWorkOrderTransExt WHERE TransID IN (SELECT DISTINCT WorkOrderTransID FROM #tblSvWorkOrderTrans)) x

	SELECT TransID, LotNum, SerNum INTO #tblSvWorkOrderTransSer FROM (
	SELECT TransID, LotNum, SerNum  FROM tblSvWorkOrderTransSer WHERE TransID IN (SELECT DISTINCT WorkOrderTransID FROM #tblSvWorkOrderTrans)
	UNION ALL
	SELECT TransID, LotNum, SerNum  FROM tblSvHistoryWorkOrderTransSer WHERE TransID IN (SELECT DISTINCT WorkOrderTransID FROM #tblSvWorkOrderTrans)) s

	-- retrieve the datasets
	--  header info (Table)
	SELECT tmp.[Counter], h.TransID, tmp.DisplayBillingAmountYN, h.TransType, h.InvcDate [InvoiceDate], h.InvcNum [InvoiceNumber], h.CurrencyID, h.ExchRate
			, ISNULL(w.SiteID, w.CustID) AS CustID
			, CASE WHEN w.SiteID IS NOT NULL THEN s.ShiptoName ELSE c.CustName END AS CustName
			, w.Attention, w.Address1, w.Address2, w.City
			, w.Region, w.PostalCode, w.Country, b.CustId AS BillCustID, b.CustName AS BillCustName
			, b.Attn AS BillAttention, b.Addr1 AS BillAddress1, b.Addr2 AS BillAddress2, b.City AS BillCity
			, b.Region AS BillRegion, b.PostalCode AS BillPostalCode, b.Country AS BillCountry
			, h.Rep1Id, h.Rep2Id, h.NetDueDate, h.DiscDueDate, w.WorkOrderNo AS OrderNo, h.OrderDate, a.CompletedDate
			, t.[Desc] AS TermsDescription, h.CustPONum [CustomerPoNumber], w.FixedPrice, w.BillingFormat
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
		FROM #Temp tmp 
			INNER JOIN dbo.tblArHistHeader h ON tmp.TransID = h.TransID AND tmp.PostRun = h.PostRun
			INNER JOIN (SELECT DISTINCT WorkOrderID, SourceId FROM #tblSvWorkOrderDispatch) d ON h.SourceId = d.SourceId
			INNER JOIN #tblSvWorkOrder w ON d.WorkOrderID = w.ID 
			LEFT JOIN #tblSvWorkOrderActivity a ON w.ID = a.WorkOrderID
			LEFT JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
			LEFT JOIN dbo.tblArShipTo s ON s.CustId = w.CustID AND s.ShiptoId = w.SiteID 
			LEFT JOIN dbo.tblArCust c ON c.CustId = w.CustID 
			LEFT JOIN dbo.tblArCust b ON b.CustId = tmp.SoldToID 
			LEFT JOIN #TaxSummary x ON h.TransID = x.TransID 
		ORDER BY h.TransID

	-- detail info (Table1)
	SELECT d.TransID, tmp.DisplayBillingAmountYN, d.EntryNum, d.PartId [ResourceID], d.[Desc] AS [Description]
		, CASE WHEN @PrintAdditionalDescriptions = 1 THEN d.AddnlDesc 
			ELSE NULL END AS AdditionalDescription
		, d.TaxClass, d.WhseId [LocID], d.LineSeq, d.UnitsSell [Unit], d.QtyShipSell [QtyShipped], d.QtyOrdSell [QtyOrdered]
		, CASE WHEN @PrintAllInBase = 1 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END AS UnitPrice
		, CASE WHEN tmp.DisplayBillingAmountYN = 0 THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE d.PriceExtFgn END END AS ExtPrice
		, d.Rep1Id, d.Rep2Id, wt.WorkOrderTransID, ISNULL(wt.TransType, 99) AS WorkOrderTransType 
	FROM #Temp tmp 
		INNER JOIN dbo.tblArHistHeader h ON tmp.TransID = h.TransID AND tmp.PostRun = h.PostRun
		INNER JOIN dbo.tblArHistDetail d ON h.TransId = d.TransID AND tmp.PostRun = d.PostRun
		INNER JOIN #tblSvWorkOrderDispatch p ON h.SourceId = p.SourceId 
		INNER JOIN #tblSvWorkOrderTrans wt ON p.DispatchID = wt.DispatchID AND d.EntryNum = wt.EntryNum 
	WHERE d.EntryNum > 0 AND d.Status <> 1	
	ORDER BY d.TransID, d.LineSeq, d.EntryNum

	-- lot info (Table2)
	SELECT l.TransID, l.LotNum AS LotNo, l.QtyUsed AS Qty 
	FROM (SELECT DISTINCT TransID, PostRun FROM #Temp) tmp 
		INNER JOIN dbo.tblArHistHeader h ON tmp.TransID = h.TransID AND tmp.PostRun = h.PostRun
		INNER JOIN dbo.tblArHistDetail d ON h.TransId = d.TransID 
		INNER JOIN #tblSvWorkOrderDispatch w ON h.SourceId = w.SourceId
		INNER JOIN #tblSvWorkOrderTrans t ON w.DispatchID = t.DispatchID AND d.EntryNum = t.EntryNum
		INNER JOIN #tblSvWorkOrderTransExt l ON t.WorkOrderTransID = l.TransID 
	WHERE d.EntryNum > 0 AND d.Status <> 1
	ORDER BY l.LotNum

	-- serial info (Table3)
	SELECT s.TransID, s.LotNum AS LotNo, s.SerNum AS SerNo 
	FROM (SELECT DISTINCT TransID, PostRun FROM #Temp) tmp 
		INNER JOIN dbo.tblArHistHeader h ON tmp.TransID = h.TransID AND tmp.PostRun = h.PostRun
		INNER JOIN dbo.tblArHistDetail d ON h.TransId = d.TransID 
		INNER JOIN #tblSvWorkOrderDispatch w ON h.SourceId = w.SourceId
		INNER JOIN #tblSvWorkOrderTrans t ON w.DispatchID = t.DispatchID AND d.EntryNum = t.EntryNum
		INNER JOIN #tblSvWorkOrderTransSer s ON t.WorkOrderTransID = s.TransID 
	WHERE d.EntryNum > 0 AND d.Status <> 1
	ORDER BY s.LotNum, s.SerNum

	-- work to do detail (Table4)
	SELECT tmp.TransID, w.WorkToDoID, w.[Description] 
	FROM (SELECT DISTINCT TransID, PostRun FROM #Temp) tmp 
		INNER JOIN dbo.tblArHistHeader  h ON tmp.TransID = h.TransID AND tmp.PostRun = h.PostRun
		INNER JOIN #tblSvWorkOrderDispatch d ON h.SourceId = d.SourceId
		INNER JOIN #tblSvWorkOrderDispatchWorkToDo w ON d.DispatchID = w.DispatchID 
	GROUP BY tmp.TransID, w.WorkToDoID, w.[Description]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvPrintInvoicesHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvPrintInvoicesHist_proc';

