


CREATE PROCEDURE [dbo].[ALP_R_JM_R188_SalesReversal_Projects]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

--converted from access query R188-Q036c-Q005-Q004c-Q004f - 12/17/14 - ER

SELECT 
ABranch.Branch,
CASE WHEN LseYn=0 THEN [GlAcctSaleRev] ELSE [GlAcctLseRev] END AS RevAcct,
SvcTkt.TicketId,
SvcTkt.ProjectId, 
ASite.SiteName,
qry52.JobPrice,
qry36.Billed AS Billing,
SvcTkt.CancelDate,
qry4f.ProjCompDate AS ProjCompleteDate,
qry36.MinInvcDate


FROM 
	(ufxALP_R_AR_Jm_Q004f_ProjDatesMax(@EndDate) AS qry4f	
	INNER JOIN((((ALP_tblJmSvcTkt AS SvcTkt
	INNER JOIN ALP_tblArAlpSite AS ASite 
	ON SvcTkt.[SiteId] = ASite.[SiteId]) 
	INNER JOIN ALP_tblJmWorkCode AS WCode
	ON SvcTkt.[WorkCodeId] = WCode.[WorkCodeId]) 
	INNER JOIN ALP_tblArAlpBranch AS ABranch
	ON SvcTkt.[BranchId] = ABranch.[BranchId]) 
	INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS qry52
	ON SvcTkt.[TicketId] = qry52.[TicketId]) 
	ON qry4f.[ProjectId] = SvcTkt.[ProjectId])
	INNER JOIN ufxALP_R_AR_Jm_Q036C_BillingsByJobMinDate(@EndDate) AS qry36
	ON SvcTkt.[TicketId] = qry36.[AlpJobNum]
		
WHERE
(((qry36.Billed)<>0))

END