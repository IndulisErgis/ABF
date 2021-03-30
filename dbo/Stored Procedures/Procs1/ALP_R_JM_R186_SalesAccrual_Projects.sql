






CREATE PROCEDURE [dbo].[ALP_R_JM_R186_SalesAccrual_Projects]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

--converted from access query R186-Q036b-Q005-Q010b - 12/17/14 - ER

SELECT 
ABranch.Branch,
CASE WHEN LseYn=0 THEN [GlAcctSaleRev] ELSE [GlAcctLseRev] END AS RevAcct,
SvcTkt.ProjectId, 
ASite.SiteName,
Sum(qry52.JobPrice) AS ProjPrice,
SUM(qry36.Billed) AS BillAmt, 
SUM(Round([JobPrice]-[Billed],0)) AS Unbilled, 
qry36.MaxInvcDate AS InvcDate,
qry104.ProjCompleteDate

FROM 
	(ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c(@EndDate) AS qry104 	
	INNER JOIN((((ALP_tblJmSvcTkt AS SvcTkt
	INNER JOIN ALP_tblArAlpSite AS ASite 
	ON SvcTkt.[SiteId] = ASite.[SiteId]) 
	INNER JOIN ALP_tblJmWorkCode AS WCode
	ON SvcTkt.[WorkCodeId] = WCode.[WorkCodeId]) 
	INNER JOIN ALP_tblArAlpBranch AS ABranch
	ON SvcTkt.[BranchId] = ABranch.[BranchId]) 
	INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS qry52
	ON SvcTkt.[TicketId] = qry52.[TicketId]) 
	ON qry104.[ProjectId] = SvcTkt.[ProjectId])
	INNER JOIN ufxALP_R_AR_Jm_Q036B_BillingsByJobMaxDate(@EndDate) AS qry36
	ON SvcTkt.[TicketId] = qry36.[AlpJobNum]
	
	
GROUP BY 
ABranch.Branch, 
CASE WHEN LseYn=0 THEN [GlAcctSaleRev] ELSE [GlAcctLseRev] END, 
SvcTkt.ProjectId, 
ASite.SiteName, 
qry104.ProjCompleteDate,
qry52.JobPrice, 
qry36.MaxInvcDate

HAVING 
SUM(Round([JobPrice]-[Billed],0))<>0
AND  ((qry104.ProjCompleteDate)<=@EndDate) 

END