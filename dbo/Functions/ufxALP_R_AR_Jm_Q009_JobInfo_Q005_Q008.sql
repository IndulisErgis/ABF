


CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008]  
(   
@Branch VARCHAR(255),  
@Department VARCHAR(10)  
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
SVT.TicketId,   
SVT.ProjectId,   
SVT.OrderDate,   
SVT.CancelDate,   
SVT.Status,   
ASite.SiteId,  
--MAH 01/13/15:  fix Site Name captured
--ASite.SiteName + CASE ASite.AlpFirstName  
--    WHEN NULL THEN '' ELSE (', ' + ASite.AlpFirstName) END AS Site, 
CASE WHEN ASite.AlpFirstName IS NULL THEN ASite.SiteName
ELSE ASite.SiteName + ', ' + ASite.AlpFirstName END AS Site,  
ASite.SiteName,  
ASite.AlpFirstName,  
ISNULL(ASite.Addr1,'') + ' ' + ISNULL(ASite.Addr2,'') AS Address,   
SUB.[Desc], 
SUB.Subdiv ,
ISNULL(SUB.InactiveYN,0)AS InactiveYN,  
MKT.MarketType,   
SVT.CustId,   
SVT.SysId,   
ST.SysType,   
SS.SysDesc,   
SVT.LseYn,   
WC.WorkCode,   
SVT.WorkDesc,   
WC.NewWorkYN,   
SVT.CsConnectYn,   
BR.Branch,   
DIV.Division,   
DPT.Dept,   
SRep.SalesRepID,   
SRep.Name AS RepName,   
SVT.CompleteDate,   
SVT.CommAmt,   
SVT.CommPaidDate,   
SVT.RMRAdded,   
SVT.RmrExpense,   
SVT.DiscRatePct,   
SVT.ContractMths,   
SVT.CloseDate,   
Q52.JobPrice,   
Q8237.PartCost,   
Q8237.OtherCost,   
Q8237.LaborCost,   
Q8237.CommCost,   
Q8237.JobCost,
--mah corrected this calculation - correcting for null in Job Cost  
ROUND(JobPrice-ISNULL(JobCost , 0) 
  + dbo.ufxPresentValue(RMRAdded-RmrExpense, .10, ContractMths),0) AS JobPV,   
SVT.TurnoverDate,   
SVT.StartRecurDate,   
SVT.BilledYN,   
JT.Tech,   
--Added to filter out estimates for jobs added after original - 11/7/19 - ER
CASE WHEN SVT.OriginalEstimatesflg='1' THEN SVT.EstCostParts
ELSE '0' END AS EstCostParts,   
CASE WHEN SVT.OriginalEstimatesflg='1' THEN SVT.EstCostLabor
ELSE '0' END AS EstCostLabor,  
CASE WHEN SVT.OriginalEstimatesflg='1' THEN SVT.EstCostMisc
ELSE '0' END AS EstCostMisc,   
CASE WHEN SVT.OriginalEstimatesflg='1' THEN SVT.EstHrs
ELSE '0' END AS EstHrs,   
SVT.PartsOhPct,   
SVT.BaseInstPrice,   
Q005B.Billed,   
Q005B.BilledTotal,   
ASite.Block,   
RES.ResolCode,
LEAD.[Desc] AS Lead
--MAH 01/08/15 - added GL accts:
,WC.GLAcctSaleRev
,WC.GLAcctSaleCOS
,WC.GLAcctLseRev
,WC.GLAcctLseCOS
--mah 01/19/15 - added two new fields to separate PartsCost and Parts OH amt
,Q8237.PartsNoOH
,Q8237.PartsOH
  
FROM ALP_tblJmWorkCode AS WC   
 INNER JOIN ALP_tblArAlpSysType AS ST   
 INNER JOIN ALP_tblJmSvcTkt AS SVT  
 INNER JOIN ALP_tblArAlpSiteSys_view AS SS   
  ON SVT.SysId = SS.SysId   
  LEFT JOIN ALP_tblArSalesRep_view AS SRep   
  ON SVT.SalesRepId = SRep.SalesRepID   
  INNER JOIN ALP_tblArAlpSite AS ASite   
  ON SVT.SiteId = ASite.SiteId   
  INNER JOIN ALP_tblArAlpBranch AS BR   
  ON SVT.BranchId = BR.BranchId   
  INNER JOIN ALP_tblArAlpDept AS DPT   
  ON SVT.DeptId = DPT.DeptId  
  LEFT JOIN ALP_tblJmTech AS JT   
  ON SVT.LeadTechId = JT.TechId   
  LEFT JOIN ALP_tblArAlpSubdivision AS SUB   
  ON ASite.SubDivID = SUB.SubdivId   
  INNER JOIN ufxALP_R_AR_Jm_Q005_JobPrice_Q002() AS Q52  
   ON SVT.TicketId = Q52.TicketId   
   INNER JOIN ufxALP_R_AR_Jm_Q008_JobCost_Q002_Q003_Q007() AS Q8237  
   ON SVT.TicketId = Q8237.TicketId   
   ON ST.SysTypeId = SS.SysTypeId   
   ON WC.WorkCodeId = SVT.WorkCodeId   
   INNER JOIN ALP_tblArAlpDivision AS DIV   
   ON SVT.DivId = DIV.DivisionId   
   LEFT JOIN ALP_tblArAlpMarket AS MKT   
   ON ASite.MarketId = MKT.MarketId   
   LEFT JOIN ufxALP_R_AR_Jm_Q005B_JobBillAmt() AS Q005B  
   ON SVT.TicketId = Q005B.AlpJobNum  
   LEFT JOIN ALP_tblJmResol AS RES   
   ON SVT.ResolId = RES.ResolID 
	LEFT JOIN dbo.ALP_tblJmSvcTktProject AS PRJ
	ON SVT.ProjectId = PRJ.ProjectId    
	LEFT JOIN dbo.ALP_tblArAlpLeadSource AS LEAD
	ON PRJ.LeadSourceId = LEAD.LeadSourceID
     
WHERE   
(BR.Branch=@Branch OR @Branch='<ALL>')  
AND   
(DPT.Dept=@Department OR @Department='<ALL>')  
  
--ORDER BY tblJmSvcTkt.TicketId  
)