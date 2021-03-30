




CREATE PROCEDURE [dbo].[ALP_R_JM_R170C_ServiceSalesMargins_byWork] 
(
@StartDate dateTime,
@EndDate dateTime,
@Branch VARCHAR(255),  
@Department VARCHAR(10),
@WorkCode VARCHAR(25)
)
AS
BEGIN
SET NOCOUNT ON
--Procedure converted from access query 'qryJm-R170C' 01/08/15 - ER

SELECT 
qry958.WorkCode, 
qry958.TicketId, 
qry958.OrderDate, 
qry958.SiteId, 
qry958.Site, 
qry958.CustId, 
qry958.Tech, 
qry958.SysDesc, 
qry958.Branch, 
qry958.Dept, 
ISNULL(JobPrice, 0) AS Price,
qry958.JobPv, 
qry958.WorkDesc, 
ISNULL(Billed, 0) AS TotBilled, 
qry958.PartCost, 
qry958.OtherCost, 
qry958.LaborCost, 
ISNULL(JobCost, PartCost+LaborCost+OtherCost) AS JobCost

FROM 
dbo.ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008(@Branch,@Department) AS qry958

WHERE
(((qry958.CompleteDate) Between @StartDate And @EndDate) AND ((qry958.ProjectId) Is Null))
AND
((@WorkCode = '<ALL>' OR qry958.WorkCode = @WorkCode) 
AND (@Branch = '<ALL>' OR qry958.Branch = @Branch) 
AND (@Department = '<ALL>' OR qry958.Dept = @Department))

ORDER BY 
qry958.WorkCode, 
qry958.TicketId, 
qry958.OrderDate, 
qry958.SiteId, 
qry958.Site, 
qry958.CustId, 
qry958.Tech, 
qry958.SysDesc, 
qry958.Branch, 
qry958.Dept, 
ISNULL(JobPrice,0),
qry958.JobPv, 
ISNULL(Billed,0), 
qry958.PartCost, 
qry958.OtherCost, 
qry958.LaborCost, 
qry958.JobCost

END