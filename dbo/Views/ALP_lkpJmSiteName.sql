
CREATE VIEW [dbo].[ALP_lkpJmSiteName]
AS
SELECT     TOP (100) PERCENT SiteName, SiteId, AlpFirstName, Addr1, Addr2
FROM         dbo.ALP_tblArAlpSite
ORDER BY SiteName