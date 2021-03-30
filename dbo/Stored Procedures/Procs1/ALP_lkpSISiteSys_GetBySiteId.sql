CREATE PROCEDURE [dbo].[ALP_lkpSISiteSys_GetBySiteId]
(
	@SiteId INT
)
AS
BEGIN
	SELECT * 
	FROM [dbo].[ALP_lkpArAlpSiteSysId]
	WHERE	[SiteId] = @SiteId
	ORDER BY [SysType]
END