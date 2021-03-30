
CREATE VIEW dbo.ALP_lkpJmSvcTktPreviousTech
AS
SELECT     TOP 100 PERCENT dbo.ALP_tblJmSvcTkt.SiteId, dbo.ALP_tblJmTech.Name, dbo.ALP_tblJmSvcTkt.CompleteDate
FROM         dbo.ALP_tblJmSvcTkt INNER JOIN
                      dbo.ALP_tblJmTech ON dbo.ALP_tblJmSvcTkt.LeadTechId = dbo.ALP_tblJmTech.TechId
WHERE     (NOT (dbo.ALP_tblJmSvcTkt.CompleteDate IS NULL))
ORDER BY dbo.ALP_tblJmSvcTkt.SiteId, dbo.ALP_tblJmSvcTkt.CompleteDate DESC