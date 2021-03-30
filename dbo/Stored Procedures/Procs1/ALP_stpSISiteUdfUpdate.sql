CREATE PROCEDURE [dbo].[ALP_stpSISiteUdfUpdate]
(
	@SiteId INT,
	@UDFId INT,
	@Value VARCHAR(255) = NULL
)
AS
BEGIN
	UPDATE [su]
	SET	[Value] = @Value
	FROM [dbo].[ALP_tblArAlpSiteUdf] AS [su]
	WHERE	[su].[SiteId] = @SiteId
		AND	[su].[UDFId] = @UDFId
END