
CREATE VIEW dbo.ALP_lkpArAlpSiteSys AS
SELECT dbo.ALP_tblArAlpSiteSys.SysId,dbo.ALP_tblArAlpSiteSys.SysDesc,dbo.ALP_tblArAlpSiteSys.SiteId  FROM  dbo.ALP_tblArAlpSiteSys WHERE PulledDate Is Null