
CREATE PROCEDURE [dbo].[ALP_R_AR_ABF_R102C_CompletedJobs_NotClosed]
(
@Branch varchar(255),
@Department varchar(10)
)
AS
SET NOCOUNT ON
BEGIN

SELECT Jm958.TicketId, 
Jm958.ProjectId, 
Jm958.CustId, 
Jm958.SiteId, 
Jm958.Site, 
Jm958.SiteName,
JM958.AlpFirstName,
Jm958.OrderDate,
CASE CsConnectYn WHEN 1 THEN 'Y' ELSE '' END AS CS, 
Jm958.RMRAdded, 
Jm958.WorkCode, 
Jm958.SysDesc, 
Jm958.JobPrice, 
Jm958.CommAmt, 
ASite.SalesRepId1, 
Jm958.CompleteDate, 
Jm958.TurnoverDate, 
Jm958.StartRecurDate, 
Jm958.CommPaidDate, 
CASE BilledYN WHEN 1 THEN 'Y' ELSE '' END AS Billed

FROM ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008(@Branch,@Department) AS Jm958
	INNER JOIN ALP_tblArAlpSite AS ASite 
		ON Jm958.SiteId = ASite.SiteId

GROUP BY 
Jm958.TicketId, 
Jm958.ProjectId, 
Jm958.CustId, 
Jm958.SiteId, 
Jm958.Site, 
Jm958.AlpFirstName,
JM958.SiteName,
Jm958.OrderDate,
CsConnectYn,
Jm958.RMRAdded, 
Jm958.WorkCode, 
Jm958.SysDesc, 
Jm958.JobPrice, 
Jm958.CommAmt, 
ASite.SalesRepId1, 
Jm958.CompleteDate, 
Jm958.TurnoverDate, 
Jm958.StartRecurDate, 
Jm958.CommPaidDate, 
BilledYN,
Jm958.Status

HAVING Jm958.Status='Completed'

ORDER BY 
ASite.SalesRepId1, 
Jm958.CompleteDate

END