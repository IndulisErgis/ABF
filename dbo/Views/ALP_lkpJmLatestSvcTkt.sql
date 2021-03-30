  
CREATE VIEW dbo.ALP_lkpJmLatestSvcTkt AS  
SELECT     TOP 1 ALP_tblJmSvcTkt.TicketId, ALP_tblJmSvcTkt.ProjectId, ALP_tblJmSvcTkt.SysId, ALP_tblArAlpSiteSys.AlarmId  
FROM         ALP_tblJmSvcTkt  --INNER JOIN --Inner join commented and changed to left outer join by NSK on 22 Aug 2016.If system is removed from site then to load data join is modified.
Left outer join
ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId   
and ALP_tbljmSvcTkt.TicketId=(Select max(TicketId) from ALP_tblJmSvcTkt)   
order by TicketId desc -- order by added by NSK on 2 Aug 2016.