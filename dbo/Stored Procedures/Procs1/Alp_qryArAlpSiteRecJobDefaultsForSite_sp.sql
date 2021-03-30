CREATE Procedure Alp_qryArAlpSiteRecJobDefaultsForSite_sp  
/* 20qryDefaultsForSite */  
 (  
  @SiteID int = null  
 )  
As  
set nocount on  
SELECT Alp_tblArAlpSite.SiteId,   
 Alp_tblArAlpSite.Phone AS SitePhone,   
 Alp_tblArAlpSite.BranchId,   
 Alp_tblArAlpSite.Contact AS SiteContact,  
 Alp_tblArAlpSiteContact.ContactID,   
 Alp_tblArAlpSiteContact.Name,   
 Alp_tblArAlpSiteContact.PrimaryYN,   
 Alp_tblArAlpSiteContact.PrimaryPhone,   
 Alp_tblArAlpSite.SalesRepId1  
FROM Alp_tblArAlpSite LEFT JOIN Alp_tblArAlpSiteContact ON Alp_tblArAlpSite.SiteId = Alp_tblArAlpSiteContact.SiteId  
WHERE (Alp_tblArAlpSite.SiteId=@SiteID);  
return