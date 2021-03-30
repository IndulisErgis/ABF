
CREATE PROCEDURE [dbo].[trav_ApVendorActivitySummary_proc]
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',    --Base currency WHEN @PrintAllInBase = 1
@Sort integer = 1
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpApVendorActivityHeader
	(
		VendorId pVendorId, 
		VName nvarchar(30), 
		InvoiceNum pInvoiceNum, 
		InvoiceDate datetime, 
		TransType smallint, 
		SalesTax pDecimal, 
		Freight pDecimal, 
		Misc pDecimal, 
		TaxFreMisc pDecimal, 
		CurrencyID pCurrency
	
	)

	CREATE TABLE #tmpApVendorActivityDtl
	(
		VendorId pVendorId,
		InvoiceNum pInvoiceNum, 
		ExtCost pDecimal, 
		CurrencyID pCurrency
		
	)

	CREATE TABLE #tmpApCheckHist
	(
		VendorId pVendorId,
		InvoiceNum pInvoiceNum, 
		GrossAmtDue pDecimal, 
		DiscAmt pDecimal, 
		NetPaidCalc pDecimal, 
		CurrencyID pCurrency
	)
	
	INSERT INTO #tmpApVendorActivityHeader
		SELECT v.VendorId, v.[Name], h.InvoiceNum, 	MIN(h.InvoiceDate), MIN(h.TransType),
			SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * (ISNULL(h.SalesTax, 0) + ISNULL(h.TaxAdjAmt, 0)) 
					 ELSE SIGN(TransType) * (ISNULL(h.SalesTaxFgn, 0) + ISNULL(h.TaxAdjAmtFgn, 0)) END) SalesTax,							
			SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * ISNULL(h.Freight,0) ELSE SIGN(TransType) * ISNULL(h.FreightFgn,0) END) Freight, 
			SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * ISNULL(h.Misc, 0) ELSE SIGN(TransType) * ISNULL(h.MiscFgn, 0) END) Misc, 			
			SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * (ISNULL(h.SalesTax, 0) + ISNULL(h.TaxAdjAmt,0) + ISNULL(h.Freight, 0) + ISNULL(h.Misc, 0)) 
					 ELSE SIGN(TransType) * (ISNULL(h.SalesTaxFgn, 0) + ISNULL(h.TaxAdjAmtFgn,0) + ISNULL(h.FreightFgn,0) + ISNULL(h.MiscFgn,0)) END) TaxFreMisc, 
			v.CurrencyID
		FROM (tblApVendor v  
			INNER JOIN tblApHistHeader h  ON v.VendorID = h.VendorId)
		WHERE h.InvoiceNum IN (SELECT t.InvoiceNum FROM #tmpVendorList t WHERE t.VendorId = h.VendorId AND h.PostRun = t.PostRun AND h.TransId = t.TransId) 
								AND ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)			
		GROUP BY v.VendorId, v.[Name],h.InvoiceNum, v.CurrencyID 


	INSERT INTO #tmpApVendorActivityDtl
		SELECT v.VendorId, h.InvoiceNum,  
			SUM(CASE WHEN @PrintAllInBase = 1 THEN SIGN(TransType) * ISNULL(d.ExtCost,0) ELSE SIGN(TransType) * ISNULL(d.ExtCostFgn,0) END) ExtCost, 
			v.CurrencyID
		FROM (tblApVendor v 
			INNER JOIN tblApHistHeader h  ON v.VendorID = h.VendorId) 
			LEFT JOIN tblApHistDetail d  ON h.PostRun = d.PostRun AND h.TransId = d.TransID AND h.InvoiceNum = d.InvoiceNum 
			INNER JOIN #tmpVendorList t ON t.VendorID = h.VendorId AND h.PostRun = t.PostRun  AND h.TransId = t.TransId 
				AND h.InvoiceNum = t.InvoiceNum AND d.EntryNum = t.EntryNum				
		WHERE ( @PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency )  AND ISNULL(d.EntryNum, 0) >= 0 
		GROUP BY v.VendorId, h.InvoiceNum, v.CurrencyID


	INSERT INTO #tmpApCheckHist
		SELECT c.VendorId, c.InvoiceNum, SUM(CASE WHEN @PrintAllInBase = 1 THEN ISNULL(GrossAmtDue, 0) ELSE ISNULL(GrossAmtDueFgn, 0) END) GrossAmtDue, 
			SUM(CASE WHEN @PrintAllInBase = 1 THEN ISNULL(DiscTaken,0) ELSE ISNULL(DiscTakenFgn,0) END) DiscTaken, 
			SUM(CASE WHEN @PrintAllInBase = 1 THEN ISNULL(NetPaidCalc,0) ELSE ISNULL(GrossAmtDueFgn,0)  - ISNULL(DiscTakenFgn,0) END) NetPaidCalc,  CurrencyID
		FROM tblApCheckHist c 
		INNER JOIN ( SELECT  VendorId,InvoiceNum,InvoiceDate FROM #tmpVendorList Group by VendorId,InvoiceNum,InvoiceDate) t 
		ON c.VendorID =t.VendorId AND c.InvoiceNum= t.InvoiceNum AND c.InvoiceDate =t.InvoiceDate
		--WHERE c.InvoiceNum IN (SELECT t.InvoiceNum FROM #tmpVendorList t WHERE c.VendorId = t.VendorId) 
				WHERE ( @PrintAllInBase = 1 OR c.CurrencyId = @ReportCurrency ) AND (c.PmtType <> 9)    
		GROUP BY c.VendorId, c.InvoiceNum, c.CurrencyID


	IF @Sort = 1
	BEGIN
		--Invoice Summary
		SELECT #tmp.VendorID, #tmp.VName, #tmp.InvoiceNum, #tmp.Invoiced, #tmp.InvoiceDate, #tmp.TransType,	#tmp.ExtCost, #tmp.SalesTax, #tmp.Freight, 
			#tmp.CalcGainLos, #tmp.Misc, #tmp.GrossAmtDue, #tmp.DiscAmt, #tmp.NetPaid,  #tmp.Balance, (#tmp.CalcBlc - #tmp.CalcGainLos)  AS CalcBalance
		FROM (
				SELECT t1.VendorID, t1.VName, t1.InvoiceNum, t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc Invoiced,
					t1.InvoiceDate, t1.TransType, t2.ExtCost, t1.SalesTax, t1.Freight,
					CASE WHEN (t1.CurrencyId = @ReportCurrency) THEN 0 ELSE
					CASE WHEN ISNULL(t3.GrossAmtDue,0) = 0 THEN 0 ELSE 
					ISNULL(t3.NetPaidcalc, 0) - (ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0)) END END AS CalcGainLos,			
					t1.Misc, ISNULL(t3.GrossAmtDue,0) GrossAmtDue, ISNULL(t3.DiscAmt,0) DiscAmt, 
					ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0) NetPaid, 
					(t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc - ISNULL(t3.GrossAmtDue,0)) Balance,
					((t2.ExtCost + t1.SalesTax + t1.Freight + t1.Misc) - ISNULL(t3.GrossAmtDue,0))  CalcBlc
				FROM #tmpApVendorActivityHeader t1 
					INNER JOIN #tmpApVendorActivityDtl t2 ON t1.VendorId = t2.VendorId AND t1.InvoiceNum = t2.InvoiceNum 
					LEFT JOIN #tmpApCheckHist t3 ON t1.VendorId = t3.VendorId AND t1.InvoiceNum = t3.InvoiceNum
			 ) #tmp
	END

	ELSE
	BEGIN 
		--Vendor summary 
		SELECT #tmp.VendorID, #tmp.VName, SUM(#tmp.Invoiced) Invoiced, SUM(#tmp.GrossAmtDue) GrossAmtDue, SUM(#tmp.DiscAmt) DiscAmt, 
			SUM(#tmp.NetPaid) NetPaid, SUM(#tmp.CalcGainLos) CalcGainLos, SUM(#tmp.CalcBalance - #tmp.CalcGainLos) CalcBalance, #tmp.CurrencyID 
		FROM (
				SELECT  t1.VendorID, t1.VName, (t1.TaxFreMisc + t2.ExtCost) Invoiced, ISNULL(t3.GrossAmtDue,0) GrossAmtDue,
					ISNULL(t3.DiscAmt,0) DiscAmt, ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0) NetPaid,  
					CASE WHEN (t1.CurrencyId = @ReportCurrency) THEN 0 ELSE
					CASE WHEN ISNULL(t3.GrossAmtDue,0)  = 0 THEN 0 ELSE
					ISNULL(t3.NetPaidcalc, 0) - (ISNULL(t3.GrossAmtDue,0) - ISNULL(t3.DiscAmt,0)) END END AS CalcGainLos,
					(t1.TaxFreMisc + t2.ExtCost - ISNULL(t3.GrossAmtDue,0)) CalcBalance, t1.CurrencyID
				FROM #tmpApVendorActivityHeader t1 
					INNER JOIN #tmpApVendorActivityDtl t2 ON t1.VendorId = t2.VendorId AND t1.InvoiceNum = t2.InvoiceNum 
					LEFT JOIN #tmpApCheckHist t3 ON t1.VendorId = t3.VendorId AND  t1.InvoiceNum = t3.InvoiceNum
			 ) #tmp
		GROUP BY #tmp.VendorId,  #tmp.VName, #tmp.CurrencyID		
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivitySummary_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorActivitySummary_proc';

