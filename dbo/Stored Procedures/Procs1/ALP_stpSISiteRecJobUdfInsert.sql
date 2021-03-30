CREATE PROCEDURE [dbo].[ALP_stpSISiteRecJobUdfInsert]
(
	@RecJobEntryUdfId INT OUTPUT,
	@RecJobEntryId INT = NULL,
	@UDFId INT = NULL,
	@Value VARCHAR(255) = NULL
)
AS
BEGIN
	INSERT INTO [dbo].[ALP_tblArAlpSiteRecJobUdf]
	([RecJobEntryId], [UDFId], [Value])
	VALUES
	(@RecJobEntryId, @UDFId, @Value)
	
	SET @RecJobEntryUdfId = @@IDENTITY
END