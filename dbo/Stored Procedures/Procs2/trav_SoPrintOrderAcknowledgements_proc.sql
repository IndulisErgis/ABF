
CREATE PROCEDURE dbo.trav_SoPrintOrderAcknowledgements_proc
@TransId pTransId = null, --set for printing online 
@PrintAdditionalDescription bit = 0, --set for printing additional descriptions
@PrintAllInBase bit = 1, --option to print all in base currency
@PrintCompletedLineItems bit = 0, --option to print completed line items
@PrintKitDetail bit = 1, --option to include kit detail
@BaseCurrencyId pCurrency = 'USD'
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
		TransId pTransId NOT NULL,
		SourceId [UniqueIdentifier] NOT NULL,
		PRIMARY KEY CLUSTERED ([TransId])
	)	

	--process live transactions
	IF (ISNULL(@TransId, '') = '')
	BEGIN
		--build the list of Invoices that are valid for printing
		INSERT INTO #Temp (TransId, SourceId)
		SELECT h.TransId, h.SourceId
		FROM #tmpTransactionList t
			INNER JOIN dbo.tblSoTransHeader h on t.TransId = h.TransId
			INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId
		WHERE h.VoidYn = 0 --exclude voids
			AND (h.PrintAcknowStatus = 0 OR h.PrintAcknowStatus = 2) 
			AND h.TransType = 9
			AND (@PrintCompletedLineItems = 1 --must be printing completed line items OR 
				OR EXISTS (SELECT TOP 1 TransId FROM dbo.tblSoTransDetail d WHERE d.TransID = h.TransId AND d.[Status] = 0)) --must have at least 1 active line item
	END
	ELSE
	BEGIN
		--select only one transaction for online processing
		INSERT INTO #Temp (TransId, SourceId)
		SELECT h.TransId, h.SourceId
		FROM dbo.tblSoTransHeader h 
		WHERE h.TransId = @TransId
			AND h.VoidYn = 0 --exclude voids
			AND (@PrintCompletedLineItems = 1 --must be printing completed line items OR 
				OR EXISTS (SELECT TOP 1 TransId FROM dbo.tblSoTransDetail d WHERE d.TransID = h.TransId AND d.[Status] = 0)) --must have at least 1 active line item
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
		INNER JOIN dbo.tblSoTransTax x ON l.TransId = x.TransId
		INNER JOIN dbo.tblSoTransHeader h ON x.TransId = h.TransId
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
	FROM dbo.tblSoTransHeader h 
		WHERE h.TaxAmtAdjFgn <> 0
		AND #TaxSummary.TransId = h.TransId
	
	--PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=12789
	--retrieve the datasets
	SELECT c.CustId, c.Attn, c.Contact, c.CustName, c.Addr1, c.Addr2, c.City, c.Region
		, c.Country, c.PostalCode, c.Phone, c.Fax, c.Email, c.Internet, b.CustId AS BillCustId
		, b.CustName AS BillCustName, b.Addr1 AS BillAddr1, b.Addr2 AS BillAddr2, b.City AS BillCity
		, b.Region AS BillRegion, b.Country AS BillCountry, b.PostalCode AS BillPostalCode
		, b.IntlPrefix BillIntlPrefix, b.Attn AS BillAttn, b.Contact AS BillContact, b.Phone AS BillPhone, b.Fax AS BillFax
		, b.Email AS BillEmail, b.Internet AS BillInternet, h.ShipToID, h.ShipToName, h.ShipToAddr1
		, h.ShipToAddr2, h.ShipToCity, h.ShipToCountry, h.ShipToRegion, h.ShipToPostalCode, h.ShipVia
		, h.ShipToAttn, Ship.Phone AS ShipToPhone, Ship.Fax AS ShipToFax, Ship.Email AS ShipToEmail
		, Ship.Internet AS ShipToInternet, t.[Desc] AS TermsDescription, h.TransType,h.SourceId
		, CASE WHEN CustPONum IS NULL THEN h.TransDate ELSE h.PODate END AS OrderDate
		, h.ReqShipDate AS [RequestedShipDate], h.ActShipDate AS ShipDate, h.ShipNum AS ShipNo, h.InvcDate AS InvoiceDate, h.Rep1Id, h.Rep2Id
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS ReportCurrencyId
		, CASE WHEN @PrintAllInBase = 1 THEN TaxableSales ELSE TaxableSalesFgn END AS TaxableSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN NonTaxableSales ELSE NonTaxableSalesFgn END AS NontaxableSubtotal
		, CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END AS Freight
		, CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END AS Misc
		, CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN ISNULL(PostedPaymentTotalFgn,0) + ISNULL(UnpostedPaymentTotalFgn,0) = ISNULL(TaxableSalesFgn, 0) + ISNULL(NonTaxableSalesFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) + ISNULL(PostedInvoiceTotalFgn, 0) THEN ISNULL(TaxableSales, 0) + ISNULL(NonTaxableSales, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) +  ISNULL(PostedInvoiceTotal, 0) - ISNULL(PostedPaymentTotal,0) ELSE ISNULL(pmt.UnpostedPaymentTotal, 0) END ELSE ISNULL(pmt.UnpostedPaymentTotalFgn, 0) END AS TotalPayment
		, h.CustPONum AS CustomerPoNo, h.CurrencyID AS CurrencyId
		, h.InvcNum AS InvoiceNo, h.OrgInvcNum AS OriginalInvoiceNo, h.TransId, h.ExchRate
		, 1 AS [Source]
		, CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxableSales, 0) + ISNULL(NonTaxableSales, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
				+ ISNULL(Freight, 0) + ISNULL(Misc, 0) 
			ELSE ISNULL(TaxableSalesFgn, 0) + ISNULL(NonTaxableSalesFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) 
			END AS InvoiceTotal
		, CASE WHEN @PrintAllInBase = 1 THEN ISNULL(hist.PostedInvoiceTotal, 0) ELSE ISNULL(hist.PostedInvoiceTotalFgn, 0) END AS PriorInvoiceAmount
		, CASE WHEN @PrintAllInBase = 1 THEN ISNULL(pmt.PostedPaymentTotal, 0) ELSE ISNULL(pmt.PostedPaymentTotalFgn, 0) END AS PriorPaymentAmount
		, CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN ISNULL(PostedPaymentTotalFgn,0) + ISNULL(UnpostedPaymentTotalFgn,0) = ISNULL(TaxableSalesFgn, 0) + ISNULL(NonTaxableSalesFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) + ISNULL(PostedInvoiceTotalFgn, 0) THEN 0
				ELSE ISNULL(TaxableSales, 0) + ISNULL(NonTaxableSales, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					+ ISNULL(Freight, 0) + ISNULL(Misc, 0) - ISNULL(pmt.UnpostedPaymentTotal, 0) + ISNULL(CalcGainLoss, 0) 
					+ CASE WHEN ISNULL(hist.PostedInvoiceTotal, 0) < ISNULL(pmt.PostedPaymentTotal, 0) THEN ISNULL(hist.PostedInvoiceTotal, 0) - ISNULL(pmt.PostedPaymentTotal, 0) ELSE 0 END END
			ELSE ISNULL(TaxableSalesFgn, 0) + ISNULL(NonTaxableSalesFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
				+ ISNULL(FreightFgn, 0) + ISNULL(MiscFgn, 0) - ISNULL(pmt.UnpostedPaymentTotalFgn, 0)
				+ CASE WHEN ISNULL(hist.PostedInvoiceTotalFgn, 0) < ISNULL(pmt.PostedPaymentTotalFgn, 0) THEN ISNULL(hist.PostedInvoiceTotalFgn, 0) - ISNULL(pmt.PostedPaymentTotalFgn, 0) ELSE 0 END
			END AS TotalDue
		, x.TaxLoc1 AS TaxLocation1, ISNULL(x.TaxAmt1, 0) AS TaxAmount1
		, x.TaxLoc2 AS TaxLocation2, ISNULL(x.TaxAmt2, 0) AS TaxAmount2
		, x.TaxLoc3 AS TaxLocation3, ISNULL(x.TaxAmt3, 0) AS TaxAmount3
		, x.TaxLoc4 AS TaxLocation4, ISNULL(x.TaxAmt4, 0) AS TaxAmount4
		, x.TaxLoc5 AS TaxLocation5, ISNULL(x.TaxAmt5, 0) AS TaxAmount5
		, NetDueDate, DiscDueDate, LocId AS TransLocation, BatchId, c.TaxExemptId, h.Notes
		, h.LocId AS LocationId
		, CASE WHEN @PrintAllInBase = 1 THEN (c.CreditLimit - c.CurAmtDue) / h.ExchRate ELSE (c.CreditLimit - c.CurAmtDue) END AS RemainingCredit
	FROM #Temp l
	INNER JOIN dbo.tblSoTransHeader h on l.TransId = h.TransId
	INNER JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
	INNER JOIN dbo.tblArCust c ON h.SoldToId = c.CustId
	LEFT JOIN dbo.tblArCust b on h.CustId = b.CustId
	LEFT JOIN dbo.tblArShipTo Ship ON h.SoldToId = Ship.CustID AND h.ShipToID = Ship.ShipToID
	LEFT JOIN #TaxSummary x on h.TransId = x.TransId
	LEFT JOIN (SELECT l.SourceId
		, SUM(TaxSubtotal + NonTaxSubtotal + SalesTax + Freight + Misc + CalcGainLoss) AS PostedInvoiceTotal
		, SUM(TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn + FreightFgn + MiscFgn) AS PostedInvoiceTotalFgn 
		FROM #Temp l INNER JOIN dbo.tblArHistHeader h on l.SourceId = h.SourceId 
		WHERE [Source] = 1
		GROUP BY l.SourceId) hist on h.SourceId = hist.SourceId
	LEFT JOIN (SELECT l.TransID
		, SUM(CASE WHEN p.PostedYn = 1 THEN p.PmtAmt - p.CalcGainLoss ELSE 0 END) PostedPaymentTotal
		, SUM(CASE WHEN p.PostedYn = 1 THEN p.PmtAmtFgn ELSE 0 END) PostedPaymentTotalFgn
		, SUM(CASE WHEN p.PostedYn = 0 THEN p.PmtAmt - p.CalcGainLoss ELSE 0 END) UnpostedPaymentTotal
		, SUM(CASE WHEN p.PostedYn = 0 THEN p.PmtAmtFgn ELSE 0 END) UnpostedPaymentTotalFgn
		FROM #Temp l INNER JOIN dbo.tblSoTransPmt p ON l.TransId = p.TransId
		GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	ORDER BY h.TransId

	--line items
	SELECT d.ItemId, d.EntryNum
		, d.LocId AS LocationId
		, d.[Descr] AS [Description]
		, CASE WHEN @PrintAdditionalDescription = 1 THEN d.AddnlDescr ELSE NULL END AS AddnlDescription
		, d.TaxClass, d.QtyOrdSell AS QtyOrdered, d.UnitsSell AS Units, d.QtyShipSell AS QtyShipped
		, CASE WHEN @PrintAllInBase = 1 THEN UnitPriceSellBasis ELSE UnitPriceSellBasisFgn END AS UnitPrice --PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=12738
		, CASE WHEN (h.TransType IN (1, 4) AND d.QtyShipSell = 0) OR (h.TransType NOT IN (1, 4) AND d.QtyOrdSell = 0) THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt + d.PriceAdjAmt ELSE PriceExtFgn + d.PriceAdjAmtFgn END END AS ExtPrice --ignore PriceAdj when no qtys processed for current status
		, d.TransId, d.ItemType, d.LottedYn
		, d.PriceAdjType, d.PriceAdjPct AS PriceAdjPct
		, CASE WHEN (h.TransType IN (1, 4) AND d.QtyShipSell = 0) OR (h.TransType NOT IN (1, 4) AND d.QtyOrdSell = 0) THEN 0 
			ELSE CASE WHEN @PrintAllInBase = 1 THEN -d.PriceAdjAmt ELSE -d.PriceAdjAmtFgn END END AS PriceAdjAmt --ignore PriceAdj when no qtys processed for current status
		, d.Kit, CASE WHEN d.GrpId IS NULL THEN d.LineSeq ELSE k.LineSeq END LineSeq --map back to the parent kit line seq for component sorting
		, d.GrpId, ISNULL(d.ReqShipDate,h.ReqShipDate) AS [RequestedShipDate], d.ActShipDate AS [ActualShipDate], d.BOLNum, d.CustomerPartNumber
	FROM #Temp l
	INNER JOIN dbo.tblSoTransDetail d ON l.TransId = d.TransID
	LEFT JOIN dbo.tblSoTransHeader h ON d.TransID= h.TransId
	LEFT JOIN (SELECT TransId, EntryNum, LineSeq 
		FROM dbo.tblSoTransDetail 
		WHERE [Kit] = 1) k 
	ON d.TransID = k.TransID and d.GrpId = k.EntryNum --lookup the lineseq of the parent kit for component sorting
	WHERE (@PrintKitDetail = 1 OR d.GrpId IS NULL)  --exclude kit components when not selected for printing
		AND (@PrintCompletedLineItems = 1 OR d.[Status] = 0) --must be printing completed line items OR line item status is active
	ORDER BY d.TransId
		, CASE WHEN d.GrpId IS NULL THEN d.LineSeq ELSE k.LineSeq END
		, CASE WHEN d.GrpId IS NULL THEN '' ELSE 'C' END --kit components sort after the parent
		, d.LineSeq, d.EntryNum

	
	-- lot info
	SELECT l.TransId, l.EntryNum, l.LotNum AS LotNo, l.QtyFilled AS Qty 
	FROM #Temp t
	INNER JOIN dbo.tblSoTransDetail d on t.TransId = d.TransID
	INNER JOIN dbo.tblSoTransDetailExt l ON d.TransId = l.TransId and d.EntryNum = l.EntryNum
	WHERE (@PrintKitDetail = 1 OR d.GrpId IS NULL)  --exclude kit components when not selected for printing
		AND (@PrintCompletedLineItems = 1 OR d.[Status] = 0) --must be printing completed line items OR line item status is active
		AND l.LotNum IS NOT NULL AND l.QtyFilled > 0 --and a valid shipped qty exists --PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=12715
	ORDER BY LotNum


	-- serial info
	SELECT s.TransId, s.EntryNum, s.SeqNum, s.LotNum AS LotNo, s.SerNum AS SerNo
		, CASE WHEN @PrintAllInBase = 1 THEN s.PriceUnit ELSE s.PriceUnitFgn END AS UnitPrice
		, 1 AS Qty 
	FROM #Temp t
	INNER JOIN dbo.tblSoTransDetail d on t.TransId = d.TransID
	INNER JOIN dbo.tblSoTransSer s on d.TransId = s.TransId and d.EntryNum = s.EntryNum
	WHERE (@PrintKitDetail = 1 OR d.GrpId IS NULL)  --exclude kit components when not selected for printing
		AND (@PrintCompletedLineItems = 1 OR d.[Status] = 0) --must be printing completed line items OR line item status is active
	ORDER BY LotNum, SerNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoPrintOrderAcknowledgements_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoPrintOrderAcknowledgements_proc';

