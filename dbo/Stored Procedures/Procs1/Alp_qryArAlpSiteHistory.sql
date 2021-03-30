CREATE PROCEDURE dbo.Alp_qryArAlpSiteHistory @Cust varchar(10), @Site varchar(10)  
As  
SET NOCOUNT ON  
SELECT ALP_tblArOpenInvoice_view.AlpSiteID, ALP_tblArOpenInvoice_view.InvcNum, Min(ALP_tblArOpenInvoice_view.TransDate) AS FirstOfTransDate,   
Amount = Sum(CASE   
 WHEN RecType > 0  THEN Amt  
 ELSE 0  
END),   
Pay = Sum(CASE   
 WHEN RecType < 0  THEN Amt  
 ELSE 0  
END),   
Balance = Sum(CASE  
 WHEN RecType > 0 THEN Amt  
 ELSE Amt * -1  
END),  
 ALP_tblArOpenInvoice_view.Status  
FROM ALP_tblArOpenInvoice_view  
WHERE (((ALP_tblArOpenInvoice_view.CustId)=@Cust))  
GROUP BY ALP_tblArOpenInvoice_view.AlpSiteID, ALP_tblArOpenInvoice_view.InvcNum, ALP_tblArOpenInvoice_view.Status  
HAVING (((ALP_tblArOpenInvoice_view.AlpSiteID)=@Site) AND ((ALP_tblArOpenInvoice_view.Status)<>4))  
ORDER BY ALP_tblArOpenInvoice_view.InvcNum, Min(ALP_tblArOpenInvoice_view.TransDate);