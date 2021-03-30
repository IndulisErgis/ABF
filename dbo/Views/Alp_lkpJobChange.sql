CREATE View  [dbo].[Alp_lkpJobChange]  
as   
SELECT top 100 percent Alp_tblJmSvcTkt.TicketId, Alp_tblJmSvcTkt.[Status], tblArHistHeader.InvcNum, Alp_tblArAlpSite.SiteId, Alp_tblArAlpSite.SiteName,  
 Alp_tblArAlpSysType.SysType, Alp_tblArAlpSiteSys.SysDesc, tblArCust.CustId, tblArCust.CustName, Alp_tblArAlpCustContract.ContractNum,  
  Alp_tblArAlpContractForm.ContractForm, Alp_tblArAlpSiteSys.SysId, Alp_tblArAlpCustContract.ContractId, Alp_tblArAlpSiteSys.AlarmId  
  --The Project Id column added by ravi on 28 sep 2016
  ,Alp_tblJmSvcTkt.ProjectId
FROM ((((((Alp_tblJmSvcTkt INNER JOIN Alp_tblArAlpSite ON Alp_tblJmSvcTkt.SiteId = Alp_tblArAlpSite.SiteId)   
INNER JOIN Alp_tblArAlpSiteSys ON Alp_tblJmSvcTkt.SysId = Alp_tblArAlpSiteSys.SysId)  
 INNER JOIN tblArCust ON Alp_tblJmSvcTkt.CustId = tblArCust.CustId)  
 INNER JOIN Alp_tblArAlpCustContract ON Alp_tblJmSvcTkt.ContractId = Alp_tblArAlpCustContract.ContractId)   
INNER JOIN Alp_tblArAlpContractForm ON Alp_tblArAlpCustContract.ContractFormId = Alp_tblArAlpContractForm.ContractFormId)  
 INNER JOIN Alp_tblArAlpSysType ON Alp_tblArAlpSiteSys.SysTypeId = Alp_tblArAlpSysType.SysTypeId)   
LEFT JOIN tblArHistHeader ON Alp_tblJmSvcTkt.InvcNum = tblArHistHeader.InvcNum  
ORDER BY Alp_tblJmSvcTkt.TicketId