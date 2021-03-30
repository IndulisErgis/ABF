
CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R402_Q401]
(
@LeadSourceType varchar(10),
@LeadSource varchar(10),
@Subdivision varchar(10)
)
AS
BEGIN
SET NOCOUNT ON

SELECT 
Q401.LeadSourceType 
,Q401.LeadSource
,Q401.Subdiv
,Q401.SiteId
,Q401.SiteName
,Q401.ServiceID
,1 AS SiteIdCount
,Q401.MoniYN



FROM ufxALP_R_AR_Site_Q401() AS Q401

WHERE 
(Q401.LeadSourceType=@LeadSourceType OR @LeadSourceType='<ALL>')
AND 
(Q401.LeadSource=@LeadSource OR @LeadSource='<ALL>')
AND 
(Q401.Subdiv=@Subdivision OR @Subdivision='<ALL>')

ORDER BY
Q401.LeadSourceType 
,Q401.LeadSource 
,Q401.Subdiv
,Q401.SiteId

END