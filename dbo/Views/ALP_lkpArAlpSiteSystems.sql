
CREATE VIEW dbo.ALP_lkpArAlpSiteSystems
AS
SELECT     TOP 100 PERCENT dbo.ALP_tblArAlpSiteSys.SysId, dbo.ALP_tblArAlpSysType.SysType, dbo.ALP_tblArAlpSiteSys.SysDesc, 
                      dbo.ALP_tblArAlpSiteSys.InstallDate AS Installed, dbo.ALP_tblArAlpSiteSys.PulledDate AS Pulled, dbo.ALP_tblArAlpCentralStation.Central, dbo.ALP_tblArAlpSiteSys.AlarmId, 
                      dbo.ALP_tblArAlpSiteSys.CustId, dbo.ALP_tblArAlpSiteSys.ContractId, dbo.ALP_tblArAlpSiteSys.WarrPlanId, dbo.ALP_tblArAlpSiteSys.WarrTerm, 
                      dbo.ALP_tblArAlpSiteSys.WarrExpires, dbo.ALP_tblArAlpSiteSys.RepPlanId, dbo.ALP_tblArAlpSiteSys.LeaseYN,dbo.ALP_tblArAlpSiteSys.SiteId
FROM         dbo.ALP_tblArAlpSiteSys INNER JOIN
                      dbo.ALP_tblArAlpSysType ON dbo.ALP_tblArAlpSiteSys.SysTypeId = dbo.ALP_tblArAlpSysType.SysTypeId INNER JOIN
                      dbo.ALP_tblArAlpCentralStation ON dbo.ALP_tblArAlpSiteSys.CentralId = dbo.ALP_tblArAlpCentralStation.CentralId
ORDER BY dbo.ALP_tblArAlpSysType.SysType, dbo.ALP_tblArAlpSiteSys.SysDesc