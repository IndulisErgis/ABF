CREATE PROCEDURE [dbo].[ALP_stpSISiteUdfInsert]
(
	@SiteId INT,
	@UDFId INT,
	@Value VARCHAR(255) = NULL
)
AS
BEGIN
	INSERT INTO [dbo].[ALP_tblArAlpSiteUdf]
	(SiteId, UDFId, Value)
	VALUES
	(@SiteId, @UDFId, @Value)
END