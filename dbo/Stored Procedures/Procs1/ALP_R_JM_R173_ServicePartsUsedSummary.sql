


/****** Object:  StoredProcedure [dbo].[ALP_R_JM_R173_ServicePartsUsedSummary]    Script Date: 01/08/2013 19:08:59 ******/
CREATE PROCEDURE [dbo].[ALP_R_JM_R173_ServicePartsUsedSummary] 
(
@StartDate datetime ,
@EndDate datetime
) 
--converted from access qryJm-R173 - 4/1/15 - ER

AS
BEGIN
SET NOCOUNT ON;
SELECT 
TECH.Name, 
STI.ItemId, 
STI.[Desc], 
STI.WhseID,
STI.Uom,
SUM(STI.QtyRemoved) AS SumOfQtyRemoved,
SUM(STI.QtyAdded) AS SumOfQtyAdded

FROM 
(((ALP_tblJmSvcTkt AS ST
INNER JOIN ALP_tblJmSvcTktItem AS STI
ON ST.TicketId = STI.TicketId) 
INNER JOIN ALP_tblArAlpSite AS ASite
ON ST.SiteId = ASite.SiteId) 
INNER JOIN ALP_tblJmTech AS TECH 
ON ST.LeadTechId = TECH.TechId) 

WHERE
(((ST.ProjectId) Is Null Or (ST.ProjectId)='') 
AND ((ST.CloseDate) Between @StartDate And @EndDate)) 
OR (((ST.ProjectId) Is Null Or (ST.ProjectId)='') 
AND ((ST.CloseDate) Between @StartDate And @EndDate))
		
GROUP BY 
TECH.Name, 
STI.ItemId, 
STI.[Desc],
STI.WhseID,
STI.Uom

HAVING
(((Sum(STI.QtyAdded))>0)) OR (((Sum(STI.QtyRemoved))>0))

END