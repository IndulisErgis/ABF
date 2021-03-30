





CREATE PROCEDURE [dbo].[ALP_R_JM_R185_SalesAccrual_ServiceJobs]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

--converted from access query R185-Q036b-Q005 - 12/15/14 - ER

SELECT 
ABranch.Branch,
SvcTkt.TicketId, 
CASE WHEN LseYn=0 THEN [GlAcctSaleRev] ELSE [GlAcctLseRev] END AS RevAcct,
SvcTkt.ProjectId, 
ASite.SiteName,
qry52.JobPrice,
qry36.Billed, 
Round([JobPrice]-[Billed],0) AS Unbilled, 
SvcTkt.CompleteDate, 
qry36.MaxInvcDate

FROM 
((((ALP_tblJmSvcTkt AS SvcTkt
	INNER JOIN ALP_tblArAlpSite AS ASite 
	ON SvcTkt.[SiteId] = ASite.[SiteId]) 
	INNER JOIN ALP_tblJmWorkCode AS WCode
	ON SvcTkt.[WorkCodeId] = WCode.[WorkCodeId]) 
	INNER JOIN ALP_tblArAlpBranch AS ABranch
	ON SvcTkt.[BranchId] = ABranch.[BranchId]) 
	INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS qry52
	ON SvcTkt.[TicketId] = qry52.[TicketId]) 
	INNER JOIN ufxALP_R_AR_Jm_Q036B_BillingsByJobMaxDate(@EndDate) AS qry36
	ON SvcTkt.[TicketId] = qry36.[AlpJobNum]

GROUP BY 
ABranch.Branch, 
CASE WHEN LseYn=0 THEN [GlAcctSaleRev] ELSE [GlAcctLseRev] END, 
SvcTkt.TicketId, 
SvcTkt.ProjectId, 
ASite.SiteName, 
qry52.JobPrice, 
qry36.Billed, 
Round([JobPrice]-[Billed],0), 
SvcTkt.CompleteDate, 
qry36.MaxInvcDate

HAVING 
(((SvcTkt.ProjectId) Is Null 
Or (SvcTkt.ProjectId)='') 
AND ((Round([JobPrice]-[Billed],0))<>0) 
AND ((SvcTkt.CompleteDate)<=@EndDate) 
AND ((qry36.MaxInvcDate)>@EndDate))


END