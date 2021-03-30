CREATE VIEW [dbo].[ALP_tblArAlpSiteUdf_view]
AS
SELECT
	[SiteId],
	[UDFId],
	[Value],
	[ts]
FROM [dbo].[ALP_tblArAlpSiteUdf]