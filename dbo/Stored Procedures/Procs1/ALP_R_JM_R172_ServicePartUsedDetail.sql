

/****** Object:  StoredProcedure [dbo].[ALP_R_JM_R172_ServicePartUsedDetail]    Script Date: 01/08/2013 19:08:59 ******/
CREATE PROCEDURE [dbo].[ALP_R_JM_R172_ServicePartUsedDetail] 
(
@StartDate datetime ,
@EndDate datetime
) 
--converted from access qryJm-R172-Q024 - 3/30/15 - ER

AS
BEGIN
SET NOCOUNT ON;
SELECT 
TECH.Name, 
ST.TicketId, 
Count(qry24.TechID) AS CountOfTechID, 
ASite.SiteName, 
STI.ItemId, 
STI.[Desc], 
STI.QtyAdded, 
STI.QtyRemoved

FROM 
(((ALP_tblJmSvcTkt AS ST
INNER JOIN ALP_tblJmSvcTktItem AS STI
ON ST.TicketId = STI.TicketId) 
INNER JOIN ALP_tblArAlpSite AS ASite
ON ST.SiteId = ASite.SiteId) 
INNER JOIN ALP_tblJmTech AS TECH 
ON ST.LeadTechId = TECH.TechId) 
INNER JOIN ufxJm_Q024_TechsOnJobs() AS qry24
ON ST.TicketId = qry24.TicketId

WHERE	
(((ST.CloseDate) Between @StartDate And @EndDate 
OR (ST.CloseDate) Between @StartDate And @EndDate))
		
GROUP BY 
TECH.Name, 
ST.TicketId, 
ASite.SiteName, 
STI.ItemId, 
STI.[Desc], 
STI.QtyAdded, 
STI.QtyRemoved, 
ST.ProjectId

HAVING
(((STI.QtyAdded)>0) 
AND ((ST.ProjectId) Is Null 
Or (ST.ProjectId)='')) 
OR (((STI.QtyRemoved)>0) 
AND ((ST.ProjectId) Is Null 
Or (ST.ProjectId)=''))

END