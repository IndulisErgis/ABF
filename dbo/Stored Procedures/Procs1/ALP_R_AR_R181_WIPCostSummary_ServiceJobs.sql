





CREATE PROCEDURE [dbo].[ALP_R_AR_R181_WIPCostSummary_ServiceJobs]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

SELECT 
ABranch.Branch,
SvcTkt.TicketId, 
ASite.SiteName, 
SvcTkt.PartsOhPct,
IsNull(PartCostExt,0) AS PartCost, 
IsNull(LaborCostExt,0) AS LaborCost, 
IsNull(PartCostExt,0)*SvcTkt.PartsOhPct AS PartsOHCost, 
--Seperating 'other' cost into two fields - ERR - 9/10/15
--ISNULL(qry3.OtherCostExt,0) AS OtherCost,
ISNULL(qry3M.OtherCostExt,0) AS OtherMiscCost,
ISNULL(qry3P.OtherCostExt,0) AS OtherPartCost,
IsNull(PartCostExt,0)+ IsNull(LaborCostExt,0) AS TotalCost


FROM 
((((ALP_tblJmSvcTkt AS SvcTkt
	INNER JOIN ALP_tblArAlpSite AS ASite 
	ON SvcTkt.[SiteId] = ASite.[SiteId]) 
	INNER JOIN ALP_tblArAlpBranch AS ABranch
	ON SvcTkt.[BranchId] = ABranch.[BranchId]) 
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionPartsWIP_Q001(@EndDate) AS qry31
	ON SvcTkt.[TicketId] = qry31.[TicketId]) 
	INNER JOIN ufxALP_R_AR_Jm_Q004_OpenSvcJobsWIP(@EndDate) AS qry4 
	ON SvcTkt.[TicketId] = qry4.[TicketId]
	LEFT JOIN ufxALP_R_AR_Jm_Q007_TimeCardsWIP_Q006(@EndDate) AS qry76
	ON SvcTkt.[TicketId] = qry76.[TicketId]) 
	--Obtaining 'other' cost info from 2 joins instead of 1 - ERR - 9/10/15
	--LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsOtherWIP_Q001(@EndDate) AS qry3
	--ON SvcTkt.[TicketId] = qry3.[TicketId]
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsOtherMiscWIP_Q001(@EndDate) AS qry3M
	ON SvcTkt.[TicketId] = qry3M.[TicketId]
	LEFT JOIN ufxALP_R_AR_Jm_Q003_ActionsOtherPartsWIP_Q001(@EndDate) AS qry3P
	ON SvcTkt.[TicketId] = qry3P.[TicketId]

WHERE SvcTkt.CreateDate <= @EndDate

END