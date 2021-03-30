CREATE VIEW [dbo].[ALP_lkpJmSvcTktProject]    
AS    
--View modified by NSK on 16 Mar 2015
--dbo.ALP_tblArAlpSiteSys table replaced by dbo.ALP_tblJmSvcTkt
SELECT  distinct   TOP (100) PERCENT dbo.ALP_tblJmSvcTktProject.ProjectId, dbo.ALP_tblJmSvcTktProject.[Desc],   
       dbo.ALP_tblJmSvcTktProject.SvcTktProjectId,     
                      dbo.ALP_tblJmSvcTktProject.SiteId, dbo.ALP_tblArAlpSite.SiteName, dbo.ALP_tblArAlpSite.Addr1,   
                      dbo.ALP_tblJmSvcTktProject.InitialOrderDate,     
                      dbo.ALP_tblJmSvcTkt.CustId, dbo.ALP_tblArCust_view.CustName, 0 AS Flag    
FROM         dbo.ALP_tblJmSvcTktProject INNER JOIN    
                      dbo.ALP_tblArAlpSite ON dbo.ALP_tblJmSvcTktProject.SiteId = dbo.ALP_tblArAlpSite.SiteId   
                      LEFT OUTER JOIN    
                      dbo.ALP_tblJmSvcTkt ON  ALP_tblJmSvcTkt.ProjectId=dbo.ALP_tblJmSvcTktProject.ProjectId                      
                      LEFT OUTER JOIN    
                      dbo.ALP_tblArCust_view ON dbo.ALP_tblJmSvcTkt.CustId = dbo.ALP_tblArCust_view.CustId  
ORDER BY dbo.ALP_tblJmSvcTktProject.ProjectId