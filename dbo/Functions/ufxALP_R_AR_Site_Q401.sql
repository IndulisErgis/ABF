CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_Q401]()
RETURNS TABLE
AS
RETURN
(
SELECT 
LST.LeadSourceType,
LS.LeadSource,
SUB.Subdiv,
ASite.SiteId,
ASite.SiteName,
ISNULL(RBS.Status,'UNKNOWN') as Status,
ServiceID

,CASE
	WHEN ServiceID='MONI' AND ([RBS].Status='Active' OR [RBS].Status='New')	
		THEN 1
		ELSE 0 END AS MoniYN
		
,CASE
	WHEN ServiceID='MONI' AND RBS.Status='Active' 
		THEN 1
		ELSE 0 END AS Active
,CASE
	WHEN ServiceID='MONI' AND RBS.Status='New' 
		THEN 1
		ELSE 0 END AS New
	
FROM ALP_tblArAlpSite AS ASite
INNER JOIN ALP_tblArAlpLeadSource AS LS
	ON ASite.LeadSourceId = LS.LeadSourceId 
INNER JOIN ALP_tblArAlpLeadSourceType AS LST
	ON LS.LeadSourceTypeID = LST.LeadSourceTypeId 
INNER JOIN ALP_tblArAlpSubdivision AS SUB 
	ON ASite.SubDivID = SUB.SubdivId
LEFT JOIN ALP_tblArAlpSiteRecBill_view AS RB 
ON ASite.SiteId = RB.SiteId 
LEFT JOIN ALP_tblArAlpSiteRecBillServ_view AS RBS 
ON RB.RecBillId = RBS.RecBillId

 
)