 CREATE PROCEDURE dbo.Alp_qryArAlpCustSiteRecBill    
 @ID pcustid, @Site int    
 --Below script modified by ravi on 08.28.2015
--Added  Alp_tblArAlpSite.Status = 'Pending' in where condtion as per email by MAH sent on 08.28.2015
As    
SET NOCOUNT ON    
SELECT Alp_tblArAlpSiteRecBill.CustId, Alp_tblArAlpSite.Status, Alp_tblArAlpSite.SiteId    
FROM Alp_tblArAlpSite INNER JOIN Alp_tblArAlpSiteRecBill ON Alp_tblArAlpSite.SiteId = Alp_tblArAlpSiteRecBill.SiteId    
WHERE Alp_tblArAlpSiteRecBill.CustId = @ID 
AND (Alp_tblArAlpSite.Status = 'Active' Or Alp_tblArAlpSite.Status = 'Local' Or  Alp_tblArAlpSite.Status = 'Pending') 
AND Alp_tblArAlpSite.SiteId <>@Site