
 CREATE View dbo.ALP_ArOpenInvoiceSummary_view    
AS    
SELECT *  From (
 (SELECT  AlpSiteID , AlpCustID, AlpInvcNum   
 FROM   ALP_tblArOpenInvoice GROUP BY  AlpSiteID,AlpInvcNum, AlpCustID )AOI
  RIGHT OUTER JOIN trav_ArOpenInvoiceSummary_view OIV  ON OIV.CustomerId = AOI.AlpCustID  
 and OIV.InvoiceNumber = AOI.AlpInvcNum   )