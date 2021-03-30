CREATE PROCEDURE [dbo].[ALP_stpSISiteRecJobUdfUpdate]
(
	@RecJobEntryUdfId INT,
	@RecJobEntryId INT = NULL,
	@UDFId INT = NULL,
	@Value VARCHAR(255) = NULL
)
AS
BEGIN
	UPDATE [srju]
	SET	[RecJobEntryId] = @RecJobEntryId,
		[UDFId] = @UDFId,
		[Value] = @Value	
	FROM [dbo].[ALP_tblArAlpSiteRecJobUdf] AS [srju]
	WHERE	[srju].[RecJobEntryUdfId] = @RecJobEntryUdfId
END