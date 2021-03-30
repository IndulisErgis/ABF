
CREATE PROCEDURE [dbo].[ALP_qrySISiteSysGetById]
(	
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@SysId int
)
AS
BEGIN
	SELECT
		[ss].[SysId],
		[ss].[CustId],
		[ss].[SiteId],
		[ss].[InstallDate],
		[ss].[ContractId],
		[ss].[SysTypeId],
		[ss].[SysDesc],
		[ss].[CentralId],
		[ss].[AlarmId],
		[ss].[WarrPlanId],
		[ss].[WarrTerm],
		[ss].[WarrExpires],
		[ss].[RepPlanId],
		[ss].[LeaseYN],
		[ss].[PulledDate],
		[ss].[CreateDate],
		[ss].[LastUpdateDate],
		[ss].[UploadDate],
		[ss].[ts],
		[ss].[ModifiedBy],
		[ss].[ModifiedDate]
	FROM [dbo].[ALP_tblArAlpSiteSys_view] AS [ss] 
	WHERE	[ss].[SysId] = @SysId
END