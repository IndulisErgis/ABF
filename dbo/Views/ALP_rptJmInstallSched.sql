
--
CREATE VIEW [dbo].[ALP_rptJmInstallSched]
AS
SELECT       ALP_tblJmTimeCard.StartDate, ALP_tblJmTech.Name, 
ALP_tblArAlpSite.SiteName, ALP_tblJmTimeCard.StartTime, ALP_tblJmTimeCard.EndTime, 
ALP_tblJmTimeCard.TicketId, ALP_tblJmSvcTkt.ProjectId, 
ALP_tblJmWorkCode.WorkCode, ALP_tblArAlpDept.Dept, dbo.ALP_tblArAlpSubdivision.Subdiv, 
ALP_tblArAlpSite.Block, ALP_tblArAlpSite.Status, dbo.ALP_tblJmTimeCode.TimeCode, 
ALP_tblJmSvcTkt.SalesRepId
FROM         dbo.ALP_tblArAlpDept 
INNER JOIN dbo.ALP_tblJmTech  
INNER JOIN dbo.ALP_tblJmTimeCard
ON ALP_tblJmTech.TechId = ALP_tblJmTimeCard.TechID 
ON ALP_tblArAlpDept.DeptId = ALP_tblJmTech.DeptId 
INNER JOIN dbo.ALP_tblJmTimeCode 
ON ALP_tblJmTimeCard.TimeCodeID = dbo.ALP_tblJmTimeCode.TimeCodeID 
LEFT OUTER JOIN dbo.ALP_tblJmWorkCode 
INNER JOIN dbo.ALP_tblJmSvcTkt
INNER JOIN dbo.ALP_tblArAlpSite
ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId 
ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId 
ON ALP_tblJmTimeCard.TicketId = ALP_tblJmSvcTkt.TicketId 
LEFT OUTER JOIN dbo.ALP_tblArAlpSubdivision 
ON ALP_tblArAlpSite.SubDivID = dbo.ALP_tblArAlpSubdivision.SubdivId

--