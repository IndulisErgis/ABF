
CREATE PROCEDURE [dbo].[trav_ApVendorAnalysisReport_proc]


@FiscalYear  Smallint = 2017,
@GlPeriod  Smallint = 10,
@View  Tinyint = 1,
@chkYTD  bit = 1,
@chkLY  bit = 1, 
@ReportCurrency nvarchar(10) = 'USD',
@PrintAllInBase bit = 1, 
@IncludeSalesTax bit = 1, 
@IncludeFreightCharges bit = 1, 
@IncludeMiscCharges bit = 1

AS
BEGIN TRY

DECLARE @Count int

      CREATE TABLE #tmpApVendorAnalysisrpt
      (
       VendorId pVendorId, 
       GLPeriodText nvarchar(30), 
	   PeriodSort smallint, 
       Purch pDecimal, Pmt pDecimal,
       DiscTaken pDecimal, 
       DiscLost pDecimal, 
       Ten99Pmt pDecimal
      )

      CREATE TABLE #tmpApVendorAnalyTot
      (
       GLPeriodText nvarchar(30), 
	   PeriodSort smallint, 
       Purch pDecimal NULL, 
       Pmt pDecimal NULL,
       DiscTaken pDecimal NULL,
       DiscLost pDecimal NULL,
       Ten99Pmt pDecimal NULL
      )

	IF @View = 0 -- Current Period
	BEGIN
		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, GLPeriod AS GLPeriodText, GLPeriod AS PeriodSort, ISNULL(Purch,0)
			, 0 AS Pmt, 0 AS DiscTaken, 0 AS DiscLost, 0 AS Ten99Pmt 
		FROM #tmpVendorList v 
			INNER JOIN 
			(
				SELECT VendorId, GLPeriod
					, SUM(SIGN(TransType) * 
						(CASE WHEN @PrintAllInBase = 1 THEN Subtotal ELSE SubtotalFgn END 
							+ CASE WHEN @IncludeSalesTax <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAdjAmt ELSE SalesTaxFgn + TaxAdjAmtFgn END ELSE 0 END 
							+ CASE WHEN @IncludeFreightCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END ELSE 0 END 
							+ CASE WHEN @IncludeMiscCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END ELSE 0 END)
						) AS Purch
				FROM dbo.tblApHistHeader h (NOLOCK) 
				WHERE FiscalYear = @FiscalYear AND GLPeriod = @GLPeriod AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY VendorId, GLPeriod
			) h 
				ON v.VendorId = h.VendorId

		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, GLPeriod AS GLPeriodText, GLPeriod AS PeriodSort, 0 AS Purch
			, ISNULL(Pmt,0), ISNULL(DiscTaken,0), ISNULL(DiscLost,0), ISNULL(Ten99Pmt,0) 
		FROM #tmpVendorList v 
			INNER JOIN
			(
				SELECT VendorID, GLPeriod
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(GrossAmtDue - DiscTaken) ELSE SUM(GrossAmtDueFgn - DiscTakenFgn) END AS Pmt
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscTaken) ELSE SUM(DiscTakenFgn) END AS DiscTaken
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscLost) ELSE SUM(DiscLostFgn) END AS DiscLost
					, SUM(CASE WHEN Ten99InvoiceYN <> 0 THEN 
						CASE WHEN @PrintAllInBase = 1 THEN (GrossAmtDue - DiscTaken) 
							ELSE (GrossAmtDueFgn - DiscTakenFgn) END ELSE 0 END) AS Ten99Pmt
				FROM dbo.tblApCheckHist h (NOLOCK) 
				WHERE VoidYn = 0 AND FiscalYear = @FiscalYear AND GLPeriod = @GLPeriod AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY h.VendorId, GLPeriod
			) h
				ON v.VendorId = h.VendorId
      END

      IF @View = 1 -- All Periods
      BEGIN
		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, GLPeriod AS GLPeriodText, GLPeriod AS PeriodSort, ISNULL(Purch,0)
			, 0 AS Pmt, 0 AS DiscTaken, 0 AS DiscLost, 0 AS Ten99Pmt 
		FROM #tmpVendorList v 
			INNER JOIN 
			(
				SELECT VendorId, GLPeriod
					, SUM(SIGN(TransType) * 
						(CASE WHEN @PrintAllInBase = 1 THEN Subtotal ELSE SubtotalFgn END 
							+ CASE WHEN @IncludeSalesTax <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAdjAmt ELSE SalesTaxFgn + TaxAdjAmtFgn END ELSE 0 END 
							+ CASE WHEN @IncludeFreightCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END ELSE 0 END 
							+ CASE WHEN @IncludeMiscCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END ELSE 0 END)
						) AS Purch
				FROM dbo.tblApHistHeader h (NOLOCK) 
				WHERE FiscalYear = @FiscalYear AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY VendorId, GLPeriod
			) h 
				ON v.VendorId = h.VendorId

		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, GLPeriod AS GLPeriodText, GLPeriod AS PeriodSort, 0 AS Purch
			, ISNULL(Pmt,0), ISNULL(DiscTaken,0), ISNULL(DiscLost,0), ISNULL(Ten99Pmt,0) 
		FROM #tmpVendorList v 
			INNER JOIN
			(
				SELECT VendorID, GLPeriod
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(GrossAmtDue - DiscTaken) ELSE SUM(GrossAmtDueFgn - DiscTakenFgn) END AS Pmt
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscTaken) ELSE SUM(DiscTakenFgn) END AS DiscTaken
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscLost) ELSE SUM(DiscLostFgn) END AS DiscLost
					, SUM(CASE WHEN Ten99InvoiceYN <> 0 THEN 
						CASE WHEN @PrintAllInBase = 1 THEN (GrossAmtDue - DiscTaken) 
							ELSE (GrossAmtDueFgn - DiscTakenFgn) END ELSE 0 END) AS Ten99Pmt
				FROM dbo.tblApCheckHist h (NOLOCK) 
				WHERE VoidYn = 0 AND FiscalYear = @FiscalYear AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY h.VendorId, GLPeriod
			) h
				ON v.VendorId = h.VendorId
      END

      IF @chkYTD = 1 -- YTD
      BEGIN
		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, 'Year-To-Date' AS GLPeriodText, 998 AS PeriodSort, ISNULL(Purch,0)
			, 0 AS Pmt, 0 AS DiscTaken, 0 AS DiscLost, 0 AS Ten99Pmt 
		FROM #tmpVendorList v 
			LEFT JOIN 
			(
				SELECT VendorId
					, SUM(SIGN(TransType) * 
						(CASE WHEN @PrintAllInBase = 1 THEN Subtotal ELSE SubtotalFgn END 
							+ CASE WHEN @IncludeSalesTax <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAdjAmt ELSE SalesTaxFgn + TaxAdjAmtFgn END ELSE 0 END 
							+ CASE WHEN @IncludeFreightCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END ELSE 0 END 
							+ CASE WHEN @IncludeMiscCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END ELSE 0 END)
						) AS Purch
				FROM dbo.tblApHistHeader h (NOLOCK) 
				WHERE FiscalYear = @FiscalYear AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY VendorId
			) h 
				ON v.VendorId = h.VendorId

		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, 'Year-To-Date' AS GLPeriodText, 998 AS PeriodSort, 0 AS Purch
			, ISNULL(Pmt,0), ISNULL(DiscTaken,0), ISNULL(DiscLost,0), ISNULL(Ten99Pmt,0) 
		FROM #tmpVendorList v 
			LEFT JOIN
			(
				SELECT VendorID
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(GrossAmtDue - DiscTaken) ELSE SUM(GrossAmtDueFgn - DiscTakenFgn) END AS Pmt
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscTaken) ELSE SUM(DiscTakenFgn) END AS DiscTaken
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscLost) ELSE SUM(DiscLostFgn) END AS DiscLost
					, SUM(CASE WHEN Ten99InvoiceYN <> 0 THEN 
						CASE WHEN @PrintAllInBase = 1 THEN (GrossAmtDue - DiscTaken) 
							ELSE (GrossAmtDueFgn - DiscTakenFgn) END ELSE 0 END) AS Ten99Pmt
				FROM dbo.tblApCheckHist h (NOLOCK) 
				WHERE VoidYn = 0 AND FiscalYear = @FiscalYear AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY h.VendorId
			) h
				ON v.VendorId = h.VendorId
      END

      IF @chkLY = 1 -- Last Year
      BEGIN
		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, 'Last-Year' AS GLPeriodText, 999 AS PeriodSort, ISNULL(Purch,0)
			, 0 AS Pmt, 0 AS DiscTaken, 0 AS DiscLost, 0 AS Ten99Pmt 
		FROM #tmpVendorList v (NOLOCK) 
			LEFT JOIN 
			(
				SELECT VendorId
					, SUM(SIGN(TransType) * 
						(CASE WHEN @PrintAllInBase = 1 THEN Subtotal ELSE SubtotalFgn END 
							+ CASE WHEN @IncludeSalesTax <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN SalesTax + TaxAdjAmt ELSE SalesTaxFgn + TaxAdjAmtFgn END ELSE 0 END 
							+ CASE WHEN @IncludeFreightCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Freight ELSE FreightFgn END ELSE 0 END 
							+ CASE WHEN @IncludeMiscCharges <> 0 THEN 
								CASE WHEN @PrintAllInBase = 1 THEN Misc ELSE MiscFgn END ELSE 0 END)
						) AS Purch
				FROM dbo.tblApHistHeader h (NOLOCK) 
				WHERE FiscalYear = @FiscalYear - 1 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY VendorId
			) h 
				ON v.VendorId = h.VendorId

		INSERT INTO #tmpApVendorAnalysisrpt (VendorId, GLPeriodText, PeriodSort, Purch, Pmt, DiscTaken, DiscLost, Ten99Pmt) 
		SELECT v.VendorId, 'Last-Year' AS GLPeriodText, 999 AS PeriodSort, 0 AS Purch
			, ISNULL(Pmt,0), ISNULL(DiscTaken,0), ISNULL(DiscLost,0), ISNULL(Ten99Pmt,0) 
		FROM #tmpVendorList v (NOLOCK) 
			LEFT JOIN
			(
				SELECT VendorID
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(GrossAmtDue - DiscTaken) ELSE SUM(GrossAmtDueFgn - DiscTakenFgn) END AS Pmt
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscTaken) ELSE SUM(DiscTakenFgn) END AS DiscTaken
					, CASE WHEN @PrintAllInBase = 1 THEN SUM(DiscLost) ELSE SUM(DiscLostFgn) END AS DiscLost
					, SUM(CASE WHEN Ten99InvoiceYN <> 0 THEN 
						CASE WHEN @PrintAllInBase = 1 THEN (GrossAmtDue - DiscTaken) 
							ELSE (GrossAmtDueFgn - DiscTakenFgn) END ELSE 0 END) AS Ten99Pmt
				FROM dbo.tblApCheckHist h (NOLOCK) 
				WHERE VoidYn = 0 AND FiscalYear = @FiscalYear - 1 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
				GROUP BY h.VendorId
			) h
				ON v.VendorId = h.VendorId
      END

      SELECT v.VendorID, v.Name, v.Addr1, v.Addr2, v.City, v.Region, v.Country, v.PostalCode, 
            v.IntlPrefix, v.Phone, v.FAX, v.LastPurchDate, v.LastPmtDate, 
            CASE WHEN @PrintAllInBase = 1 THEN v.GrossDue ELSE v.GrossDuefgn END GrossDue, 
            CASE WHEN @PrintAllInBase = 1 THEN v.Prepaid ELSE v.Prepaidfgn END Prepaid,
            t.TermsCode AS TermsCode, t.DiscDays, a.GLPeriodText, PeriodSort, a.Purch, a.Pmt, a.DiscTaken, a.DiscLost, a.Ten99Pmt
      FROM tblApVendor v  INNER JOIN tblApTermscode t (NOLOCK) ON v.TermsCode = t.TermsCode 
            LEFT JOIN 
			(SELECT VendorId, GLPeriodText, PeriodSort, SUM(Purch) Purch, SUM(Pmt) Pmt, SUM(DiscTaken) DiscTaken, SUM(DiscLost) DiscLost, SUM(Ten99Pmt) Ten99Pmt  
				FROM #tmpApVendorAnalysisrpt GROUP BY VendorId, GLPeriodText, PeriodSort) a ON v.VendorId = a.VendorId
            INNER JOIN #tmpVendorList tmp ON v.VendorId = tmp.VendorId
      ORDER BY v.VendorID

	SELECT GLPeriodText, PeriodSort, SUM(Purch) AS Purch, SUM(Pmt) AS Pmt, SUM(DiscTaken) AS DiscTaken, SUM(DiscLost) AS DiscLost, SUM(Ten99Pmt) AS Ten99Pmt 
	FROM #tmpApVendorAnalysisrpt GROUP BY GLPeriodText, PeriodSort

	SELECT CASE WHEN @PrintAllInBase = 1 THEN SUM(Prepaid)  ELSE SUM(PrepaidFgn)  END TotPrepaid, 
			 CASE WHEN @PrintAllInBase = 1 THEN SUM(GrossDue) ELSE SUM(GrossDueFgn) END TotGrossDue
	FROM dbo.tblApVendor v INNER JOIN #tmpVendorList t ON v.VendorId = t.VendorId
	WHERE  ( @PrintAllInBase = 1 OR v.CurrencyId = @ReportCurrency )

END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorAnalysisReport_proc';

