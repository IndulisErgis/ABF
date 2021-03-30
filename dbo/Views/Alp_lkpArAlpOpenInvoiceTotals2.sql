CREATE VIEW dbo.Alp_lkpArAlpOpenInvoiceTotals2  
AS  
SELECT ALP_tblArOpenInvoice_view.CustId, Min(ALP_tblArOpenInvoice_view.TransDate) AS InvcDate,   
ALP_tblArOpenInvoice_view.InvcNum,   
Amount = Sum(CASE  
WHEN RecType > 0 THEN Amt  
ELSE 0  
END),  
Paid = Sum(CASE   
WHEN RecType < 0 THEN Amt * -1  
ELSE 0  
END),  
Sum(Sign(RecType) * Amt) As InvcTotal  
FROM ALP_tblArOpenInvoice_view   
GROUP BY ALP_tblArOpenInvoice_view.CustId, ALP_tblArOpenInvoice_view.InvcNum