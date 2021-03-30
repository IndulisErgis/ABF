CREATE VIEW dbo.Alp_lkpArAlpCheckServiceProcessed  
AS  
SELECT     dbo.ALP_tblArAlpSiteRecBillServ .Processed, dbo.Alp_tblArAlpSite.SiteId  
FROM         dbo.ALP_tblArAlpSiteRecBill INNER JOIN  
                      dbo.Alp_tblArAlpSiteRecBillServ ON dbo.ALP_tblArAlpSiteRecBill.RecBillId = dbo.Alp_tblArAlpSiteRecBillServ.RecBillId INNER JOIN  
                      dbo.Alp_tblArAlpSite ON dbo.ALP_tblArAlpSiteRecBill.SiteId = dbo.ALP_tblArAlpSite .SiteId