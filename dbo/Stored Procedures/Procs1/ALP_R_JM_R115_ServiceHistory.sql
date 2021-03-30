

CREATE PROCEDURE [dbo].[ALP_R_JM_R115_ServiceHistory]
(
@Branch VARCHAR(255)='<ALL>',
@Department VARCHAR(255)='<ALL>',
@StartDate datetime,
@EndDate datetime,
@CustId VARCHAR(255)='<ALL>',
@SiteId VARCHAR(255)='<ALL>'
) 
AS
BEGIN
SET NOCOUNT ON
--converted from access qryJM-R115-Q009 - 4/2/2015 - ER

SELECT 
qry958.Branch, 
qry958.Dept, 
qry958.TicketId, 
qry958.OrderDate, 
qry958.Status, 
qry958.SiteId, 
qry958.Site, 
qry958.Address, 
qry958.CustId, 
CUST.CustName, 
qry958.SalesRepID, 
qry958.JobPrice, 
qry958.Tech, 
qry958.SysType, 
qry958.WorkCode, 
qry958.WorkDesc, 
RESOL.ResolutionCode, 
STI.ResDesc

FROM 
((ufxALP_R_AR_Jm_Q009_JobInfo_Q005_Q008(@Branch,@Department) AS qry958
LEFT JOIN ALP_tblJmSvcTktItem AS STI
ON qry958.TicketId = STI.TicketId) 
LEFT JOIN ALP_tblJmResolution AS RESOL
ON STI.ResolutionId = RESOL.ResolutionId) 
INNER JOIN ALP_tblArCust_view AS CUST
ON qry958.CustId = CUST.CustId

WHERE 
(@Branch='<ALL>' OR qry958.Branch=@Branch) 
AND (@Department='<ALL>' OR qry958.Dept=@Department) 
AND (qry958.OrderDate Between @StartDate And @EndDate) 
AND (@SiteId='<ALL>' OR CONVERT(VARCHAR(255),qry958.SiteId)=@SiteId)
AND (@CustId='<ALL>' OR qry958.CustId=@CustId)  
AND (qry958.ProjectId Is Null)


END