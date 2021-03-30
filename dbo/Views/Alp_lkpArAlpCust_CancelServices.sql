CREATE VIEW dbo.Alp_lkpArAlpCust_CancelServices    
AS    
SELECT DISTINCT     
                       dbo.ALP_tblArCust_view .CustId,  CustName,  TermsCode,  DistCode, CurrencyId,     
                      AlpListServices,  AlpFirstName, dbo.Alp_tblArAlpSiteRecBill.SiteId, dbo.Alp_tblArAlpSiteRecBillServ.Status    
FROM         dbo.ALP_tblArCust_view  INNER JOIN    
                      dbo.Alp_tblArAlpSiteRecBill ON  dbo.ALP_tblArCust_view .CustId = dbo.Alp_tblArAlpSiteRecBill.CustId INNER JOIN    
                      dbo.Alp_tblArAlpSiteRecBillServ ON dbo.Alp_tblArAlpSiteRecBill.RecBillId = dbo.Alp_tblArAlpSiteRecBillServ.RecBillId    
WHERE     (dbo.Alp_tblArAlpSiteRecBillServ.Status = 'Active' and ALP_tblArCust_view.Status =0 )