
CREATE VIEW [dbo].[ALP_lkpJmSvcTktSysPanel]  
AS  
SELECT     TOP 100 PERCENT ALP_tblArAlpSiteSysItem.SysId, ALP_tblArAlpSiteSysItem.ItemId, ALP_tblArAlpSiteSysItem.[Desc] AS Descr,
ALP_tblArAlpSiteSysItem.PanelYN ,ALP_tblArAlpSiteSys.InstallDate
FROM         dbo.ALP_tblArAlpSiteSysItem  
--Below join added by NSK on 28 Apr 2015
--start
INNER JOIN
ALP_tblArAlpSiteSys ON ALP_tblArAlpSiteSysItem.SysId = ALP_tblArAlpSiteSys.SysId
--end
WHERE     (PanelYN = 1) 
--below condition added by NSK on 28 Apr 2015 
and ALP_tblArAlpSiteSysItem.RemoveYN=0 and ALP_tblArAlpSiteSys.PulledDate is null