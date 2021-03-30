
  
CREATE VIEW [dbo].[ALP_lkpJmSvcTktTicketNo]  
AS  
SELECT TOP 100 PERCENT dbo.ALP_tblJmSvcTkt.TicketId,   
    dbo.ALP_tblJmSvcTkt.Status,   
    CASE WHEN AlpFirstName IS NULL OR  
    AlpFirstName = '' THEN SiteName ELSE SiteName + ', ' + AlpFirstName  
     END AS Name, dbo.ALP_tblJmWorkCode.WorkCode,   
    dbo.ALP_tblJmSvcTkt.ProjectId, dbo.ALP_tblJmSvcTkt.SiteId ,
    --Added by NSK on 16 Apr 2014 
    ALP_tblArAlpSite.Addr1,ALP_tblArAlpSite.Addr2,ALP_tblArAlpSite.City
FROM dbo.ALP_tblJmWorkCode INNER JOIN  
    dbo.ALP_tblJmSvcTkt INNER JOIN  
    dbo.ALP_tblArAlpSite ON   
    dbo.ALP_tblJmSvcTkt.SiteId = dbo.ALP_tblArAlpSite.SiteId ON   
    dbo.ALP_tblJmWorkCode.WorkCodeId = dbo.ALP_tblJmSvcTkt.WorkCodeId  
ORDER BY dbo.ALP_tblJmSvcTkt.TicketId