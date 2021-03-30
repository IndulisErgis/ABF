

CREATE FUNCTION [dbo].[ufxALP_R_JM_Q040_OpenJobsOldestDate]()
RETURNS TABLE
AS
RETURN
(

--converted from access qryJm-Q040-OpenJobsOldestDate - 3/25/15 - ER
SELECT ST.SiteId, 
[SiteName] + case when AlpFirstName is null then '' else ', ' + AlpFirstName end AS Site, 
ASite.Addr1 + ' ' + ASite.Addr2 AS Address, 
ST.Status, 
CASE ST.[Status] 
WHEN 'New' 
THEN Min(ST.OrderDate)
WHEN 'Targeted' 
THEN Min(ST.PrefDate)
ELSE Min(qry39.MaxSchDate)END AS OldestDate

FROM ALP_tblJmSvcTkt AS ST
INNER JOIN ALP_tblArAlpSite AS ASite
ON ST.SiteId = ASite.SiteId 
LEFT JOIN [ufxALP_R_JM_Q039_MaxTimeCardDate]() AS qry39 
ON ST.TicketId = qry39.TicketId

WHERE ST.Status<>'closed' AND ST.Status<>'canceled' AND ST.Status<>'completed'

GROUP BY ST.SiteId, 
([SiteName] + case when AlpFirstName is null then '' else ', ' + AlpFirstName end), 
(ASite.Addr1 + ' ' + ASite.Addr2), ST.Status

HAVING  (CASE ST.Status 
WHEN 'New' 
THEN Min(ST.OrderDate)
WHEN 'Targeted' 
THEN Min(ST.PrefDate)
ELSE Min(qry39.MaxSchDate)END) Is Not Null

)