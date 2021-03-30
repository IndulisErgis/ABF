

CREATE VIEW dbo.ALP_lkpArAlpCheckSystemStatus
AS
SELECT     dbo.ALP_tblArAlpSiteSys.SiteId, dbo.ALP_tblArAlpSiteSys.PulledDate
FROM         dbo.ALP_tblArAlpSiteSys INNER JOIN
                      dbo.ALP_tblArAlpSite ON dbo.ALP_tblArAlpSiteSys.SiteId = dbo.ALP_tblArAlpSite.SiteId
WHERE     (dbo.ALP_tblArAlpSiteSys.PulledDate IS NULL) AND (dbo.ALP_tblArAlpSiteSys.InstallDate IS NOT NULL)