


CREATE PROCEDURE [dbo].[ALP_R_JM_R105_JobsByBranch] 
( 
	@StartDate Datetime,
 @EndDate Datetime,
 @Branch VARCHAR(255)='<ALL>',
 @Department VARCHAR(255)='<ALL>'
)
--converted from access query qryJm-R105-Q009 - 03/10/15 - ER
AS
SELECT Q958.TicketId, 
Q958.ProjectId, 
Q958.OrderDate, 
Q958.Status, 
Q958.SiteId, 
Q958.Site, 
Q958.Address, 
Q958.CustId, 
Q958.SysType, 
Q958.SysDesc, 
Q958.LseYn, 
Q958.WorkCode, 
Q958.WorkDesc, 
Q958.NewWorkYN, 
Q958.CsConnectYn, 
Q958.Branch, 
Q958.Division,
 Q958.Dept, 
 Q958.SalesRepID, 
 Q958.RepName, 
 Q958.CommAmt, 
 Q958.RMRAdded, 
 Q958.CompleteDate, 
 Q958.CloseDate, 
 Q958.JobPrice
FROM ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008(@Branch,@Department) as Q958
WHERE Q958.OrderDate Between @StartDate And @EndDate