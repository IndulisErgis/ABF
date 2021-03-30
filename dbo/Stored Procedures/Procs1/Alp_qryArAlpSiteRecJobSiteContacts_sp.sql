CREATE Procedure [dbo].[Alp_qryArAlpSiteRecJobSiteContacts_sp]    
/* 02/26/2014 - Ravi - Change to pull all contacts not just primary contacts and 
Added additional columns( Firstname,Title,OtherePhone,otherext,primaryext)
*/    
 (    
  @SiteID int = null    
 )    
AS    
set nocount on    
SELECT siteid,[Alp_tblArAlpSiteContact].[Name],     
 [Alp_tblArAlpSiteContact].[PrimaryPhone],     
 [Alp_tblArAlpSiteContact].[PrimaryYN],    
 [Alp_tblArAlpSiteContact].FirstName ,
 [Alp_tblArAlpSiteContact].Title   ,
 [Alp_tblArAlpSiteContact].OtherPhone    ,
 [Alp_tblArAlpSiteContact].OtherExt     ,
 [Alp_tblArAlpSiteContact].PrimaryExt   ,
 [ALP_tblArAlpSiteContact].FirstName + ' ' +   [ALP_tblArAlpSiteContact].[Name] +
 -- Case added by NSK on 30 Apr 2014 to check null title values
 CASE WHEN Title is NULL THEN '' ELSE ' (' +  [ALP_tblArAlpSiteContact].Title  + ')' END as Contact  
       
FROM [Alp_tblArAlpSiteContact]  
WHERE 
--((([Alp_tblArAlpSiteContact].[PrimaryYN])= 1)      And 
 (([Alp_tblArAlpSiteContact].[SiteId])= @SiteID);     
return