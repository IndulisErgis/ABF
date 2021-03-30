
CREATE VIEW [dbo].[ALP_lkpJmSvcTktTimeCard] AS 
--LatestStartDate column and group by added on 16 Apr 2015
SELECT Status, PrefDate,ALP_tblJmSvcTkt.TicketId,max(startDate) as LatestStartDate
FROM dbo.ALP_tblJmSvcTkt 
INNER JOIN dbo.ALP_tblJmTimeCard ON   
dbo.ALP_tblJmSvcTkt.TicketId = dbo.ALP_tblJmTimeCard.TicketId group by ALP_tblJmSvcTkt.TicketId,Status,PrefDate