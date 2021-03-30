
CREATE VIEW dbo.ALP_lkpArAlpSiteDetails AS
SELECT SiteName,AlpFirstName, Addr1, Addr2,City,Region,PostalCode,LeadSourceId,Phone, BranchId,SiteId FROM  dbo.ALP_tblArAlpSite