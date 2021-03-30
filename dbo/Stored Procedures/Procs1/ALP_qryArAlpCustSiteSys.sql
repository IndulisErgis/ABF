CREATE PROCEDURE dbo.[ALP_qryArAlpCustSiteSys]       
 @ID pCustID, @Site int      
As      
--Below script modified by ravi on 08.28.2015
--Added  Alp_tblArAlpSite.Status = 'Pending' in where condtion as per email by MAH sent on 08.28.2015
SET NOCOUNT ON      
SELECT Alp_tblArAlpSiteSys.CustId, Alp_tblArAlpSite.Status, Alp_tblArAlpSite.SiteId      
FROM Alp_tblArAlpSite INNER JOIN Alp_tblArAlpSiteSys ON Alp_tblArAlpSite.SiteId = Alp_tblArAlpSiteSys.SiteId      
WHERE Alp_tblArAlpSiteSys.CustId = @ID AND (Alp_tblArAlpSite.Status = 'Active' Or  Alp_tblArAlpSite.Status = 'Local'
Or  Alp_tblArAlpSite.Status = 'Pending')  
 AND Alp_tblArAlpSite.SiteId <>@Site