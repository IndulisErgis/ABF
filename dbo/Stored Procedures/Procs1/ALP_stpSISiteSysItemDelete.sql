CREATE PROCEDURE [dbo].[ALP_stpSISiteSysItemDelete]
(
	@SysItemId INT
)
AS
BEGIN
	DELETE FROM [dbo].[ALP_tblArAlpSiteSysItem]
	WHERE	[SysItemId] = @SysItemId
END