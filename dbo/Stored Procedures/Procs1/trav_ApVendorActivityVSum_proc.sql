
CREATE Procedure [dbo].[trav_ApVendorActivityVSum_proc]
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD'    --Base currency WHEN @PrintAllInBase = 1

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpApVendorActivityHeader
	(
		VendorId pVendorId, 
		VName Varchar(30), 
		InvoiceNum pInvoiceNum, 
		TaxFreMisc pDec, 
		CurrencyID pCurrency
	)

	CREATE TABLE #tmpApVendorActivityDtl
	(
		VendorId pVendorId,  
		InvoiceNum pInvoiceNum, 
		ExtCost pDec, 
		CurrencyID pCurrency
	)

	CREATE TABLE #tmpApCheckHist
	(
		VendorId pVendorId, 
		InvoiceNum pInvoiceNum, 
		GrossAmtDue pDec, 
		DiscAmt pDec, 
		NetPaidCalc pDec,  
		CurrencyID pCurrency
	)
	
	INSERT INTO #tmpApVendorActivityHeader
		SELECT v.VendorId, v.Name, h.InvoiceNum, 
			SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * (h.SalesTax + h.TaxAdjAmt + h.Freight + h.Misc) 
				ELSE SIGN(TransType) * (h.SalesTaxFgn + h.TaxAdjAmtFgn + h.FreightFgn + h.MiscFgn) END) TaxFreMisc, v.CurrencyID
		FROM (tblApVendor v (NOLOCK) 
			INNER JOIN tblApHistHeader h (NOLOCK) ON v.VendorID = h.VendorId )
			INNER JOIN #tmpVendorSumList t ON t.VendorID = h.VendorId --AND h.PostRun = t.PostRun  AND h.TransId = t.TransId 
				--AND h.InvoiceNum = t.InvoiceNum 
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )
		GROUP BY v.VendorId, V.Name, v.CurrencyID, h.InvoiceNum

	INSERT INTO #tmpApVendorActivityDtl
		SELECT v.VendorId, d.InvoiceNum, 
			ISNULL(SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * (d.ExtCost) ELSE SIGN(TransType) * (d.ExtCostFgn) END),0) ExtCost, v.CurrencyID
		FROM (tblApVendor v (NOLOCK) 
			INNER JOIN tblApHistHeader h (NOLOCK) ON v.VendorID = h.VendorId)
			LEFT JOIN tblApHistDetail d (NOLOCK) ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum 
			INNER JOIN #tmpVendorSumList t ON h.VendorID = t.VendorId --AND h.PostRun = t.PostRun  AND h.TransId = t.TransId 
				--AND h.InvoiceNum = t.InvoiceNum 
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency ) AND ISNULL(d.EntryNum, 0) >= 0 
		GROUP BY v.VendorId, V.Name, v.CurrencyID, d.InvoiceNum 

	INSERT INTO #tmpApCheckHist
		SELECT c.VendorId, c.InvoiceNum, SUM(CASE WHEN @PrintAllInBase = 1 THEN c.GrossAmtDue ELSE c.GrossAmtDueFgn END),
			SUM(CASE WHEN @PrintAllInBase = 1 THEN c.DiscTaken ELSE c.DiscTakenFgn END) DiscAmt,  
			SUM(CASE WHEN @PrintAllInBase = 1 THEN NetPaidCalc ELSE c.GrossAmtDueFgn - c.DiscTakenFgn END) NetPaidCalc, c.CurrencyID
		FROM tblApCheckHist c (NOLOCK) 
			INNER JOIN tblApHistHeader h (NOLOCK) ON c.VendorId = h.VendorId AND c.InvoiceNum = h.InvoiceNum
			INNER JOIN #tmpVendorSumList t ON c.VendorId = t.VendorId
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency ) AND (PmtType <> 9) 
		GROUP BY c.VendorId, c.CurrencyID, c.InvoiceNum

	SELECT #tmp.VendorID, #tmp.VName, SUM(#tmp.Invoiced) Invoiced, SUM(#tmp.GrossAmtDue) GrossAmtDue, SUM(#tmp.DiscAmt) DiscAmt, 
		SUM(#tmp.NetPaid) NetPaid, SUM(#tmp.CalcGainLos) CalcGainLos, SUM(#tmp.CalcBalance - #tmp.CalcGainLos) CalcBalance, #tmp.CurrencyID 
	FROM (
			SELECT t1.VendorID, t1.VName,  CAST((t1.TaxFreMisc + t2.ExtCost) AS float) Invoiced, CAST(ISNULL(t3.GrossAmtDue,0) AS float) GrossAmtDue,
				CAST(ISNULL(t3.DiscAmt,0) AS float) DiscAmt, CAST(ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0) AS float) NetPaid,  
				CASE WHEN ISNULL(t3.GrossAmtDue,0)  = 0 THEN 0 ELSE
				CAST(ISNULL(t3.NetPaidcalc, 0) - (ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0)) AS float) END AS CalcGainLos,
				(t1.TaxFreMisc + t2.ExtCost - ISNULL(t3.GrossAmtDue,0)) CalcBalance, t1.CurrencyID
			FROM #tmpApVendorActivityHeader t1 
				INNER JOIN #tmpApVendorActivityDtl t2 ON t1.VendorId = t2.VendorId AND t1.InvoiceNum = t2.InvoiceNum
				LEFT JOIN #tmpApCheckHist t3 ON t1.VendorId = t3.VendorId AND  t1.InvoiceNum = t3.InvoiceNum
		 ) #tmp
	GROUP BY #tmp. VendorId,  #tmp.VName, #tmp.CurrencyID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.14311.1561', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivityVSum_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 14311', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivityVSum_proc';

