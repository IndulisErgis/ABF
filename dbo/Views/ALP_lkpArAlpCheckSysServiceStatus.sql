
CREATE VIEW dbo.ALP_lkpArAlpCheckSysServiceStatus
AS
SELECT     dbo.ALP_tblArAlpSiteRecBillServ.Status, dbo.ALP_tblArAlpSiteRecBillServ.SysId
FROM         dbo.ALP_tblArAlpSiteRecBill INNER JOIN
                      dbo.ALP_tblArAlpSiteRecBillServ ON dbo.ALP_tblArAlpSiteRecBill.RecBillId = dbo.ALP_tblArAlpSiteRecBillServ.RecBillId
WHERE     (dbo.ALP_tblArAlpSiteRecBillServ.Status = 'New') OR
                      (dbo.ALP_tblArAlpSiteRecBillServ.Status = 'Active')