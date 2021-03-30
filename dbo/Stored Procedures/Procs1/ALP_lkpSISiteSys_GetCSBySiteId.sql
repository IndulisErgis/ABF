CREATE PROCEDURE [dbo].[ALP_lkpSISiteSys_GetCSBySiteId]
(
	@SiteId INT
)
AS
BEGIN
	SELECT * 
	FROM [dbo].[ALP_lkpArAlpSiteSysIdByCS]
	WHERE	[SiteId] = @SiteId
	ORDER BY [SysType]
END