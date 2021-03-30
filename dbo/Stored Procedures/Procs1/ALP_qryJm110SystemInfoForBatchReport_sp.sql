
create Procedure [dbo].[ALP_qryJm110SystemInfoForBatchReport_sp]
/* 
	Created by NP.
	For batch Reports EFI# 1852
	RecordSource for System Info subform of Control Center */
	(
	@SysID int = null	
	)
As
	set nocount on
	SELECT SS.SysId, SS.SysDesc, 
		SS.CentralId, SS.InstallDate, SS.AlarmId, 
		SS.WarrExpires, cs.Central,DealerNum
	FROM ALP_tblArAlpSiteSys SS (NOLOCK) LEFT JOIN ALP_tblArAlpCentralStation CS (NOLOCK)
		ON SS.CentralId = CS.CentralId
	WHERE SS.Sysid = @Sysid
	ORDER BY SS.SysId
	return