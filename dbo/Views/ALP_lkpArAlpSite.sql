
CREATE VIEW [dbo].[ALP_lkpArAlpSite]    
AS    
SELECT     dbo.ALP_tblArAlpSite.SiteId, dbo.ALP_tblArAlpSite.SiteName + ' (' + CAST(dbo.ALP_tblArAlpSite.SiteId AS varchar(10)) + ')' AS SiteNameId,     
                      dbo.ALP_tblArAlpSite.AlpFirstName, dbo.ALP_tblArAlpSite.Phone, dbo.ALP_tblArAlpSite.BranchId, dbo.ALP_tblArAlpBranch.Branch ,  
                      --added by NSk on 18 mar 2015  
                      --start  
                      SiteName= CASE   
        WHEN  dbo.ALP_tblArAlpSite.SiteName is null  
          and dbo.ALP_tblArAlpSite.AlpFirstName is not null  
         THEN dbo.ALP_tblArAlpSite.AlpFirstName   
        WHEN dbo.ALP_tblArAlpSite.SiteName is not null  
         and  dbo.ALP_tblArAlpSite.AlpFirstName is  null  
         THEN dbo.ALP_tblArAlpSite.SiteName   
        WHEN dbo.ALP_tblArAlpSite.SiteName is not null   
       and  dbo.ALP_tblArAlpSite.AlpFirstName is not null  
        THEN dbo.ALP_tblArAlpSite.SiteName + ',' +  dbo.ALP_tblArAlpSite.AlpFirstName   
        END    
                      --end 
        --below column added by NSK on 22 may 2015
        ,ALP_tblArAlpSite.SalesRepId1 
FROM         dbo.ALP_tblArAlpSite INNER JOIN    
                      dbo.ALP_tblArAlpBranch ON dbo.ALP_tblArAlpSite.BranchId = dbo.ALP_tblArAlpBranch.BranchId