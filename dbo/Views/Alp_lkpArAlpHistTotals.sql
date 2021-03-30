CREATE VIEW dbo.Alp_lkpArAlpHistTotals  
AS  
SELECT     CustId, AlpSiteID, InvcNum, TaxSubtotal AS TaxTotal, NonTaxSubtotal AS NonTaxTotal, SalesTax AS Tax, Freight, Misc  
FROM         dbo.ALP_tblArHistHeader_view   
WHERE     (TransType > 0)