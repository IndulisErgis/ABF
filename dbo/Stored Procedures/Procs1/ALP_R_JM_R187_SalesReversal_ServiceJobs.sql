






CREATE PROCEDURE [dbo].[ALP_R_JM_R187_SalesReversal_ServiceJobs]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

--converted from access query R187-Q036c-Q005 - 12/18/14 - ER

SELECT 
ABranch.Branch,
SvcTkt.TicketId, 
CASE WHEN LseYn=0 THEN [GlAcctSaleRev] ELSE [GlAcctLseRev] END AS RevAcct,
SvcTkt.ProjectId, 
ASite.SiteName,
qry52.JobPrice,
qry36.Billed, 
SvcTkt.CancelDate,
SvcTkt.CompleteDate, 
qry36.MinInvcDate

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
	INNER JOIN ufxALP_R_AR_Jm_Q036C_BillingsByJobMinDate(@EndDate) AS qry36
	ON SvcTkt.[TicketId] = qry36.[AlpJobNum]

WHERE
(((SvcTkt.ProjectId) Is Null 
Or (SvcTkt.ProjectId)='') 
AND ((qry36.Billed)>0) 
AND ((SvcTkt.CancelDate) Is Null 
Or (SvcTkt.CancelDate)>@EndDate) 
AND ((SvcTkt.CompleteDate) Is Null 
Or (SvcTkt.CompleteDate)>@EndDate));

END