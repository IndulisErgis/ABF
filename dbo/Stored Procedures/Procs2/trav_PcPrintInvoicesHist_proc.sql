
CREATE PROCEDURE dbo.trav_PcPrintInvoicesHist_proc
@PostRun pPostRun = null,
@TransId pTransId = null, --set for printing online or from history
@PrintAllInBase bit = 1,
@BaseCurrencyId pCurrency = null,
@PrecCurr tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #TaxSummary
	(
		TransId pTransId,
		PostRun pPostRun,
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
        PostRun pPostRun NOT NULL
		PRIMARY KEY CLUSTERED ([TransId], PostRun)
	)	
	
	INSERT INTO #Temp (TransId, PostRun) 
	SELECT TransId, PostRun
	FROM dbo.tblArHistHeader
	WHERE TransId = @TransId and PostRun = @PostRun
		AND VoidYn = 0 --exclude voids
		AND Source = 3
		
	--summarize and cross-tab the taxes by level 
	--	note: TaxLocId cannot be duplicated for multiple tax levels
	INSERT INTO #TaxSummary (TransId, PostRun
		, TaxLoc1, TaxAmt1, TaxLoc2, TaxAmt2, TaxLoc3, TaxAmt3, TaxLoc4, TaxAmt4, TaxLoc5, TaxAmt5)
	SELECT TransId, PostRun, Max(TaxLoc1), Sum(TaxAmt1), Max(TaxLoc2), Sum(TaxAmt2)
		, Max(TaxLoc3), Sum(TaxAmt3), Max(TaxLoc4), Sum(TaxAmt4), Max(TaxLoc5), Sum(TaxAmt5)
	FROM (SELECT x.TransId, x.PostRun
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
		INNER JOIN dbo.tblArHistTax x ON l.TransId = x.TransId and l.PostRun = x.PostRun
		INNER JOIN dbo.tblArHistHeader h ON x.TransId = h.TransId and x.PostRun = h.PostRun
		INNER JOIN dbo.tblSmTaxGroup s  ON h.TaxGrpID = s.TaxGrpID
		WHERE s.ReportMethod <> 0) ctab
	GROUP BY TransId, PostRun

	--Add the tax adjustment to the appropriate tax location
	UPDATE #TaxSummary 
		Set TaxAmt1 = TaxAmt1 + CASE WHEN [TaxLoc1] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt2 = TaxAmt2 + CASE WHEN [TaxLoc2] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt3 = TaxAmt3 + CASE WHEN [TaxLoc3] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt4 = TaxAmt4 + CASE WHEN [TaxLoc4] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
		, TaxAmt5 = TaxAmt5 + CASE WHEN [TaxLoc5] = h.[TaxLocAdj] THEN CASE WHEN @PrintAllInBase = 1 THEN h.TaxAmtAdj ELSE h.TaxAmtAdjFgn END ELSE 0 END
	FROM dbo.tblArHistHeader h 
		WHERE h.TaxAmtAdjFgn <> 0
		AND #TaxSummary.PostRun = h.PostRun AND #TaxSummary.TransId = h.TransId	

	--retrieve the datasets
	-- header info
	SELECT h.TransId, CASE WHEN h.TransType < 0 THEN -1 ELSE 1 END AS TransType, h.CredMemNum AS OriginalInvoiceNo,
		h.InvcDate AS InvoiceDate, h.InvcNum AS InvoiceNo, h.CurrencyId, h.ExchRate, c.CustId, c.CustName, c.Attn, 
		c.Addr1, c.Addr2, c.City, c.Region, c.PostalCode, c.Country, h.Rep1Id, h.Rep2Id, NetDueDate, DiscDueDate,
		t.[Desc] AS TermsDescription, h.CustPONum AS CustomerPoNo, h.OrderDate, x.TaxLoc1 AS TaxLocation1,
		x.TaxLoc2 AS TaxLocation2, x.TaxLoc3 AS TaxLocation3,
		x.TaxLoc4 AS TaxLocation4, x.TaxLoc5 AS TaxLocation5,
		ISNULL(x.TaxAmt1, 0) AS TaxAmount1, ISNULL(x.TaxAmt2, 0) AS TaxAmount2, ISNULL(x.TaxAmt3, 0) AS TaxAmount3,
		ISNULL(x.TaxAmt4, 0) AS TaxAmount4, ISNULL(x.TaxAmt5, 0) AS TaxAmount5,
		CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxableSubtotal, 
		CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NontaxableSubtotal, 0 AS Freight, 0 AS Misc,
		CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTax, 
		CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
			END AS InvoiceTotal,
		CASE WHEN @PrintAllInBase = 1 Then ISNULL(h.TotPmtAmt - h.TotPmtGainLoss, 0) ELSE ISNULL(h.TotPmtAmtFgn, 0) END AS TotalPayment,
		CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 
				THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					- ISNULL(h.TotPmtAmt - h.TotPmtGainLoss, 0) + ISNULL(CalcGainLoss, 0)
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
					- ISNULL(h.TotPmtAmtFgn, 0)
			END
			END AS TotalDue, h.PrintOption
		, h.ShipToID, h.ShipToName,h.ShipToAttn, h.ShipToAddr1, h.ShipToAddr2, h.ShipToCity, h.ShipToRegion, h.ShipToPostalCode, h.ShipToCountry
	FROM #Temp l
	INNER JOIN dbo.tblArHistHeader h on l.TransId = h.TransId and l.PostRun = h.PostRun
	LEFT JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
	LEFT JOIN dbo.tblArCust c ON c.CustId = h.CustId
	LEFT JOIN #TaxSummary x on h.TransId = x.TransId
	ORDER BY h.TransId, h.PostRun
	
	-- detail info
	SELECT d.TransId, d.JobId AS ProjectId, d.ProjName AS ProjectName, d.PhaseId, d.PhaseName,
		d.TaskId, d.TaskName, d.ActivityType AS [Type], d.PartId AS ResourceId, d.[Desc] AS [Description], d.AddnlDesc AS AdditionalDescription, d.QtyShipSell AS Qty, d.TaxClass,
		CASE WHEN @PrintAllInBase = 1 THEN d.PriceExt ELSE PriceExtFgn END AS ExtPrice,
		CASE WHEN @PrintAllInBase = 1 THEN d.UnitPriceSell ELSE d.UnitPriceSellFgn END AS UnitPrice, d.ActShipDate AS ActivityDate, 
		d.EntryNum, d.TransHistId, d.LineSeq 
	FROM #Temp l INNER JOIN dbo.tblArHistDetail d ON l.TransId = d.TransID and  l.PostRun = d.PostRun
	WHERE d.EntryNum > 0 AND (d.PriceExt <> 0 OR d.ZeroPrint = 1)
	ORDER BY d.TransId,  d.PostRun, d.LineSeq, d.EntryNum

	-- totals
	SELECT CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS [CurrencyId] 
		, COUNT(h.TransId) AS [InvoicesPrinted]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END) AS [Taxable]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END) AS [Nontaxable]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END) AS [SalesTax]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN ISNULL(h.TotPmtAmt - h.TotPmtGainLoss, 0) ELSE ISNULL(h.TotPmtAmtFgn, 0) END) AS [Prepaid]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
			END) AS [InvoiceTotal]
		, SUM(CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 
				THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					- ISNULL(h.TotPmtAmt - h.TotPmtGainLoss, 0) + ISNULL(CalcGainLoss, 0)
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
					- ISNULL(h.TotPmtAmtFgn, 0)
			END
			END) AS [NetDue]
	FROM #Temp l INNER JOIN dbo.tblArHistHeader h on l.TransId = h.TransId and l.PostRun = h.PostRun 
	GROUP BY CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrintInvoicesHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrintInvoicesHist_proc';

