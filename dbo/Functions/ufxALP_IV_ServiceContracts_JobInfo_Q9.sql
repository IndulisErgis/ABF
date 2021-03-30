

CREATE FUNCTION [dbo].[ufxALP_IV_ServiceContracts_JobInfo_Q9]  
(   
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
SVT.TicketId AS Q9TicketId,  
ASite.SiteId AS Q9SiteId,
SVT.SysId AS Q9SysId, 
ST.SysType, -- AS Q9SysType,
SS.SysDesc, -- AS Q9SysDesc,    
SVT.Status AS Q9Status,   
CASE WHEN ASite.AlpFirstName IS NULL THEN ASite.SiteName
	ELSE ASite.SiteName + ', ' + ASite.AlpFirstName END AS Q9Site, --Q9Site,  
ISNULL(ASite.Addr1,'') + ' ' + ISNULL(ASite.Addr2,'') AS Q9Address, --Q9Address,   
--SVT.CustId,   
--SVT.LseYn,   
WC.WorkCode, -- AS Q9WorkCode,   
SVT.WorkDesc,   
BR.Branch, -- AS Q9Branch,   
DIV.Division, -- AS Q9Division,   
DPT.Dept, -- AS Q9Dept,
SVT.OrderDate,      
SVT.CompleteDate,   
SVT.CloseDate, 
ISNULL(Q52.JobPrice,0) as Q9JobPrice,   
ISNULL(Q8237.PartCost,0) as Q9PartCost,   
ISNULL(Q8237.OtherCost,0) as Q9OtherCost,   
ISNULL(Q8237.LaborCost,0) as Q9LaborCost,   
ISNULL(Q8237.CommCost,0) as Q9CommCost,   
ISNULL(Q8237.JobCost,0) as Q9JobCost,
ROUND(JobPrice-ISNULL(JobCost , 0) 
  + dbo.ufxPresentValue(RMRAdded-RmrExpense, .10, ContractMths),0) AS Q9JobPV,   
--SVT.BilledYN,   
JT.Tech as LeadTech,
ASite.SalesRepId1 as Rep,   
Q005B.Billed, -- as Q9Billed,   
ISNULL(Q005B.BilledTotal,0) as Q9BilledTotal,   
RES.ResolCode, -- as Q9ResolCode,
--mah 01/19/15 - added two new fields to separate PartsCost and Parts OH amt
ISNULL(Q8237.PartsNoOH,0) as Q9PartsNoOH,
ISNULL(Q8237.PartsOH,0) as Q9PartsOH,
--SVT.RecJobEntryId,
--SVT.RecSvcId,
--SVT.ContractId,
Q6.Q6LastVisitDate as LastVisitDate,
ISNULL(Q6.Q6ActHrs,0) as ActHrs
  
FROM ALP_tblJmSvcTkt AS SVT  
	INNER JOIN ALP_tblArAlpSiteSys_view AS SS   ON SVT.SysId = SS.SysId 
	INNER JOIN ALP_tblArAlpSysType AS ST ON SS.SysTypeId = ST.SysTypeId  
	INNER JOIN ALP_tblJmWorkCode AS WC ON SVT.WorkCodeId = WC.WorkCodeId 
	INNER JOIN ALP_tblArAlpDivision AS DIV ON SVT.DivId = DIV.DivisionId 
	INNER JOIN ALP_tblArAlpSite AS ASite   
		ON SVT.SiteId = ASite.SiteId   
	INNER JOIN ALP_tblArAlpBranch AS BR   
		ON SVT.BranchId = BR.BranchId   
	INNER JOIN ALP_tblArAlpDept AS DPT   
		ON SVT.DeptId = DPT.DeptId  
	LEFT OUTER JOIN ALP_tblJmTech JT ON SVT.LeadTechId = JT.TechId
	LEFT OUTER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS Q52  
		ON SVT.TicketId = Q52.TicketId   
	LEFT OUTER JOIN ufxALP_R_AR_Jm_Q008_JobCost_Q002_Q003_Q007() AS Q8237  
		ON SVT.TicketId = Q8237.TicketId   
	LEFT JOIN ufxALP_R_AR_Jm_Q005B_JobBillAmt() AS Q005B  
		ON SVT.TicketId = Q005B.AlpJobNum  
	LEFT JOIN ALP_tblJmResol AS RES   
		ON SVT.ResolId = RES.ResolID
	LEFT OUTER JOIN ufxALP_IV_ServiceContracts_TC_Q6() Q6
		ON SVT.TicketId = Q6.Q6TicketId 
     
WHERE   (SVT.Status <> 'Canceled' and SVT.Status <> 'Cancelled' and SVT.Status <> 'New')
		AND WC.WorkCode LIKE 'SC-%'
)