
CREATE VIEW [dbo].[ALP_lkpArAlpSiteWorkBySystem]
AS
SELECT     SysId, SysDesc, SiteId, CustId
FROM         dbo.ALP_tblArAlpSiteSys