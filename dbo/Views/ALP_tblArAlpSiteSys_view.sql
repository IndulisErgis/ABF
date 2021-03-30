CREATE VIEW [dbo].[ALP_tblArAlpSiteSys_view]
AS
SELECT
	[SysId],
	[CustId],
	[SiteId],
	[InstallDate],
	[ContractId],
	[SysTypeId],
	[SysDesc],
	[CentralId],
	[AlarmId],
	[WarrPlanId],
	[WarrTerm],
	[WarrExpires],
	[RepPlanId],
	[LeaseYN],
	[PulledDate],
	[CreateDate],
	[LastUpdateDate],
	[UploadDate],
	[ts],
	[ModifiedBy],
	[ModifiedDate]
FROM [dbo].[ALP_tblArAlpSiteSys]