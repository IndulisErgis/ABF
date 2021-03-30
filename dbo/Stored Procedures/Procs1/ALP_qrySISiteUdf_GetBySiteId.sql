CREATE PROCEDURE [dbo].[ALP_qrySISiteUdf_GetBySiteId]
(
	@SiteId INT
)
AS
BEGIN
	SELECT
	[u].[SiteId], [u].[UDFId], [u].[Value], [u].[ts]
	FROM [dbo].[ALP_tblArAlpSiteUdf_view] AS [u]
	WHERE [u].[SiteId] = @SiteId
END