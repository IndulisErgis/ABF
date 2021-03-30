CREATE VIEW [dbo].[ALP_tblArAlpSiteContact_view]
AS
SELECT
	[ContactID],
	[SiteId],
	[Name],
	[PrimaryYN],
	[Title],
	[IntlPrefix],
	[PrimaryPhone],
	[PrimaryExt],
	[PrimaryType],
	[OtherPhone],
	[OtherExt],
	[OtherType],
	[Fax],
	[Email],
	[Comments],
	[FirstName],
	[CreateDate],
	[LastUpdateDate],
	[UploadDate],
	[ts],
	[ModifiedBy],
	[ModifiedDate]
FROM [dbo].[ALP_tblArAlpSiteContact]