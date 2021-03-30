
CREATE VIEW [dbo].[ALP_lkpJmTimeCardTktNo]
AS
SELECT TOP 100 PERCENT dbo.ALP_tblJmSvcTkt.TicketId, dbo.ALP_tblJmSvcTkt.Status, dbo.ALP_tblJmSvcTkt.ProjectID,
		dbo.ALP_tblArAlpSite.SiteName, dbo.ALP_tblJmWorkCode.WorkCode
FROM dbo.ALP_tblJmSvcTkt 
	INNER JOIN dbo.ALP_tblArAlpSite ON dbo.ALP_tblJmSvcTkt.SiteId = dbo.ALP_tblArAlpSite.SiteId
	INNER JOIN dbo.ALP_tblJmWorkCode ON dbo.ALP_tblJmSvcTkt.WorkCodeId = dbo.ALP_tblJmWorkCode.WorkCodeId
ORDER BY dbo.ALP_tblJmSvcTkt.TicketId