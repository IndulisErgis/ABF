CREATE  procedure dbo.ALP_lkpJmSvcTktSiteId_sp  
 (  
 @SiteID integer = 0  
 )  
AS  
-- EFI# 1723 MAH created prc to reduce extra SiteID rows returned to SvcTkt Form  
-- EFI# 1719 MAH added Market Type field 
-- MAH 04/22/14:  added default DivisionID if Market has not been set for the Site 
SELECT     dbo.ALP_tblArAlpSite.SiteId,  dbo.ALP_tblArAlpSite.SiteName + ' (' + CAST(dbo.ALP_tblArAlpSite.SiteId AS varchar(10))   
                      + ')' AS SiteNameId, dbo.ALP_tblArAlpSite.AlpFirstName,dbo.ALP_tblArAlpSite.Addr1, dbo.ALP_tblArAlpSite.Addr2, dbo.ALP_tblArAlpSite.City, COALESCE (dbo.ALP_tblArAlpSite.Addr1, '')   
                      + ' ' + COALESCE (dbo.ALP_tblArAlpSite.Addr2, '') + ' ' + COALESCE (dbo.ALP_tblArAlpSite.City, '') + ' ' + COALESCE (dbo.ALP_tblArAlpSite.Region, '')   
                      + ' ' + COALESCE (dbo.ALP_tblArAlpSite.PostalCode, '') AS Address, dbo.ALP_tblArAlpSite.Phone, dbo.ALP_tblArAlpSite.Status, dbo.ALP_tblArAlpSite.BranchId,   
                      dbo.ALP_tblArAlpSite.TaxLocId, dbo.ALP_tblArAlpSite.SalesRepId1, dbo.ALP_tblArAlpSite.Country, dbo.ALP_tblArAlpSite.PostalCode, dbo.ALP_tblArAlpSite.CreditHoldYn,   
                      dbo.ALP_tblArAlpSite.LeadSourceId,
                      --MAH 04/22/14 - added default divisionID if no Market has been selected for the Site:
                      --dbo.ALP_tblArAlpMarket.DivisionId
                      CASE WHEN dbo.ALP_tblArAlpMarket.DivisionId IS NULL THEN 1 ELSE dbo.ALP_tblArAlpMarket.DivisionId END AS DivisionId, 
                      dbo.ALP_tblArAlpSite.SiteMemo, dbo.ALP_tblArAlpSite.Taxable, dbo.ALP_tblArAlpMarket.MarketType  
FROM         dbo.ALP_tblArAlpSite LEFT OUTER JOIN  
                      dbo.ALP_tblArAlpMarket ON dbo.ALP_tblArAlpSite.MarketId = dbo.ALP_tblArAlpMarket.MarketId  
WHERE dbo.ALP_tblArAlpSite.SiteId = @SiteID  
ORDER BY dbo.ALP_tblArAlpSite.SiteName, dbo.ALP_tblArAlpSite.AlpFirstName