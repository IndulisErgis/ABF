CREATE PROCEDURE [dbo].[ALP_stpSISiteRecJobDelete]
(
	@RecJobEntryId INT
)
AS
BEGIN
	DELETE FROM [dbo].[ALP_tblArAlpSiteRecJob]
	WHERE	[RecJobEntryId] = @RecJobEntryId
END