

CREATE VIEW dbo.ALP_lkpArAlpCheckServiceStatus
AS
SELECT     dbo.ALP_tblArAlpSiteRecBill.SiteId, dbo.ALP_tblArAlpSiteRecBillServ.ServiceStartDate, dbo.ALP_tblArAlpSiteRecBillServ.Status
FROM         dbo.ALP_tblArAlpSiteRecBill INNER JOIN
                      dbo.ALP_tblArAlpSiteRecBillServ ON dbo.ALP_tblArAlpSiteRecBill.RecBillId = dbo.ALP_tblArAlpSiteRecBillServ.RecBillId
WHERE     (NOT (dbo.ALP_tblArAlpSiteRecBillServ.ServiceStartDate IS NULL)) AND ((dbo.ALP_tblArAlpSiteRecBillServ.Status = 'Active') OR
                      (dbo.ALP_tblArAlpSiteRecBillServ.Status = 'New'))