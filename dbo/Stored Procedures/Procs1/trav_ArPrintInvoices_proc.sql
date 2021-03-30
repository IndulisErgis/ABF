
CREATE PROCEDURE dbo.trav_ArPrintInvoices_proc
@LastInvoice pInvoiceNum = null, --set for batch mode printing
@ProjectInvoices bit = 0,  --set when printing project costing invoices (batch mode)
@TransId pTransId = null, --set for printing online or from history
@PrintAdditionalDescription bit = 0, --set for printing additional descriptions
@PrintAllInBase bit = 1,
@BaseCurrencyId pCurrency = null
AS
SET NOCOUNT ON
BEGIN TRY
	CREATE TABLE #TaxSummary
	(
		TransId pTransId,
		TaxLoc1 pTaxLoc null,
		TaxAmt1 pDecimal, 
		TaxLoc2 pTaxLoc null,
		TaxAmt2 pDecimal, 
		TaxLoc3 pTaxLoc null,
		TaxAmt3 pDecimal, 
		TaxLoc4 pTaxLoc null,
		TaxAmt4 pDecimal, 
		TaxLoc5 pTaxLoc null,
		TaxAmt5 pDecimal, 
		PRIMARY KEY CLUSTERED ([TransId])
	)

	CREATE TABLE #Temp
	( 
		TransId pTransId NOT NULL
		PRIMARY KEY CLUSTERED ([TransId])
	)	
	
	--process live transactions
	IF (ISNULL(@TransId, '') = '')
	BEGIN
		--build the list of Invoices that are valid for printing
		INSERT INTO #Temp (TransId)
		SELECT h.TransId
		FROM #tmpTransactionList t
			INNER JOIN dbo.tblArTransHeader h on t.TransId = h.TransId
			INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId
		WHERE h.VoidYn = 0 --exclude voids
			AND (h.PrintStatus = 0 Or h.PrintStatus = 2) 
			AND (c.StmtInvcCode = 3 Or c.StmtInvcCode = 2) 
			AND (h.InvcNum > @LastInvoice or NULLIF(h.InvcNum, '') Is Null) 
			AND ((@ProjectInvoices = 0 AND (h.ProjItem <> 'PR' Or h.ProjItem Is Null)) OR (@ProjectInvoices = 1 AND (h.ProjItem = 'PR')))
	END
	ELSE
	BEGIN
		--select only one transaction for online processing
		INSERT INTO #Temp (TransId) 
		SELECT h.TransId
		FROM dbo.tblArTransHeader h 
		WHERE h.TransId = @TransId
			AND h.VoidYn = 0 --exclude voids
			AND ((@ProjectInvoices = 0 AND (h.ProjItem <> 'PR' Or h.ProjItem Is Null)) OR (@ProjectInvoices = 1 AND (h.ProjItem = 'PR')))
	END

	--summarize and cross-tab the taxes by level 
	--	note: TaxLocId cannot be duplicated for multiple tax levels
	INSERT INTO #TaxSummary (TransId
		, TaxLoc1, TaxAmt1, TaxLoc2, TaxAmt2, TaxLoc3, TaxAmt3, TaxLoc4, TaxAmt4, TaxLoc5, TaxAmt5)
	SELECT TransId, Max(TaxLoc1), Sum(TaxAmt1), Max(TaxLoc2), Sum(TaxAmt2)
		, Max(TaxLoc3), Sum(TaxAmt3), Max(TaxLoc4), Sum(TaxAmt4), Max(TaxLoc5), Sum(TaxAmt5)
	FROM (SELECT x.TransId
			, CASE WHEN x.[Level] = 1 THEN x.TaxLocId ELSE NULL END TaxLoc1
			, CASE WHEN x.[Level] = 1 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt1
			, CASE WHEN x.[Level] = 2 THEN x.TaxLocId ELSE NULL END TaxLoc2
			, CASE WHEN x.[Level] = 2 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt2
			, CASE WHEN x.[Level] = 3 THEN x.TaxLocId ELSE NULL END TaxLoc3
			, CASE WHEN x.[Level] = 3 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt3
			, CASE WHEN x.[Level] = 4 THEN x.TaxLocId ELSE NULL END TaxLoc4
			, CASE WHEN x.[Level] = 4 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt4
			, CASE WHEN x.[Level] = 5 THEN x.TaxLocId ELSE NULL END TaxLoc5
			, CASE WHEN x.[Level] = 5 THEN CASE WHEN @PrintAllInBase = 1 THEN x.TaxAmt ELSE x.TaxAmtFgn END ELSE 0 END TaxAmt5
		FROM #Temp l
		INNER JOIN dbo.tblArTransTax x ON l.TransId = x.TransId
		INNER JOIN dbo.tblArTransHeader h ON x.TransId = h.TransId
		INNER JOIN dbo.tblSmTaxGroup s  ON h.TaxGrpID = s.TaxGrpID
		WHERE s.ReportMethod <> 0) ctab
	GROUP BY TransId
	
	--Add the tax adjustment to the appropriate tax location
	UPDATE #TaxSummary 
		Set TaxAmt1 = TaxAmt1 + CASE WHEN [TaxLoc1] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt2 = TaxAmt2 + CASE WHEN [TaxLoc2] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt3 = TaxAmt3 + CASE WHEN [TaxLoc3] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt4 = TaxAmt4 + CASE WHEN [TaxLoc4] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt5 = TaxAmt5 + CASE WHEN [TaxLoc5] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
	FROM dbo.tblArTransHeader h 
		WHERE h.TaxAmtAdjFgn <> 0
		AND #TaxSummary.TransId = h.TransId
	

	--retrieve the datasets
	-- header info
	SELECT c.CustId, c.Attn, c.Contact, c.CustName, c.Addr1, c.Addr2, c.City, c.Region
		, c.Country, c.PostalCode, c.Phone, c.Fax, c.Email, c.Internet, c.CustId AS BillCustId
		, c.CustName AS BillCustName, c.Addr1 AS BillAddr1, c.Addr2 AS BillAddr2, c.City AS BillCity
		, c.Region AS BillRegion, c.Country AS BillCountry, c.PostalCode AS BillPostalCode
		, c.IntlPrefix BillIntlPrefix, c.Phone AS BillPhone, c.Fax AS BillFax, c.Email AS BillEmail
		, c.Internet AS BillInternet, c.Attn AS BillAttn, c.Contact AS BillContact, h.ShipToID, h.ShipToName, h.ShipToAddr1
		, h.ShipToAddr2, h.ShipToCity, h.ShipToCountry, h.ShipToRegion, h.ShipToPostalCode
		, h.ShipVia, h.ShipToAttn , Ship.Phone AS ShipToPhone, Ship.Fax AS ShipToFax
		, Ship.Email AS ShipToEmail, Ship.Internet AS ShipToInternet
		, t.[Desc] AS TermsDescription, h.TransType, h.OrderDate
		, h.ShipDate AS [RequestedShipDate], h.ShipDate, h.ShipNum AS ShipNo, h.InvcDate AS InvoiceDate, h.Rep1Id, h.Rep2Id
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS ReportCurrencyId
		, CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxableSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NontaxableSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS Freight
		, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS Misc
		, CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN pmt.PaymentTotalFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) ELSE ISNULL(pmt.PaymentTotal, 0) END ELSE ISNULL(pmt.PaymentTotalFgn, 0) END AS TotalPayment
		, h.CustPONum AS CustomerPoNo, h.CurrencyID AS CurrencyId
		, h.InvcNum AS InvoiceNo, h.OrgInvcNum AS OriginalInvoiceNo, h.TransId, h.ExchRate
		, 0 AS [Source]
		, CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) 
			END AS InvoiceTotal
		, 0 AS PriorInvoiceAmount --placeholder for values returned by SO Invoicing
		, 0 AS PriorPaymentAmount --placeholder for values returned by SO Invoicing
		, CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 
				THEN CASE WHEN pmt.PaymentTotalFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN 0 ELSE ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					+ ISNULL(Freight, 0) + ISNULL(Misc, 0) - ISNULL(pmt.PaymentTotal, 0) + ISNULL(CalcGainLoss, 0) END
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
					+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) - ISNULL(pmt.PaymentTotalFgn, 0)
			END
			END AS TotalDue
		, x.TaxLoc1 AS TaxLocation1, ISNULL(x.TaxAmt1, 0) AS TaxAmount1
		, x.TaxLoc2 AS TaxLocation2, ISNULL(x.TaxAmt2, 0) AS TaxAmount2
		, x.TaxLoc3 AS TaxLocation3, ISNULL(x.TaxAmt3, 0) AS TaxAmount3
		, x.TaxLoc4 AS TaxLocation4, ISNULL(x.TaxAmt4, 0) AS TaxAmount4
		, x.TaxLoc5 AS TaxLocation5, ISNULL(x.TaxAmt5, 0) AS TaxAmount5
		, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, WhseId AS TransLocation, BatchId, c.TaxExemptId, NULL as Notes
		, h.WhseId AS LocationId
		, Null AS [PickingSlipNo], Null AS [PackingSlipNo]
		, CASE WHEN @PrintAllInBase = 1 THEN (c.CreditLimit - c.CurAmtDue) / h.ExchRate ELSE (c.CreditLimit - c.CurAmtDue) END AS RemainingCredit
		, h.SourceId
	FROM #Temp l
	INNER JOIN dbo.tblArTransHeader h on l.TransId = h.TransId
	INNER JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
	INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId
	LEFT JOIN dbo.tblArShipTo Ship ON h.CustID = Ship.CustID AND h.ShipToID = Ship.ShipToID 
	LEFT JOIN #TaxSummary x on h.TransId = x.TransId
	LEFT JOIN (SELECT l.TransID
		, SUM(p.PmtAmt - p.CalcGainLoss) PaymentTotal
		, SUM(p.PmtAmtFgn) PaymentTotalFgn
		FROM #Temp l INNER JOIN dbo.tblArTransPmt p ON l.TransId = p.TransId
		GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	ORDER BY h.TransId

	-- detail info
	SELECT d.PartId AS ItemId, d.EntryNum
		, d.WhseId AS LocationId
		, d.[Desc] AS [Description]
		, CASE WHEN @PrintAdditionalDescription = 1 THEN d.AddnlDesc ELSE NULL END AS AddnlDescription
		, d.TaxClass, d.QtyOrdSell AS QtyOrdered, d.UnitsSell AS Units, d.QtyShipSell AS QtyShipped
		, CASE WHEN @PrintAllInBase = 1 THEN UnitPriceSell ELSE UnitPriceSellFgn END AS UnitPrice
		, CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt + d.PriceAdjAmt ELSE PriceExtFgn + d.PriceAdjAmtFgn END AS ExtPrice
		, d.TransId, d.PartType AS ItemType, d.LottedYn
		, d.PriceAdjType, d.PriceAdjPct
		, CASE WHEN @PrintAllInBase = 1 THEN -d.PriceAdjAmt ELSE -d.PriceAdjAmtFgn END AS PriceAdjAmt
		, 0 AS Kit, d.LineSeq 
		, NULL AS GrpId, NULL as BOLNum
		, d.ReqShipDate AS [RequestedShipDate], h.ShipDate AS [ActualShipDate]
		, NULL AS [BinNo], d.QtyBackordSell AS [QtyBackordered], d.Rep1Id, d.Rep2Id, d.CustomerPartNumber 
	FROM #Temp l 
	INNER JOIN dbo.tblArTransHeader h on l.TransID = h.TransId
	INNER JOIN dbo.tblArTransDetail d ON l.TransId = d.TransID 
	ORDER BY d.TransId, d.LineSeq, d.EntryNum
	
	-- lot info
	SELECT l.TransId, l.EntryNum, l.LotNum AS LotNo, l.QtyFilled AS Qty 
	FROM #Temp t
	INNER JOIN dbo.tblArTransLot l ON t.TransId = l.TransId
	ORDER BY LotNum


	-- serial info
	SELECT s.TransId, s.EntryNum, s.SeqNum, s.LotNum AS LotNo, s.SerNum AS SerNo
		, CASE WHEN @PrintAllInBase = 1 THEN s.PriceUnit ELSE s.PriceUnitFgn END AS UnitPrice
		, 1 AS Qty 
	FROM #Temp t
	INNER JOIN dbo.tblArTransSer s on t.TransId = s.TransId
	ORDER BY LotNum, SerNum

	-- totals
	SELECT CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS [CurrencyId] 
		, COUNT(h.TransId) AS [InvoicesPrinted]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END) AS [Taxable]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END) AS [Nontaxable]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END) AS [SalesTax]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END) AS [Freight]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END) AS [Misc]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN pmt.PaymentTotalFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) ELSE ISNULL(pmt.PaymentTotal, 0) END  --Show invoice total in base if fully paid in foreign currency
				ELSE ISNULL(pmt.PaymentTotalFgn, 0) END) AS [Prepaid]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) 
			END) AS [InvoiceTotal]
		, SUM(CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 
				THEN CASE WHEN pmt.PaymentTotalFgn = ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) THEN 0 ELSE ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					+ ISNULL(Freight, 0) + ISNULL(Misc, 0) - ISNULL(pmt.PaymentTotal, 0) + ISNULL(CalcGainLoss, 0) END --Show 0 if fully paid in foreign currency
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
					+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) - ISNULL(pmt.PaymentTotalFgn, 0)
			END
			END) AS [NetDue]
	FROM #Temp l
	INNER JOIN dbo.tblArTransHeader h on l.TransId = h.TransId
	LEFT JOIN (SELECT l.TransID
		, SUM(p.PmtAmt - p.CalcGainLoss) PaymentTotal
		, SUM(p.PmtAmtFgn) PaymentTotalFgn
		FROM #Temp l INNER JOIN dbo.tblArTransPmt p ON l.TransId = p.TransId
		GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	GROUP BY CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrintInvoices_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArPrintInvoices_proc';

