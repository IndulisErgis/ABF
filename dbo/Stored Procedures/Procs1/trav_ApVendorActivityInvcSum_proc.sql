
CREATE PROCEDURE [dbo].[trav_ApVendorActivityInvcSum_proc]
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD'    --Base currency WHEN @PrintAllInBase = 1

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpApVendorActivityHeader
	(
		VendorId pVendorId, 
		VName varchar(30), 
		InvoiceNum pInvoiceNum, 
		InvoiceDate datetime, 
		TransType smallint, 
		SalesTax pDec, 
		Freight pDec, 
		Misc pDec, 
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
		SELECT v.VendorId, v.[Name], h.InvoiceNum, MIN(h.InvoiceDate), MIN(h.TransType),
			ISNULL(SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * (h.SalesTax + h.TaxAdjAmt) 
							ELSE SIGN(TransType) * (h.SalesTaxFgn + h.TaxAdjAmtFgn) END),0)  SalesTax,
			ISNULL(SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * h.Freight ELSE SIGN(TransType) * h.FreightFgn END),0) Freight, 
			ISNULL(SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * h.Misc ELSE SIGN(TransType) * h.MiscFgn END),0) Misc, v.CurrencyID
		FROM (tblApVendor v (NOLOCK) 
			INNER JOIN tblApHistHeader h (NOLOCK) ON v.VendorID = h.VendorId)
		    INNER JOIN #tmpVendorSumList t ON t.VendorID = h.VendorId 
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )
		GROUP BY v.VendorId, v.[Name], h.InvoiceNum, v.CurrencyID

	INSERT INTO #tmpApVendorActivityDtl
		SELECT v.VendorId, h.InvoiceNum, 
			ISNULL(SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * d.ExtCost ELSE SIGN(TransType) * d.ExtCostFgn END),0) ExtCost, v.CurrencyID
		FROM (tblApVendor v (NOLOCK) 
			INNER JOIN tblApHistHeader h (NOLOCK) ON v.VendorID = h.VendorId) 
			LEFT JOIN tblApHistDetail d (NOLOCK) ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum 
		    INNER JOIN #tmpVendorSumList t ON t.VendorID = h.VendorId 
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )  AND ISNULL(d.EntryNum, 0) >= 0 
		GROUP BY v.VendorId, h.InvoiceNum, v.CurrencyID

	INSERT INTO #tmpApCheckHist
		SELECT c.VendorId, c.InvoiceNum, SUM(CASE WHEN @PrintAllInBase = 1 THEN GrossAmtDue ELSE GrossAmtDueFgn END) GrossAmtDue, 
			SUM(CASE WHEN @PrintAllInBase = 1 THEN DiscTaken ELSE DiscTakenFgn END) DiscTaken, 
			SUM(CASE WHEN @PrintAllInBase = 1 THEN NetPaidCalc else GrossAmtDueFgn  - DiscTakenFgn end) NetPaidCalc,  CurrencyID
		FROM tblApCheckHist c (NOLOCK) 
			INNER JOIN #tmpVendorSumList t ON c.VendorId = t.VendorId --AND c.InvoiceNum= t.InvoiceNum
		WHERE ( @PrintAllInBase = 1 OR c.CurrencyId = @ReportCurrency ) AND (PmtType <> 9) 
		GROUP BY c.VendorId, c.InvoiceNum, c.CurrencyID		

	SELECT #tmp.VendorID, #tmp.VName, #tmp.InvoiceNum, #tmp.Invoiced, #tmp.InvoiceDate, #tmp.TransType,	#tmp.ExtCost, #tmp.SalesTax, #tmp.Freight, 
		#tmp.CalcGainLos, #tmp.Misc, #tmp.GrossAmtDue, #tmp.DiscAmt, #tmp.NetPaid,  #tmp.Balance, (#tmp.CalcBlc - #tmp.CalcGainLos)  AS CalcBalance
	FROM (
			SELECT t1.VendorID, t1.VName, t1.InvoiceNum, t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc Invoiced,
				t1.InvoiceDate, t1.TransType,t2.ExtCost, t1.SalesTax, t1.Freight,
				CASE WHEN ISNULL(t3.GrossAmtDue,0) = 0 THEN 0 ELSE 
				--then ((t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc) - ISNULL(t3.GrossAmtDue,0)) ELSE 0 END AS CalcGainLos, 
				CAST(ISNULL(t3.NetPaidcalc, 0) - (ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0)) AS float) END AS CalcGainLos,			
				t1.Misc, ISNULL(t3.GrossAmtDue,0) GrossAmtDue, ISNULL(t3.DiscAmt,0) DiscAmt, 
				ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0) NetPaid, 
				(t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc - ISNULL(t3.GrossAmtDue,0)) Balance,
				--((t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc) - ISNULL(t3.GrossAmtDue,0)) + (CASE WHEN ISNULL(t3.GrossAmtDue,0) <> 0 
				--THEN
				((t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc) - ISNULL(t3.GrossAmtDue,0))  CalcBlc
			FROM #tmpApVendorActivityHeader t1 
				INNER JOIN #tmpApVendorActivityDtl t2 ON t1.VendorId = t2.VendorId AND t1.InvoiceNum = t2.InvoiceNum
				LEFT JOIN #tmpApCheckHist t3 ON t1.VendorId = t3.VendorId AND t1.InvoiceNum = t3.InvoiceNum
		 ) #tmp

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.14311.1561', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivityInvcSum_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 14311', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivityInvcSum_proc';

