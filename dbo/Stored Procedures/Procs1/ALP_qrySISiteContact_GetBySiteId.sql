CREATE PROCEDURE [dbo].[ALP_qrySISiteContact_GetBySiteId]
(
	@SiteId INT
)
AS
BEGIN
	SELECT
		[c].[ContactID], [c].[SiteId], [c].[Name], [c].[PrimaryYN], [c].[Title], [c].[IntlPrefix], [c].[PrimaryPhone], [c].[PrimaryExt], [c].[PrimaryType], [c].[OtherPhone], [c].[OtherExt], [c].[OtherType], [c].[Fax], [c].[Email], [c].[Comments], [c].[FirstName], [c].[CreateDate], [c].[LastUpdateDate], [c].[UploadDate], [c].[ts], [c].[ModifiedBy], [c].[ModifiedDate]
	FROM [dbo].[ALP_tblArAlpSiteContact_view] AS [c]
	WHERE	[c].[SiteId] = @SiteId
	ORDER BY
		[c].[PrimaryYN] DESC,
		[c].[Name] ASC,
		[c].[FirstName] ASC
END