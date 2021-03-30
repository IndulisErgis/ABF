CREATE PROCEDURE [dbo].[ALP_stpSISiteRecJobUdfDelete]
(
	@RecJobEntryUdfId INT
)
AS
BEGIN
	DELETE FROM [dbo].[ALP_tblArAlpSiteRecJobUdf]
	WHERE	[RecJobEntryUdfId] = @RecJobEntryUdfId
END