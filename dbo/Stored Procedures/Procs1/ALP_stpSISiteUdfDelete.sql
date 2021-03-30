CREATE PROCEDURE [dbo].[ALP_stpSISiteUdfDelete]
(
	@SiteId INT,
	@UDFId INT
)
AS
BEGIN
	DELETE FROM [dbo].[ALP_tblArAlpSiteUdf]
	WHERE	[SiteId] = @SiteId
		AND	[UDFId] = @UDFId
END