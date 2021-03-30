CREATE VIEW [dbo].[ALP_tblArAlpSiteRecJobUdf_view]
AS
SELECT
	[RecJobEntryUdfId],
	[RecJobEntryId],
	[UDFId],
	[Value],
	[ts]
FROM [dbo].[ALP_tblArAlpSiteRecJobUdf]