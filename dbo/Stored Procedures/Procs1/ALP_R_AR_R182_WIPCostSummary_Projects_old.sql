







CREATE PROCEDURE [dbo].[ALP_R_AR_R182_WIPCostSummary_Projects_old]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

SELECT
ABranch.Branch,
SvcTkt.ProjectId,
ASite.SiteName, 
ASite.SiteId,
SUM(IsNull(PartCostExt,0)) AS PartCost,
SUM(IsNull(LaborCostExt,0)) AS LaborCost,
SUM(IsNull(PartCostExt,0)*IsNull(SvcTkt.PartsOhPct,0)) AS PartsOHCost,
SUM(ISNULL(OtherCostExt,0)) AS OtherCost,
SUM(IsNull(PartCostExt,0)+ IsNull(LaborCostExt,0)+(IsNull(OtherCostExt,0)*IsNull(SvcTkt.PartsOhPct,0))+ISNULL(OtherCostExt,0))AS TotalCost


FROM 
(((((ALP_tblJmSvcTkt AS SvcTkt
	INNER JOIN ALP_tblArAlpSite AS ASite 
	ON SvcTkt.[SiteId] = ASite.[SiteId]) 
	INNER JOIN ALP_tblArAlpBranch AS ABranch
	ON SvcTkt.[BranchId] = ABranch.[BranchId]) 
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionPartsWIP_Q001(@EndDate) AS qry31 
	ON SvcTkt.[TicketId] = qry31.[TicketId]) 
	INNER JOIN ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP(@EndDate) AS qry4
	ON SvcTkt.[ProjectId] = qry4.[ProjectId]) 
	LEFT JOIN ufxALP_R_AR_Jm_Q007_TimeCardsWIP_Q006(@EndDate) AS qry76 
	ON SvcTkt.[TicketId] = qry76.[TicketId]) 
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsOtherWIP_Q001(@EndDate) AS qry3
	ON SvcTkt.[TicketId] = qry3.[TicketId]

--Added WHERE clause from JM_Q004_OpenProjJobsWIP here to correct closed tickets from appearing - 3/4/15 - ER	
--WHERE  (((SvcTkt.CompleteDate) Is Null) 
--	AND ((SvcTkt.CancelDate) Is Null 
--	Or (SvcTkt.CancelDate)>@EndDate)) 
--	OR (((SvcTkt.CompleteDate)>@EndDate) 
--	AND ((SvcTkt.CancelDate) Is Null))	

GROUP BY ABranch.Branch, SvcTkt.ProjectId, Asite.SiteId, ASite.SiteName

END