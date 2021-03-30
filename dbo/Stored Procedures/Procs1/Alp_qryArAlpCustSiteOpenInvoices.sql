CREATE PROCEDURE dbo.Alp_qryArAlpCustSiteOpenInvoices @Cust pCustId, @Site varchar(10)   
As  
SET NOCOUNT ON  
SELECT DISTINCT Alp_lkpArAlpOpenInvoiceTotals2.InvcDate, Alp_lkpArAlpOpenInvoiceTotals2.InvcNum, Round([TaxTotal]+[NonTaxTotal],2) AS Net,   
 Alp_lkpArAlpOpenInvoiceTotals2.Amount, Alp_lkpArAlpOpenInvoiceTotals2.Paid, Alp_lkpArAlpOpenInvoiceTotals2.InvcTotal  
FROM Alp_lkpArAlpOpenInvoiceTotals2 LEFT JOIN Alp_lkpArAlpHistTotals ON Alp_lkpArAlpOpenInvoiceTotals2.InvcNum = Alp_lkpArAlpHistTotals.InvcNum  
WHERE (((Alp_lkpArAlpOpenInvoiceTotals2.CustId)= @Cust) AND ((Alp_lkpArAlpHistTotals.AlpSiteID)=@Site))  
ORDER BY Alp_lkpArAlpOpenInvoiceTotals2.InvcDate DESC , Alp_lkpArAlpOpenInvoiceTotals2.InvcNum DESC;