CREATE VIEW dbo.ALP_lkpJmSvcTktSysId AS   
SELECT dbo.ALP_tblArAlpSiteSys.custid,dbo.ALP_tblArAlpSiteSys.SysId, dbo.ALP_tblArAlpSiteSys.SiteId, dbo.ALP_tblArAlpSysType.SysType,  
 dbo.ALP_tblArAlpSiteSys.SysDesc, dbo.ALP_tblArAlpSiteSys.PulledDate, dbo.ALP_tblArAlpSiteSys.RepPlanId,  
 dbo.ALP_tblArAlpSiteSys.WarrExpires, dbo.ALP_tblArAlpSysType.ServPriceId, dbo.ALP_tblArAlpSiteSys.LeaseYN,   
 dbo.ALP_tblArAlpSiteSys.WarrPlanId, dbo.ALP_tblArAlpSiteSys.AlarmId, dbo.ALP_tblArAlpSiteSys.ContractId,  
 dbo.ALP_tblArAlpSysType.InstPriceId,  
 Convert(varchar,dbo.ALP_tblArAlpSiteSys.SysId) + '-' + dbo.ALP_tblArAlpSiteSys.SysDesc as SysIdDesc  
 FROM dbo.ALP_tblArAlpSysType INNER JOIN dbo.ALP_tblArAlpSiteSys ON dbo.ALP_tblArAlpSysType.SysTypeId = dbo.ALP_tblArAlpSiteSys.SysTypeId