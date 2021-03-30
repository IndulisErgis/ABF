CREATE procedure  Alp_rptAlpEI_GetArTransHeader_BatchTotal_sp 
 (
		@PrintAllInBase bit = 1,  
		@BaseCurrencyId pCurrency = null 
 )
 as 
 begin
 
 
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
 FROM #temp1 l  
			INNER JOIN dbo.tblArTransHeader h on l.TransID2 = h.TransId  
			LEFT JOIN (SELECT i.TransID2  
			, SUM(p.PmtAmt - p.CalcGainLoss) PaymentTotal  
			, SUM(p.PmtAmtFgn) PaymentTotalFgn  
			FROM #temp1 i INNER JOIN dbo.tblArTransPmt p ON i.TransID2 = p.TransId  
			GROUP BY i.TransID2) pmt ON h.TransId = pmt.TransID2 
 GROUP BY CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END 
  
 End