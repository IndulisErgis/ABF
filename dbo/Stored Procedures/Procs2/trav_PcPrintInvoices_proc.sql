
CREATE PROCEDURE dbo.trav_PcPrintInvoices_proc
@LastInvoice pInvoiceNum = null, --set for batch mode printing
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
		FROM #tmpTransactionList t	INNER JOIN dbo.tblPcInvoiceHeader h on t.TransId = h.TransId
			INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId
		WHERE h.VoidYn = 0 --exclude voids
			AND (h.PrintStatus = 0 Or h.PrintStatus = 2) 
			AND (c.StmtInvcCode = 3 Or c.StmtInvcCode = 2) 
			AND (h.InvcNum > @LastInvoice or ISNULL(h.InvcNum,'') = '') 
	END
	ELSE
	BEGIN
		--select only one transaction for online processing
		INSERT INTO #Temp (TransId) 
		SELECT h.TransId
		FROM dbo.tblPcInvoiceHeader h 
		WHERE h.TransId = @TransId AND h.VoidYn = 0 --exclude voids
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
	FROM #Temp l INNER JOIN dbo.tblPcInvoiceTax x ON l.TransId = x.TransId
			INNER JOIN dbo.tblPcInvoiceHeader h ON x.TransId = h.TransId
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
	FROM dbo.tblPcInvoiceHeader h 
		WHERE h.TaxAmtAdjFgn <> 0
		AND #TaxSummary.TransId = h.TransId
			

	--retrieve the datasets
	-- header info
	SELECT h.TransId, CASE WHEN h.TransType < 0 THEN -1 ELSE 1 END AS TransType, h.OrgInvcNum AS OriginalInvoiceNo,
		h.InvcDate AS InvoiceDate, h.InvcNum AS InvoiceNo, h.CurrencyId, h.ExchRate, c.CustId, c.CustName, c.Attn, 
		c.Addr1, c.Addr2, c.City, c.Region, c.PostalCode, c.Country, h.Rep1Id, h.Rep2Id, NetDueDate, DiscDueDate,
		t.[Desc] AS TermsDescription, h.CustPONum AS CustomerPoNo, h.OrderDate, x.TaxLoc1 AS TaxLocation1,
		x.TaxLoc2 AS TaxLocation2, x.TaxLoc3 AS TaxLocation3,
		x.TaxLoc4 AS TaxLocation4, x.TaxLoc5 AS TaxLocation5,
		ISNULL(x.TaxAmt1, 0) AS TaxAmount1, ISNULL(x.TaxAmt2, 0) AS TaxAmount2, ISNULL(x.TaxAmt3, 0) AS TaxAmount3,
		ISNULL(x.TaxAmt4, 0) AS TaxAmount4, ISNULL(x.TaxAmt5, 0) AS TaxAmount5,
		CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS ReportCurrencyId,
		CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END AS TaxableSubtotal, 
		CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END AS NontaxableSubtotal, 0 AS Freight, 0 AS Misc,
		CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END AS SalesTax, 
		CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
			END AS InvoiceTotal,
		CASE WHEN @PrintAllInBase = 1 Then ISNULL(pmt.DepositTotal, 0) ELSE ISNULL(pmt.DepositTotalFgn, 0) END AS TotalPayment,  
		CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 
				THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					- ISNULL(pmt.DepositTotal, 0) + ISNULL(CalcGainLoss, 0)
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
					- ISNULL(pmt.DepositTotalFgn, 0)
			END
			END AS TotalDue, h.PrintOption
		, s.SiteID AS ShipToID, s.Name AS ShipToName, s.Attention AS ShipToAttn, s.Address1 AS ShipToAddr1, s.Address2 AS ShipToAddr2, s.City AS ShipToCity
		, s.Region AS ShipToRegion, s.PostalCode AS ShipToPostalCode, s.Country AS ShipToCountry, h.SourceId
	FROM #Temp l
	INNER JOIN dbo.tblPcInvoiceHeader h on l.TransId = h.TransId 
		INNER JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
		INNER JOIN dbo.tblArCust c ON c.CustId = h.CustId	
		LEFT JOIN (SELECT TransId, MAX(ProjectDetailId) AS ProjectDetailId FROM dbo.tblPcInvoiceDetail GROUP BY TransId) d ON h.TransId=d.TransId
		LEFT JOIN dbo.tblPcProjectDetail pd on pd.Id=d.ProjectDetailId
		LEFT JOIN dbo.trav_PcProject_view p ON pd.ProjectId = p.Id
		LEFT JOIN  dbo.tblPcProjectDetailSiteInfo s ON s.ProjectDetailID=p.ProjectDetailID
		LEFT JOIN #TaxSummary x on h.TransId = x.TransId
		LEFT JOIN (SELECT l.TransID
			, SUM(p.DepositAmtApply) DepositTotal
			, SUM(ROUND(p.DepositAmtApply * h.ExchRate,ISNULL(c.CurrDecPlaces, @PrecCurr))) DepositTotalFgn
			FROM #Temp l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
				INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId 
				LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId 
			GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	ORDER BY h.TransId

	-- detail info
	SELECT d.TransId, d.EntryNum, p.ProjectName AS ProjectId, v.[Description] AS ProjectName, t.PhaseId, s.[Description] AS PhaseName,
		t.TaskId, k.[Description] AS TaskName, a.[Type], a.ResourceId, d.Descr AS [Description], d.AddnlDesc AS AdditionalDescription, d.Qty, d.TaxClass,
		CASE WHEN @PrintAllInBase = 1 THEN d.ExtPrice ELSE ExtPriceFgn END AS ExtPrice,
		CASE WHEN d.Qty = 0 THEN CASE WHEN @PrintAllInBase = 1 THEN d.ExtPrice ELSE ExtPriceFgn END ELSE 
			CASE WHEN @PrintAllInBase = 1 THEN d.ExtPrice ELSE ExtPriceFgn END / d.Qty END AS UnitPrice, a.ActivityDate
		, d.LineSeq 
	FROM #Temp l INNER JOIN dbo.tblPcInvoiceDetail d ON l.TransId = d.TransID 
		INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
		INNER JOIN dbo.tblPcProjectDetail t ON a.ProjectDetailId = t.Id
		INNER JOIN dbo.tblPcProject p ON t.ProjectId = p.Id 
		INNER JOIN dbo.trav_PcProject_view v ON p.Id = v.Id
		LEFT JOIN dbo.tblPcPhase s ON t.PhaseId = s.PhaseId 
		LEFT JOIN dbo.tblPcTask k ON t.TaskId = k.TaskId
	WHERE d.ExtPrice <> 0 OR d.ZeroPrint = 1
	ORDER BY d.TransId, d.LineSeq, d.EntryNum

	-- totals
	SELECT CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS [CurrencyId] 
		, COUNT(h.TransId) AS [InvoicesPrinted]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal ELSE TaxSubtotalFgn END) AS [Taxable]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN NonTaxSubtotal ELSE NonTaxSubtotalFgn END) AS [Nontaxable]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAmtAdj ELSE SalesTaxFgn + TaxAmtAdjFgn END) AS [SalesTax]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN ISNULL(pmt.DepositTotal, 0) ELSE ISNULL(pmt.DepositTotalFgn, 0) END) AS [Prepaid]
		, SUM(SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 
			THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0) 
			ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
			END) AS [InvoiceTotal]
		, SUM(CASE WHEN h.TransType < 0 --return 0 for TotalDue on Credit Transactions
			THEN 0
			ELSE
				CASE WHEN @PrintAllInBase = 1 
				THEN ISNULL(TaxSubtotal, 0) + ISNULL(NonTaxSubtotal, 0) + ISNULL(SalesTax, 0) + ISNULL(TaxAmtAdj, 0)
					- ISNULL(pmt.DepositTotal, 0) + ISNULL(CalcGainLoss, 0)
				ELSE ISNULL(TaxSubtotalFgn, 0) + ISNULL(NonTaxSubtotalFgn, 0) + ISNULL(SalesTaxFgn, 0) + ISNULL(TaxAmtAdjFgn, 0)
					- ISNULL(pmt.DepositTotalFgn, 0)
			END
			END) AS [NetDue]
	FROM #Temp l INNER JOIN dbo.tblPcInvoiceHeader h on l.TransId = h.TransId
		LEFT JOIN (SELECT l.TransID
			, SUM(p.DepositAmtApply) DepositTotal
			, SUM(ROUND(p.DepositAmtApply * h.ExchRate,ISNULL(c.CurrDecPlaces, @PrecCurr))) DepositTotalFgn
			FROM #Temp l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
				INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId 
				LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId 
			GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId
	GROUP BY CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrintInvoices_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrintInvoices_proc';

